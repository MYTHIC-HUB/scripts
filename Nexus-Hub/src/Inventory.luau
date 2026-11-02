-- Cosmetic Changer page attached only to the native MM2 inventory structures.
-- Sources: MM2 v1456 Inventory.lua, Inventory2.lua and InventoryPhone.lua.
-- No native item ownership, equip RPC, or trade data is changed by this page.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Inventory = {}
Inventory.__index = Inventory

local COLORS = {
    background = Color3.fromRGB(25, 23, 24), card = Color3.fromRGB(46, 42, 43),
    text = Color3.fromRGB(245, 241, 242), muted = Color3.fromRGB(173, 163, 166),
    accent = Color3.fromRGB(239, 51, 64), fx = Color3.fromRGB(225, 171, 43), evo = Color3.fromRGB(55, 178, 132),
}
local function child(parent, name) return parent and parent:FindFirstChild(name) end
local function gui(object) return object and object:IsA("GuiObject") end
local function disconnect(connections)
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
end
local function make(className, properties, parent)
    local object = Instance.new(className)
    for key, value in pairs(properties) do object[key] = value end
    object.Parent = parent
    return object
end
local function label(parent, text, size, position, fontSize, color)
    return make("TextLabel", { Text = text, Size = size, Position = position, BackgroundTransparency = 1,
        TextColor3 = color or COLORS.text, TextSize = fontSize or 13, Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd }, parent)
end
local function button(parent, text, size, position)
    return make("TextButton", { Text = text, Size = size, Position = position, BackgroundColor3 = COLORS.card,
        BorderSizePixel = 0, TextColor3 = COLORS.text, TextSize = 13, Font = Enum.Font.GothamBold,
        AutoButtonColor = true }, parent)
end
local function remember(mount, object, property, value)
    local properties = mount.saved[object]
    if not properties then properties = {} mount.saved[object] = properties end
    if not properties[property] then properties[property] = { original = object[property] } end
    object[property] = value
    properties[property].applied = value
end
local function restore(saved)
    for object, properties in pairs(saved) do
        if object.Parent then
            for property, state in pairs(properties) do
                if object[property] == state.applied then object[property] = state.original end
            end
        end
    end
end

function Inventory.describe(inventory, phone)
    if not gui(inventory) then return nil end
    local main, nav = child(inventory, "Main"), child(inventory, "Nav")
    local weapons = child(main, "Weapons")
    local navigation = child(nav, "Main") or nav
    local weaponButton = child(navigation, "Weapons")
    if not gui(main) or not gui(nav) or not gui(weapons) or not gui(child(weapons, "Items"))
        or not gui(child(weapons, "Equipped")) or not weaponButton or not weaponButton:IsA("GuiButton") then return nil end
    return { inventory = inventory, main = main, nav = nav, navigation = navigation,
        weapons = weapons, weaponButton = weaponButton, phone = phone == true }
end

function Inventory.layouts(playerGui)
    local layouts = {}
    if not playerGui then return layouts end
    for _, screen in ipairs(playerGui:GetChildren()) do
        if screen:IsA("ScreenGui") then
            local gameGui = child(screen, "Game")
            for _, name in ipairs({ "Inventory2", "Inventory" }) do
                local layout = Inventory.describe(child(gameGui, name), false)
                if layout then table.insert(layouts, layout) end
            end
            local screens = child(child(screen, "Lobby"), "Screens")
            local layout = Inventory.describe(child(screens, "Inventory"), true)
            if layout then table.insert(layouts, layout) end
        end
    end
    return layouts
end

function Inventory.new(context, assets)
    local self = setmetatable({ context = context, assets = assets, alive = true, mounts = {}, failed = {}, connections = {}, elapsed = 0 }, Inventory)
    self.player = Players.LocalPlayer
    table.insert(self.connections, RunService.Heartbeat:Connect(function(delta)
        if not self.alive then return end
        self.elapsed += delta
        if self.elapsed < 0.4 then return end
        self.elapsed = 0
        self:_tick()
    end))
    self:_tick()
    return self
end
function Inventory:_get(id, fallback)
    local value = self.context.get and self.context.get(id)
    if value == nil then value = self.context.settings[id] end
    return value == nil and fallback or value
end
function Inventory:_notify(message)
    if self.alive and self.context.notify then self.context.notify(message) end
end
function Inventory:_choose(id)
    if not self.alive then return false end
    local call = self.context.action
    local ok, accepted, problem = pcall(function()
        if call then return call("skins.catalog", { id = id }) end
        return self.assets:Action("skins.catalog", { id = id })
    end)
    if ok and accepted then
        ok, accepted, problem = pcall(function()
            if self.context.set then return self.context.set("skins.enabled", true) end
            return self.assets:Set("skins.enabled", true)
        end)
    end
    if not ok or not accepted then self:_notify(ok and (problem or "Modelo visual indisponivel.") or tostring(accepted)) return false end
    for _, mount in pairs(self.mounts) do mount.selection = nil end
    return true
end

function Inventory:_preview(parent, entry)
    if entry.thumbnail then
        return make("ImageLabel", { Name = "Preview", Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1, Image = entry.thumbnail, ScaleType = Enum.ScaleType.Fit, ZIndex = parent.ZIndex + 1 }, parent)
    end
    local modelEntry = self.assets:_model(entry.id, entry.kind)
    if not self.alive or not parent.Parent or not modelEntry then return nil end
    local viewport = make("ViewportFrame", { Name = "Preview", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        Ambient = Color3.fromRGB(180, 180, 180), LightColor = Color3.fromRGB(255, 255, 255), ZIndex = parent.ZIndex + 1 }, parent)
    local model = make("Model", { Name = "NexusPreview" }, viewport)
    local parts = modelEntry.source:GetDescendants()
    if modelEntry.source:IsA("BasePart") then table.insert(parts, modelEntry.source) end
    local count = 0
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and count < 64 then
            local ok, copy = pcall(part.Clone, part)
            if ok and copy then
                for _, object in ipairs(copy:GetDescendants()) do
                    if object:IsA("LuaSourceContainer") or object:IsA("JointInstance") or object:IsA("Constraint")
                        or object:IsA("BodyMover") or object:IsA("BasePart") then object:Destroy() end
                end
                copy.Anchored, copy.CanCollide, copy.CanTouch, copy.CanQuery = true, false, false, false
                copy.LocalTransparencyModifier, copy.Parent = 0, model
                count += 1
            end
        end
    end
    if count == 0 then viewport:Destroy() return nil end
    local bounds, size = model:GetBoundingBox()
    local radius = math.max(size.X, size.Y, size.Z, 0.5)
    local camera = make("Camera", { FieldOfView = 35,
        CFrame = CFrame.lookAt(bounds.Position + Vector3.new(radius * 0.45, radius * 0.3, radius * 1.8), bounds.Position) }, viewport)
    viewport.CurrentCamera = camera
    return viewport
end
function Inventory:_show(mount, visible)
    if not self.alive or not mount.page.Parent then return end
    mount.page.Visible = visible
    if mount.layout.phone then
        if visible then
            mount.phoneNav = { original = mount.layout.nav.Visible, applied = false }
            mount.layout.nav.Visible = false
        elseif mount.phoneNav then
            if mount.layout.nav.Visible == mount.phoneNav.applied then mount.layout.nav.Visible = mount.phoneNav.original end
            mount.phoneNav = nil
        end
    end
    if visible then mount.signature, mount.selection = nil, nil; self:_render(mount) end
end
function Inventory:_mount(layout)
    local mount = { layout = layout, saved = {}, connections = {}, cardConnections = {}, cards = {}, previews = {}, kind = "Knife" }
    self.mounts[layout.inventory] = mount
    local nativeButtons = {}
    for _, object in ipairs(layout.navigation:GetChildren()) do if object:IsA("GuiButton") then table.insert(nativeButtons, object) end end
    table.sort(nativeButtons, function(a, b)
        if a.LayoutOrder ~= b.LayoutOrder then return a.LayoutOrder < b.LayoutOrder end
        return a.Position.Y.Scale * 10000 + a.Position.Y.Offset < b.Position.Y.Scale * 10000 + b.Position.Y.Offset
    end)
    local listLayout = layout.navigation:FindFirstChildWhichIsA("UIListLayout")
    if listLayout then remember(mount, listLayout, "SortOrder", Enum.SortOrder.LayoutOrder) end
    local count = #nativeButtons + 1
    local order = 0
    for _, native in ipairs(nativeButtons) do
        order += 1
        remember(mount, native, "LayoutOrder", order)
        remember(mount, native, "Size", UDim2.new(native.Size.X.Scale, native.Size.X.Offset, 1 / count, -4))
        if not listLayout then
            remember(mount, native, "AnchorPoint", Vector2.zero)
            remember(mount, native, "Position", UDim2.new(native.Position.X.Scale, native.Position.X.Offset, (order - 1) / count, 0))
        end
        table.insert(mount.connections, native.Activated:Connect(function() self:_show(mount, false) end))
        if native == layout.weaponButton then order += 1; mount.order = order end
    end
    mount.tab = button(layout.navigation, "◇\nChanger", UDim2.new(layout.weaponButton.Size.X.Scale, layout.weaponButton.Size.X.Offset, 1 / count, -4),
        UDim2.new(layout.weaponButton.Position.X.Scale, layout.weaponButton.Position.X.Offset, ((mount.order or count) - 1) / count, 0))
    mount.tab.Name, mount.tab.LayoutOrder, mount.tab.BackgroundColor3 = "NexusChanger", mount.order or count, COLORS.accent
    mount.page = make("Frame", { Name = "NexusChanger", Size = layout.weapons.Size,
        Position = layout.phone and UDim2.fromScale(0, 0) or layout.weapons.Position,
        AnchorPoint = layout.weapons.AnchorPoint, BackgroundColor3 = COLORS.background,
        BorderSizePixel = 0, Visible = false, ZIndex = layout.weapons.ZIndex + 5, Active = true }, layout.main)
    local base = mount.page.ZIndex
    local header = make("Frame", { Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, ZIndex = base + 1 }, mount.page)
    local back = button(header, "‹", UDim2.fromOffset(30, 32), UDim2.fromOffset(4, 5))
    back.ZIndex = base + 2
    mount.knife = button(header, "Knife", UDim2.fromOffset(68, 32), UDim2.fromOffset(38, 5))
    mount.gun = button(header, "Gun", UDim2.fromOffset(62, 32), UDim2.fromOffset(110, 5))
    mount.knife.ZIndex, mount.gun.ZIndex = base + 2, base + 2
    mount.search = make("TextBox", { Name = "Search", Text = "", PlaceholderText = "Search", ClearTextOnFocus = false,
        Position = UDim2.fromOffset(178, 5), Size = UDim2.new(1, -184, 0, 32), BackgroundColor3 = COLORS.card,
        BorderSizePixel = 0, TextColor3 = COLORS.text, PlaceholderColor3 = COLORS.muted, Font = Enum.Font.Gotham,
        TextSize = 12, ZIndex = base + 2 }, header)
    mount.list = make("ScrollingFrame", { Name = "Items", Position = UDim2.fromOffset(4, 48),
        Size = UDim2.new(0.76, -8, 1, -76), BackgroundTransparency = 1, BorderSizePixel = 0,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4, ZIndex = base + 1 }, mount.page)
    make("UIGridLayout", { CellSize = UDim2.new(1 / 3, -5, 0, 128), CellPadding = UDim2.fromOffset(5, 5),
        SortOrder = Enum.SortOrder.LayoutOrder, FillDirectionMaxCells = 3 }, mount.list)
    mount.equipped = make("Frame", { Name = "Selected", Position = UDim2.new(0.76, 4, 0, 48),
        Size = UDim2.new(0.24, -8, 1, -76), BackgroundTransparency = 1, ZIndex = base + 1 }, mount.page)
    mount.slots = {}
    for index, kind in ipairs({ "Knife", "Gun" }) do
        local slot = make("Frame", { Name = kind, Position = UDim2.fromOffset(0, (index - 1) * 142),
            Size = UDim2.new(1, 0, 0, 136), BackgroundColor3 = COLORS.card, BorderSizePixel = 0, ZIndex = base + 2 }, mount.equipped)
        local preview = make("Frame", { Size = UDim2.new(1, -8, 0, 92), Position = UDim2.fromOffset(4, 4),
            BackgroundTransparency = 1, ZIndex = base + 3 }, slot)
        local title = label(slot, kind, UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 1, -38), 10, COLORS.muted)
        local name = label(slot, "—", UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 1, -20), 11)
        title.ZIndex, name.ZIndex = base + 3, base + 3
        mount.slots[kind] = { preview = preview, name = name }
    end
    local footer = label(mount.page, "Changer", UDim2.new(1, -8, 0, 20), UDim2.new(0, 4, 1, -23), 10, COLORS.muted)
    footer.ZIndex = base + 2
    table.insert(mount.connections, mount.tab.Activated:Connect(function() self:_show(mount, not mount.page.Visible) end))
    table.insert(mount.connections, back.Activated:Connect(function() self:_show(mount, false) end))
    table.insert(mount.connections, mount.knife.Activated:Connect(function() mount.kind = "Knife"; mount.signature = nil; self:_render(mount) end))
    table.insert(mount.connections, mount.gun.Activated:Connect(function() mount.kind = "Gun"; mount.signature = nil; self:_render(mount) end))
    table.insert(mount.connections, mount.search:GetPropertyChangedSignal("Text"):Connect(function() mount.signature = nil; self:_render(mount) end))
    table.insert(mount.connections, layout.inventory:GetPropertyChangedSignal("Visible"):Connect(function()
        if not layout.inventory.Visible then self:_show(mount, false) end
    end))
    table.insert(mount.connections, mount.page:GetPropertyChangedSignal("Visible"):Connect(function()
        if not mount.page.Visible and mount.phoneNav then self:_show(mount, false) end
    end))
end
function Inventory:_render(mount)
    if not self.alive or not mount.page.Visible then return end
    local entries = self.assets:GetWeaponCatalog(mount.kind, mount.search.Text)
    if not self.alive or not mount.page.Parent or not mount.page.Visible then return end
    local ids = {}
    for _, entry in ipairs(entries) do table.insert(ids, entry.id .. ":" .. entry.name) end
    local signature = table.concat(ids, "|")
    if mount.signature ~= signature then
        mount.signature = signature
        disconnect(mount.cardConnections)
        for _, card in ipairs(mount.cards) do card.button:Destroy() end
        table.clear(mount.cards)
        for index, entry in ipairs(entries) do
            local card = button(mount.list, "", UDim2.fromOffset(110, 128), UDim2.new())
            card.LayoutOrder, card.ZIndex = index, mount.page.ZIndex + 2
            local preview = make("Frame", { Size = UDim2.new(1, -8, 1, -42), Position = UDim2.fromOffset(4, 3),
                BackgroundTransparency = 1, ZIndex = card.ZIndex + 1 }, card)
            local tag = label(card, "Changer", UDim2.new(1, -8, 0, 16), UDim2.new(0, 4, 1, -39), 9, COLORS.accent)
            local name = label(card, entry.name, UDim2.new(1, -8, 0, 20), UDim2.new(0, 4, 1, -22), 11)
            tag.ZIndex, name.ZIndex = card.ZIndex + 1, card.ZIndex + 1
            for badgeIndex, badge in ipairs(entry.badges or {}) do
                local seal = label(card, badge, UDim2.fromOffset(30, 16), UDim2.fromOffset(3 + (badgeIndex - 1) * 31, 3), 9,
                    badge == "FX" and COLORS.fx or COLORS.evo)
                seal.ZIndex = card.ZIndex + 3
            end
            table.insert(mount.cards, { button = card, holder = preview, entry = entry })
            table.insert(mount.cardConnections, card.Activated:Connect(function() if self:_choose(entry.id) then self:_render(mount) end end))
        end
        mount.list.CanvasPosition = Vector2.zero
    end
    mount.knife.BackgroundColor3 = mount.kind == "Knife" and COLORS.accent or COLORS.card
    mount.gun.BackgroundColor3 = mount.kind == "Gun" and COLORS.accent or COLORS.card
    local selected = tostring(self:_get("skins.knife", "")) .. "|" .. tostring(self:_get("skins.gun", ""))
    if mount.selection ~= selected then
        mount.selection = selected
        for kind, slot in pairs(mount.slots) do
            slot.preview:ClearAllChildren()
            local entry = self.assets:_model(self:_get(kind == "Knife" and "skins.knife" or "skins.gun", ""), kind)
            slot.name.Text = entry and entry.name or "—"
            if entry then self:_preview(slot.preview, entry) end
        end
    end
    -- Only materialize geometry previews for cards currently inside the scroller.
    local top, bottom = mount.list.AbsolutePosition.Y, mount.list.AbsolutePosition.Y + mount.list.AbsoluteSize.Y
    local previews = 0
    for _, card in ipairs(mount.cards) do
        local visible = card.button.AbsolutePosition.Y + card.button.AbsoluteSize.Y >= top and card.button.AbsolutePosition.Y <= bottom
        if visible and previews < 16 then
            previews += 1
            if not card.preview then card.preview = self:_preview(card.holder, card.entry) end
        elseif card.preview then card.preview:Destroy(); card.preview = nil end
        local active = self:_get(card.entry.kind == "Knife" and "skins.knife" or "skins.gun", "") == card.entry.id
        card.button.BackgroundColor3 = active and COLORS.accent:Lerp(COLORS.card, 0.65) or COLORS.card
    end
end
function Inventory:_unmount(inventory)
    local mount = self.mounts[inventory]
    if not mount then return end
    disconnect(mount.connections)
    disconnect(mount.cardConnections)
    if mount.phoneNav and mount.layout.nav.Parent and mount.layout.nav.Visible == mount.phoneNav.applied then
        mount.layout.nav.Visible = mount.phoneNav.original
    end
    if mount.page then mount.page:Destroy() end
    if mount.tab then mount.tab:Destroy() end
    restore(mount.saved)
    self.mounts[inventory] = nil
end
function Inventory:_tick()
    if not self.alive then return end
    local playerGui = self.player and self.player:FindFirstChild("PlayerGui")
    local seen = {}
    for _, layout in ipairs(Inventory.layouts(playerGui)) do
        seen[layout.inventory] = true
        if not self.mounts[layout.inventory] and not self.failed[layout.inventory] then
            local ok, problem = pcall(self._mount, self, layout)
            if not ok then
                self:_unmount(layout.inventory)
                self.failed[layout.inventory] = true
                self:_notify("O inventario atual nao aceitou o Changer: " .. tostring(problem))
            end
        end
    end
    for inventory, mount in pairs(self.mounts) do
        if not seen[inventory] or not mount.page.Parent or not mount.tab.Parent then self:_unmount(inventory)
        elseif mount.page.Visible then self:_render(mount) end
    end
    for inventory in pairs(self.failed) do if not seen[inventory] then self.failed[inventory] = nil end end
end
function Inventory:Destroy()
    if not self.alive then return end
    self.alive = false
    disconnect(self.connections)
    local inventories = {}
    for inventory in pairs(self.mounts) do table.insert(inventories, inventory) end
    for _, inventory in ipairs(inventories) do self:_unmount(inventory) end
end

return Inventory
