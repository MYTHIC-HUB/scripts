-- Exercise the real layout/reparenting code without a Roblox GUI renderer.
local services = {}
local game = { GetService = function(_, name)
    services[name] = services[name] or {}
    return services[name]
end }
local Color3 = { fromRGB = function(r, g, b) return { R = r, G = g, B = b } end }
local UDim2 = {}
function UDim2.new(xs, xo, ys, yo)
    return { X = { Scale = xs, Offset = xo }, Y = { Scale = ys, Offset = yo } }
end
function UDim2.fromOffset(x, y) return UDim2.new(0, x, 0, y) end
local Instance = { new = function() error("Reflow must not construct or replace controls") end }

-- INSERT_UI_MODULE

local function finite(number)
    return type(number) == "number" and number == number and math.abs(number) < math.huge
end

-- Dragging the divider must adapt to the remaining content space, including at
-- both ends of the supported window sizes and with invalid saved input.
for width = 640, 1100, 20 do
    local previousColumns = 2
    for _, request in ipairs({ -1000, 0, 150, 180, 204, 250, 300, 360, 1000 }) do
        local layout = UI.Layout(width, request, false)
        assert(finite(layout.sidebar) and finite(layout.content), "Layout leaked NaN/Infinity")
        assert(layout.sidebar > 0 and layout.content > 0 and layout.sidebar + layout.content < width,
            "Sidebar or content would overlap the window bounds")
        assert(layout.columns == 1 or layout.columns == 2, "Invalid column count")
        assert(layout.columns <= previousColumns, "Widening the sidebar unexpectedly created more columns")
        previousColumns = layout.columns
        assert(UI.Layout(width, request, true).columns == 1, "Full-width pages must stay full-width")
    end
end
for _, invalid in ipairs({ 0 / 0, math.huge, -math.huge, "invalid" }) do
    local layout = UI.Layout(invalid, invalid, false)
    assert(finite(layout.sidebar) and finite(layout.content) and layout.content > 0,
        "Invalid input must recover to a usable layout")
end
assert(UI.Layout(nil, nil, false).columns >= 1, "Missing saved values must be usable")
assert(UI.Layout(1000, 180, false).columns == 2, "Wide content should have two columns")
assert(UI.Layout(640, 300, false).columns == 1, "Narrow content should stack cards")

local parentWrites = 0
local function control(properties)
    return setmetatable({}, {
        __index = function(_, key)
            if key == "Destroy" or key == "ClearAllChildren" then
                return function() error("Reflow must preserve existing controls and connections") end
            end
            return properties[key]
        end,
        __newindex = function(_, key, value)
            if key == "Parent" then parentWrites += 1 end
            properties[key] = value
        end,
    })
end
local left, right = {}, {}
local selectedValue = { Text = "Craudete", Focused = true }
local callback = function() return selectedValue.Text end
local cardA = control({ Input = selectedValue, Activated = callback })
local cardB = control({ Checked = true })
local cardC = control({ Expanded = false })
local collapsed = { ["Farm/Trade"] = true }
local instance = setmetatable({
    width = 1000, sidebarWidth = 204, sidebar = {}, content = {},
    sidebarHandle = {}, sidebarLine = {}, accent = {},
    columns = { left, right }, cardRecords = {
        { card = cardA, column = 1, order = 1 },
        { card = cardB, column = 2, order = 2 },
        { card = cardC, column = 1, order = 3 },
    }, collapsed = collapsed,
}, UI)

instance:_applyLayout()
assert(instance.columnCount == 2 and cardA.Parent == left and cardB.Parent == right and cardC.Parent == left,
    "Initial two-column layout lost the section placement")
assert(left.Visible and right.Visible, "Both columns must be visible in a wide layout")
local firstCard, secondCard = instance.cardRecords[1].card, instance.cardRecords[2].card
parentWrites = 0
instance.sidebarWidth = 250
instance:_applyLayout()
assert(parentWrites == 0, "Small divider movements must not recreate/reparent unchanged cards")

instance.width, instance.sidebarWidth = 740, 330
instance.sidebarDragging = { input = "touch" }
instance:_applyLayout()
assert(instance.columnCount == 1 and left.Visible and not right.Visible, "Narrow content did not stack")
assert(cardA.Parent == left and cardB.Parent == left and cardC.Parent == left, "Stacked cards are missing")
assert(cardA.LayoutOrder < cardB.LayoutOrder and cardB.LayoutOrder < cardC.LayoutOrder,
    "Reflow must preserve the source section order")
assert(instance.sidebarLine.BackgroundColor3 == instance.accent and instance.sidebarLine.BackgroundTransparency == 0,
    "The active divider must be highlighted")
assert(instance.sidebarHandle.Position.X.Offset < instance.sidebarWidth,
    "The divider hit target must follow the sidebar edge")
local actualContentWidth = instance.width * instance.content.Size.X.Scale + instance.content.Size.X.Offset
assert(actualContentWidth == UI.Layout(instance.width, instance.sidebarWidth, false).content,
    "The GUI bounds must use the same content width as the reflow decision")

instance.width, instance.sidebarWidth, instance.sidebarDragging = 1000, 204, nil
instance:_applyLayout()
assert(instance.columnCount == 2 and cardB.Parent == right and right.Visible, "Widening must restore the second column")
assert(instance.sidebarLine.BackgroundTransparency > 0, "Divider highlight stayed active after release")
assert(instance.cardRecords[1].card == firstCard and instance.cardRecords[2].card == secondCard,
    "Reflow replaced a card instance")
assert(cardA.Input == selectedValue and selectedValue.Focused and selectedValue.Text == "Craudete"
    and cardA.Activated == callback and callback() == "Craudete", "Reflow lost control state or callbacks")
assert(cardB.Checked and cardC.Expanded == false and instance.collapsed == collapsed and collapsed["Farm/Trade"],
    "Reflow changed settings or collapsed section state")
instance.forceSingleColumn = true
instance:_applyLayout()
assert(instance.columnCount == 1 and cardB.Parent == left, "Explicit full-width pages must override a wide window")
print("PASS: divider bounds, two/one/two-column reflow, stable controls/state/callbacks and active highlight")
