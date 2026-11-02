-- Headless native-inventory integration contract; no Roblox server or rendering.
local function signal()
    local result = { listeners = {} }
    function result:Connect(callback)
        local connection = { callback = callback, Connected = true }
        function connection:Disconnect() self.Connected = false end
        table.insert(self.listeners, connection)
        return connection
    end
    function result:Fire(...)
        for _, listener in ipairs(table.clone(self.listeners)) do if listener.Connected then listener.callback(...) end end
    end
    function result:Active()
        local count = 0
        for _, listener in ipairs(self.listeners) do if listener.Connected then count += 1 end end
        return count
    end
    return result
end
local function enum()
    return setmetatable({}, { __index = function(self, key) local value = {}; rawset(self, key, value) return value end })
end
local Enum = setmetatable({}, { __index = function(self, key) local value = enum(); rawset(self, key, value) return value end })
local Vector2 = { new = function(x, y) return { X = x, Y = y } end, zero = { X = 0, Y = 0 } }
local UDim2 = {}
function UDim2.new(x, xo, y, yo) return { X = { Scale = x or 0, Offset = xo or 0 }, Y = { Scale = y or 0, Offset = yo or 0 } } end
function UDim2.fromOffset(x, y) return UDim2.new(0, x, 0, y) end
function UDim2.fromScale(x, y) return UDim2.new(x, 0, y, 0) end
local Color3 = { fromRGB = function(r, g, b) return { R = r, G = g, B = b, Lerp = function(self) return self end } end }
local objects, methods = {}, {}
local guiClasses = { Frame = true, ScrollingFrame = true, TextButton = true, ImageButton = true,
    TextBox = true, TextLabel = true, ImageLabel = true, ViewportFrame = true }
local failClass
local Instance = {}
function Instance.new(className)
    if failClass == className then error("Simulated GUI allocation failure") end
    local properties = { Name = className, Parent = nil, Size = UDim2.fromScale(1, 1), Position = UDim2.new(),
        AnchorPoint = Vector2.zero, AbsolutePosition = Vector2.zero, AbsoluteSize = Vector2.new(600, 350),
        LayoutOrder = 0, Visible = true, ZIndex = 1, Text = "" }
    local object = { _class = className, _properties = properties, _children = {}, _signals = {}, _attributes = {}, Activated = signal() }
    setmetatable(object, {
        __index = function(self, key) return methods[key] or self._properties[key] end,
        __newindex = function(self, key, value)
            local previous = properties[key]
            if key == "Parent" and previous ~= value then
                if previous then local i = table.find(previous._children, self); if i then table.remove(previous._children, i) end end
                if value then table.insert(value._children, self) end
            end
            properties[key] = value
            if previous ~= value and self._signals[key] then self._signals[key]:Fire() end
        end,
    })
    table.insert(objects, object)
    return object
end
function methods:IsA(name)
    if name == self._class or name == "Instance" then return true end
    if name == "GuiObject" then return guiClasses[self._class] == true end
    if name == "GuiButton" then return self._class == "TextButton" or self._class == "ImageButton" end
    return name == "BasePart" and self._class == "Part"
end
function methods:GetChildren() return table.clone(self._children) end
function methods:GetDescendants()
    local result = {}
    for _, child in ipairs(self._children) do table.insert(result, child); for _, nested in ipairs(child:GetDescendants()) do table.insert(result, nested) end end
    return result
end
function methods:FindFirstChild(name, recursive)
    for _, child in ipairs(self._children) do if child.Name == name then return child end end
    if recursive then for _, child in ipairs(self._children) do local found = child:FindFirstChild(name, true); if found then return found end end end
end
function methods:FindFirstChildWhichIsA(name, recursive)
    for _, child in ipairs(self._children) do if child:IsA(name) then return child end end
    if recursive then for _, child in ipairs(self._children) do local found = child:FindFirstChildWhichIsA(name, true); if found then return found end end end
end
function methods:GetAttribute(name) return self._attributes[name] end
function methods:GetFullName() return self.Parent and self.Parent:GetFullName() .. "." .. self.Name or self.Name end
function methods:GetPropertyChangedSignal(name) self._signals[name] = self._signals[name] or signal(); return self._signals[name] end
function methods:ClearAllChildren() for _, child in ipairs(self:GetChildren()) do child:Destroy() end end
function methods:Destroy() self:ClearAllChildren(); self.Parent = nil; rawset(self, "Destroyed", true) end
local function object(className, name, parent)
    local result = Instance.new(className); result.Name, result.Parent = name, parent; return result
end
local player = object("Player", "Player")
local playerGui = object("PlayerGui", "PlayerGui", player)
local replicated = object("ReplicatedStorage", "ReplicatedStorage")
local heartbeat = signal()
local services = { Players = { LocalPlayer = player }, ReplicatedStorage = replicated, RunService = { Heartbeat = heartbeat }, AvatarEditorService = {} }
local game = { GetService = function(_, name) return services[name] end }

-- INSERT_ASSETS_MODULE
-- INSERT_INVENTORY_MODULE

local weaponRoot = object("Folder", "Weapons", replicated)
for _, name in ipairs({ "TreeGun2023", "Gingerscope", "IceHammer", "UnknownModel" }) do
    local model = object("Model", name, weaponRoot)
    object("Part", "Handle", model)
end
local metadata = {
    TreeGun2023 = { ItemName = "Evergun", ItemType = "Gun", Rarity = "Godly", FX = true, Image = "https://www.roblox.com/asset/?id=123" },
    Gingerscope = { ItemName = "Gingerscope", ItemType = "Gun", Rarity = "Ancient", FX = true, Image = "rbxassetid://456" },
    IceHammer = { ItemName = "Icecrusher", ItemType = "Knife", Rarity = "Rare", EvoBaseID = "IceHammer", Image = "http://www.roblox.com/Thumbs/Asset.ashx?assetId=789&width=150" },
    Unreplicated = { ItemName = "Not available", ItemType = "Gun", Image = "rbxassetid://999" },
}
local settings = { ["skins.filter"] = "Knife", ["skins.rarity"] = "Common" }
local notices, changed = {}, 0
local context = { settings = settings, adapters = { WeaponMetadata = metadata }, get = function(id) return settings[id] end,
    notify = function(message) table.insert(notices, message) end }
local assets = setmetatable({ alive = true, context = context, settings = settings, scanAt = 0, models = {}, byId = {} }, Assets)
function assets:_refreshVisuals() changed += 1 return true end
local catalog = assets:GetWeaponCatalog("All", "")
assert(#catalog == 3, "Only actually replicated, classifiable models may become cards")
assert(#assets:GetWeaponCatalog("Gun", "EVER") == 1, "Search must use display names and ignore hub filters")
assert(#assets:GetWeaponCatalog("Gun", "TreeGun") == 1, "Internal IDs must remain searchable")
local ice = assets:_model("IceHammer", "Knife")
assert(ice.name == "Icecrusher" and ice.rarity == "Rare", "Real metadata must override name-based rarity inference")
assert(ice.thumbnail == "rbxassetid://789" and table.find(ice.badges, "Evo"), "Use the native thumbnail and verified Evo marker")
assert(not assets:_model("Not available"), "Metadata alone must never create a usable model")
context.action = function(id, payload) return assets:Action(id, payload) end
context.set = function(id, value) return assets:Set(id, value) end

local function nativeInventory(container, name)
    local native = object("Frame", name, container)
    local main, nav = object("Frame", "Main", native), object("Frame", "Nav", native)
    local weapons = object("Frame", "Weapons", main)
    object("Frame", "Items", weapons); object("Frame", "Equipped", weapons)
    for i, title in ipairs({ "Weapons", "Effects", "Pets" }) do
        local tab = object("TextButton", title, nav)
        tab.LayoutOrder, tab.Position, tab.Size = i, UDim2.new(0, 0, (i - 1) / 3, 0), UDim2.new(1, 0, 1 / 3, 0)
    end
    return native, nav
end
local screen = object("ScreenGui", "OtherMainName", playerGui)
local gameGui = object("Frame", "Game", screen)
local invalid = object("Frame", "Inventory", gameGui)
object("Frame", "Main", invalid); object("Frame", "Nav", invalid)
assert(not Inventory.describe(invalid), "A matching name without native structure must not be modified")
local native, nav = nativeInventory(gameGui, "Inventory2")
local weaponButton = nav:FindFirstChild("Weapons")
local originalSize, originalPosition, originalOrder = weaponButton.Size, weaponButton.Position, weaponButton.LayoutOrder
local changer = Inventory.new(context, assets)
assert(#Inventory.layouts(playerGui) == 1 and changer.mounts[native], "Discover the documented structure under any ScreenGui name")
local mount = changer.mounts[native]
assert(nav:FindFirstChild("NexusChanger") == mount.tab and not mount.page.Visible, "Add one hidden page and a native Changer tab")
mount.tab.Activated:Fire()
assert(mount.page.Visible and #mount.cards == 1, "Knife page must show only replicated knives")
mount.gun.Activated:Fire()
assert(#mount.cards == 2, "Gun tab must have an independent filter")
mount.search.Text = "ever"
assert(#mount.cards == 1 and mount.cards[1].entry.name == "Evergun", "Search must rebuild visible cards")
mount.cards[1].button.Activated:Fire()
assert(settings["skins.enabled"] == true and settings["skins.gun"] == assets:_model("Evergun").id and changed == 1,
    "An explicit selection must enable and apply the cosmetic through controller callbacks")
mount.search.Text = ""
mount.knife.Activated:Fire()
mount.cards[1].button.Activated:Fire()
assert(settings["skins.knife"] == ice.id and settings["skins.gun"] == assets:_model("Evergun").id,
    "Knife and Gun selections must be preserved separately")
nav:FindFirstChild("Effects").Activated:Fire()
assert(not mount.page.Visible, "Native navigation must close only the Changer page")
assert(native:FindFirstChild("Main"):FindFirstChild("Weapons").Visible, "Native page ownership stays with the game")
mount.tab.Activated:Fire(); native.Visible = false
assert(not mount.page.Visible, "Closing native inventory must also close Changer")
native.Parent = nil; changer:_tick()
assert(not changer.mounts[native] and mount.tab.Destroyed and mount.page.Destroyed, "Replaced GUI must release the old mount")
assert(weaponButton.Size == originalSize and weaponButton.Position == originalPosition and weaponButton.LayoutOrder == originalOrder,
    "Release must restore native geometry exactly")
local replacement, replacementNav = nativeInventory(gameGui, "Inventory2")
changer:_tick(); assert(changer.mounts[replacement], "GUI replacement must be mounted lazily")
local externalSize = UDim2.fromOffset(87, 42)
replacementNav:FindFirstChild("Pets").Size = externalSize
changer:Destroy(); changer:Destroy()
assert(not replacementNav:FindFirstChild("NexusChanger") and heartbeat:Active() == 0, "Unload must remove every owned object and listener")
assert(replacementNav:FindFirstChild("Pets").Size == externalSize, "Cleanup must preserve later native layout changes")
invalid:Destroy()
local failedNative, failedNav = nativeInventory(gameGui, "Inventory")
replacement.Parent = nil
local before = failedNav:FindFirstChild("Weapons").Size
failClass = "ScrollingFrame"
local failed = Inventory.new(context, assets)
assert(not failed.mounts[failedNative] and not failedNav:FindFirstChild("NexusChanger"), "Partial allocation failure must clean up owned objects")
assert(failedNav:FindFirstChild("Weapons").Size == before, "Partial failure must restore geometry")
local noticeCount = #notices
assert(noticeCount == 1, "The simulated mount failure must actually have reached allocation")
failed:_tick(); assert(#notices == noticeCount, "An incompatible GUI must not flood errors every heartbeat")
failClass = nil
failed:Destroy()
failedNative.Parent = nil
local lobby = object("Frame", "Lobby", screen)
local screens = object("Frame", "Screens", lobby)
local phone, phoneNav = nativeInventory(screens, "Inventory")
local navigation = object("Frame", "Main", phoneNav)
for _, tab in ipairs(phoneNav:GetChildren()) do if tab:IsA("GuiButton") then tab.Parent = navigation end end
local phoneChanger = Inventory.new(context, assets)
local phoneMount = phoneChanger.mounts[phone]
assert(phoneMount and phoneMount.layout.phone, "The documented phone layout must be recognized")
phoneMount.tab.Activated:Fire()
assert(not phoneNav.Visible and phoneMount.page.Visible, "Phone Changer must take over the native page area")
phoneMount.page.Visible = false
assert(phoneNav.Visible, "Native navigation hiding the page must release the phone navigation cover")
phoneMount.tab.Activated:Fire(); phoneChanger:Destroy()
assert(phoneNav.Visible and not navigation:FindFirstChild("NexusChanger") and heartbeat:Active() == 0,
    "Phone unload must restore navigation and disconnect every owned callback")
local yielding = Inventory.new(context, assets)
local yieldingMount = yielding.mounts[phone]
local getCatalog = assets.GetWeaponCatalog
function assets:GetWeaponCatalog(kind, query)
    local entries = getCatalog(self, kind, query)
    yielding:Destroy() -- Models/metadata can yield while native GUI or hub is removed.
    return entries
end
yieldingMount.tab.Activated:Fire()
assert(not navigation:FindFirstChild("NexusChanger") and heartbeat:Active() == 0,
    "A pending catalog result must not recreate UI after unload")
assets.GetWeaponCatalog = getCatalog
print("PASS: native Changer discovery, replicated metadata, search, independent slots, cosmetic routing, GUI replacement and reversible cleanup")
