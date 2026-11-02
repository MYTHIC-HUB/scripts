-- MM2 client protocols observed in tlredz/decompiledGames, commit 0552a0f.
-- Sources: v1456 Modules/ShopModule.lua, Modules/ProfileData.lua, Menu/GUI.lua.
-- No Roblox service is accessed until new(), allowing the rules to be tested offline.
local Integrations = {}
Integrations.__index = Integrations

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end
local function balance(profile, currency)
    if type(profile) ~= "table" then return nil end
    local value = profile[currency]
    local materials = type(profile.Materials) == "table" and profile.Materials.Owned
    local weapons = type(profile.Weapons) == "table" and profile.Weapons.Owned
    if value == nil and type(materials) == "table" then value = materials[currency] end
    if value == nil and type(weapons) == "table" then value = weapons[currency] end
    if value == nil and currency ~= "Coins" and currency ~= "Gems"
        and (type(materials) == "table" or type(weapons) == "table") then value = 0 end
    return finite(value) and value >= 0 and value or nil
end
local function cratesFromShop(shop, descriptions)
    local entries, indexed = {}, {}
    if type(shop) ~= "table" or type(shop.Weapons) ~= "table" then return entries, indexed end
    for id, data in pairs(shop.Weapons) do
        if type(id) == "string" and type(data) == "table" and data.DataType == "MysteryBox" and type(data.Price) == "table" then
            local prices = {}
            for currency, amount in pairs(data.Price) do
                if type(currency) == "string" and not currency:lower():find("robux", 1, true)
                    and finite(amount) and amount >= 0 then prices[currency] = amount end
            end
            if next(prices) then
                local description = type(descriptions) == "table" and descriptions[id]
                local name = type(description) == "table" and description.Name or id
                local entry = { id = id, name = type(name) == "string" and name or id,
                    dataType = "MysteryBox", prices = prices, order = finite(data.LayoutOrder) and data.LayoutOrder or 9999 }
                entries[#entries + 1], indexed[id] = entry, entry
            end
        end
    end
    table.sort(entries, function(a, b) return a.order == b.order and a.name < b.name or a.order < b.order end)
    return entries, indexed
end
local function currencyOptions(entry)
    local options, currencies = { "Auto" }, {}
    for currency in pairs(entry and entry.prices or {}) do currencies[#currencies + 1] = currency end
    table.sort(currencies, function(a, b)
        local rank = { Coins = 1, Key = 2, Gems = 4 }
        local ar, br = rank[a] or 3, rank[b] or 3
        return ar == br and a < b or ar < br
    end)
    for _, currency in ipairs(currencies) do options[#options + 1] = currency end
    return options
end
local function chooseCurrency(entry, requested, profile)
    if not entry then return nil, "Escolha uma caixa disponivel no catalogo do jogo." end
    local options = requested == "Auto" and currencyOptions(entry) or { requested }
    for _, currency in ipairs(options) do
        local price = entry.prices[currency]
        local amount = balance(profile, currency)
        if price ~= nil and amount ~= nil and amount >= price then return currency end
    end
    return nil, "Saldo insuficiente ou moeda nao confirmada para esta caixa."
end
local function rewardId(value, items)
    if type(value) ~= "string" or value == "" or type(items) ~= "table" or type(items[value]) ~= "table" then return nil end
    return value
end
local function bagState(kind, current, maximum)
    if type(kind) ~= "string" or not finite(current) or not finite(maximum)
        or current < 0 or maximum <= 0 or current > maximum then return nil end
    return { kind = kind, current = current, maximum = maximum, full = current >= maximum }
end
Integrations.rules = {
    balance = balance, cratesFromShop = cratesFromShop, currencyOptions = currencyOptions,
    chooseCurrency = chooseCurrency, rewardId = rewardId, bagState = bagState,
}

local BOX_IDS = {
    ["boxes.box"] = true, ["boxes.currency"] = true, ["boxes.delay"] = true,
    ["boxes.animation"] = true, ["boxes.auto"] = true, ["boxes.open"] = true,
}
local BAG_IDS = { ["farm.shootFull"] = true, ["farm.respawnFull"] = true, ["farm.killFull"] = true }
local ROLE_IDS = {
    ["rolefarm.sheriff"] = true, ["rolefarm.murderer"] = true,
    ["rolefarm.innocent"] = true, ["rolefarm.exp"] = true, ["rolefarm.prestige"] = true,
}
function Integrations.new(context)
    local self = setmetatable({
        context = context, settings = context.settings, alive = true, connections = {}, eventConnections = {}, modules = {},
        entries = {}, crates = {}, opened = 0, lastDrop = "-", boxStatus = "Off", roleStatus = "Off",
        boxGeneration = 0, boxInFlight = false, nextBoxAt = 0, dataAt = 0, elapsed = 0,
        round = 0, bagActions = {}, inRound = false, lastRoleAction = 0, lastPrestigeAt = 0,
        survivalGeneration = 0,
    }, Integrations)
    self.players = game:GetService("Players")
    self.player = self.players.LocalPlayer
    self.replicated = game:GetService("ReplicatedStorage")
    self.runService = game:GetService("RunService")
    self.workspace = game:GetService("Workspace")
    self.pathfinding = game:GetService("PathfindingService")
    self.inRound = self.player:GetAttribute("Alive") == true
    self:_bindEvents()
    self.connections[#self.connections + 1] = self.player.CharacterAdded:Connect(function()
        self:_characterChanged()
    end)
    self.connections[#self.connections + 1] = self.runService.Heartbeat:Connect(function(delta)
        if not self.alive then return end
        self.elapsed += delta
        if self.elapsed < 0.25 then return end
        self.elapsed = 0
        self:_tick()
    end)
    task.defer(function() if self.alive then self:_refreshData() end end)
    return self
end
function Integrations:_characterChanged()
    self.bag, self.bagActions = nil, {}
    self:_stopSurvival()
end
function Integrations:_get(id, fallback)
    local value = self.context.get and self.context.get(id)
    if value == nil then value = self.settings[id] end
    if value == nil then return fallback end
    return value
end
function Integrations:_notify(message)
    if self.alive and self.context.notify then self.context.notify(message) end
end
function Integrations:_path(...)
    local object = self.replicated
    for _, name in ipairs({ ... }) do object = object and object:FindFirstChild(name) end
    return object
end
function Integrations:_remote(className, ...)
    local object = self:_path(...)
    return object and object:IsA(className) and object or nil
end
function Integrations:_module(object)
    if not object or not object:IsA("ModuleScript") then return nil end
    if self.modules[object] ~= nil then return self.modules[object] or nil end
    local ok, value = pcall(require, object)
    if not self.alive then return nil end
    self.modules[object] = ok and type(value) == "table" and value or nil
    return self.modules[object] or nil
end
function Integrations:_refreshData()
    if self.dataLoading or os.clock() < self.dataAt then return end
    self.dataAt, self.dataLoading = os.clock() + 5, true
    local shop = self:_module(self:_path("Database", "Sync", "Shop"))
    self.items = self:_module(self:_path("Database", "Sync", "Item"))
    local descriptions = self:_module(self:_path("Database", "Sync", "MysteryBox"))
    self.entries, self.crates = cratesFromShop(shop, descriptions)
    local getProfile = self:_remote("RemoteFunction", "Remotes", "Inventory", "GetProfileData")
    self.profile = getProfile and self:_module(self:_path("Modules", "ProfileData")) or nil
    self.levelModule = self:_module(self:_path("Modules", "LevelModule"))
    self.boxModule = self:_module(self:_path("Modules", "BoxModule"))
    self:_bindEvents()
    self.dataLoading = false
end
function Integrations:_bindEvents()
    local function bind(key, event, callback)
        local current = self.eventConnections[key]
        if current and current.event == event then return end
        if current then current.connection:Disconnect(); self.eventConnections[key] = nil end
        if event then self.eventConnections[key] = { event = event, connection = event.OnClientEvent:Connect(callback) } end
    end
    self.coinEvent = self:_remote("RemoteEvent", "Remotes", "Gameplay", "CoinCollected")
    self.roundStart = self:_remote("RemoteEvent", "Remotes", "Gameplay", "RoundStart")
    self.roundEnd = self:_remote("RemoteEvent", "Remotes", "Gameplay", "RoundEndFade")
    bind("coin", self.coinEvent, function(kind, current, maximum)
        local state = bagState(kind, current, maximum)
        if self.alive and state then self.bag = state; self.inRound = true end
    end)
    bind("start", self.roundStart, function()
        self.round += 1
        self.inRound, self.bag, self.bagActions = true, nil, {}
    end)
    bind("end", self.roundEnd, function()
        self.round += 1
        self.inRound, self.bag, self.bagActions = false, nil, {}
        self:_stopSurvival()
    end)
end
function Integrations:_role()
    local gameFeatures = self.context.gameFeatures
    if gameFeatures and gameFeatures._role then return gameFeatures:_role(self.player) end
    return "unknown"
end
function Integrations:_parts()
    local character = self.player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then return root, humanoid, character end
    return nil
end
function Integrations:GetOptions(id)
    if id == "boxes.box" then
        local options = { { label = "Select box", value = "" } }
        for _, entry in ipairs(self.entries) do options[#options + 1] = { label = entry.name, value = entry.id } end
        return options
    end
    if id == "boxes.currency" then return currencyOptions(self.crates[self:_get("boxes.box", "")]) end
    return nil
end
function Integrations:GetCatalog() return {} end
function Integrations:Supports(id)
    if BOX_IDS[id] then
        if id == "boxes.delay" then return true end
        if id == "boxes.animation" then
            return self.boxModule and type(self.boxModule.OpenBox) == "function" or false,
                "O modulo nativo de animacao de caixas ainda nao carregou."
        end
        return #self.entries > 0 and self:_remote("RemoteFunction", "Remotes", "Shop", "OpenCrate") ~= nil,
            "O catalogo Shop.Weapons ou o protocolo OpenCrate ainda nao esta disponivel."
    end
    if id == "rolefarm.prestige" then
        return self.profile ~= nil and self.levelModule and type(self.levelModule.GetLevel) == "function"
            and self:_remote("RemoteEvent", "Remotes", "Inventory", "Prestige") ~= nil or false,
            "O perfil, calculo de nivel ou Prestige ainda nao esta disponivel."
    end
    if BAG_IDS[id] then
        if not self.coinEvent then return false, "CoinCollected ainda nao foi observado." end
        if id == "farm.respawnFull" then
            local ok, signal = pcall(function() return self.player.Kill end)
            return type(getfenv().replicatesignal) == "function" and ok and signal ~= nil,
                "O ambiente nao fornece o sinal de reset do personagem."
        end
        if id == "farm.killFull" then
            return type(getfenv().firetouchinterest) == "function", "O ambiente nao fornece contato de faca."
        end
        return self.context.gameFeatures:Supports("sheriff.shoot")
    end
    if id == "rolefarm.sheriff" then return self.context.gameFeatures:Supports("sheriff.shoot") end
    if id == "rolefarm.murderer" then
        return type(getfenv().firetouchinterest) == "function", "O ambiente nao fornece contato de faca."
    end
    if id == "rolefarm.innocent" or id == "rolefarm.exp" then
        return self.roundStart ~= nil and self.roundEnd ~= nil,
            "Os eventos de rodada ainda nao foram observados."
    end
    return nil
end
function Integrations:Set(id, value)
    local supported, reason = self:Supports(id)
    if supported == nil then return false, "Controle desconhecido nesta integracao." end
    if not supported and value ~= false then return false, reason end
    if id == "boxes.box" and value ~= "" and not self.crates[value] then return false, "Caixa ausente do catalogo atual." end
    if id == "boxes.box" and value == "" then self.settings["boxes.auto"] = false end
    if id == "boxes.currency" and value ~= "Auto" then
        local entry = self.crates[self:_get("boxes.box", "")]
        if not entry or entry.prices[value] == nil then return false, "Esta moeda nao compra a caixa selecionada." end
    end
    if id == "boxes.auto" and value then
        local entry = self.crates[self:_get("boxes.box", "")]
        local currency, problem = chooseCurrency(entry, self:_get("boxes.currency", "Auto"), self.profile)
        if not currency then return false, problem end
    end
    if id == "boxes.delay" then
        value = tonumber(value)
        if not finite(value) then return false, "Intervalo invalido." end
        value = math.clamp(value, 0.1, 10)
    end
    self.settings[id] = value
    if id == "boxes.auto" then
        self.boxGeneration += 1
        self.nextBoxAt = value and (os.clock() + self:_delay()) or 0
        if not value and not self.boxInFlight then self.boxStatus = "Off" end
    elseif id == "boxes.box" then
        local currency = self:_get("boxes.currency", "Auto")
        local entry = self.crates[value]
        if currency ~= "Auto" and (not entry or entry.prices[currency] == nil) then self.settings["boxes.currency"] = "Auto" end
        self.boxGeneration += 1
        self.nextBoxAt = os.clock() + self:_delay()
    elseif id == "boxes.currency" then
        self.boxGeneration += 1
        self.nextBoxAt = os.clock() + self:_delay()
    elseif (id == "rolefarm.innocent" or id == "rolefarm.exp") and not value then
        if not self:_get("rolefarm.innocent", false) and not self:_get("rolefarm.exp", false) then self:_stopSurvival() end
    end
    return true
end
function Integrations:_delay() return math.clamp(tonumber(self:_get("boxes.delay", 1)) or 1, 0.1, 10) end
function Integrations:_open(automatic)
    if not self.alive then return false, "Hub encerrado." end
    if self.boxInFlight then return false, "Uma abertura ja esta aguardando resposta do jogo." end
    if os.clock() < self.nextBoxAt then return false, "Aguarde o intervalo de abertura." end
    local remote = self:_remote("RemoteFunction", "Remotes", "Shop", "OpenCrate")
    local entry = self.crates[self:_get("boxes.box", "")]
    local currency, problem = chooseCurrency(entry, self:_get("boxes.currency", "Auto"), self.profile)
    if not remote or not currency then return false, problem or "OpenCrate indisponivel." end
    self.boxInFlight, self.boxStatus = true, "Waiting for server"
    local generation = self.boxGeneration
    local spawn = self.context.spawn or task.spawn
    spawn(function()
        if not self.alive or (automatic and (generation ~= self.boxGeneration or not self:_get("boxes.auto", false))) then
            self.boxInFlight = false
            self.boxStatus = self.alive and (self:_get("boxes.auto", false) and "Waiting for interval" or "Off") or "Closed"
            return
        end
        -- OFF/ON never clears this lock while the actual request remains pending.
        local ok, result = pcall(remote.InvokeServer, remote, entry.id, entry.dataType, currency)
        if not self.alive then self.boxInFlight = false return end
        local reward = ok and rewardId(result, self.items)
        if reward then
            self.opened += 1
            self.lastDrop = self.items[reward].ItemName or reward
            self.boxStatus = "Opened"
            if generation == self.boxGeneration and self:_get("boxes.animation", false)
                and self.boxModule and type(self.boxModule.OpenBox) == "function" then
                local animated = pcall(self.boxModule.OpenBox, entry.id, reward)
                if not animated then self:_notify("A caixa abriu, mas a animacao nativa retornou um erro.") end
            end
        else
            self.boxStatus = ok and "No confirmed reward" or "Request failed"
            if self:_get("boxes.auto", false) then self.settings["boxes.auto"] = false end
            self:_notify(ok and "O jogo nao confirmou um item; novas aberturas foram pausadas." or "A solicitacao de abertura retornou um erro.")
        end
        self.boxInFlight = false
        self.nextBoxAt = os.clock() + self:_delay()
    end)
    return true, "Solicitacao enviada usando " .. currency .. "; aguardando o item confirmado."
end
function Integrations:Action(id)
    if id == "boxes.open" then return self:_open() end
    return false, "Acao desconhecida nesta integracao."
end
function Integrations:_stopSurvival()
    self.survivalGeneration += 1
    local survival = self.survival
    self.survival, self.pathLoading = nil, false
    if survival and survival.humanoid.Parent and survival.humanoid.Health > 0 and survival.root.Parent then
        survival.humanoid:MoveTo(survival.root.Position)
    end
end
function Integrations:_survive(root, humanoid, character)
    if self.pathLoading then return end
    if self.survival then
        local point = self.survival.points[self.survival.index]
        if self.survival.character ~= character then self:_stopSurvival() return end
        local distance = point and (root.Position - point.Position).Magnitude
        if distance and (not self.survival.distance or distance < self.survival.distance - 0.25) then
            self.survival.distance, self.survival.progressAt = distance, os.clock()
        end
        if point and distance < 3 then
            self.survival.index += 1
            self.survival.distance, self.survival.progressAt = nil, os.clock()
            point = self.survival.points[self.survival.index]
        end
        if os.clock() - (self.survival.progressAt or os.clock()) > 3 then
            self:_stopSurvival()
            self.nextSurvivalAt = os.clock() + 0.5
            return
        end
        if point then
            if point.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            humanoid:MoveTo(point.Position)
            return
        end
        self.survival = nil
    end
    if os.clock() < (self.nextSurvivalAt or 0) then return end
    self.nextSurvivalAt = os.clock() + 3
    local gameFeatures = self.context.gameFeatures
    local murderer = gameFeatures:_target("murderer")
    local danger = murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart")
    if not danger then self.roleStatus = "Survival: waiting for observed threat" return end
    local destination, distance
    for _, map in ipairs(self.workspace:GetChildren()) do
        local spawns = map:FindFirstChild("Spawns")
        if map:FindFirstChild("CoinContainer") and spawns then
            for _, spawn in ipairs(spawns:GetChildren()) do
                if spawn:IsA("BasePart") then
                    local magnitude = (spawn.Position - danger.Position).Magnitude
                    if not distance or magnitude > distance then destination, distance = spawn.Position, magnitude end
                end
            end
        end
    end
    if not destination then self.roleStatus = "Survival: waiting for map spawns" return end
    self.pathLoading = true
    local generation = self.survivalGeneration
    task.spawn(function()
        local path = self.pathfinding:CreatePath()
        local ok = pcall(path.ComputeAsync, path, root.Position, destination)
        if not self.alive or generation ~= self.survivalGeneration or self.player.Character ~= character then path:Destroy(); return end
        self.pathLoading = false
        if ok and path.Status == Enum.PathStatus.Success then
            self.survival = { character = character, root = root, humanoid = humanoid,
                points = path:GetWaypoints(), index = 2, progressAt = os.clock() }
            self.roleStatus = "Following survival route; rewards decided by game"
        else self.roleStatus = "No traversable survival route" end
        path:Destroy()
    end)
end
function Integrations:_tickBag(role)
    if not self.inRound or not self.bag or not self.bag.full then return end
    local gameFeatures = self.context.gameFeatures
    local function once(id, eligible, action)
        if self:_get(id, false) and not self.bagActions[id] and eligible then
            local ok = action()
            if ok then self.bagActions[id] = true end
        end
    end
    once("farm.shootFull", role == "sheriff" or role == "hero", function()
        if gameFeatures.gunInFlight or gameFeatures.shot then return false end
        return gameFeatures:_shoot()
    end)
    once("farm.killFull", role == "murderer", function() return gameFeatures:_killAll(false) end)
    once("farm.respawnFull", true, function()
        local replicate = getfenv().replicatesignal
        local ok, signal = pcall(function() return self.player.Kill end)
        return ok and signal ~= nil and type(replicate) == "function" and pcall(replicate, signal)
    end)
end
function Integrations:_tick()
    if not self.alive then return end
    if os.clock() >= self.dataAt and not self.dataLoading then task.spawn(function() if self.alive then self:_refreshData() end end) end
    if self:_get("boxes.auto", false) and not self.boxInFlight and os.clock() >= self.nextBoxAt then
        local ok, problem = self:_open(true)
        if not ok then self.settings["boxes.auto"] = false; self.boxStatus = "Paused"; self:_notify(problem) end
    end
    local role = self:_role()
    local root, humanoid, character = self:_parts()
    if root then self:_tickBag(role) end
    if self.inRound and root and os.clock() - self.lastRoleAction >= 0.9 then
        if self:_get("rolefarm.sheriff", false) and (role == "sheriff" or role == "hero") then
            self.lastRoleAction = os.clock()
            if not self.context.gameFeatures.gunInFlight and not self.context.gameFeatures.shot then self.context.gameFeatures:_shoot() end
            self.roleStatus = "Sheriff action requested"
        elseif self:_get("rolefarm.murderer", false) and role == "murderer" then
            self.lastRoleAction = os.clock()
            self.context.gameFeatures:_killAll(false)
            self.roleStatus = "Knife contacts requested"
        end
        local surviving = self:_get("rolefarm.innocent", false) and role == "innocent"
            or self:_get("rolefarm.exp", false) and role ~= "murderer" and role ~= "unknown"
        if surviving and not self:_get("player.fly", false) and not self.context.gameFeatures.farmSession then
            self:_survive(root, humanoid, character)
        elseif self.survival then self:_stopSurvival() end
    end
    if self:_get("rolefarm.prestige", false) and os.clock() - self.lastPrestigeAt >= 30
        and self.profile and finite(self.profile.NewXP) and self.levelModule and type(self.levelModule.GetLevel) == "function" then
        local ok, level = pcall(self.levelModule.GetLevel, self.profile.NewXP)
        local remote = self:_remote("RemoteEvent", "Remotes", "Inventory", "Prestige")
        if ok and finite(level) and level >= 100 and remote then
            self.lastPrestigeAt = os.clock()
            local sent = pcall(remote.FireServer, remote)
            if sent then self.roleStatus = "Prestige requested; awaiting profile update" end
        end
    end
end
function Integrations:GetStats()
    local profile = self.profile or {}
    local level
    if self.levelModule and type(self.levelModule.GetLevel) == "function" and finite(profile.NewXP) then
        local ok, value = pcall(self.levelModule.GetLevel, profile.NewXP)
        if ok and finite(value) then level = value end
    end
    local entry = self.crates[self:_get("boxes.box", "")]
    local currency = chooseCurrency(entry, self:_get("boxes.currency", "Auto"), profile)
    return {
        boxes = { opened = self.opened, lastDrop = self.lastDrop, status = self.boxStatus,
            balance = balance(profile, currency or "Coins") or "Not replicated" },
        rolefarm = { role = self:_role(), status = self.roleStatus, level = level or "Not replicated",
            prestige = finite(profile.Prestige) and profile.Prestige or "Not replicated",
            wins = "Not confirmed", kills = "Not confirmed" },
    }
end
function Integrations:Destroy()
    if not self.alive then return end
    self.alive = false
    self.boxGeneration += 1
    self:_stopSurvival()
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    for _, record in pairs(self.eventConnections) do record.connection:Disconnect() end
    table.clear(self.connections)
    table.clear(self.eventConnections)
    table.clear(self.modules)
end

return Integrations
