local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local UI = {}
UI.__index = UI
UI.SUPPORTED_SETTINGS = {
    ["ui.menuKey"] = true, ["ui.showFps"] = true,
    ["ui.scale"] = true, ["ui.fit"] = true, ["ui.radius"] = true,
    ["ui.textScale"] = true, ["ui.font"] = true, ["ui.opacity"] = true,
    ["ui.sidebarDensity"] = true, ["ui.compactSidebar"] = true,
    ["ui.halloween"] = true, ["ui.accentColor"] = true, ["ui.baseTheme"] = true,
    ["ui.panelColor"] = true, ["ui.cardStyle"] = true, ["ui.background"] = true,
    ["ui.backgroundIntensity"] = true, ["ui.blur"] = true, ["ui.animations"] = true,
    ["ui.tooltips"] = true, ["ui.launcher"] = true, ["ui.language"] = true,
}

local PALETTE = {
    background = Color3.fromRGB(17, 13, 15),
    sidebar = Color3.fromRGB(20, 15, 17),
    card = Color3.fromRGB(27, 21, 23),
    control = Color3.fromRGB(35, 28, 30),
    line = Color3.fromRGB(64, 49, 53),
    text = Color3.fromRGB(239, 233, 235),
    muted = Color3.fromRGB(151, 137, 142),
    disabled = Color3.fromRGB(95, 83, 87),
    accent = Color3.fromRGB(239, 51, 64),
}

local MOBILE = {
    { id = "mobile.fly", target = "player.fly", label = "FLY", toggle = true },
    { id = "mobile.bhop", target = "player.bhop", label = "BHOP", toggle = true },
    { id = "mobile.flingSheriff", target = "troll.flingTarget", label = "FLING S", role = "Sheriff" },
    { id = "mobile.flingMurderer", target = "troll.flingTarget", label = "FLING M", role = "Murderer" },
    { id = "mobile.shotMurderer", target = "sheriff.shoot", label = "SHOOT" },
    { id = "mobile.killAll", target = "murderer.killAll", label = "KILL ALL" },
    { id = "mobile.invisible", target = "player.invisible", label = "HIDE", toggle = true },
    { id = "mobile.knifeThrow", target = "murderer.throwAim", label = "THROW" },
    { id = "mobile.speed", target = "player.speedEnabled", label = "SPEED", toggle = true },
    { id = "mobile.speedGlitch", target = "player.speedGlitch", label = "GLITCH", toggle = true },
}

local function disconnectAll(connections)
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
end

local function contains(value, query)
    return string.find(string.lower(tostring(value or "")), query, 1, true) ~= nil
end

local function getTabs(page)
    if page.tabs and #page.tabs > 0 then return page.tabs end
    return { { id = "main", title = page.title, sections = page.sections or {} } }
end

local function sectionMatches(section, query)
    if query == "" or contains(section.title, query) then return true end
    for _, control in ipairs(section.controls or {}) do
        if contains(control.label, query) or contains(control.id, query) then return true end
    end
    return false
end

function UI.Layout(width, requestedSidebar, forceSingle)
    width = tonumber(width) or 730
    if width ~= width or math.abs(width) == math.huge then width = 730 end
    width = math.clamp(width, 640, 1100)
    local sidebar = tonumber(requestedSidebar) or 204
    if sidebar ~= sidebar or math.abs(sidebar) == math.huge then sidebar = 204 end
    sidebar = math.clamp(sidebar, 150, math.min(360, width - 358))
    local content = width - sidebar - 46
    return { sidebar = sidebar, content = content, columns = (forceSingle or content < 460) and 1 or 2 }
end

function UI:_applyLayout()
    local layout = UI.Layout(self.width, self.sidebarWidth, self.forceSingleColumn)
    self.sidebarWidth = layout.sidebar
    self.sidebar.Size = UDim2.new(0, layout.sidebar, 1, 0)
    self.content.Position = UDim2.fromOffset(layout.sidebar + 22, 0)
    self.content.Size = UDim2.new(1, -layout.sidebar - 46, 1, 0)
    if self.sidebarHandle then
        self.sidebarHandle.Position = UDim2.fromOffset(layout.sidebar - 5, 0)
        self.sidebarLine.BackgroundColor3 = self.sidebarDragging and self.accent or PALETTE.line
        self.sidebarLine.BackgroundTransparency = self.sidebarDragging and 0 or 0.45
    end
    for index, column in ipairs(self.columns or {}) do
        column.Visible = index <= layout.columns
        column.Position = UDim2.new((index - 1) / layout.columns, index == 1 and 0 or 6, 0, 0)
        column.Size = UDim2.new(1 / layout.columns, layout.columns == 1 and -5 or -8, 0, 0)
    end
    if self.columnCount ~= layout.columns then
        for _, record in ipairs(self.cardRecords or {}) do
            record.card.Parent = self.columns[layout.columns == 1 and 1 or record.column]
            record.card.LayoutOrder = record.order
        end
        self.columnCount = layout.columns
    end
end

function UI:_closePopup()
    local popup = self.popup
    self.popup = nil
    if popup then
        if popup.frame.Parent then popup.frame.Visible = false end
        if popup.closed then popup.closed() end
    end
end

function UI:_openPopup(frame, anchor, width, height, centered, closed)
    self:_closePopup()
    local scale = math.max(self.scale.Scale, 0.1)
    local point = (anchor.AbsolutePosition - self.window.AbsolutePosition) / scale
    local size = anchor.AbsoluteSize / scale
    width, height = math.min(width, self.width - 16), math.min(height, self.height - 16)
    local x = centered and (self.width - width) / 2 or math.clamp(point.X, 8, self.width - width - 8)
    local y = centered and 10 or point.Y + size.Y + 3
    if y + height > self.height - 8 then y = math.max(8, point.Y - height - 3) end
    frame.Position, frame.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(width, height)
    frame.Visible = true
    self.popup = { frame = frame, anchor = anchor, closed = closed }
end

function UI:_get(id, fallback)
    local ok, value = pcall(self.controller.Get, self.controller, id)
    if ok and value ~= nil then return value end
    return fallback
end

function UI:_supported(control)
    if not self.controller.IsSupported then return true end
    local ok, supported, reason = pcall(self.controller.IsSupported, self.controller, control)
    if not ok then return false, "Integracao indisponivel: " .. tostring(supported) end
    return supported ~= false, reason or "Esta funcao depende de uma integracao ainda nao configurada."
end

function UI:_connect(signal, callback, rendered)
    local connection = signal:Connect(callback)
    table.insert(rendered and self.renderConnections or self.connections, connection)
    return connection
end

function UI:_make(className, properties, parent, style)
    local object = Instance.new(className)
    for key, value in pairs(properties or {}) do object[key] = value end
    if object:IsA("GuiObject") and parent and parent:IsA("GuiObject") and parent.ZIndex >= 50 and (not properties or properties.ZIndex == nil) then
        object.ZIndex = parent.ZIndex + 1
    end
    object.Parent = parent
    if style then self.styles[object] = style end
    return object
end

function UI:_round(object, radius)
    local corner = self:_make("UICorner", { CornerRadius = UDim.new(0, radius or 10) }, object)
    self.corners[corner] = radius or 10
    return corner
end

function UI:_stroke(object)
    return self:_make("UIStroke", { Color = PALETTE.line, Thickness = 1, Transparency = 0.15 }, object, { Color = "line" })
end

function UI:_label(parent, value, size, fontSize, color)
    local label = self:_make("TextLabel", {
        BackgroundTransparency = 1, Size = size or UDim2.new(1, 0, 0, 24),
        Text = tostring(value or ""), Font = Enum.Font.Gotham,
        TextSize = fontSize or 13, TextColor3 = PALETTE[color or "text"],
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
    }, parent, { TextColor3 = color or "text" })
    self.fonts[label] = fontSize or 13
    return label
end

function UI:_navIcon(parent, id)
    local icon = self:_make("Frame", {
        Name = "Icon", Position = UDim2.new(0, 0, 0.5, -16),
        Size = UDim2.fromOffset(32, 32), BackgroundTransparency = 1, BorderSizePixel = 0,
    }, parent)
    self:_round(icon, 24)
    local function line(x1, y1, x2, y2)
        local dx, dy = x2 - x1, y2 - y1
        self:_make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(4 + (x1 + x2) / 2, 4 + (y1 + y2) / 2),
            Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy), 1.5),
            Rotation = math.deg(math.atan2(dy, dx)), BorderSizePixel = 0, BackgroundColor3 = PALETTE.muted,
        }, icon)
    end
    local paths = {
        murderer = {{6,5,18,17},{18,5,6,17},{5,16,8,19},{16,19,19,16}},
        sheriff = {{6,5,12,3},{12,3,18,5},{18,5,17,15},{17,15,12,20},{12,20,7,15},{7,15,6,5}},
        visuals = {{3,12,8,7},{8,7,16,7},{16,7,21,12},{21,12,16,17},{16,17,8,17},{8,17,3,12},{12,9,12,15}},
        player = {{9,5,15,5},{15,5,15,10},{15,10,9,10},{9,10,9,5},{6,20,6,16},{6,16,10,13},{10,13,14,13},{14,13,18,16},{18,16,18,20}},
        teleport = {{6,5,12,3},{12,3,18,5},{18,5,19,12},{19,12,12,21},{12,21,5,12},{5,12,6,5},{10,8,14,8},{14,8,14,12},{14,12,10,12},{10,12,10,8}},
        farm = {{5,9,9,5},{9,5,14,5},{14,5,18,9},{18,9,18,14},{18,14,14,18},{14,18,9,18},{9,18,5,14},{5,14,5,9},{10,9,14,9},{14,9,14,14},{14,14,10,14},{10,14,10,9}},
        animations = {{10,4,14,4},{12,8,12,15},{6,10,12,12},{12,12,18,10},{12,15,7,21},{12,15,17,21}},
        troll = {{5,7,19,7},{19,7,18,16},{18,16,12,20},{12,20,6,16},{6,16,5,7},{8,11,10,11},{14,11,16,11},{9,15,15,15}},
        music = {{9,17,9,5},{9,5,18,3},{18,3,18,15},{6,17,9,17},{15,15,18,15}},
        mobile = {{7,3,17,3},{17,3,17,21},{17,21,7,21},{7,21,7,3},{10,18,14,18}},
        settings = {{5,7,19,7},{5,12,19,12},{5,17,19,17},{9,4,9,10},{15,9,15,15},{10,14,10,20}},
        server = {{5,4,19,4},{19,4,19,20},{19,20,5,20},{5,20,5,4},{5,12,19,12},{8,8,9,8},{8,16,9,16}},
    }
    for _, points in ipairs(paths[id] or paths.settings) do line(table.unpack(points)) end
    return icon
end

function UI:_button(parent, value, size)
    local button = self:_make("TextButton", {
        Size = size or UDim2.new(1, 0, 0, 34), Text = tostring(value or ""),
        BackgroundColor3 = PALETTE.control, BorderSizePixel = 0,
        TextColor3 = PALETTE.text, Font = Enum.Font.GothamMedium,
        TextSize = 12, AutoButtonColor = true,
    }, parent, { BackgroundColor3 = "control", TextColor3 = "text" })
    self.fonts[button] = 12
    self:_round(button, 10)
    return button
end

function UI:_input(parent, placeholder, size)
    local input = self:_make("TextBox", {
        Size = size or UDim2.new(1, 0, 0, 34), BackgroundColor3 = PALETTE.control,
        BorderSizePixel = 0, Text = "", PlaceholderText = placeholder or "",
        TextColor3 = PALETTE.text, PlaceholderColor3 = PALETTE.muted,
        Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, parent, { BackgroundColor3 = "control", TextColor3 = "text", PlaceholderColor3 = "muted" })
    self.fonts[input] = 12
    self:_round(input, 9)
    self:_make("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }, input)
    return input
end

function UI:_set(control, value)
    local supported, reason = self:_supported(control)
    if not supported then self:Notify(reason) return false end
    local ok, accepted, message = pcall(self.controller.Set, self.controller, control.id, value)
    if not ok then self:Notify(accepted) return false end
    if accepted == false then self:Notify(message or "Nao foi possivel aplicar esta opcao.") return false end
    self:Refresh()
    return true
end

function UI:_bounds(control)
    local minimum, maximum = control.min or 0, control.max or 100
    if self.controller.GetBounds then
        local ok, low, high = pcall(self.controller.GetBounds, self.controller, control.id)
        if ok and type(low) == "number" and type(high) == "number"
            and low == low and high == high and math.abs(low) < math.huge
            and math.abs(high) < math.huge and low <= high then
            minimum, maximum = low, high
        end
    end
    return minimum, maximum
end

function UI:_action(control, payload)
    local supported, reason = self:_supported(control)
    if not supported then self:Notify(reason) return end
    local ok, accepted, message = pcall(self.controller.Action, self.controller, control.action or control.id, payload)
    if not ok then self:Notify(accepted) return end
    if accepted == false then self:Notify(message or "Acao indisponivel nesta sessao.") end
    if not self.destroyed then self:Refresh() end
end

function UI:_tooltip(object, control, rendered)
    self:_connect(object.MouseEnter, function()
        if not self:_get("ui.tooltips", true) then return end
        local supported, reason = self:_supported(control)
        local message = control.description or control.tooltip
        if not supported then message = reason end
        if message and message ~= "" then
            self.tooltip.Text = tostring(message)
            self.tooltip.Visible = true
        end
    end, rendered)
    self:_connect(object.MouseLeave, function() self.tooltip.Visible = false end, rendered)
    self:_connect(object.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        local supported, reason = self:_supported(control)
        if not supported then self:Notify(reason) end
    end, rendered)
end

function UI:_row(parent, height)
    return self:_make("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, height or 40),
        ClipsDescendants = false,
    }, parent)
end

function UI:_control(parent, control)
    local kind = control.type or "toggle"
    if kind == "note" then
        local note = self:_label(parent, control.label or control.text, UDim2.new(1, 0, 0, 0), 11, "muted")
        note.AutomaticSize = Enum.AutomaticSize.Y
        note.TextYAlignment = Enum.TextYAlignment.Top
        return
    end
    if control.id == "skins.filter" then self:_skinFilter(parent, control) return end
    if kind == "stats" then self:_stats(parent, control) return end
    if kind == "players" then self:_players(parent, control) return end
    if kind == "catalog" then self:_catalog(parent, control) return end

    if kind == "button" then
        local button = self:_button(parent, control.label .. (control.keybind and "  [" .. control.keybind .. "]" or ""))
        self:_tooltip(button, control, true)
        self:_connect(button.Activated, function() self:_action(control) end, true)
        table.insert(self.updaters, function()
            local supported = self:_supported(control)
            button.TextColor3 = supported and PALETTE.text or PALETTE.disabled
        end)
        return
    end

    local row = self:_row(parent, kind == "slider" and 64 or 43)
    self:_tooltip(row, control, true)
    local label = self:_label(row, control.label, UDim2.new(kind == "slider" and 0.70 or 0.60, -5, 0, 36), 12)
    if control.keybind and kind == "toggle" then
        local key = self:_label(row, tostring(control.keybind), UDim2.fromOffset(25, 22), 10, "muted")
        key.AnchorPoint = Vector2.new(1, 0)
        key.Position = UDim2.new(1, -55, 0, 7)
        key.TextXAlignment = Enum.TextXAlignment.Center
        key.BackgroundColor3 = PALETTE.control
        key.BackgroundTransparency = 0.25
        self:_round(key, 7)
    end
    local function labelState()
        local supported = self:_supported(control)
        label.TextColor3 = supported and PALETTE.text or PALETTE.disabled
        if control.labels then
            label.Text = tostring(control.labels[self:_get(control.dynamicMax)] or control.label)
        end
    end
    table.insert(self.updaters, labelState)

    if kind == "toggle" then
        local switch = self:_button(row, "", UDim2.fromOffset(48, 25))
        switch.AnchorPoint = Vector2.new(1, 0)
        switch.Position = UDim2.new(1, 0, 0, 6)
        self:_round(switch, 20)
        local dot = self:_make("Frame", {
            Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(4, 3),
            BackgroundColor3 = Color3.fromRGB(218, 211, 214), BorderSizePixel = 0,
        }, switch)
        self:_round(dot, 20)
        local lastEnabled, transition
        table.insert(self.renderCleanups, function() if transition then transition:Cancel() end end)
        table.insert(self.updaters, function()
            local enabled = self:_get(control.id, control.default or false) == true
            local supported = self:_supported(control)
            switch.BackgroundColor3 = enabled and supported and self.accent or PALETTE.control
            switch.BackgroundTransparency = supported and 0 or 0.4
            local position = UDim2.fromOffset(enabled and 26 or 4, 3)
            if lastEnabled ~= nil and enabled ~= lastEnabled and self:_get("ui.animations", true) then
                if transition then transition:Cancel() end
                transition = TweenService:Create(dot, TweenInfo.new(0.12), { Position = position })
                transition:Play()
            elseif lastEnabled == nil or not self:_get("ui.animations", true) then
                dot.Position = position
            end
            lastEnabled = enabled
            dot.BackgroundTransparency = supported and 0 or 0.5
        end)
        self:_connect(switch.Activated, function()
            self:_set(control, not self:_get(control.id, control.default or false))
        end, true)
        return
    end

    if kind == "slider" then
        local valueLabel = self:_label(row, "", UDim2.new(0.30, 0, 0, 30), 11, "muted")
        valueLabel.Position = UDim2.fromScale(0.70, 0)
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        local hitbox = self:_button(row, "", UDim2.new(1, 0, 0, 25))
        hitbox.Position = UDim2.fromOffset(0, 32)
        hitbox.BackgroundTransparency = 1
        local rail = self:_make("Frame", {
            Position = UDim2.new(0, 5, 0.5, -3), Size = UDim2.new(1, -10, 0, 6),
            BackgroundColor3 = PALETTE.control, BorderSizePixel = 0,
        }, hitbox, { BackgroundColor3 = "control" })
        self:_round(rail, 6)
        local fill = self:_make("Frame", {
            Size = UDim2.fromScale(0, 1), BackgroundColor3 = self.accent, BorderSizePixel = 0,
        }, rail, { BackgroundColor3 = "accent" })
        self:_round(fill, 6)
        local thumb = self:_make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
            Size = UDim2.fromOffset(15, 15), BackgroundColor3 = PALETTE.text, BorderSizePixel = 0,
        }, rail, { BackgroundColor3 = "text" })
        self:_round(thumb, 20)
        local step = control.step or 1
        table.insert(self.updaters, function()
            local minimum, maximum = self:_bounds(control)
            local value = tonumber(self:_get(control.id, control.default or minimum)) or minimum
            value = math.clamp(value, minimum, maximum)
            local alpha = maximum > minimum and math.clamp((value - minimum) / (maximum - minimum), 0, 1) or 0
            fill.Size = UDim2.fromScale(alpha, 1)
            thumb.Position = UDim2.fromScale(alpha, 0.5)
            local formatted = step >= 1 and string.format("%.0f", value) or string.format("%.2f", value)
            valueLabel.Text = formatted .. tostring(control.suffix or control.unit or "")
            local supported = self:_supported(control)
            fill.BackgroundTransparency = supported and 0 or 0.65
            thumb.BackgroundTransparency = supported and 0 or 0.65
        end)
        local function move(input)
            if rail.AbsoluteSize.X <= 0 then return end
            local minimum, maximum = self:_bounds(control)
            local alpha = math.clamp((input.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
            local raw = minimum + alpha * (maximum - minimum)
            local value = step > 0 and minimum + math.floor((raw - minimum) / step + 0.5) * step or raw
            self:_set(control, math.clamp(value, minimum, maximum))
        end
        self:_connect(hitbox.InputBegan, function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local supported, reason = self:_supported(control)
            if not supported then self:Notify(reason) return end
            if self.activeSlider then return end
            self.activeSlider = { input = input, move = move }
            move(input)
        end, true)
        return
    end

    if kind == "select" then
        local select = self:_button(row, "", UDim2.new(0.40, -2, 0, 30))
        select.Position = UDim2.new(0.60, 2, 0, 3)
        select.TextTruncate = Enum.TextTruncate.AtEnd
        local options = control.options or {}
        local open = false
        local optionHeight = 0
        local dropdown = self:_make("ScrollingFrame", {
            Size = UDim2.fromOffset(160, optionHeight),
            BackgroundColor3 = PALETTE.control, BorderSizePixel = 0, ScrollBarThickness = 3,
            Visible = false, CanvasSize = UDim2.fromOffset(0, #options * 30),
            ZIndex = 61, Active = true,
        }, self.popupLayer, { BackgroundColor3 = "control" })
        self:_round(dropdown, 8)
        self:_make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, dropdown)
        local function optionValue(option)
            if type(option) == "table" then return option.value or option.id or option.label end
            return option
        end
        local function optionLabel(option)
            if type(option) == "table" then return option.label or option.title or option.value or option.id end
            return option
        end
        local choices, choiceConnections, signature = {}, {}, nil
        local function clearChoices()
            disconnectAll(choiceConnections)
            for _, choice in ipairs(choices) do choice:Destroy() end
            table.clear(choices)
        end
        table.insert(self.renderCleanups, clearChoices)
        table.insert(self.renderCleanups, function()
            if self.popup and self.popup.frame == dropdown then self:_closePopup() end
            dropdown:Destroy()
        end)
        local function refreshOptions()
            if self.controller.GetOptions then
                local ok, loaded = pcall(self.controller.GetOptions, self.controller, control.id)
                if ok and type(loaded) == "table" then options = loaded end
            end
            local parts = {}
            for _, option in ipairs(options) do
                table.insert(parts, tostring(optionValue(option)) .. "\0" .. tostring(optionLabel(option)))
            end
            local nextSignature = table.concat(parts, "\1")
            if nextSignature == signature then return end
            signature = nextSignature
            clearChoices()
            optionHeight = math.min(#options, 6) * 30
            dropdown.CanvasSize = UDim2.fromOffset(0, #options * 30)
            for _, option in ipairs(options) do
                local choice = optionValue(option)
                local choiceButton = self:_button(dropdown, optionLabel(option), UDim2.new(1, -4, 0, 30))
                table.insert(choices, choiceButton)
                table.insert(choiceConnections, choiceButton.Activated:Connect(function()
                    self:_closePopup()
                    self:_set(control, choice)
                    open, dropdown.Visible = false, false
                end))
            end
            if open then
                self:_openPopup(dropdown, select, math.max(160, select.AbsoluteSize.X / self.scale.Scale), optionHeight, false, function() open = false end)
                open = true
            end
        end
        refreshOptions()
        table.insert(self.dynamic, refreshOptions)
        table.insert(self.updaters, function()
            refreshOptions()
            local current = self:_get(control.id, control.default or optionValue(options[1]))
            local caption = tostring(current or "Select")
            for _, option in ipairs(options) do
                if optionValue(option) == current then caption = tostring(optionLabel(option)) break end
            end
            select.Text = caption .. "  ⌄"
            select.TextColor3 = self:_supported(control) and PALETTE.text or PALETTE.disabled
        end)
        self:_connect(select.Activated, function()
            local supported, reason = self:_supported(control)
            if not supported then self:Notify(reason) return end
            if open then self:_closePopup() return end
            refreshOptions()
            if #options == 0 then return end
            self:_openPopup(dropdown, select, math.max(160, select.AbsoluteSize.X / self.scale.Scale), optionHeight, false, function() open = false end)
            open = true
        end, true)
        return
    end

    if kind == "input" then
        label.Size = UDim2.new(0.42, -4, 0, 36)
        local input = self:_input(row, control.placeholder or "...", UDim2.new(0.58, 0, 0, 32))
        input.Position = UDim2.new(0.42, 0, 0, 2)
        table.insert(self.updaters, function()
            if not input:IsFocused() then input.Text = tostring(self:_get(control.id, control.default or "")) end
            input.TextEditable = self:_supported(control)
        end)
        self:_connect(input.FocusLost, function(enterPressed)
            self:_set(control, input.Text)
            if enterPressed and control.action then self:_action(control, { value = input.Text, id = input.Text }) end
        end, true)
        return
    end
    label.Text = tostring(control.label or control.id) .. " (" .. tostring(kind) .. ")"
end

function UI:_skinFilter(parent, control)
    local row = self:_row(parent, 38)
    for index, value in ipairs({ "All", "Knife", "Gun" }) do
        local chip = self:_button(row, value, UDim2.fromOffset(52, 29))
        chip.Position = UDim2.fromOffset((index - 1) * 57, 2)
        table.insert(self.updaters, function()
            chip.BackgroundColor3 = self:_get(control.id, "All") == value and self.accent or PALETTE.control
        end)
        self:_connect(chip.Activated, function() self:_set(control, value) end, true)
    end
    local count = self:_label(row, "", UDim2.new(1, -180, 1, 0), 10, "muted")
    count.Position, count.TextXAlignment = UDim2.fromOffset(180, 0), Enum.TextXAlignment.Right
    table.insert(self.dynamic, function()
        local ok, items = pcall(self.controller.GetCatalog, self.controller, "skins.catalog")
        count.Text = ok and type(items) == "table" and tostring(#items) .. " skins" or ""
    end)
end

function UI:_stats(parent, control)
    local frame = self:_make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1,
    }, parent)
    self:_make("UIGridLayout", {
        CellSize = UDim2.new(0.5, -4, 0, 67), CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder, FillDirectionMaxCells = 2,
    }, frame)
    local fields = control.items or control.fields
    if not fields then
        fields = {}
        for field in string.gmatch(control.label or "Session / Total / Status / Players", "[^/]+") do
            table.insert(fields, field:match("^%s*(.-)%s*$"))
        end
    end
    local rowCount = math.ceil(#fields / 2)
    frame.Size = UDim2.new(1, 0, 0, rowCount * 67 + math.max(0, rowCount - 1) * 6)
    local values = {}
    for index, field in ipairs(fields) do
        local key = type(field) == "table" and (field.key or field.id) or field
        local label = type(field) == "table" and (field.label or key) or field
        local cell = self:_make("Frame", {
            BackgroundColor3 = PALETTE.control, BorderSizePixel = 0, LayoutOrder = index,
        }, frame, { BackgroundColor3 = "control" })
        self:_round(cell, 8)
        local caption = self:_label(cell, label, UDim2.new(1, -16, 0, 22), 10, "muted")
        caption.Position = UDim2.fromOffset(8, 5)
        local value = self:_label(cell, "-", UDim2.new(1, -16, 0, 30), 18, "accent")
        value.Font = Enum.Font.GothamBold
        value.Position = UDim2.fromOffset(8, 28)
        values[key] = value
    end
    table.insert(self.dynamic, function()
        local ok, stats = pcall(self.controller.GetStats, self.controller)
        if not ok or type(stats) ~= "table" then return end
        local namespace = tostring(control.id):gsub("%.stats$", "")
        local source = type(stats[control.id]) == "table" and stats[control.id]
            or type(stats[namespace]) == "table" and stats[namespace] or stats
        local normalized = {}
        for key, value in pairs(source) do
            normalized[string.lower(tostring(key)):gsub("[^%w]", "")] = value
        end
        normalized.job = normalized.job or normalized.jobid
        for key, label in pairs(values) do
            local value = source[key]
            if value == nil then value = normalized[string.lower(tostring(key)):gsub("[^%w]", "")] end
            label.Text = value ~= nil and tostring(value) or "-"
        end
    end)
end

function UI:_players(parent, control)
    local container = self:_make("Frame", {
        BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
    }, parent)
    self:_make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, container)
    local search = self:_input(container, "Search player")
    search.LayoutOrder = 0
    local list = self:_make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 1,
    }, container)
    self:_make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, list)
    local rowConnections, rows, signature = {}, {}, ""
    local function clear()
        disconnectAll(rowConnections)
        for _, row in ipairs(rows) do row:Destroy() end
        table.clear(rows)
    end
    table.insert(self.renderCleanups, clear)
    local function update()
        local ok, players = pcall(self.controller.GetPlayers, self.controller)
        if not ok or type(players) ~= "table" then players = {} end
        local parts = { string.lower(search.Text) }
        for _, target in ipairs(players) do
            table.insert(parts, tostring(target.userId) .. tostring(target.role) .. tostring(target.displayName))
        end
        local nextSignature = table.concat(parts, "|")
        if nextSignature == signature then return end
        signature = nextSignature
        clear()
        local query = string.lower(search.Text)
        for _, target in ipairs(players) do
            if query == "" or contains(target.name, query) or contains(target.displayName, query) then
                local row = self:_row(list, 44)
                table.insert(rows, row)
                local name = self:_label(row, target.displayName or target.name, UDim2.new(1, -48, 0, 22), 12)
                name.TextTruncate = Enum.TextTruncate.AtEnd
                local detail = self:_label(row, "@" .. tostring(target.name or "") .. " | " .. tostring(target.role or "?"), UDim2.new(1, -48, 0, 20), 9, "muted")
                detail.Position = UDim2.fromOffset(0, 22)
                local action = self:_button(row, ">", UDim2.fromOffset(32, 32))
                action.Position = UDim2.new(1, -34, 0, 5)
                table.insert(rowConnections, action.Activated:Connect(function()
                    self:_action(control, { userId = target.userId, name = target.name })
                end))
            end
        end
        if #rows == 0 then
            local empty = self:_label(list, "No players", UDim2.new(1, 0, 0, 45), 11, "muted")
            empty.TextXAlignment = Enum.TextXAlignment.Center
            table.insert(rows, empty)
        end
    end
    self:_connect(search:GetPropertyChangedSignal("Text"), update, true)
    table.insert(self.dynamic, update)
end

function UI:_catalog(parent, control)
    if control.id == "music.songs" then
        local song = self:_button(parent, "", UDim2.new(1, 0, 0, 54))
        song.BackgroundTransparency = 1
        local badge = self:_button(song, "♪", UDim2.fromOffset(38, 38))
        badge.Position = UDim2.fromOffset(0, 8)
        self.styles[badge] = { BackgroundColor3 = "accent", TextColor3 = "text" }
        local title = self:_label(song, "Craudete", UDim2.new(1, -54, 0, 22), 12)
        title.Position = UDim2.fromOffset(50, 7)
        local artist = self:_label(song, "Brancoala", UDim2.new(1, -54, 0, 20), 10, "muted")
        artist.Position = UDim2.fromOffset(50, 29)
        local function play() self:_action(control, { id = "craudete" }) end
        self:_connect(song.Activated, play, true)
        self:_connect(badge.Activated, play, true)
        self:_tooltip(song, control, true)
        return
    end
    local input, filter
    if control.compact then
        local selector = self:_button(parent, "", UDim2.new(1, 0, 0, 38))
        local panel = self:_make("Frame", {
            Size = UDim2.fromOffset(430, 370), BackgroundColor3 = PALETTE.card, BorderSizePixel = 0, Visible = false,
        }, self.popupLayer, { BackgroundColor3 = "card" })
        self:_round(panel, 14)
        self:_stroke(panel)
        local title = self:_label(panel, control.label, UDim2.fromOffset(92, 34), 12)
        title.Position = UDim2.fromOffset(10, 3)
        filter = self:_input(panel, "Search", UDim2.new(1, -144, 0, 30))
        filter.Position = UDim2.fromOffset(104, 5)
        local close = self:_button(panel, "×", UDim2.fromOffset(27, 27))
        close.Position = UDim2.new(1, -31, 0, 6)
        self:_connect(close.Activated, function() self:_closePopup() end, true)
        local scroller = self:_make("ScrollingFrame", {
            Position = UDim2.fromOffset(10, 43), Size = UDim2.new(1, -20, 1, -53),
            BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
            CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, panel)
        self:_connect(selector.Activated, function()
            if self.popup and self.popup.frame == panel then self:_closePopup()
            else self:_openPopup(panel, selector, 430, 370, true) end
        end, true)
        table.insert(self.renderCleanups, function()
            if self.popup and self.popup.frame == panel then self:_closePopup() end
            panel:Destroy()
        end)
        table.insert(self.updaters, function()
            local current = tostring(self:_get(control.id, ""))
            local label = current == "" and "Default" or current
            if self.controller.GetCatalog then
                local ok, items = pcall(self.controller.GetCatalog, self.controller, control.id)
                if ok then
                    for _, item in ipairs(items or {}) do
                        if tostring(item.id) == current then label = item.name or label break end
                    end
                end
            end
            selector.Text = tostring(control.label) .. "   /   " .. label .. "   >"
        end)
        parent = scroller
    end
    if control.id == "skins.catalog" then
        local row = self:_row(parent, 42)
        filter = self:_input(row, "Search skins", UDim2.new(1, 0, 0, 34))
    elseif not control.compact and control.id ~= "animations.emoteCatalog" then
        local row = self:_row(parent, 82)
        local caption = self:_label(row, control.label or "Asset catalog", UDim2.new(1, 0, 0, 24), 11, "muted")
        caption.TextYAlignment = Enum.TextYAlignment.Top
        input = self:_input(row, control.placeholder or "Asset ID / username", UDim2.new(0.70, -5, 0, 34))
        input.Position = UDim2.fromOffset(0, 32)
        local apply = self:_button(row, control.buttonLabel or "Apply", UDim2.new(0.30, 0, 0, 34))
        apply.Position = UDim2.new(0.70, 0, 0, 32)
        self:_connect(apply.Activated, function()
            self:_action(control, { id = input.Text, value = input.Text })
        end, true)
        self:_tooltip(apply, control, true)
    end
    local grid = self:_make("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
    }, parent)
    local gridColumns = control.compact and 4 or (control.id:sub(1, 11) == "animations." or control.id:sub(1, 6) == "skins.") and 3 or 2
    self:_make("UIGridLayout", {
        CellSize = UDim2.new(1 / gridColumns, -4, 0, 108), CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder, FillDirectionMaxCells = gridColumns,
    }, grid)
    local entries, entryConnections, signature = {}, {}, ""
    local function clearEntries()
        disconnectAll(entryConnections)
        for _, entry in ipairs(entries) do entry:Destroy() end
        table.clear(entries)
    end
    table.insert(self.renderCleanups, clearEntries)
    local function updateCatalog()
        local items = control.items or {}
        if self.controller.GetCatalog then
            local ok, loaded = pcall(self.controller.GetCatalog, self.controller, control.id)
            if ok and type(loaded) == "table" then items = loaded end
        end
        if filter and filter.Text ~= "" then
            local query, filtered = string.lower(filter.Text), {}
            for _, item in ipairs(items) do
                if type(item) == "table" and (contains(item.name, query) or contains(item.id, query)) then
                    table.insert(filtered, item)
                end
            end
            items = filtered
        end
        local parts = { filter and filter.Text or "" }
        for _, item in ipairs(items) do
            local data = type(item) == "table" and item or { name = item }
            table.insert(parts, tostring(data.id or "") .. ":" .. tostring(data.name or data.label or "")
                .. ":" .. tostring(data.thumbnail or "") .. ":" .. tostring(data.rarity or ""))
        end
        local nextSignature = table.concat(parts, "|")
        if signature == nextSignature then return end
        signature = nextSignature
        clearEntries()
        local rowCount = math.ceil(#items / gridColumns)
        grid.Size = UDim2.new(1, 0, 0, rowCount * 108 + math.max(0, rowCount - 1) * 6)
        for index, item in ipairs(items) do
            local data = type(item) == "table" and item or { name = item }
            local card = self:_button(grid, "", UDim2.fromOffset(100, 108))
            table.insert(entries, card)
            card.LayoutOrder = index
            local image = data.thumbnail
            local assetId = tonumber(data.assetId or (data.kind ~= "Avatar" and data.id))
            if type(image) ~= "string" or not (image:match("^rbxthumb://") or image:match("^rbxassetid://%d+$")) then image = nil end
            if not image and assetId then image = "rbxthumb://type=Asset&id=" .. tostring(assetId) .. "&w=150&h=150" end
            if image then
                self:_make("ImageLabel", {
                    BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 4),
                    Size = UDim2.new(1, -16, 0, 65),
                    Image = image,
                }, card)
            else
                local icon = self:_label(card, string.sub(tostring(data.name or "ID"), 1, 1), UDim2.new(1, 0, 0, 64), 28, "accent")
                icon.TextXAlignment = Enum.TextXAlignment.Center
                icon.TextTransparency = 0.25
            end
            local caption = self:_label(card, data.name or data.label or data.id, UDim2.new(1, -12, 0, 24), 10)
            caption.Position = UDim2.fromOffset(6, 65)
            caption.TextTruncate = Enum.TextTruncate.AtEnd
            local detail = self:_label(card, data.rarity or data.kind or "Reference", UDim2.new(1, -12, 0, 17), 8, "muted")
            detail.Position = UDim2.fromOffset(6, 90)
            for badgeIndex, badge in ipairs(data.badges or {}) do
                if badge == "FX" or badge == "Evo" then
                    local tag = self:_label(card, badge, UDim2.fromOffset(30, 16), 8)
                    tag.Position = UDim2.new(1, -34, 0, 4 + (badgeIndex - 1) * 18)
                    tag.TextXAlignment = Enum.TextXAlignment.Center
                    tag.BackgroundTransparency = 0.05
                    tag.BackgroundColor3 = badge == "FX" and Color3.fromRGB(171, 124, 18) or Color3.fromRGB(47, 126, 132)
                    self:_round(tag, 4)
                end
            end
            table.insert(entryConnections, card.Activated:Connect(function()
                local value = tostring(data.id or data.name or "")
                if input then input.Text = value end
                self:_action(control, { id = value, value = value, item = data, index = index })
                if control.compact then self:_closePopup() end
            end))
        end
    end
    if filter then self:_connect(filter:GetPropertyChangedSignal("Text"), updateCatalog, true) end
    table.insert(self.dynamic, updateCatalog)
end

function UI:_mobileTrigger(definition)
    local control = { id = definition.target, capability = definition.target }
    if definition.toggle then
        self:_set(control, not self:_get(definition.target, false))
        return
    end
    local payload
    if definition.role then
        local ok, players = pcall(self.controller.GetPlayers, self.controller)
        if ok and type(players) == "table" then
            for _, target in ipairs(players) do
                if string.lower(tostring(target.role)) == string.lower(definition.role) then
                    payload = { userId = target.userId, name = target.name, role = definition.role }
                    break
                end
            end
        end
        if not payload then self:Notify("Papel " .. definition.role .. " nao confirmado nesta sessao.") return end
    end
    self:_action(control, payload)
end

function UI:ResetMobilePositions()
    self.mobilePositions = {}
    self:_refreshMobile()
end

function UI:UnlockMobileButtons()
    self.mobileLocked = {}
    table.clear(self.pendingMobile)
end

function UI:_refreshMobile()
    if not self.mobileButtons then return end
    local available = self.host.AbsoluteSize
    for index, definition in ipairs(MOBILE) do
        local button = self.mobileButtons[definition.id]
        if not button then
            button = self:_button(self.host, definition.label, UDim2.fromOffset(62, 62))
            button.AnchorPoint = Vector2.new(0.5, 0.5)
            button.BackgroundTransparency = 0.18
            button.ZIndex = 10
            self:_round(button, 35)
            self:_stroke(button)
            self.mobileButtons[definition.id] = button
            self:_connect(button.InputBegan, function(input)
                if self.activeMobile then return end
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    self.activeMobile = {
                        input = input, start = input.Position, position = button.Position,
                        definition = definition, button = button, started = os.clock(), dragged = false,
                    }
                end
            end)
        end
        local supported = self:_supported({ id = definition.id, capability = definition.target })
        button.Visible = self:_get(definition.id, false) == true and supported
        local size = 62 * math.clamp((tonumber(self:_get(definition.id .. "Size", 100)) or 100) / 100, 0.5, 2)
        button.Size = UDim2.fromOffset(size, size)
        local position = self.mobilePositions[definition.id]
        if not position then
            local column, row = (index - 1) % 3, math.floor((index - 1) / 3)
            position = Vector2.new(available.X * (0.74 + column * 0.095), available.Y * (0.78 - row * 0.17))
        end
        button.Position = UDim2.fromOffset(
            math.clamp(position.X, size / 2, math.max(size / 2, available.X - size / 2)),
            math.clamp(position.Y, size / 2, math.max(size / 2, available.Y - size / 2))
        )
        button.TextColor3 = definition.toggle and self:_get(definition.target, false) and self.accent or PALETTE.text
    end
end

function UI:_weaponSlots(parent)
    local row = self:_row(parent, 88)
    for index, kind in ipairs({ "Knife", "Gun" }) do
        local slot = self:_button(row, "", UDim2.new(0.5, -4, 0, 80))
        slot.Position = UDim2.new((index - 1) * 0.5, index == 1 and 0 or 4, 0, 3)
        self:_stroke(slot)
        local image = self:_make("ImageLabel", { Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(4, 9),
            BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit }, slot)
        local title = self:_label(slot, kind, UDim2.new(1, -94, 0, 17), 9, "muted")
        title.Position = UDim2.fromOffset(67, 10)
        local name = self:_label(slot, "None", UDim2.new(1, -94, 0, 24), 11)
        name.Position, name.TextTruncate = UDim2.fromOffset(67, 25), Enum.TextTruncate.AtEnd
        local rarity = self:_label(slot, "", UDim2.new(1, -94, 0, 17), 8, "muted")
        rarity.Position = UDim2.fromOffset(67, 51)
        local clear = self:_button(slot, "×", UDim2.fromOffset(22, 24))
        clear.Position, clear.BackgroundTransparency = UDim2.new(1, -26, 0.5, -12), 1
        self:_connect(clear.Activated, function() self:_action({ id = "skins.reset" }, { kind = kind }) end, true)
        self:_connect(slot.Activated, function()
            self:_set({ id = "skins.filter" }, kind)
            for _, update in ipairs(self.dynamic) do update() end
            if self.skinCatalogCard and self.skinCatalogCard.Parent then
                local offset = (self.skinCatalogCard.AbsolutePosition.Y - self.body.AbsolutePosition.Y) / self.scale.Scale
                self.body.CanvasPosition = Vector2.new(0, math.max(0, self.body.CanvasPosition.Y + offset))
            end
        end, true)
        local function update()
            local current = tostring(self:_get(kind == "Knife" and "skins.knife" or "skins.gun", ""))
            local ok, items = pcall(self.controller.GetCatalog, self.controller, "skins.selection")
            local selected
            if ok and type(items) == "table" then
                for _, item in ipairs(items) do
                    if tostring(item.id) == current or string.lower(tostring(item.name)) == string.lower(current) then selected = item break end
                end
            end
            name.Text, rarity.Text, image.Image = selected and selected.name or current ~= "" and current or "None",
                selected and selected.rarity or "", selected and selected.thumbnail or ""
            clear.Visible = current ~= ""
        end
        table.insert(self.dynamic, update)
        table.insert(self.updaters, update)
    end
    return row
end

function UI:_roleFilters(parent, controls)
    local frame = self:_row(parent, 116)
    local title = self:_label(frame, "Show Roles", UDim2.new(1, 0, 0, 20), 10, "muted")
    title.Position = UDim2.fromOffset(0, 0)
    local roles = {
        { "esp.murderer", Color3.fromRGB(214, 73, 78) },
        { "esp.sheriff", Color3.fromRGB(87, 153, 210) },
        { "esp.hero", Color3.fromRGB(211, 179, 76) },
        { "esp.innocent", Color3.fromRGB(99, 180, 80) },
        { "esp.noRole", PALETTE.muted },
    }
    for index, definition in ipairs(roles) do
        local control
        for _, candidate in ipairs(controls) do if candidate.id == definition[1] then control = candidate break end end
        if control then
            local wide = index == 5
            local chip = self:_button(frame, control.label, UDim2.new(wide and 1 or 0.5, wide and 0 or -3, 0, 27))
            chip.Position = UDim2.new((index % 2 == 0 and not wide) and 0.5 or 0, index % 2 == 0 and 3 or 0,
                0, 23 + math.floor((index - 1) / 2) * 30)
            local outline = self:_stroke(chip)
            table.insert(self.updaters, function()
                local enabled = self:_get(control.id, true)
                chip.BackgroundColor3 = definition[2]:Lerp(PALETTE.control, 0.77)
                chip.BackgroundTransparency = enabled and 0 or 0.7
                chip.TextColor3 = enabled and PALETTE.text or PALETTE.disabled
                outline.Color, outline.Transparency = definition[2], enabled and 0.3 or 0.8
            end)
            self:_connect(chip.Activated, function() self:_set(control, not self:_get(control.id, true)) end, true)
            self:_tooltip(chip, control, true)
        end
    end
    return frame
end

function UI:_musicPlayer(parent, controls)
    local row = self:_row(parent, 66)
    row.LayoutOrder = 1
    local badge = self:_button(row, "♪", UDim2.fromOffset(52, 52))
    badge.Position = UDim2.fromOffset(0, 5)
    self.styles[badge] = { BackgroundColor3 = "accent", TextColor3 = "text" }
    local title = self:_label(row, "Craudete", UDim2.new(1, -242, 0, 26), 14)
    title.Position = UDim2.fromOffset(66, 9)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    local artist = self:_label(row, "Brancoala", UDim2.new(1, -242, 0, 20), 10, "muted")
    artist.Position = UDim2.fromOffset(66, 35)
    local definitions = {
        { "music.shuffle", "⇄", 0 }, { "music.previous", "|‹", 30 },
        { "music.play", "▷", 60 }, { "music.next", "›|", 106 }, { "music.repeat", "↻", 136 },
    }
    local embedded = {}
    for _, definition in ipairs(definitions) do
        local id, glyph, offset = table.unpack(definition)
        local control
        for _, candidate in ipairs(controls) do if candidate.id == id then control = candidate break end end
        if control then
            embedded[id] = true
            local play = id == "music.play"
            local button = self:_button(row, glyph, UDim2.fromOffset(play and 40 or 27, play and 40 or 30))
            button.Position = UDim2.new(1, -164 + offset, 0, play and 12 or 17)
            button.BackgroundTransparency = play and 0 or 1
            if play then self.styles[button] = { BackgroundColor3 = "accent", TextColor3 = "text" } end
            self:_connect(button.Activated, function()
                if control.type == "toggle" then self:_set(control, not self:_get(id, false))
                else self:_action(control) end
            end, true)
            self:_tooltip(button, control, true)
            table.insert(self.dynamic, function()
                if control.type == "toggle" then button.TextColor3 = self:_get(id, false) and self.accent or PALETTE.muted end
                if play then
                    local ok, stats = pcall(self.controller.GetStats, self.controller)
                    if ok and type(stats) == "table" and stats.music then button.Text = stats.music.playing and "Ⅱ" or stats.music.loading and "…" or "▷" end
                end
            end)
        end
    end
    self:_connect(badge.Activated, function() self:_action({ id = "music.play" }) end, true)
    return embedded
end

function UI:_card(parent, section, context, query)
    local card = self:_make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = PALETTE.card, BorderSizePixel = 0,
    }, parent, { BackgroundColor3 = "card" })
    if section.id == "skins.catalogSection" then self.skinCatalogCard = card end
    self:_round(card, 11)
    self:_stroke(card)
    self:_make("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder }, card)
    local key = context .. ":" .. tostring(section.id or section.title)
    if self.collapsed[key] == nil and section.collapsed then self.collapsed[key] = true end
    local heading = self:_button(card, "", UDim2.new(1, 0, 0, 42))
    heading.BackgroundTransparency = 1
    heading.LayoutOrder = 0
    local iconId = tostring(section.id):match("^(%w+)")
    if iconId == "visuals" or iconId == "skins" then iconId = "visuals" end
    if iconId == "boxes" or iconId == "rolefarm" or iconId == "webhook" or iconId == "trade" then iconId = "farm" end
    local mark = self:_navIcon(heading, iconId)
    mark.Position, mark.Size = UDim2.fromOffset(9, 7), UDim2.fromOffset(28, 28)
    mark.BackgroundColor3, mark.BackgroundTransparency = self.accent:Lerp(PALETTE.card, 0.84), 0.05
    for _, line in ipairs(mark:GetChildren()) do
        if line:IsA("Frame") then line.BackgroundColor3 = self.accent; self.styles[line] = { BackgroundColor3 = "accent" } end
    end
    local caption = self:_label(heading, section.title or section.id or "Options", UDim2.new(1, -68, 1, 0), 12)
    caption.Position = UDim2.fromOffset(40, 0)
    caption.Font = Enum.Font.GothamBold
    if query ~= "" then
        caption.Text = tostring(section.title or section.id) .. " / " .. context
        self.fonts[caption] = 10
    end
    local arrow = self:_label(heading, self.collapsed[key] and ">" or "v", UDim2.fromOffset(15, 30), 12, "muted")
    arrow.Position = UDim2.new(1, -25, 0, 6)
    local body = self:_make("Frame", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1, LayoutOrder = 1, Visible = not self.collapsed[key],
    }, card)
    self:_make("UIPadding", {
        PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
    }, body)
    self:_make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, body)
    local sectionWide = contains(section.title, query)
    local embedded = section.id == "music.player" and query == "" and self:_musicPlayer(body, section.controls) or {}
    local order = next(embedded) and 1 or 0
    for _, control in ipairs(section.controls or {}) do
        if section.id == "skins.main" and query == "" and control.id == "skins.knife" then
            order += 1
            self:_weaponSlots(body).LayoutOrder = order
            embedded["skins.knife"], embedded["skins.gun"] = true, true
        end
        local roleFilter = section.id == "visuals.esp.main" and query == "" and (control.id == "esp.murderer"
            or control.id == "esp.sheriff" or control.id == "esp.hero" or control.id == "esp.innocent" or control.id == "esp.noRole")
        if roleFilter then
            embedded[control.id] = true
            if control.id == "esp.murderer" then
                order += 1
                self:_roleFilters(body, section.controls).LayoutOrder = order
            end
        end
        if not embedded[control.id] and (query == "" or sectionWide or contains(control.label, query) or contains(control.id, query)) then
            order += 1
            local before = body:GetChildren()
            self:_control(body, control)
            local previous = {}
            for _, child in ipairs(before) do previous[child] = true end
            for _, child in ipairs(body:GetChildren()) do
                if child:IsA("GuiObject") and not previous[child] then child.LayoutOrder = order end
            end
        end
    end
    self:_connect(heading.Activated, function()
        if #(section.controls or {}) == 0 then return end
        self.collapsed[key] = not self.collapsed[key]
        body.Visible = not self.collapsed[key]
        arrow.Text = body.Visible and "v" or ">"
    end, true)
    return card
end

function UI:_render()
    if self.destroyed then return end
    self:_closePopup()
    self.activeSlider = nil
    self.tooltip.Visible = false
    disconnectAll(self.renderConnections)
    for _, cleanup in ipairs(self.renderCleanups) do cleanup() end
    table.clear(self.renderCleanups)
    self.updaters, self.dynamic = {}, {}
    self.body:ClearAllChildren()
    self.subtabs:ClearAllChildren()
    self:_round(self.subtabs, 20)
    self:_stroke(self.subtabs)
    local query = string.lower(self.search.Text)
    local selected
    for _, page in ipairs(self.catalog) do
        if page.id == self.selectedPage then selected = page break end
    end
    selected = selected or self.catalog[1]
    if not selected then return end
    self.title.Text = query == "" and selected.title or "Search"
    self.subtitle.Text = query == "" and (selected.subtitle or "") or "Matching controls across all tabs"
    local tabs = getTabs(selected)
    local tabId = self.selectedTabs[selected.id] or (tabs[1] and tabs[1].id)
    local hasTabs = #tabs > 1 and query == ""
    local bodyTop = hasTabs and 128 or 78
    self.body.Position, self.body.Size = UDim2.fromOffset(0, bodyTop), UDim2.new(1, 0, 1, -bodyTop - 18)
    self.subtabs.Visible = hasTabs
    self:_make("UIPadding", { PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3) }, self.subtabs)
    self:_make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 0),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, self.subtabs)
    if hasTabs then
        local stripWidth = 8
        for _, tab in ipairs(tabs) do stripWidth += math.max(60, #tostring(tab.title) * 6 + 40) end
        self.subtabs.Size = UDim2.fromOffset(stripWidth, 38)
        for index, tab in ipairs(tabs) do
            local tabButton = self:_button(self.subtabs, tab.title, UDim2.new(0, math.max(60, #tostring(tab.title) * 6 + 40), 1, 0))
            tabButton.LayoutOrder = index
            tabButton.TextSize = 11
            self.fonts[tabButton] = 11
            tabButton.BackgroundTransparency = tab.id == tabId and 0 or 1
            self:_connect(tabButton.Activated, function()
                self.selectedTabs[selected.id] = tab.id
                self:_render()
            end, true)
        end
    end
    local columns = {}
    local singleColumn = query == "" and (selected.id == "animations" or selected.id == "music"
        or (selected.id == "visuals" and tabId == "skins"))
    self.forceSingleColumn = singleColumn
    self.columns, self.cardRecords, self.columnCount = columns, {}, nil
    for index = 1, 2 do
        local column = self:_make("Frame", {
            Size = UDim2.new(0.5, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, self.body)
        self:_make("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder }, column)
        columns[index] = column
    end
    local count = 0
    for _, page in ipairs(query == "" and { selected } or self.catalog) do
        for _, tab in ipairs(getTabs(page)) do
            if query ~= "" or tab.id == tabId then
                for _, section in ipairs(tab.sections or {}) do
                    if sectionMatches(section, query) then
                        count += 1
                        local column = section.column or ((count - 1) % 2 + 1)
                        local preferred = column == 2 and 2 or 1
                        local card = self:_card(columns[preferred], section, page.title .. "/" .. tostring(tab.title or ""), query)
                        table.insert(self.cardRecords, { card = card, column = preferred, order = count })
                    end
                end
            end
        end
    end
    if count == 0 then self:_label(columns[1], "No matching controls", UDim2.new(1, 0, 0, 50), 12, "muted") end
    self.body.CanvasPosition = Vector2.zero
    for pageId, nav in pairs(self.navigation) do
        nav.BackgroundTransparency = pageId == selected.id and 0 or 1
        nav.TextColor3 = pageId == selected.id and self.accent or PALETTE.text
    end
    self:Refresh()
    for _, update in ipairs(self.dynamic) do update() end
end

function UI:_fit()
    if self.destroyed then return end
    self:_applyLayout()
    local size = self.host.AbsoluteSize
    if size.X <= 0 or size.Y <= 0 then return end
    local scale = math.clamp(tonumber(self:_get("ui.scale", 0.8)) or 0.8, 0.2, 2)
    if self:_get("ui.fit", true) then
        scale = math.min(scale, math.max(0.1, (size.X - 20) / self.width), math.max(0.1, (size.Y - 20) / self.height))
    end
    self.scale.Scale = scale
    local half = Vector2.new(self.width * scale / 2, self.height * scale / 2)
    local position = self.window.Position
    local center = Vector2.new(position.X.Scale * size.X + position.X.Offset, position.Y.Scale * size.Y + position.Y.Offset)
    self.window.Position = UDim2.fromOffset(
        math.clamp(center.X, math.min(half.X, size.X / 2), math.max(size.X - half.X, size.X / 2)),
        math.clamp(center.Y, math.min(half.Y, size.Y / 2), math.max(size.Y - half.Y, size.Y / 2))
    )
end

function UI:Refresh()
    if self.destroyed then return end
    local color = self:_get("ui.accentColor", "#EF3340")
    if typeof(color) == "Color3" then
        self.accent = color
    elseif type(color) == "string" and color:match("^#?%x%x%x%x%x%x$") then
        local hex = color:gsub("#", "")
        self.accent = Color3.fromHex(hex)
    end
    local opacity = math.clamp(tonumber(self:_get("ui.opacity", 1)) or 1, 0.2, 1)
    local radius = math.clamp(tonumber(self:_get("ui.radius", 1)) or 1, 0, 3)
    local textScale = math.clamp(tonumber(self:_get("ui.textScale", 1)) or 1, 0.7, 1.7)
    local panelColor = self:_get("ui.panelColor", "#151111")
    if type(panelColor) == "string" and panelColor:match("^#?%x%x%x%x%x%x$") then
        local hex = panelColor:gsub("#", "")
        panelColor = Color3.fromHex(hex)
    elseif typeof(panelColor) ~= "Color3" then
        panelColor = PALETTE.background
    end
    for object, properties in pairs(self.styles) do
        if object.Parent then
            for property, role in pairs(properties) do
                object[property] = role == "accent" and self.accent or role == "background" and panelColor or PALETTE[role]
            end
        else self.styles[object] = nil end
    end
    for object, base in pairs(self.corners) do
        if object.Parent then object.CornerRadius = UDim.new(0, base * radius) else self.corners[object] = nil end
    end
    local fontName = tostring(self:_get("ui.font", "Ubuntu"))
    local fontOk, font = pcall(function() return Enum.Font[fontName] end)
    for object, base in pairs(self.fonts) do
        if object.Parent then
            object.TextSize = math.max(8, base * textScale)
            if fontOk and font then
                self.fontWeights[object] = self.fontWeights[object] or object.FontFace.Weight
                object.Font = font
                local face = object.FontFace
                object.FontFace = Font.new(face.Family, self.fontWeights[object], face.Style)
            end
        else self.fonts[object] = nil end
    end
    self.window.BackgroundTransparency = 1 - opacity
    self.sidebar.BackgroundTransparency = 1 - opacity
    if self.backgroundGradient then
        local intensity = math.clamp(tonumber(self:_get("ui.backgroundIntensity", 1.5)) or 1.5, 0, 1.5) / 1.5
        self.backgroundLayer.Visible = self:_get("ui.background", "Halloween") == "Halloween" and intensity > 0
        self.backgroundGradient.Color = ColorSequence.new(self.accent, Color3.fromRGB(0, 0, 0))
        self.backgroundGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1 - intensity * 0.18),
            NumberSequenceKeypoint.new(1, 1 - intensity * 0.06),
        })
        self.web.Visible = self:_get("ui.halloween", true) == true
        for _, line in ipairs(self.webLines) do
            line.BackgroundColor3 = self.accent:Lerp(PALETTE.muted, 0.65)
            line.BackgroundTransparency = 0.74
        end
    end
    self.hud.Visible = self:_get("ui.showFps", true) == true and self:_get("mobile.showPing", true) == true
    self.launcher.Visible = self:_get("ui.launcher", true) == true or not self.window.Visible
    local compact = self:_get("ui.compactSidebar", false)
    if self.compactSidebar ~= compact then
        self.sidebarWidth, self.compactSidebar = compact and 170 or 204, compact
    end
    for pageId, nav in pairs(self.navigation) do
        nav.TextColor3 = PALETTE.text
        local title = nav:FindFirstChild("Title")
        if title then title.TextColor3 = nav.TextColor3 end
        local icon = nav:FindFirstChild("Icon")
        if icon then
            icon.BackgroundColor3 = self.accent
            icon.BackgroundTransparency = pageId == self.selectedPage and 0 or 1
            for _, line in ipairs(icon:GetChildren()) do
                if line:IsA("Frame") then line.BackgroundColor3 = pageId == self.selectedPage and PALETTE.text or PALETTE.muted end
            end
        end
    end
    for _, update in ipairs(self.updaters) do update() end
    self:_refreshMobile()
    if self:_get("ui.blur", self:_get("ui.blurBehind", false)) and self.window.Visible then
        if not self.blur then self.blur = self:_make("BlurEffect", { Name = "NexusHubBlur", Size = 12 }, Lighting) end
    elseif self.blur then
        self.blur:Destroy()
        self.blur = nil
    end
    self:_fit()
end

function UI:Notify(message)
    if self.destroyed then return end
    self.noticeGeneration += 1
    local generation = self.noticeGeneration
    self.notice.Text = tostring(message)
    self.notice.Visible = true
    task.delay(7, function()
        if not self.destroyed and self.noticeGeneration == generation then self.notice.Visible = false end
    end)
end

function UI:SetVisible(visible)
    if self.destroyed then return end
    self.window.Visible = visible == true
    self:_closePopup()
    if not self.window.Visible then self.sidebarDragging, self.activeSlider = nil, nil end
    self.tooltip.Visible = false
    self:Refresh()
end

function UI:Destroy()
    if self.destroyed then return end
    self.destroyed = true
    self:_closePopup()
    disconnectAll(self.connections)
    disconnectAll(self.renderConnections)
    for _, cleanup in ipairs(self.renderCleanups) do cleanup() end
    table.clear(self.renderCleanups)
    if self.blur then self.blur:Destroy() end
    if self.gui then self.gui:Destroy() end
    self.activeSlider = nil
    self.activeMobile = nil
    self.sidebarDragging = nil
    table.clear(self.updaters)
    table.clear(self.dynamic)
end

function UI.new(catalog, controller)
    local self = setmetatable({
        catalog = catalog, controller = controller, width = 730, height = 525, sidebarWidth = 204,
        connections = {}, renderConnections = {}, renderCleanups = {},
        updaters = {}, dynamic = {}, navigation = {}, collapsed = {}, selectedTabs = {},
        styles = setmetatable({}, { __mode = "k" }), corners = setmetatable({}, { __mode = "k" }),
        fonts = setmetatable({}, { __mode = "k" }), fontWeights = setmetatable({}, { __mode = "k" }), accent = PALETTE.accent,
        selectedPage = catalog[1] and catalog[1].id, destroyed = false, noticeGeneration = 0,
        mobileButtons = {}, mobilePositions = {}, mobileLocked = {}, mobileLastTap = {}, pendingMobile = {},
    }, UI)
    local player = Players.LocalPlayer
    assert(player, "Nexus Hub UI deve executar no cliente Roblox.")
    self.gui = self:_make("ScreenGui", {
        Name = "NexusHub", ResetOnSpawn = false, DisplayOrder = 80,
        ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    }, player:WaitForChild("PlayerGui"))
    self.host = self:_make("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
    }, self.gui)
    self.window = self:_make("Frame", {
        Size = UDim2.fromOffset(self.width, self.height), Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = PALETTE.background,
        BorderSizePixel = 0, ClipsDescendants = true,
    }, self.host, { BackgroundColor3 = "background" })
    self:_round(self.window, 12)
    self:_stroke(self.window)
    self.scale = self:_make("UIScale", { Scale = 0.8 }, self.window)
    self.backgroundLayer = self:_make("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0, Active = false, Selectable = false,
    }, self.window)
    self.backgroundGradient = self:_make("UIGradient", {
        Color = ColorSequence.new(PALETTE.accent, Color3.fromRGB(0, 0, 0)), Rotation = 35,
        Transparency = NumberSequence.new(0.9),
    }, self.backgroundLayer)
    self.sidebar = self:_make("Frame", {
        Size = UDim2.new(0, 204, 1, 0), BackgroundColor3 = PALETTE.sidebar, BorderSizePixel = 0,
    }, self.window, { BackgroundColor3 = "sidebar" })
    local logo = self:_label(self.sidebar, "N", UDim2.fromOffset(34, 42), 26, "accent")
    logo.Position = UDim2.fromOffset(18, 10)
    logo.Font = Enum.Font.GothamBlack
    local brand = self:_label(self.sidebar, "Nexus Hub", UDim2.new(1, -65, 0, 28), 16)
    brand.Position = UDim2.fromOffset(60, 13)
    brand.Font = Enum.Font.GothamBold
    local gameName = self:_label(self.sidebar, "Murder Mystery 2", UDim2.new(1, -65, 0, 18), 9, "muted")
    gameName.Position = UDim2.fromOffset(60, 39)
    self.search = self:_input(self.sidebar, "Search", UDim2.new(1, -28, 0, 36))
    self.search.Position = UDim2.fromOffset(14, 76)
    local nav = self:_make("ScrollingFrame", {
        Position = UDim2.fromOffset(12, 128), Size = UDim2.new(1, -24, 1, -178),
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 2, BorderSizePixel = 0, BackgroundTransparency = 1,
    }, self.sidebar)
    self:_make("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, nav)
    for index, page in ipairs(catalog) do
        local navButton = self:_button(nav, "", UDim2.new(1, -2, 0, 42))
        navButton.TextXAlignment = Enum.TextXAlignment.Left
        navButton.LayoutOrder = index
        navButton.BackgroundTransparency = 1
        local label = self:_label(navButton, page.title, UDim2.new(1, -42, 1, 0), 12)
        label.Font = Enum.Font.GothamBold
        label.Name, label.Position = "Title", UDim2.fromOffset(38, 0)
        self:_navIcon(navButton, page.id)
        self.navigation[page.id] = navButton
        self:_connect(navButton.Activated, function()
            self.selectedPage = page.id
            if self.search.Text ~= "" then self.search.Text = "" else self:_render() end
        end)
    end
    local version = self:_label(self.sidebar, "NEXUS  /  MM2", UDim2.new(1, -28, 0, 26), 10, "muted")
    version.Position = UDim2.new(0, 14, 1, -35)
    self.content = self:_make("Frame", {
        Position = UDim2.fromOffset(218, 0), Size = UDim2.new(1, -232, 1, 0), BackgroundTransparency = 1,
    }, self.window)
    local header = self:_make("Frame", {
        Size = UDim2.new(1, -82, 0, 74), BackgroundTransparency = 1, Active = true,
    }, self.content)
    self.title = self:_label(header, "Nexus Hub", UDim2.new(1, 0, 0, 30), 20)
    self.title.Position = UDim2.fromOffset(0, 12)
    self.title.Font = Enum.Font.GothamBold
    self.subtitle = self:_label(header, "", UDim2.new(1, 0, 0, 20), 11, "muted")
    self.subtitle.Position = UDim2.fromOffset(0, 44)
    local minimize = self:_button(self.content, "-", UDim2.fromOffset(32, 32))
    minimize.Position = UDim2.new(1, -72, 0, 17)
    local close = self:_button(self.content, "X", UDim2.fromOffset(32, 32))
    close.Position = UDim2.new(1, -34, 0, 17)
    self.subtabs = self:_make("Frame", {
        Position = UDim2.fromOffset(0, 80), Size = UDim2.fromOffset(285, 38), BackgroundTransparency = 0.2,
        BackgroundColor3 = PALETTE.card, BorderSizePixel = 0,
    }, self.content, { BackgroundColor3 = "card" })
    self:_round(self.subtabs, 20)
    self:_stroke(self.subtabs)
    self.body = self:_make("ScrollingFrame", {
        Position = UDim2.fromOffset(0, 128), Size = UDim2.new(1, 0, 1, -146),
        BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, self.content)
    self:_make("UIPadding", { PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 12) }, self.body)
    self.sidebarHandle = self:_make("TextButton", {
        Name = "SidebarDivider", Size = UDim2.new(0, 10, 1, 0), Text = "",
        BackgroundTransparency = 1, BorderSizePixel = 0, Active = true, AutoButtonColor = false, ZIndex = 12,
    }, self.window)
    self.sidebarLine = self:_make("Frame", {
        Position = UDim2.fromOffset(4, 8), Size = UDim2.new(0, 1, 1, -16),
        BackgroundColor3 = PALETTE.line, BackgroundTransparency = 0.45, BorderSizePixel = 0, ZIndex = 12,
    }, self.sidebarHandle)
    self.web = self:_make("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(170, 170), BackgroundTransparency = 1,
        Active = false, Selectable = false, ClipsDescendants = true,
    }, self.window)
    self.webLines = {}
    local function webLine(a, b)
        local delta = b - a
        local line = self:_make("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2),
            Size = UDim2.fromOffset(delta.Magnitude, 1), Rotation = math.deg(math.atan2(delta.Y, delta.X)),
            BorderSizePixel = 0, BackgroundColor3 = PALETTE.muted, BackgroundTransparency = 0.74,
            Active = false, Selectable = false,
        }, self.web)
        table.insert(self.webLines, line)
    end
    local origin = Vector2.new(170, 0)
    local function webPoint(radius, spoke)
        local angle = spoke * math.pi / 10
        return origin + Vector2.new(-math.cos(angle) * radius, math.sin(angle) * radius)
    end
    for spoke = 0, 5 do webLine(origin, webPoint(205, spoke)) end
    for _, radius in ipairs({ 27, 52, 83, 119, 162, 205 }) do
        for spoke = 0, 4 do webLine(webPoint(radius, spoke), webPoint(radius, spoke + 1)) end
    end
    local resize = self:_button(self.window, ".:", UDim2.fromOffset(23, 23))
    resize.Position = UDim2.new(1, -26, 1, -26)
    resize.ZIndex = 5
    self.launcher = self:_button(self.host, "Nexus Hub   ⌄", UDim2.fromOffset(125, 30))
    self.launcher.Position = UDim2.fromOffset(12, 12)
    self.launcher.TextColor3 = self.accent
    self.fonts[self.launcher] = 11
    self.hud = self:_make("Frame", {
        AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 8),
        Size = UDim2.fromOffset(220, 24), BackgroundColor3 = PALETTE.background, BorderSizePixel = 0,
    }, self.host, { BackgroundColor3 = "background" })
    self:_round(self.hud, 6)
    self:_stroke(self.hud)
    self.hudText = self:_label(self.hud, "Nexus Hub  |  -- FPS  |  -- ms", UDim2.new(1, -16, 1, 0), 10)
    self.hudText.Position = UDim2.fromOffset(8, 0)
    self.hudText.TextXAlignment = Enum.TextXAlignment.Center
    self.notice = self:_label(self.content, "", UDim2.new(1, -12, 0, 14), 9, "muted")
    self.notice.Position = UDim2.new(0, 0, 1, -16)
    self.notice.BackgroundTransparency = 1
    self.notice.TextTruncate = Enum.TextTruncate.AtEnd
    self.notice.Visible = false
    self.notice.ZIndex = 50
    self:_round(self.notice, 10)
    self.tooltip = self:_label(self.host, "", UDim2.fromOffset(260, 74), 11)
    self.tooltip.BackgroundColor3 = PALETTE.card
    self.tooltip.BackgroundTransparency = 0.05
    self.tooltip.Visible = false
    self.tooltip.ZIndex = 60
    self:_round(self.tooltip, 8)
    self:_make("UIPadding", {
        PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
    }, self.tooltip)
    self.popupLayer = self:_make("Frame", {
        Name = "PopupLayer", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, ZIndex = 60,
    }, self.window)

    local drag, resizing
    self:_connect(self.sidebarHandle.InputBegan, function(input)
        if drag or resizing or self.activeSlider then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_closePopup()
            self.sidebarDragging = { input = input, start = input.Position, width = self.sidebarWidth }
            self:_applyLayout()
        end
    end)
    self:_connect(header.InputBegan, function(input)
        if drag or resizing or self.sidebarDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_closePopup()
            drag = { input = input, start = input.Position, position = self.window.Position }
        end
    end)
    self:_connect(resize.InputBegan, function(input)
        if drag or resizing or self.sidebarDragging then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self:_closePopup()
            resizing = { input = input, start = input.Position, width = self.width, height = self.height }
        end
    end)
    self:_connect(UserInputService.InputChanged, function(input)
        local function matches(active)
            return active and (active.input == input or (active.input.UserInputType == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseMovement))
        end
        if matches(self.sidebarDragging) then
            local active = self.sidebarDragging
            self.sidebarWidth = active.width + (input.Position.X - active.start.X) / math.max(self.scale.Scale, 0.1)
            self:_applyLayout()
        elseif matches(drag) then
            local delta = input.Position - drag.start
            self.window.Position = UDim2.new(drag.position.X.Scale, drag.position.X.Offset + delta.X,
                drag.position.Y.Scale, drag.position.Y.Offset + delta.Y)
            self:_fit()
        elseif matches(resizing) then
            local delta = (input.Position - resizing.start) / self.scale.Scale
            self.width, self.height = math.clamp(resizing.width + delta.X, 640, 1100), math.clamp(resizing.height + delta.Y, 400, 850)
            self.window.Size = UDim2.fromOffset(self.width, self.height)
            self:_fit()
        elseif matches(self.activeSlider) then
            self.activeSlider.move(input)
        elseif matches(self.activeMobile) then
            local active = self.activeMobile
            local delta = input.Position - active.start
            if delta.Magnitude > 8 then active.cancelTap = true end
            if not self.mobileLocked[active.definition.id] and os.clock() - active.started > 0.25 then
                active.dragged = true
                local point = Vector2.new(active.position.X.Offset + delta.X, active.position.Y.Offset + delta.Y)
                self.mobilePositions[active.definition.id] = point
                self:_refreshMobile()
            end
        end
        if self.tooltip.Visible then
            local position = UserInputService:GetMouseLocation()
            local size = self.host.AbsoluteSize
            self.tooltip.Position = UDim2.fromOffset(math.clamp(position.X + 14, 0, math.max(0, size.X - 265)),
                math.clamp(position.Y + 10, 0, math.max(0, size.Y - 80)))
        end
    end)
    self:_connect(UserInputService.InputEnded, function(input)
        if self.sidebarDragging and input == self.sidebarDragging.input then
            self.sidebarDragging = nil
            self:_applyLayout()
        end
        if drag and input == drag.input then drag = nil end
        if resizing and input == resizing.input then resizing = nil end
        if self.activeSlider and input == self.activeSlider.input then self.activeSlider = nil end
        if self.activeMobile and input == self.activeMobile.input then
            local active = self.activeMobile
            self.activeMobile = nil
            if not active.dragged and not active.cancelTap then
                local id = active.definition.id
                local now = os.clock()
                if self:_get("mobile.doubleTapLock", false) then
                    if self.pendingMobile[id] and now - (self.mobileLastTap[id] or 0) < 0.35 then
                        self.pendingMobile[id] = nil
                        self.mobileLocked[id] = not self.mobileLocked[id]
                        self.mobileLastTap[id] = 0
                    else
                        local pending = {}
                        self.pendingMobile[id], self.mobileLastTap[id] = pending, now
                        task.delay(0.36, function()
                            if self.destroyed or self.pendingMobile[id] ~= pending then return end
                            self.pendingMobile[id] = nil
                            if self:_get(id, false) == true then self:_mobileTrigger(active.definition) end
                        end)
                    end
                else
                    self.mobileLastTap[id] = now
                    self:_mobileTrigger(active.definition)
                end
            end
        end
    end)
    self:_connect(UserInputService.WindowFocusReleased, function()
        drag, resizing, self.activeSlider, self.activeMobile, self.sidebarDragging = nil, nil, nil, nil, nil
        self:_closePopup()
        self:_applyLayout()
    end)
    self:_connect(UserInputService.InputBegan, function(input)
        local popup = self.popup
        if not popup then return end
        if input.KeyCode == Enum.KeyCode.Escape then self:_closePopup() return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local function inside(object)
            if not object.Parent then return false end
            local point, size = object.AbsolutePosition, object.AbsoluteSize
            return input.Position.X >= point.X and input.Position.X <= point.X + size.X
                and input.Position.Y >= point.Y and input.Position.Y <= point.Y + size.Y
        end
        if not inside(popup.frame) and not inside(popup.anchor) then self:_closePopup() end
    end)
    self:_connect(UserInputService.InputBegan, function(input, processed)
        if processed or UserInputService:GetFocusedTextBox() then return end
        local key = tostring(self:_get("ui.menuKey", "P")):gsub("Enum.KeyCode%.", "")
        if input.KeyCode.Name == key or input.KeyCode == Enum.KeyCode.RightControl then self:SetVisible(not self.window.Visible) end
    end)
    self:_connect(minimize.Activated, function() self:SetVisible(false) end)
    self:_connect(self.launcher.Activated, function() self:SetVisible(not self.window.Visible) end)
    self:_connect(close.Activated, function() self:_action({ id = "unload" }) end)
    self:_connect(self.search:GetPropertyChangedSignal("Text"), function() self:_render() end)
    self:_connect(self.body:GetPropertyChangedSignal("CanvasPosition"), function() self:_closePopup() end)
    self:_connect(self.host:GetPropertyChangedSignal("AbsoluteSize"), function() self:_closePopup(); self:_fit() end)
    self:_connect(self.gui.Destroying, function() self:Destroy() end)
    local frames, elapsed = 0, 0
    self:_connect(RunService.RenderStepped, function() frames += 1 end)
    self:_connect(RunService.Heartbeat, function(delta)
        elapsed += delta
        if elapsed < 1 then return end
        local ping
        pcall(function() ping = player:GetNetworkPing() * 1000 end)
        local latency = type(ping) == "number" and string.format("%d ms", math.floor(ping + 0.5)) or "-- ms"
        self.hudText.Text = string.format("Nexus Hub  |  %d FPS  |  %s", math.floor(frames / elapsed + 0.5), latency)
        frames, elapsed = 0, 0
        for _, update in ipairs(self.dynamic) do update() end
    end)
    self:_render()
    return self
end

return UI
