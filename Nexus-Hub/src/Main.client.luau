local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
assert(RunService:IsClient(), "Nexus Hub deve executar no cliente Roblox.")

local Catalog = require(script.Parent.Catalog)
local Controller = require(script.Parent.Controller)
local Features = require(script.Parent.Features)
local Game = require(script.Parent.Game)
local Assets = require(script.Parent.Assets)
local Inventory = require(script.Parent.Inventory)
local Integrations = require(script.Parent.Integrations)
local Desync = require(script.Parent.Desync)
local Music = require(script.Parent.Music)
local UI = require(script.Parent.UI)

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
for _, name in ipairs({ "NexusHub", "MM2OriginalHub" }) do
    local previous = playerGui:FindFirstChild(name)
    if previous then
        local event = previous:FindFirstChild("Shutdown")
        if event and event:IsA("BindableEvent") then event:Fire() else previous:Destroy() end
    end
end

local ui, controller, features, gameFeatures, assets, inventory, integrations, desync, music
local closed, queuedMessage = false, nil
local connections = {}
local function notify(message)
    if closed then return end
    if ui then ui:Notify(message) else queuedMessage = tostring(message) end
end
local function unload()
    if closed then return end
    closed = true
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
    if integrations then integrations:Destroy() end
    if desync then desync:Destroy() end
    if music then music:Destroy() end
    if inventory then inventory:Destroy() end
    if assets then assets:Destroy() end
    if controller then controller:Destroy() end
    if ui then ui:Destroy() end
end

local mobileTargets = {
    ["mobile.fly"] = "player.fly", ["mobile.bhop"] = "player.bhop",
    ["mobile.flingSheriff"] = "troll.flingTarget", ["mobile.flingMurderer"] = "troll.flingTarget",
    ["mobile.shotMurderer"] = "sheriff.shoot", ["mobile.killAll"] = "murderer.killAll",
    ["mobile.invisible"] = "player.invisible", ["mobile.knifeThrow"] = "murderer.throwAim",
    ["mobile.speed"] = "player.speedEnabled", ["mobile.speedGlitch"] = "player.speedGlitch",
}
local uiExtras = {
    ["ui.blur"] = true, ["ui.resetAppearance"] = true,
    ["mobile.style"] = true, ["mobile.resetPositions"] = true,
    ["mobile.doubleTapLock"] = true, ["mobile.unlock"] = true, ["mobile.showPing"] = true,
}
local function mobileBase(id)
    if mobileTargets[id] then return id end
    if string.sub(id, -4) == "Size" then
        local base = string.sub(id, 1, -5)
        if mobileTargets[base] then return base end
    end
    return nil
end

controller = Controller.new(Catalog, {
    notify = notify, unload = unload,
    supports = function(id)
        if uiExtras[id] or UI.SUPPORTED_SETTINGS[id] then return true end
        local base = mobileBase(id)
        if base then return controller:IsSupported(mobileTargets[base]) end
        if id == "mobile.roundTimer" then return false, "O evento de rodada ainda nao foi identificado." end
        return nil
    end,
    set = function(id)
        if uiExtras[id] or UI.SUPPORTED_SETTINGS[id] or mobileBase(id) then return true end
        return nil
    end,
    action = function(id)
        if id == "mobile.resetPositions" then
            if ui then ui:ResetMobilePositions() end
            return true, "Posicoes dos botoes restauradas."
        end
        if id == "mobile.unlock" then
            if ui then ui:UnlockMobileButtons() end
            return true, "Botoes desbloqueados."
        end
        if id == "ui.resetAppearance" then
            for key, control in pairs(controller.controls) do
                if key:sub(1, 3) == "ui." and control.default ~= nil then
                    local supported = controller:IsSupported(control)
                    if supported then controller:Set(key, control.default) end
                end
            end
            return true, "Aparencia Nexus restaurada."
        end
        return nil
    end,
    getCatalog = function(id)
        if music and id == "music.songs" then return music:GetCatalog(id) end
        if assets then
            local items = assets:GetCatalog(id)
            if #items > 0 then return items end
        end
        if id == "music.songs" and features then return features:GetSongs() end
        return nil
    end,
    onChanged = function(id)
        if ui and (id:sub(1, 3) == "ui." or id:sub(1, 7) == "mobile." or id == "farm.method") then ui:Refresh() end
    end,
})

local context = {
    settings = controller.settings,
    get = function(id, fallback) return controller:Get(id, fallback) end,
    notify = notify,
    set = function(id, value) return controller:Set(id, value) end,
    action = function(id, payload) return controller:Action(id, payload) end,
    -- Integrations can be supplied here after their runtime protocol is verified.
    adapters = {},
}

local initialized, problem = xpcall(function()
    features = Features.new(context)
    context.features = features
    context.override = function(source, object, property, value) features:_override(source, object, property, value) end
    context.release = function(source) features:_release(source) end
    controller:SetHandlers({ features })
    gameFeatures = Game.new(context)
    context.gameFeatures = gameFeatures
    controller:SetHandlers({ features, gameFeatures })
    assets = Assets.new(context)
    controller:SetHandlers({ assets, features, gameFeatures })
    inventory = Inventory.new(context, assets)
    desync = Desync.new(context)
    controller:SetHandlers({ desync, assets, features, gameFeatures })
    integrations = Integrations.new(context)
    context.integrations = integrations
    controller:SetHandlers({ integrations, desync, assets, features, gameFeatures })
    music = Music.new(context)
    controller:SetHandlers({ integrations, desync, music, assets, features, gameFeatures })
    ui = UI.new(Catalog, controller)
    local event = Instance.new("BindableEvent")
    event.Name, event.Parent = "Shutdown", ui.gui
    table.insert(connections, event.Event:Connect(unload))
    table.insert(connections, ui.gui.Destroying:Connect(unload))
    table.insert(connections, UserInputService.InputBegan:Connect(function(input, processed)
        if processed or UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == Enum.KeyCode.Q and controller:Get("player.fly", false) then return end
        for id, control in pairs(controller.controls) do
            if control.keybind == input.KeyCode.Name then
                local ok, message
                if control.type == "toggle" then ok, message = controller:Set(id, not controller:Get(id, false))
                else ok, message = controller:Action(id) end
                if not ok or message then notify(message or "Acao indisponivel.") end
                if ui then ui:Refresh() end
                break
            end
        end
    end))
    if queuedMessage then notify(queuedMessage) end
end, debug.traceback)

if not initialized then
    unload()
    error("Falha ao iniciar Nexus Hub: " .. tostring(problem))
end
