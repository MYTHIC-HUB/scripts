-- Run the real select/popup/font flow without a Roblox GUI renderer.
local function signal()
    local event = { listeners = {} }
    function event:Connect(callback)
        local connection = { Connected = true, callback = callback }
        function connection:Disconnect() self.Connected = false end
        table.insert(self.listeners, connection)
        return connection
    end
    function event:Fire(...)
        for _, connection in ipairs(table.clone(self.listeners)) do
            if connection.Connected then connection.callback(...) end
        end
    end
    return event
end
local vectorMeta = {}
local function vector(x, y) return setmetatable({ X = x or 0, Y = y or 0 }, vectorMeta) end
function vectorMeta.__sub(a, b) return vector(a.X - b.X, a.Y - b.Y) end
function vectorMeta.__div(a, b) return vector(a.X / b, a.Y / b) end
local Vector2 = { new = vector, zero = vector() }
local UDim2 = {}
function UDim2.new(x, xo, y, yo) return { X = { Scale = x or 0, Offset = xo or 0 }, Y = { Scale = y or 0, Offset = yo or 0 } } end
function UDim2.fromOffset(x, y) return UDim2.new(0, x, 0, y) end
function UDim2.fromScale(x, y) return UDim2.new(x, 0, y, 0) end
local UDim = { new = function(scale, offset) return { Scale = scale, Offset = offset } end }
local Color3 = {}
function Color3.fromRGB(r, g, b)
    return { R = r, G = g, B = b, Lerp = function(self) return self end }
end
function Color3.fromHex(hex)
    return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
end
local function enumType()
    return setmetatable({}, { __index = function(self, key) rawset(self, key, key); return key end })
end
local Enum = setmetatable({}, { __index = function(self, key)
    local value = enumType(); rawset(self, key, value); return value
end })
local Font = { new = function(family, weight, style) return { Family = family, Weight = weight, Style = style } end }
local fontWeights = { GothamBold = Enum.FontWeight.Bold, GothamBlack = Enum.FontWeight.Heavy, GothamMedium = Enum.FontWeight.Medium }
local methods = {}
local Instance = {}
function Instance.new(class)
    local properties = { ClassName = class, Name = class, Parent = nil, Visible = true, ZIndex = 1,
        Position = UDim2.new(), Size = UDim2.new(), AbsolutePosition = vector(), AbsoluteSize = vector(180, 30),
        FontFace = Font.new("family/Gotham", Enum.FontWeight.Regular, Enum.FontStyle.Normal) }
    local object = { _properties = properties, _children = {}, _signals = {},
        Activated = signal(), MouseEnter = signal(), MouseLeave = signal(), InputBegan = signal() }
    return setmetatable(object, {
        __index = function(self, key) return methods[key] or self._properties[key] end,
        __newindex = function(self, key, value)
            if key == "Parent" and properties.Parent ~= value then
                if properties.Parent then
                    local index = table.find(properties.Parent._children, self)
                    if index then table.remove(properties.Parent._children, index) end
                end
                if value then table.insert(value._children, self) end
            elseif key == "Font" then
                properties.FontFace = Font.new("family/" .. tostring(value), fontWeights[value] or Enum.FontWeight.Regular, Enum.FontStyle.Normal)
            end
            properties[key] = value
        end,
    })
end
function methods:GetChildren() return table.clone(self._children) end
function methods:FindFirstChild(name)
    for _, child in ipairs(self._children) do if child.Name == name then return child end end
end
function methods:IsA(name) return self.ClassName == name or name == "GuiObject" end
function methods:GetPropertyChangedSignal(name)
    self._signals[name] = self._signals[name] or signal()
    return self._signals[name]
end
function methods:Destroy()
    for _, child in ipairs(self:GetChildren()) do child:Destroy() end
    self.Parent = nil
    rawset(self, "Destroyed", true)
end
local services = {}
local game = { GetService = function(_, name) services[name] = services[name] or {}; return services[name] end }

-- INSERT_UI_MODULE

local settings = { ["ui.font"] = "Ubuntu", ["ui.textScale"] = 1.2 }
local changes, notices = {}, {}
local controller = {}
function controller:Get(id) return settings[id] end
function controller:IsSupported() return true end
function controller:Set(id, value) settings[id] = value; changes[#changes + 1] = { id, value }; return true end
local host = Instance.new("Frame")
local window = Instance.new("Frame"); window.Parent = host; window.AbsolutePosition = vector(100, 100)
local popupLayer = Instance.new("Frame"); popupLayer.Parent = window
local sidebar = Instance.new("Frame"); sidebar.Parent = window
local instance = setmetatable({ controller = controller, width = 730, height = 525, window = window, sidebar = sidebar,
    popupLayer = popupLayer, scale = { Scale = 0.8 }, styles = {}, corners = {}, fonts = {}, fontWeights = {},
    renderConnections = {}, connections = {}, renderCleanups = {}, dynamic = {}, updaters = {}, navigation = {},
    hud = {}, launcher = {}, accent = Color3.fromRGB(239, 51, 64) }, UI)
function instance:_fit() end
function instance:_refreshMobile() end
function instance:Notify(message) notices[#notices + 1] = message end

local body = Instance.new("Frame"); body.Parent = window
local sibling = Instance.new("Frame"); sibling.Parent = body; sibling.LayoutOrder = 2
local originalSiblingSize, originalSiblingPosition = sibling.Size, sibling.Position
instance:_control(body, { id = "test.method", type = "select", label = "Farm Method", default = "Fast", options = { "Fast", "Under Map", "Teleport" } })
local row, select, dropdown
for _, child in ipairs(body:GetChildren()) do if child ~= sibling then row = child end end
for _, child in ipairs(row:GetChildren()) do if child.ClassName == "TextButton" then select = child end end
for _, child in ipairs(popupLayer:GetChildren()) do if child.ClassName == "ScrollingFrame" then dropdown = child end end
assert(row and select and dropdown and dropdown.Parent == popupLayer and not dropdown.Visible,
    "A select must create a hidden overlay outside its content row")
local originalRowSize = row.Size
select.AbsolutePosition, select.AbsoluteSize = vector(600, 450), vector(80, 24)
select.Activated:Fire()
assert(instance.popup and instance.popup.frame == dropdown and dropdown.Visible, "Select activation must open its overlay")
assert(row.Size == originalRowSize and sibling.Size == originalSiblingSize and sibling.Position == originalSiblingPosition,
    "Opening a select must not grow its row or move sibling controls")
local function withinWindow(frame)
    assert(frame.Position.X.Offset >= 0 and frame.Position.Y.Offset >= 0, "Popup escaped the top/left window bounds")
    assert(frame.Position.X.Offset + frame.Size.X.Offset <= instance.width
        and frame.Position.Y.Offset + frame.Size.Y.Offset <= instance.height, "Popup escaped the right/bottom window bounds")
end
withinWindow(dropdown)
assert(dropdown.Position.Y.Offset < (select.AbsolutePosition.Y - window.AbsolutePosition.Y) / instance.scale.Scale,
    "A select near the bottom must open above its anchor")
local choice
for _, child in ipairs(dropdown:GetChildren()) do if child.ClassName == "TextButton" and child.Text == "Under Map" then choice = child end end
assert(choice, "The option list must contain the controller choice")
choice.Activated:Fire()
assert(settings["test.method"] == "Under Map" and #changes == 1, "A choice must dispatch its value exactly once")
assert(not instance.popup and not dropdown.Visible and row.Size == originalRowSize, "Selection must close without reflow")
assert(#notices == 0, "A supported selection must not emit activation notices")

-- Opening another menu must close the old one and release its local open state.
select.Activated:Fire(); assert(dropdown.Visible)
local other = Instance.new("Frame"); other.Parent = popupLayer
instance:_openPopup(other, select, 10000, 10000, false)
assert(not dropdown.Visible and other.Visible and instance.popup.frame == other, "Only one popup may be open")
withinWindow(other)
select.Activated:Fire()
assert(not other.Visible and dropdown.Visible and instance.popup.frame == dropdown,
    "Closing another popup must leave the previous select able to open again")
instance:_closePopup()
assert(not instance.popup and not dropdown.Visible, "Explicit close must hide the active popup")
instance:_openPopup(other, select, 10000, 10000, true)
withinWindow(other)

-- Changing the font family or text scale must retain each label's original weight.
local regular = instance:_label(body, "Regular", UDim2.fromOffset(100, 20), 12)
local bold = instance:_label(body, "Bold", UDim2.fromOffset(100, 20), 16); bold.Font = Enum.Font.GothamBold
local heavy = instance:_label(body, "Heavy", UDim2.fromOffset(100, 20), 20); heavy.Font = Enum.Font.GothamBlack
instance:Refresh()
assert(regular.FontFace.Family == "family/Ubuntu" and regular.FontFace.Weight == Enum.FontWeight.Regular,
    "Normal labels must remain normal after applying the theme font")
assert(bold.FontFace.Weight == Enum.FontWeight.Bold and heavy.FontFace.Weight == Enum.FontWeight.Heavy,
    "Theme refresh must not flatten headings to regular weight")
assert(math.abs(bold.TextSize - 19.2) < 0.001, "Text size must still follow the configured scale")
settings["ui.font"] = "Gotham"; instance:Refresh()
assert(regular.FontFace.Family == "family/Gotham" and bold.FontFace.Family == "family/Gotham"
    and bold.FontFace.Weight == Enum.FontWeight.Bold and heavy.FontFace.Weight == Enum.FontWeight.Heavy,
    "A second font change must preserve the initially captured hierarchy")

select.Activated:Fire()
assert(dropdown.Visible)
for _, connection in ipairs(instance.renderConnections) do connection:Disconnect() end
for _, cleanup in ipairs(instance.renderCleanups) do cleanup() end
assert(dropdown.Destroyed and not dropdown.Parent and not instance.popup,
    "Render cleanup must remove the overlay and clear the active-popup reference")
local changesBefore = #changes
choice.Activated:Fire()
assert(#changes == changesBefore, "Old choices must be disconnected after a render cleanup")
print("PASS: select overlays without reflow, value dispatch, bounds, mutual exclusion, popup cleanup and preserved font weights")
