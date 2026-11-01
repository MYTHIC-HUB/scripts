local Controller = {}
Controller.__index = Controller

local uiSettings = {
    ["ui.scale"] = true, ["ui.fit"] = true, ["ui.radius"] = true,
    ["ui.textScale"] = true, ["ui.font"] = true, ["ui.opacity"] = true,
    ["ui.menuKey"] = true, ["ui.showFps"] = true, ["ui.showKeybinds"] = true,
    ["ui.accentColor"] = true, ["ui.panelColor"] = true,
    ["ui.compactSidebar"] = true, ["ui.sidebarDensity"] = true,
    ["ui.animations"] = true, ["ui.tooltips"] = true, ["ui.launcher"] = true,
}

local function walk(catalog, visit)
    for _, page in ipairs(catalog) do
        local groups = page.tabs or { { sections = page.sections } }
        for _, group in ipairs(groups) do
            for _, section in ipairs(group.sections or {}) do
                for _, control in ipairs(section.controls or {}) do
                    visit(control, page, group, section)
                end
            end
        end
    end
end

function Controller.new(catalog, options)
    local self = setmetatable({
        catalog = catalog, options = options or {}, settings = {}, controls = {},
        handlers = {}, activeToggles = {}, revisions = {}, alive = true,
    }, Controller)
    walk(catalog, function(control)
        assert(type(control.id) == "string", "Control sem ID")
        assert(not self.controls[control.id], "ID duplicado: " .. control.id)
        self.controls[control.id] = control
        if control.default ~= nil then self.settings[control.id] = control.default end
    end)
    self.settings["ui.accentColor"] = "#EF3340"
    return self
end

function Controller:SetHandlers(handlers)
    self.handlers = handlers
end

function Controller:Get(id, fallback)
    local value = self.settings[id]
    if value == nil then return fallback end
    return value
end

function Controller:GetBounds(id)
    local control = self.controls[id] or {}
    local minimum, maximum = control.min or 0, control.max or 100
    if id == "farm.speed" then
        local limits = { Fast = 24, ["Under Map"] = 22, Teleport = 26 }
        maximum = limits[self:Get("farm.method", "Fast")] or 24
    elseif id == "player.spinSpeed" then
        minimum, maximum = 0, 100
    end
    return minimum, maximum
end

function Controller:_handler(id)
    for _, handler in ipairs(self.handlers) do
        local supported, reason = handler:Supports(id)
        if supported ~= nil then return handler, supported, reason end
    end
    return nil, false, "Integracao desta funcao ainda nao identificada."
end

function Controller:IsSupported(control)
    if not self.alive then return false, "Hub encerrado." end
    if type(control) == "string" then control = self.controls[control] or { id = control } end
    if control.type == "note" or control.type == "stats" then return true end
    local id = control.id
    if control.type == "toggle" and self.activeToggles[id] then return true end
    if uiSettings[id] then return true end
    if id == "unload" or id == "general.unload" or id == "general.reset" then return true end
    if self.options.supports then
        local supported, reason = self.options.supports(id)
        if supported ~= nil then return supported, reason end
    end
    local _, supported, reason = self:_handler(id)
    return supported, reason
end

function Controller:_normalize(control, value)
    if control.type == "toggle" then
        if type(value) ~= "boolean" then return nil, "Use verdadeiro ou falso." end
    elseif control.type == "slider" then
        value = tonumber(value)
        if not value or value ~= value or math.abs(value) == math.huge then
            return nil, "Numero invalido."
        end
        local minimum, maximum = self:GetBounds(control.id)
        value = math.clamp(value, minimum, maximum)
        if control.step and control.step > 0 then
            value = minimum + math.floor((value - minimum) / control.step + 0.5) * control.step
            value = math.clamp(value, minimum, maximum)
        end
    elseif control.type == "select" then
        local found = false
        for _, option in ipairs(control.options or {}) do
            local expected = type(option) == "table" and option.value or option
            if value == expected then found = true break end
        end
        if not found then return nil, "Opcao nao incluida na referencia." end
    elseif control.type == "input" then
        if type(value) ~= "string" then return nil, "Informe um texto." end
        value = string.sub(value, 1, control.maxLength or 512)
        if control.id == "ui.accentColor" or control.id == "ui.panelColor"
            or control.id == "tracers.color" or control.id == "tracers.tailColor" then
            if not value:match("^#?%x%x%x%x%x%x$") then
                return nil, "Use uma cor hexadecimal com seis digitos, como #EF3340."
            end
        end
    end
    return value
end

function Controller:Set(id, value)
    if not self.alive then return false, "Hub encerrado." end
    local control = self.controls[id]
    if not control then return false, "Controle desconhecido: " .. tostring(id) end
    local deactivating = control.type == "toggle" and value == false and self.activeToggles[id] == true
    local supported, reason = self:IsSupported(control)
    if not supported then return false, reason end
    local normalized, problem = self:_normalize(control, value)
    if problem then return false, problem end
    local revision = (self.revisions[id] or 0) + 1
    self.revisions[id] = revision
    local previous = self.settings[id]
    local previousFarmSpeed = self.settings["farm.speed"]
    local previousFarmRevision = self.revisions["farm.speed"] or 0
    self.settings[id] = normalized
    if id == "farm.method" and self.controls["farm.speed"] then
        local minimum, maximum = self:GetBounds("farm.speed")
        self.settings["farm.speed"] = math.clamp(tonumber(previousFarmSpeed) or maximum, minimum, maximum)
    end
    local ok, message = nil, nil
    if uiSettings[id] then
        ok = true
    else
        if self.options.set then ok, message = self.options.set(id, normalized) end
        if ok == nil then
            local handler, available, why = self:_handler(id)
            if handler and (available or deactivating) then
                local called, result, detail = pcall(handler.Set, handler, id, normalized)
                ok, message = called and result == true, called and detail or tostring(result)
            else
                ok, message = false, why
            end
        end
    end
    if not self.alive then return false, "Hub encerrado." end
    if self.revisions[id] ~= revision then return false, "Esta alteracao foi substituida por uma mais recente." end
    if ok ~= true then
        self.settings[id] = previous
        if id == "farm.method" and (self.revisions["farm.speed"] or 0) == previousFarmRevision then
            self.settings["farm.speed"] = previousFarmSpeed
        end
        return false, message or "A alteracao nao foi aplicada."
    end
    if control.type == "toggle" then self.activeToggles[id] = normalized == true or nil end
    if self.options.onChanged then self.options.onChanged(id, normalized) end
    return true, message
end

function Controller:Reset()
    local changed, skipped = 0, 0
    local farmMethod = self.controls["farm.method"]
    if farmMethod and self:Get("farm.method") ~= farmMethod.default then
        local ok = self:Set("farm.method", farmMethod.default)
        if ok then changed += 1 else skipped += 1 end
    end
    for id, control in pairs(self.controls) do
        if control.default ~= nil and self.settings[id] ~= control.default then
            local ok = self:Set(id, control.default)
            if ok then changed += 1 else skipped += 1 end
        end
    end
    return true, string.format("%d ajustes restaurados; %d indisponiveis.", changed, skipped)
end

function Controller:Action(id, payload)
    if not self.alive then return false, "Hub encerrado." end
    if id == "unload" or id == "general.unload" then
        if self.options.unload then self.options.unload() end
        return true
    end
    if id == "general.reset" then return self:Reset() end
    if self.options.action then
        local ok, message = self.options.action(id, payload)
        if ok ~= nil then return ok, message end
    end
    local handler, supported, reason = self:_handler(id)
    if not handler or not supported then return false, reason end
    local called, ok, message = pcall(handler.Action, handler, id, payload)
    if not called then return false, tostring(ok) end
    return ok == true, message
end

function Controller:GetPlayers()
    for _, handler in ipairs(self.handlers) do
        if handler.GetPlayers then return handler:GetPlayers() end
    end
    return {}
end

function Controller:GetStats()
    local stats = {}
    for _, handler in ipairs(self.handlers) do
        if handler.GetStats then
            for key, value in pairs(handler:GetStats()) do stats[key] = value end
        end
    end
    return stats
end

function Controller:GetCatalog(id)
    if self.options.getCatalog then return self.options.getCatalog(id) or {} end
    return {}
end

function Controller:Destroy()
    if not self.alive then return end
    self.alive = false
    for index = #self.handlers, 1, -1 do
        local ok, message = pcall(self.handlers[index].Destroy, self.handlers[index])
        if not ok and self.options.notify then self.options.notify(tostring(message)) end
    end
    self.handlers = {}
end

Controller.walk = walk
return Controller
