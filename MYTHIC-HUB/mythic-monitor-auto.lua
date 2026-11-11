-- Luau | mythic-monitor.lua | Roblox client with Mythic Hub and HTTPS request support
-- Starts automatically with Mythic Hub. Public write-only endpoint; no embedded credentials.
local globals = getgenv()
local config = {url = "https://mythic-hub-ingest.enzogabriel-camargo.chatgpt.site"}
assert(type(config) == "table", "Configure MYTHIC_MONITOR antes de iniciar o monitor.")
assert(type(config.url) == "string" and config.url:match("^https://"), "URL HTTPS obrigatoria.")

local http = game:GetService("HttpService")
local players = game:GetService("Players")
local storage = game:GetService("ReplicatedStorage")
local player = players.LocalPlayer
local send_request = request or http_request or (syn and syn.request)
assert(type(send_request) == "function", "O ambiente nao fornece requisicoes HTTPS.")

if type(globals.__mythic_monitor_stop) == "function" then globals.__mythic_monitor_stop() end
local running, connections = true, {}
local session_id = http:GenerateGUID(false)
local farmed, active_seconds, sequence = 0, 0, 0
local counts, baseline_ready, profile = {}, false, nil
local farm_was_enabled = false

local function farm_enabled()
    local api = globals.__pulseFarmAPI
    if type(api) ~= "table" or type(api.getEnabled) ~= "function" then return false end
    local ok, value = pcall(api.getEnabled)
    return ok and value == true
end

local function balance()
    local ok, value = pcall(function()
        if not profile then
            local modules = storage:FindFirstChild("Modules")
            local module = modules and modules:FindFirstChild("ProfileData")
            if not module then return nil end
            profile = require(module)
        end
        local owned = profile.Materials and profile.Materials.Owned
        return owned and tonumber(owned.Coins) or nil
    end)
    if ok and value and value >= 0 and value == math.floor(value) then return value end
    return nil
end

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
end

globals.__mythic_monitor_stop = function()
    running = false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(connections)
end

task.spawn(function()
    local remotes = storage:WaitForChild("Remotes", 30)
    local gameplay = remotes and remotes:WaitForChild("Gameplay", 30)
    local collected = gameplay and gameplay:WaitForChild("CoinCollected", 30)
    if not running then return end
    if not collected then
        warn("MYTHIC Monitor: evento CoinCollected indisponivel; saldo continua sendo enviado.")
        return
    end
    local function round_start()
        counts, baseline_ready = {}, true
    end
    -- Only RoundStart resets the counters. CoinsStarted can arrive after a collection.
    local round = gameplay:FindFirstChild("RoundStart")
    if round then connect(round.OnClientEvent, round_start) end
    connect(collected.OnClientEvent, function(kind, count)
        -- Events for candy and keys never contribute to the ordinary coin counter.
        if kind ~= "Coin" and kind ~= "Coins" then return end
        if type(count) ~= "number" or count < 0 or count ~= math.floor(count) then return end
        local previous = counts.coins
        local added = 0
        if previous ~= nil then
            if count >= previous then added = count - previous else added = count end
        elseif baseline_ready then
            added = count
        end
        -- A first observation mid-round establishes a baseline, avoiding old gains.
        counts.coins = count
        if farm_enabled() and farm_was_enabled then farmed += added end
    end)
end)

task.spawn(function()
    local last = os.clock()
    farm_was_enabled = farm_enabled()
    while running do
        task.wait(1)
        local now = os.clock()
        local enabled = farm_enabled()
        if enabled and farm_was_enabled then active_seconds += math.min(now - last, 5) end
        farm_was_enabled, last = enabled, now
    end
end)

task.spawn(function()
    local failures = 0
    while running do
        sequence += 1
        local payload = {
            user_id = player.UserId,
            username = player.Name,
            display_name = player.DisplayName,
            session_id = session_id,
            balance = balance(),
            farmed = farmed,
            active_seconds = math.floor(active_seconds),
            farming = farm_enabled(),
            sequence = sequence,
        }
        local ok, response = pcall(send_request, {
            Url = config.url:gsub("/+$", "") .. "/api/heartbeat",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
            },
            Body = http:JSONEncode(payload),
        })
        local status = ok and type(response) == "table" and tonumber(response.StatusCode) or nil
        if status and status >= 200 and status < 300 then
            failures = 0
        else
            failures += 1
            warn("MYTHIC Monitor: envio falhou (HTTP " .. tostring(status or "indisponivel") .. ").")
        end
        task.wait(math.min(30 * (2 ^ math.min(failures, 3)), 180))
    end
end)

print("MYTHIC Monitor: envio ativo. Apenas nick, UserId, saldo e estatisticas de farm sao enviados.")
