-- Native client features; game-specific actions require explicit adapters.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Passive API references, inspected without running third-party code:
-- https://github.com/tontov/NewMM2/blob/main/SCRIPT#L435 (roles), #L5454 (lobby).
-- https://github.com/Joystickplays/psychic-octo-invention/blob/main/source/yarhm/1.20/yarhm.lua
-- Lines 5177-5183: map; 5494-5500: gun; 6137-6141: stab; 6158-6163: throw.
-- These paths are enabled only when matching live instances/classes exist.

local Game = {}
Game.__index = Game

local roleColors = {
    murderer = Color3.fromRGB(239, 51, 64), sheriff = Color3.fromRGB(75, 157, 255),
    hero = Color3.fromRGB(241, 200, 74), innocent = Color3.fromRGB(85, 198, 102),
    unknown = Color3.fromRGB(180, 181, 194),
}
local roleLabels = {
    murderer = "FACA DETECTADA", sheriff = "ARMA DETECTADA", hero = "HERO", innocent = "INNOCENT",
    unknown = "PAPEL DESCONHECIDO",
}
local defaults = {
    ["visuals.maxDistance"] = 2000, ["visuals.visibilityCheck"] = false,
    ["farm.speed"] = 24, ["farm.method"] = "Fast", ["sheriff.flickSpeed"] = 6,
    ["sheriff.flickReturn"] = 75, ["sheriff.prediction"] = 20,
    ["sheriff.resolver"] = true, ["sheriff.aimType"] = "Classic",
    ["tracers.width"] = 100, ["tracers.duration"] = 1.2, ["tracers.speed"] = 520,
    ["tracers.color"] = "#69C5FF", ["tracers.tailColor"] = "#FF5AD2",
    ["webhook.interval"] = 10,
}
local native = {}
for _, id in ipairs({
    "visuals.esp", "visuals.maxDistance", "visuals.visibilityCheck", "visuals.gunEsp",
    "esp.murderer", "esp.sheriff", "esp.hero", "esp.innocent", "esp.noRole", "esp.unknown",
    "teleport.murderer", "teleport.sheriff", "teleport.player",
    "sheriff.autoPickup", "sheriff.pickup", "sheriff.resolver", "sheriff.aimType",
    "sheriff.flickSpeed", "sheriff.flickReturn", "sheriff.prediction", "sheriff.shoot", "sheriff.fovCircle",
    "farm.enabled", "farm.method", "farm.speed", "farm.avoidMurderer", "farm.pickup",
    "tracers.color", "tracers.tailColor", "tracers.rainbow", "tracers.width", "tracers.duration",
    "tracers.speed", "tracers.style", "tracers.method", "tracers.preview",
    "server.rejoin", "server.jobId", "server.joinJob",
}) do native[id] = true end

local adapterOnly = {
    ["sheriff.silentAim"] = "Silent aim exige integracao validada com os disparos do MM2.",
    ["sheriff.flickMouse"] = "As fotos nao especificam a entrada de mouse exigida por esta funcao.",
    ["murderer.aura"] = "Kill Aura exige um adapter validado para a faca do MM2.",
    ["murderer.killAll"] = "Kill All exige um adapter validado para a faca do MM2.",
    ["murderer.killGunPlayers"] = "Esta acao exige um adapter validado para a faca do MM2.",
    ["murderer.target"] = "Esta acao exige um adapter validado para a faca do MM2.",
    ["murderer.throwAim"] = "Knife Throw exige integracao validada com o lancamento da faca.",
    ["murderer.autoThrow"] = "Knife Throw exige integracao validada com o lancamento da faca.",
    ["murderer.knifeTracers"] = "Tracers de facas exigem uma fonte validada de lancamentos.",
    ["tracers.enabled"] = "O preview funciona; tiros reais exigem uma fonte validada de disparos.",
    ["tracers.impact"] = "Efeitos de impacto exigem uma fonte validada de disparos.",
    ["tracers.muzzle"] = "Muzzle Flash exige uma fonte validada de disparos.",
    ["tracers.otherShots"] = "Tiros de outros jogadores exigem uma fonte validada de disparos.",
}
local adapterPrefixes = { "rolefarm.", "boxes.", "webhook.", "skins.", "server.vote", "server.dupe", "server.stopVotes", "server.autoDupe", "server.farmPriority", "server.exploreMaps", "server.otherMaps", "server.mapPriority", "server.silentRespawn", "server.map" }

local function partOf(object)
    if not object then return nil end
    if object:IsA("BasePart") then return object end
    if object:IsA("Model") then return object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart", true) end
    if object:IsA("Tool") then return object:FindFirstChild("Handle") end
    return nil
end
local function rootOf(target)
    local character = target and target.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if character and character:IsDescendantOf(Workspace) and root and root:IsA("BasePart") and humanoid and humanoid.Health > 0 then return root, humanoid end
    return nil
end
local function findTool(target, name)
    local character = target.Character
    local backpack = target:FindFirstChildOfClass("Backpack")
    for _, container in pairs({ character, backpack }) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and string.lower(item.Name) == string.lower(name) then return item end
        end
    end
    return nil
end
local function hexColor(value, fallback)
    if typeof(value) == "Color3" then return value end
    local hex = tostring(value or ""):gsub("#", "")
    if #hex == 6 and hex:match("^%x+$") then
        return Color3.fromRGB(tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16))
    end
    return fallback
end
local function webhookUrl(value)
    if type(value) ~= "string" or #value > 4096 then return nil end
    local trimmed = value:match("^%s*(.-)%s*$")
    local host, path = trimmed:match("^https://([^/]+)(/[^%s%?#]+)$")
    if not host then return nil end
    host = host:lower()
    if host ~= "discord.com" and host ~= "discordapp.com" and host ~= "canary.discord.com" and host ~= "ptb.discord.com" then return nil end
    local valid = path:match("^/api/webhooks/%d+/[%w_%-]+$") or path:match("^/api/v%d+/webhooks/%d+/[%w_%-]+$")
    if not valid then return nil end
    return "https://" .. host .. path
end

function Game.new(context)
    local self = setmetatable({}, Game)
    self.context, self.settings, self.adapters = context, context.settings or {}, context.adapters or {}
    self.player, self.alive = Players.LocalPlayer, true
    self.connections, self.markers, self.gunMarkers = {}, {}, {}
    self.coins, self.guns, self.visited = {}, {}, setmetatable({}, { __mode = "k" })
    self.status, self.moves, self.elapsed, self.pickupAt = "Waiting for coins", 0, 0, 0
    self.webhookGeneration, self.webhookLastNotice, self.webhookLastTest = 0, -math.huge, -math.huge
    self.roles, self.roleEpoch, self.roleRevision, self.roleRefreshAt = {}, 0, 0, 0
    self.folder = Instance.new("Folder")
    self.folder.Name = "NexusGameVisuals"
    self.folder.Parent = Workspace
    self.visualGui = Instance.new("ScreenGui")
    self.visualGui.Name, self.visualGui.ResetOnSpawn = "NexusAimVisuals", false
    self.visualGui.IgnoreGuiInset = true
    self.visualGui.Parent = self.player:WaitForChild("PlayerGui")
    local circle = Instance.new("Frame")
    circle.Name, circle.AnchorPoint = "FOV", Vector2.new(0.5, 0.5)
    circle.Size, circle.Position = UDim2.fromOffset(240, 240), UDim2.fromScale(0.5, 0.5)
    circle.BackgroundTransparency, circle.Visible = 1, false
    circle.Parent = self.visualGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(1, 0), circle
    local stroke = Instance.new("UIStroke")
    stroke.Thickness, stroke.Color, stroke.Parent = 1, roleColors.murderer, circle
    self.circle = circle
    self.aimRenderName = "NexusAim_" .. HttpService:GenerateGUID(false)
    RunService:BindToRenderStep(self.aimRenderName, Enum.RenderPriority.Camera.Value + 1, function()
        self:_updateAim()
    end)
    local function track(object)
        if object:IsDescendantOf(self.folder) then return end
        if object:IsA("BasePart") and (object.Name == "Coin_Server" or (object.Name == "Coin" and object:FindFirstAncestor("CoinContainer"))) then
            self.coins[object] = true
        end
        if object.Name == "GunDrop" and partOf(object) then self.guns[object] = true end
        if object:IsA("BasePart") then
            local drop = object:FindFirstAncestor("GunDrop")
            if drop then self.guns[drop] = true end
        end
    end
    for _, object in ipairs(Workspace:GetDescendants()) do track(object) end
    self:_connect(Workspace.DescendantAdded, track)
    self:_connect(Workspace.DescendantRemoving, function(object)
        self.coins[object], self.guns[object], self.visited[object] = nil, nil, nil
        if self.farmTarget == object then self:_cancelFarm() end
    end)
    self:_connect(Players.PlayerRemoving, function(target) self:_removeMarker(target) end)
    self:_connect(self.player.CharacterRemoving, function() self:_cancelFarm() self.shot = nil end)
    self:_connect(self.player.CharacterAdded, function() self:_cancelFarm() self.shot = nil end)
    self:_connect(RunService.Heartbeat, function(delta)
        self.elapsed += delta
        if self.elapsed < 0.2 then return end
        self.elapsed = 0
        self:_tick()
    end)
    return self
end

function Game:_roleRemote()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local extras = remotes and remotes:FindFirstChild("Extras")
    local remote = extras and extras:FindFirstChild("GetPlayerData")
    return remote and remote:IsA("RemoteFunction") and remote or nil
end
function Game:_acceptRoles(data, charactersSnapshot)
    if type(data) ~= "table" then return end
    local parsed = {}
    for name, record in pairs(data) do
        local target = type(name) == "string" and Players:FindFirstChild(name)
        if target and target:IsA("Player") and type(record) == "table" and type(record.Role) == "string"
            and (not charactersSnapshot or charactersSnapshot[target.UserId] == target.Character) then
            local role = record.Role:lower()
            if roleColors[role] and record.Dead ~= true and record.Killed ~= true then
                parsed[target.UserId] = { role = role, character = target.Character }
            end
        end
    end
    self.roles, self.rolesAt = parsed, os.clock()
end
function Game:_refreshRoles()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local gameplay = remotes and remotes:FindFirstChild("Gameplay")
    local event = gameplay and gameplay:FindFirstChild("PlayerDataChanged")
    if event and not event:IsA("RemoteEvent") then event = nil end
    if event ~= self.roleEvent then
        if self.roleConnection then self.roleConnection:Disconnect() end
        self.roleEvent = event
        self.roleConnection = event and event.OnClientEvent:Connect(function(data)
            if self.alive then
                self.roleRevision += 1
                self:_acceptRoles(data)
            end
        end) or nil
    end
    if os.clock() < self.roleRefreshAt or self.roleInFlight then return end
    self.roleRefreshAt = os.clock() + 5
    local remote = self:_roleRemote()
    if not remote then return end
    self.roleInFlight = true
    local epoch, revision, charactersSnapshot = self.roleEpoch, self.roleRevision, {}
    for _, target in ipairs(Players:GetPlayers()) do charactersSnapshot[target.UserId] = target.Character end
    task.spawn(function()
        if not self.alive or self.roleEpoch ~= epoch then self.roleInFlight = false return end
        local ok, data = pcall(remote.InvokeServer, remote)
        self.roleInFlight = false
        if not self.alive or self.roleEpoch ~= epoch then return end
        if ok and self.roleRevision == revision then self:_acceptRoles(data, charactersSnapshot) end
    end)
end
function Game:_mapSpawn(lobby)
    if lobby then
        local regular = Workspace:FindFirstChild("RegularLobby")
        local spawns = regular and regular:FindFirstChild("Spawns")
        if spawns then
            for _, spawn in ipairs(spawns:GetChildren()) do if spawn:IsA("BasePart") then return spawn end end
        end
        return nil
    end
    for _, map in ipairs(Workspace:GetChildren()) do
        if map:FindFirstChild("CoinContainer") and map:FindFirstChild("Spawns") then
            for _, spawn in ipairs(map.Spawns:GetChildren()) do if spawn:IsA("BasePart") then return spawn end end
        end
    end
    return nil
end
function Game:_weaponRemote(toolName, name)
    local tool = findTool(self.player, toolName)
    if not tool then return nil end
    local remote
    if toolName == "Gun" then
        local knifeLocal = tool:FindFirstChild("KnifeLocal")
        local createBeam = knifeLocal and knifeLocal:FindFirstChild("CreateBeam")
        remote = createBeam and createBeam:FindFirstChild("RemoteFunction")
        if remote and remote:IsA("RemoteFunction") then return remote, tool end
    else
        remote = tool:FindFirstChild(name)
        if remote and remote:IsA("RemoteEvent") then return remote, tool end
    end
    return nil
end

function Game:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.connections, connection)
    return connection
end
function Game:_get(id, fallback)
    local value
    if self.context.get then value = self.context.get(id) end
    if value == nil then value = self.settings[id] end
    if value == nil then value = defaults[id] end
    if value == nil then return fallback end
    return value
end
function Game:_notify(message)
    if self.context.notify then self.context.notify(message) end
end
function Game:_adapter(id, payload)
    local handler = self.adapters[id]
    if type(handler) ~= "function" then return false, "Adapter ausente: " .. id end
    local ok, result, message = pcall(handler, payload, self)
    if not ok then return false, tostring(result) end
    if result == false then return false, message or "O adapter nao confirmou a acao." end
    return true, message or "Acao enviada ao adapter."
end
function Game:_requestFunction()
    local environment = getfenv()
    local request = environment.request or environment.http_request
    return type(request) == "function" and request or nil
end
function Game:Supports(id)
    if type(self.adapters[id]) == "function" then return true end
    if id == "webhook.disconnect" then
        return false, "O cliente nao fornece um evento confiavel para enviar alerta depois da desconexao."
    end
    if id == "webhook.url" or id == "webhook.enabled" or id == "webhook.interval" or id == "webhook.test" then
        return self:_requestFunction() ~= nil, "O ambiente nao fornece request/http_request para enviar webhooks."
    end
    if native[id] then return true end
    if id == "server.copyJob" then
        local environment = getfenv()
        return type(environment.setclipboard) == "function", "Clipboard nao esta disponivel neste cliente."
    end
    if id == "server.hop" or id == "server.small" then
        local environment = getfenv()
        local request = environment.request or environment.http_request
        return type(request) == "function" or type(self.adapters.ListServers) == "function", "A listagem de servidores exige API HTTP fornecida pelo ambiente."
    end
    if id == "teleport.lobby" or id == "teleport.map" then
        local location = self.adapters[id == "teleport.lobby" and "LobbyTarget" or "MapTarget"]
        return typeof(location) == "Instance" or typeof(location) == "CFrame" or typeof(location) == "Vector3"
            or self:_mapSpawn(id == "teleport.lobby") ~= nil, "Nenhum destino com a estrutura de spawns documentada foi observado."
    end
    if id == "murderer.aura" or id == "murderer.target" then
        return self:_weaponRemote("Knife", "Stab") ~= nil, "A Tool Knife.Stab (RemoteEvent) ainda nao foi observada."
    end
    if id == "murderer.autoThrow" then
        return self:_weaponRemote("Knife", "Throw") ~= nil, "A Tool Knife.Throw (RemoteEvent) ainda nao foi observada."
    end
    if adapterOnly[id] then return false, adapterOnly[id] end
    for _, prefix in ipairs(adapterPrefixes) do
        if id:sub(1, #prefix) == prefix then return false, "Integracao do jogo nao validada para esta funcao." end
    end
    if id:sub(1, 5) == "farm." then return false, "Esta rotina exige dados ou eventos do servidor ainda nao validados." end
    return nil
end
function Game:Set(id, value)
    local supported, reason = self:Supports(id)
    local turningOff = supported == false and value == false
    if supported ~= true and not turningOff then return false, reason or "Opcao nao gerenciada pelo modulo do jogo." end
    if id == "farm.method" and value ~= "Fast" and value ~= "Teleport" then
        return false, "O metodo Under... aparece truncado nas fotos; comportamento ainda nao validado."
    end
    if id == "sheriff.aimType" and value ~= "Classic" then return false, "Somente o tipo Classic foi mostrado e implementado." end
    if id == "tracers.method" and value ~= "Classic" then return false, "Somente o metodo Classic foi mostrado e implementado." end
    if id == "tracers.style" and value ~= "Energy" then return false, "Somente o estilo Energy foi mostrado e implementado." end
    if id == "webhook.url" then
        if value ~= "" and not webhookUrl(value) then return false, "Use uma URL HTTPS completa de webhook do Discord." end
        self.webhookGeneration += 1
        self.webhookInFlight = nil
        if value == "" then self.settings["webhook.enabled"] = false end
    elseif id == "webhook.enabled" then
        if value and not webhookUrl(self:_get("webhook.url", "")) then return false, "Configure uma URL HTTPS valida de webhook do Discord antes de ativar." end
        self.webhookGeneration += 1
        self.webhookInFlight = nil
        self.nextWebhookAt = value and (os.clock() + self:_webhookInterval()) or nil
    elseif id == "webhook.interval" then
        value = tonumber(value)
        if not value or value ~= value or value == math.huge or value == -math.huge then return false, "Intervalo de webhook invalido." end
        value = math.clamp(value, 1, 120)
        self.nextWebhookAt = os.clock() + value * 60
    end
    if type(self.adapters[id]) == "function" then
        local ok, message = self:_adapter(id, value)
        if not ok then return false, message end
    end
    self.settings[id] = value
    if id == "farm.enabled" and not value then self:_cancelFarm() self.status = "Off" end
    if id == "farm.method" or id == "farm.speed" then self:_cancelFarm() end
    self:_updateMarkers()
    self.circle.Visible = self:_get("sheriff.fovCircle", false) == true
    return true
end
function Game:_webhookInterval()
    return math.clamp(tonumber(self:_get("webhook.interval", 10)) or 10, 1, 120) * 60
end
function Game:_sendWebhook(isTest)
    local request = self:_requestFunction()
    if not request then return false, "API HTTP indisponivel para o webhook." end
    local url = webhookUrl(self:_get("webhook.url", ""))
    if not url then return false, "Configure uma URL HTTPS valida de webhook do Discord." end
    if self.webhookInFlight then return false, "Um envio de webhook ja esta em andamento." end
    if isTest and os.clock() - self.webhookLastTest < 5 then return false, "Aguarde alguns segundos antes de testar novamente." end
    if isTest then self.webhookLastTest = os.clock() end
    local generation = self.webhookGeneration
    self.webhookInFlight = generation
    local stats = self:GetStats()
    local function field(name, value)
        local display = value
        if value == nil or value == "Not confirmed" or value == "Not replicated" then display = "Nao confirmado pelo cliente" end
        return { name = name, value = tostring(display):sub(1, 1024), inline = true }
    end
    local body = HttpService:JSONEncode({
        username = "Nexus Hub",
        allowed_mentions = { parse = {} },
        embeds = { {
            title = isTest and "Teste de webhook" or "Estatisticas de farm",
            color = 0xEF3340,
            fields = {
                field("Status", stats.status), field("Moedas nesta sessao", stats.session),
                field("Moedas por dia", stats.coinsPerDay), field("Total replicado", stats.total),
            },
            footer = { text = "Nexus Hub | Somente estatisticas observadas; sem identificadores pessoais." },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        } },
    })
    task.spawn(function()
        if not self.alive or self.webhookGeneration ~= generation then return end
        local ok, response = pcall(request, {
            Url = url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body,
        })
        if not self.alive or self.webhookGeneration ~= generation then return end
        self.webhookInFlight = nil
        local status = ok and type(response) == "table" and tonumber(response.StatusCode or response.Status) or nil
        local success = status and status >= 200 and status < 300
        if success then
            if isTest then self:_notify("Webhook de teste enviado.") end
        elseif isTest or os.clock() - self.webhookLastNotice >= 60 then
            self.webhookLastNotice = os.clock()
            self:_notify(status and ("Falha no envio do webhook (HTTP " .. tostring(status) .. ").")
                or "Falha no envio do webhook. Confira a conexao e a URL configurada.")
        end
    end)
    return true, isTest and "Envio de teste agendado." or "Envio de estatisticas agendado."
end

function Game:_role(target)
    if type(self.adapters.GetRoles) == "function" then
        local ok, roles = pcall(self.adapters.GetRoles)
        local value = ok and type(roles) == "table" and (roles[target.UserId] or roles[target.Name])
        local role = type(value) == "table" and (value.Role or value.role) or value
        role = role and string.lower(tostring(role))
        if roleColors[role] then return role, true end
    end
    local saved = self.roles[target.UserId]
    if saved and saved.character == target.Character and os.clock() - (self.rolesAt or 0) < 15 then return saved.role, true end
    if findTool(target, "Knife") then return "murderer" end
    if findTool(target, "Gun") then return "sheriff" end
    return "unknown"
end
function Game:GetPlayers()
    local result = {}
    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= self.player then
            table.insert(result, { name = target.Name, displayName = target.DisplayName, userId = target.UserId, role = self:_role(target) })
        end
    end
    table.sort(result, function(a, b) return a.name:lower() < b.name:lower() end)
    return result
end
function Game:GetStats()
    local total
    local leaderstats = self.player:FindFirstChild("leaderstats")
    local coins = leaderstats and (leaderstats:FindFirstChild("Coins") or leaderstats:FindFirstChild("Coin"))
    if coins and (coins:IsA("IntValue") or coins:IsA("NumberValue")) then total = coins.Value end
    local stats = {
        Status = self.status, Session = "Not confirmed", Total = total or "Not replicated",
        Moves = self.moves, Players = #Players:GetPlayers(), Job = game.JobId,
        Role = self:_role(self.player), Wins = "Not replicated", Kills = "Not replicated",
        Opened = "Not confirmed", Balance = total or "Not replicated", LastDrop = "Not confirmed",
    }
    stats.status, stats.session, stats.total = stats.Status, stats.Session, stats.Total
    stats.coinsPerDay, stats.moves, stats.players = "Not confirmed", self.moves, stats.Players
    stats.jobId, stats.role, stats.wins, stats.kills = stats.Job, stats.Role, stats.Wins, stats.Kills
    stats.level, stats.prestige = "Not replicated", "Not replicated"
    stats.opened, stats.balance, stats.lastDrop = stats.Opened, stats.Balance, stats.LastDrop
    stats.farm = { session = stats.session, coinsPerDay = stats.coinsPerDay, total = stats.total, status = stats.status }
    stats.rolefarm = { role = stats.role, status = "Off", wins = stats.wins, kills = stats.kills, level = stats.level, prestige = stats.prestige }
    stats.boxes = { opened = stats.opened, status = "Off", balance = stats.balance, lastDrop = stats.lastDrop }
    return stats
end
function Game:_removeMarker(target)
    local marker = self.markers[target]
    if marker then marker.highlight:Destroy() marker.billboard:Destroy() self.markers[target] = nil end
end
function Game:_visible(root, targetPart)
    local camera = Workspace.CurrentCamera
    if not camera then return false end
    local parameters = RaycastParams.new()
    parameters.FilterType = Enum.RaycastFilterType.Exclude
    parameters.FilterDescendantsInstances = { self.player.Character or self.folder, self.folder }
    local result = Workspace:Raycast(camera.CFrame.Position, targetPart.Position - camera.CFrame.Position, parameters)
    return not result or result.Instance:IsDescendantOf(root.Parent)
end
function Game:_updateMarkers()
    local seen, seenGuns = {}, {}
    local localRoot = rootOf(self.player)
    if self:_get("visuals.esp", false) then
        for _, target in ipairs(Players:GetPlayers()) do
            local root = rootOf(target)
            local character = target.Character
            if target ~= self.player and root then
                local role, confirmed = self:_role(target)
                local distance = localRoot and (root.Position - localRoot.Position).Magnitude or 0
                local enabled = self:_get(role == "unknown" and "esp.noRole" or "esp." .. role, true) ~= false
                if enabled and distance <= self:_get("visuals.maxDistance", 2000)
                    and (not self:_get("visuals.visibilityCheck", false) or self:_visible(root, root)) then
                    seen[target] = true
                    local marker = self.markers[target]
                    if marker and marker.character ~= character then self:_removeMarker(target) marker = nil end
                    if not marker then
                        local highlight = Instance.new("Highlight")
                        highlight.Adornee, highlight.FillTransparency = character, 0.75
                        highlight.DepthMode, highlight.Parent = Enum.HighlightDepthMode.AlwaysOnTop, self.folder
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.fromOffset(220, 58)
                        billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
                        billboard.AlwaysOnTop, billboard.Parent = true, self.folder
                        local label = Instance.new("TextLabel")
                        label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
                        label.Font, label.TextSize, label.TextStrokeTransparency = Enum.Font.GothamBold, 12, 0.35
                        label.Parent = billboard
                        marker = { character = character, highlight = highlight, billboard = billboard, label = label }
                        self.markers[target] = marker
                    end
                    marker.billboard.Adornee = character:FindFirstChild("Head") or root
                    marker.highlight.FillColor, marker.highlight.OutlineColor = roleColors[role], roleColors[role]
                    marker.label.TextColor3 = roleColors[role]
                    marker.label.Text = target.DisplayName .. "\n" .. (confirmed and role:upper() or roleLabels[role]) .. string.format("\n%.0f ST", distance)
                end
            end
        end
    end
    for target in pairs(self.markers) do if not seen[target] then self:_removeMarker(target) end end
    if self:_get("visuals.gunEsp", false) then
        for object in pairs(self.guns) do
            local part = object.Parent and partOf(object)
            if part and part:IsA("BasePart") then
                seenGuns[object] = true
                if not self.gunMarkers[object] then
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee, highlight.FillColor = object, roleColors.sheriff
                    highlight.OutlineColor, highlight.DepthMode = roleColors.sheriff, Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = self.folder
                    self.gunMarkers[object] = highlight
                end
            end
        end
    end
    for object, marker in pairs(self.gunMarkers) do
        if not seenGuns[object] then marker:Destroy() self.gunMarkers[object] = nil end
    end
end

function Game:_gunPart()
    local localRoot = rootOf(self.player)
    if not localRoot then return nil end
    local best, distance
    for object in pairs(self.guns) do
        local part = object.Parent and partOf(object)
        if part and part:IsA("BasePart") then
            local magnitude = (part.Position - localRoot.Position).Magnitude
            if not distance or magnitude < distance then best, distance = part, magnitude end
        end
    end
    return best
end
function Game:_pickup()
    local root = rootOf(self.player)
    local part = self:_gunPart()
    if not root then return false, "Personagem sem HumanoidRootPart ativo." end
    if not part then return false, "Nenhum objeto GunDrop foi observado neste mapa." end
    self:_cancelFarm()
    self.nextFarmAt = os.clock() + 0.75
    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 2, 0)) * root.CFrame.Rotation
    self.pickupAt = os.clock()
    return true, "Personagem movido ate GunDrop; coleta depende do servidor."
end
function Game:_cancelFarm()
    if self.farmConnection then self.farmConnection:Disconnect() self.farmConnection = nil end
    if self.farmTween then self.farmTween:Cancel() self.farmTween = nil end
    self.farmTarget, self.farmRoot = nil, nil
end
function Game:_farm()
    if not self:_get("farm.enabled", false) then return end
    local root = rootOf(self.player)
    if not root then self:_cancelFarm() self.status = "Waiting for character" return end
    if self.farmRoot and self.farmRoot ~= root then self:_cancelFarm() end
    if self.nextFarmAt and os.clock() < self.nextFarmAt then return end
    if self:_get("farm.avoidMurderer", false) then
        for _, target in ipairs(Players:GetPlayers()) do
            local targetRoot = target ~= self.player and rootOf(target)
            if targetRoot and self:_role(target) == "murderer" and (targetRoot.Position - root.Position).Magnitude < 25 then
                self:_cancelFarm() self.status = "Paused: knife nearby" return
            end
        end
    end
    if self.farmTarget and self.farmTarget.Parent then return end
    local best, distance
    local function candidate(part)
        if typeof(part) ~= "Instance" or not part:IsA("BasePart") or not part.Parent then return end
        if (self.visited[part] or 0) > os.clock() then return end
        local magnitude = (part.Position - root.Position).Magnitude
        if not distance or magnitude < distance then best, distance = part, magnitude end
    end
    if type(self.adapters.CoinParts) == "function" then
        local ok, parts = pcall(self.adapters.CoinParts)
        if ok and type(parts) == "table" then for _, part in ipairs(parts) do candidate(part) end end
    else
        for part in pairs(self.coins) do candidate(part) end
        for _, object in ipairs(CollectionService:GetTagged("NexusCoin")) do candidate(partOf(object)) end
    end
    if not best then self.status = "Waiting for observed coins" return end
    local method = tostring(self:_get("farm.method", "Fast")):lower()
    local position = best.Position + Vector3.new(0, method:find("under", 1, true) and -3 or 1.5, 0)
    self.farmTarget, self.farmRoot, self.visited[best] = best, root, os.clock() + 7
    self.moves += 1
    self.status = "Moving; collection not confirmed"
    if method == "teleport" then
        root.CFrame = CFrame.new(position) * root.CFrame.Rotation
        self.farmTarget = nil
        self.nextFarmAt = os.clock() + math.max(0.2, 10 / math.max(1, tonumber(self:_get("farm.speed", 24)) or 24))
    else
        local duration = math.clamp(distance / math.max(1, tonumber(self:_get("farm.speed", 24)) or 24), 0.1, 15)
        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(position) * root.CFrame.Rotation,
        })
        self.farmTween = tween
        self.farmConnection = tween.Completed:Connect(function()
            if self.farmTween == tween then self:_cancelFarm() end
        end)
        tween:Play()
    end
end
function Game:_target(role)
    local localRoot = rootOf(self.player)
    local best, distance
    for _, target in ipairs(Players:GetPlayers()) do
        local root = target ~= self.player and rootOf(target)
        if root and self:_role(target) == role then
            local magnitude = localRoot and (root.Position - localRoot.Position).Magnitude or 0
            if not distance or magnitude < distance then best, distance = target, magnitude end
        end
    end
    return best
end
function Game:_shoot()
    local root, humanoid = rootOf(self.player)
    local gun = findTool(self.player, "Gun")
    local target = self:_target("murderer")
    local targetRoot = rootOf(target)
    local camera = Workspace.CurrentCamera
    if not root or not humanoid or not gun then return false, "Uma Tool Gun e um personagem ativo sao necessarios." end
    if not targetRoot or not camera then return false, "Nenhum alvo com faca foi observado." end
    if gun.Parent ~= self.player.Character then humanoid:EquipTool(gun) end
    self.shot = {
        original = camera.CFrame, camera = camera, gun = gun, target = target,
        start = os.clock(), duration = 1 / math.max(1, self:_get("sheriff.flickSpeed", 6)),
    }
    return true, "Camera apontada e Tool:Activate agendado; disparo depende da Tool do jogo."
end
function Game:_updateAim()
    local shot = self.shot
    if not self.alive or not shot then return end
    local targetRoot = rootOf(shot.target)
    if not rootOf(self.player) or not targetRoot or Workspace.CurrentCamera ~= shot.camera or shot.gun.Parent ~= self.player.Character then
        self.shot = nil
        return
    end
    local position = targetRoot.Position
    if self:_get("sheriff.resolver", true) then
        position += targetRoot.AssemblyLinearVelocity * (self:_get("sheriff.prediction", 20) / 1000)
    end
    local aimed = CFrame.lookAt(shot.camera.CFrame.Position, position)
    local progress = math.clamp((os.clock() - shot.start) / shot.duration, 0, 1)
    shot.camera.CFrame = shot.original:Lerp(aimed, progress)
    if progress < 1 then return end
    -- Hold the aimed camera for a frame before the Tool reads client input.
    if not shot.readyAt then shot.readyAt = os.clock() + 1 / 60 return end
    if os.clock() < shot.readyAt then return end
    local remote = self:_weaponRemote("Gun")
    if remote and not self.gunInFlight then
        self.gunInFlight = true
        task.spawn(function()
            if not self.alive or not rootOf(self.player) or shot.gun.Parent ~= self.player.Character then self.gunInFlight = false return end
            local ok = pcall(remote.InvokeServer, remote, 1, position, "AH2")
            if not self.alive then return end
            self.gunInFlight = false
            if not ok then self:_notify("O servidor nao confirmou a solicitacao de disparo.") end
        end)
    else
        local ok, message = pcall(shot.gun.Activate, shot.gun)
        if not ok then self:_notify(tostring(message)) end
    end
    local ratio = math.clamp(self:_get("sheriff.flickReturn", 75) / 100, 0, 1)
    if ratio > 0 then shot.camera.CFrame = aimed:Lerp(shot.original, ratio) end
    self.shot = nil
end
function Game:_knifeAttack(target, throw)
    local root, humanoid = rootOf(self.player)
    local targetRoot = rootOf(target)
    local remote, tool = self:_weaponRemote("Knife", throw and "Throw" or "Stab")
    if not root or not humanoid or not targetRoot or not remote then return false, "Faca, alvo ou assinatura do remote indisponivel." end
    if not throw and (targetRoot.Position - root.Position).Magnitude > 8 then return false, "O alvo precisa estar ao alcance da faca (8 studs)." end
    if tool.Parent ~= self.player.Character then humanoid:EquipTool(tool) end
    local ok
    if throw then ok = pcall(remote.FireServer, remote, tool:GetPivot(), targetRoot.Position)
    else ok = pcall(remote.FireServer, remote, "Slash") end
    return ok, ok and "Ataque solicitado; resultado depende do servidor." or "O remote de ataque retornou um erro."
end
function Game:_previewTracer()
    local camera = Workspace.CurrentCamera
    if not camera then return false, "Camera indisponivel." end
    local startPosition = camera.CFrame.Position + camera.CFrame.RightVector * 1.5 - camera.CFrame.UpVector
    local endPosition = startPosition + camera.CFrame.LookVector * 45
    local holder = Instance.new("Part")
    holder.Name, holder.Anchored, holder.CanCollide, holder.CanTouch, holder.CanQuery = "NexusTracerPreview", true, false, false, false
    holder.Transparency, holder.Size, holder.Parent = 1, Vector3.new(0.1, 0.1, 0.1), self.folder
    local start = Instance.new("Attachment")
    local finish = Instance.new("Attachment")
    start.Parent, finish.Parent = holder, holder
    start.WorldPosition, finish.WorldPosition = startPosition, startPosition
    local beam = Instance.new("Beam")
    beam.Attachment0, beam.Attachment1 = start, finish
    beam.FaceCamera = true
    beam.LightEmission = self:_get("tracers.style", "Energy") == "Energy" and 1 or 0
    beam.Width0 = math.clamp(self:_get("tracers.width", 100) / 500, 0.02, 2)
    beam.Width1 = beam.Width0 * 0.3
    local color = self:_get("tracers.rainbow", false) and Color3.fromHSV(os.clock() % 5 / 5, 0.8, 1)
        or hexColor(self:_get("tracers.color"), Color3.fromRGB(105, 197, 255))
    beam.Color = ColorSequence.new(color, hexColor(self:_get("tracers.tailColor"), color))
    beam.Parent = holder
    local duration = math.clamp(tonumber(self:_get("tracers.duration", 1.2)) or 1.2, 0.1, 10)
    local travel = math.clamp(45 / math.max(1, tonumber(self:_get("tracers.speed", 520)) or 520), 0.02, duration)
    TweenService:Create(finish, TweenInfo.new(travel, Enum.EasingStyle.Linear), { WorldPosition = endPosition }):Play()
    Debris:AddItem(holder, duration)
    return true, "Preview visual local; nao representa um disparo confirmado."
end
function Game:_joinServer(small)
    local servers
    if type(self.adapters.ListServers) == "function" then
        local ok, result = pcall(self.adapters.ListServers)
        if not ok then return false, tostring(result) end
        servers = result
    else
        local environment = getfenv()
        local request = environment.request or environment.http_request
        if type(request) ~= "function" then return false, "API HTTP indisponivel." end
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local ok, response = pcall(request, { Url = url, Method = "GET" })
        if not ok then return false, tostring(response) end
        if not response.Success and response.StatusCode ~= 200 then return false, "Falha HTTP ao listar servidores." end
        local parsedOk, body = pcall(HttpService.JSONDecode, HttpService, response.Body)
        if not parsedOk then return false, "Resposta de servidores invalida." end
        servers = body.data
    end
    if type(servers) ~= "table" then return false, "Nenhuma lista de servidores foi recebida." end
    local candidates = {}
    for _, server in ipairs(servers) do
        if type(server) == "table" and server.id ~= game.JobId and type(server.id) == "string"
            and type(server.playing) == "number" and type(server.maxPlayers) == "number" and server.playing < server.maxPlayers then
            table.insert(candidates, server)
        end
    end
    if #candidates == 0 then return false, "Nenhum servidor publico disponivel nesta pagina." end
    if small then table.sort(candidates, function(a, b) return a.playing < b.playing end) end
    local chosen = candidates[small and 1 or math.random(1, #candidates)]
    local ok, message = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, chosen.id, self.player)
    return ok, ok and "Solicitacao de teleporte enviada." or tostring(message)
end

function Game:Action(id, payload)
    if type(self.adapters[id]) == "function" then return self:_adapter(id, payload) end
    local supported, reason = self:Supports(id)
    if supported ~= true then return false, reason or "Acao nao gerenciada pelo modulo do jogo." end
    if id == "webhook.test" then return self:_sendWebhook(true) end
    if id == "murderer.target" then
        local userId = type(payload) == "table" and payload.userId or tonumber(payload)
        return self:_knifeAttack(userId and Players:GetPlayerByUserId(userId), false)
    end
    if id == "sheriff.pickup" then return self:_pickup() end
    if id == "sheriff.shoot" then return self:_shoot() end
    if id == "tracers.preview" then return self:_previewTracer() end
    if id == "server.hop" or id == "server.small" then return self:_joinServer(id == "server.small") end
    if id == "server.copyJob" then getfenv().setclipboard(game.JobId) return true, "Job ID copiado." end
    if id == "server.rejoin" or id == "server.joinJob" then
        local jobId = id == "server.rejoin" and game.JobId or self:_get("server.jobId", "")
        if type(payload) == "string" and #payload > 0 then jobId = payload end
        if type(jobId) ~= "string" or #jobId < 1 then return false, "Preencha um Job ID." end
        local ok, message = pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, jobId, self.player)
        return ok, ok and "Solicitacao de teleporte enviada." or tostring(message)
    end
    if id:sub(1, 9) == "teleport." then
        local root = rootOf(self.player)
        if not root then return false, "Personagem indisponivel." end
        local destination
        if id == "teleport.player" then
            local userId = type(payload) == "table" and payload.userId or tonumber(payload)
            destination = rootOf(userId and Players:GetPlayerByUserId(userId))
        elseif id == "teleport.murderer" then destination = rootOf(self:_target("murderer"))
        elseif id == "teleport.sheriff" then destination = rootOf(self:_target("sheriff"))
        elseif id == "teleport.lobby" then destination = self.adapters.LobbyTarget or self:_mapSpawn(true)
        elseif id == "teleport.map" then destination = self.adapters.MapTarget or self:_mapSpawn(false) end
        local targetCFrame = typeof(destination) == "CFrame" and destination
            or (typeof(destination) == "Vector3" and CFrame.new(destination))
        if typeof(destination) == "Instance" then
            local part = partOf(destination)
            if part then targetCFrame = part.CFrame end
        end
        if not targetCFrame then return false, "Destino nao observado ou nao configurado." end
        self:_cancelFarm()
        root.CFrame = targetCFrame + Vector3.new(0, 3, 0)
        return true, "Movimento local aplicado; o servidor pode corrigir a posicao."
    end
    return false, "Este controle nao e uma acao."
end
function Game:_tick()
    if not self.alive then return end
    self:_refreshRoles()
    self:_updateMarkers()
    self.circle.Visible = self:_get("sheriff.fovCircle", false) == true
    if (self:_get("sheriff.autoPickup", false) or self:_get("farm.pickup", false)) and os.clock() - self.pickupAt > 3
        and not findTool(self.player, "Gun") and self:_gunPart() then self:_pickup() end
    self:_farm()
    if os.clock() - (self.lastKnifeAt or 0) >= 0.7 and (self:_get("murderer.aura", false) or self:_get("murderer.autoThrow", false)) then
        self.lastKnifeAt = os.clock()
        local localRoot = rootOf(self.player)
        local nearest, distance
        for _, target in ipairs(Players:GetPlayers()) do
            local targetRoot = target ~= self.player and rootOf(target)
            if localRoot and targetRoot then
                local magnitude = (targetRoot.Position - localRoot.Position).Magnitude
                if not distance or magnitude < distance then nearest, distance = target, magnitude end
            end
        end
        if nearest then
            if self:_get("murderer.aura", false) and distance <= 8 then self:_knifeAttack(nearest, false)
            elseif self:_get("murderer.autoThrow", false) then self:_knifeAttack(nearest, true) end
        end
    end
    if self:_get("webhook.enabled", false) then
        if not self.nextWebhookAt then self.nextWebhookAt = os.clock() + self:_webhookInterval() end
        if os.clock() >= self.nextWebhookAt then
            self.nextWebhookAt = os.clock() + self:_webhookInterval()
            self:_sendWebhook(false)
        end
    end
end
function Game:Destroy()
    if not self.alive then return end
    self.alive = false
    self.webhookGeneration += 1
    self.webhookInFlight = nil
    self.shot = nil
    self.roleEpoch += 1
    if self.roleConnection then self.roleConnection:Disconnect() end
    RunService:UnbindFromRenderStep(self.aimRenderName)
    self:_cancelFarm()
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    table.clear(self.connections)
    self.folder:Destroy()
    self.visualGui:Destroy()
    table.clear(self.markers)
    table.clear(self.gunMarkers)
end

return Game
