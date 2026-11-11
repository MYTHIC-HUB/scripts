-- Luau | mythic-monitor.lua | Roblox client with Mythic Hub and HTTPS request support
-- Starts automatically with Mythic Hub. Public write-only endpoint; no embedded credentials.
local loader_environment = ...
local globals = getgenv()
local CLIENT_VERSION = "monitor-v3"
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
local farmed, candy_farmed, active_seconds, sequence = 0, 0, 0, 0
local candy_key = nil
local counts, baseline_ready, profile = {}, false, nil
local farm_was_enabled = false

local api_known = false
local last_event_kind = nil
local warned_missing_api = false
local function farm_enabled()
    -- The hub's offline environment has its own globals, separate from getgenv().
    local api
    local function inspect(scope)
        if type(scope) ~= "table" then return nil end
        local environment = scope.PulseOfflineEnvironment
        if type(environment) == "table" and type(environment.getgenv) == "function" then
            local ok, isolated = pcall(environment.getgenv)
            if ok and type(isolated) == "table" and type(isolated.__pulseFarmAPI) == "table" then
                return isolated.__pulseFarmAPI
            end
        end
        if type(scope.__pulseFarmAPI) == "table" then return scope.__pulseFarmAPI end
        return nil
    end
    -- Use the exact environment of the loaded hub, not the executor's unrelated globals.
    api = inspect(loader_environment)
    if not api and type(loader_environment) == "table" and type(loader_environment.getgenv) == "function" then
        local ok, scope = pcall(loader_environment.getgenv)
        if ok then api = inspect(scope) end
    end
    if not api then api = inspect(globals) end
    api_known = type(api) == "table" and type(api.getEnabled) == "function"
    if type(api) ~= "table" or type(api.getEnabled) ~= "function" then
        if not warned_missing_api then
            warned_missing_api = true
            warn("MYTHIC Monitor: aguardando API de estado do farm.")
        end
        return false
    end
    warned_missing_api = false
    local ok, value = pcall(api.getEnabled)
    return ok and value == true
end

local clock_at = os.clock()
farm_was_enabled = farm_enabled()
local function update_clock()
    local now = os.clock()
    if farm_was_enabled then active_seconds += math.max(0, now - clock_at) end
    clock_at, farm_was_enabled = now, farm_enabled()
end

local function balances()
    local ok, coins, candies = pcall(function()
        if not profile then
            local modules = storage:FindFirstChild("Modules")
            local module = modules and modules:FindFirstChild("ProfileData")
            if not module then return nil, nil end
            profile = require(module)
        end
        local owned = profile.Materials and profile.Materials.Owned
        if type(owned) ~= "table" then return nil, nil end
        local latest, selected = nil, nil
        for name, value in pairs(owned) do
            local year = type(name) == "string" and tonumber(name:match("^Candies(%d+)$"))
            if year and tonumber(value) and (not latest or year > latest) then
                latest, selected = year, name
            end
        end
        if selected then candy_key = selected end
        return tonumber(owned.Coins), selected and tonumber(owned[selected]) or nil
    end)
    local function valid(value)
        return type(value) == "number" and value >= 0 and value == math.floor(value) and value or nil
    end
    if not ok then return nil, nil end
    return valid(coins), valid(candies)
end

local last_coins, last_candies = balances()
local balance_farmed, balance_candy_farmed = 0, 0
local balance_at, balance_enabled = os.clock(), farm_enabled()
local function sample_balances()
    local coins, candies = balances()
    local enabled = farm_enabled()
    if enabled and balance_enabled then
        if coins and last_coins then balance_farmed = balance_farmed + math.max(0, coins - last_coins) end
        if candies and last_candies then balance_candy_farmed = balance_candy_farmed + math.max(0, candies - last_candies) end
    end
    last_coins, last_candies, balance_enabled = coins, candies, enabled
    return coins, candies
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
        last_event_kind = tostring(kind):sub(1, 48)
        local currency
        if kind == "Coin" or kind == "Coins" then
            currency = "coins"
        elseif type(kind) == "string" and (kind == "Candy" or kind == "Candies"
            or kind == candy_key or kind:match("^Candies%d+$")) then
            currency = "candies"
        else
            return
        end
        if type(count) ~= "number" or count < 0 or count ~= math.floor(count) then return end
        local previous = counts[currency]
        local added = 0
        if previous ~= nil then
            if count >= previous then added = count - previous else added = count end
        elseif baseline_ready then
            added = count
        end
        -- A first observation mid-round establishes a baseline, avoiding old gains.
        counts[currency] = count
        if farm_enabled() then
            if currency == "candies" then candy_farmed += added else farmed += added end
        end
    end)
end)

-- Sample the actual enabled state every client frame; pause/resume uses a monotonic clock.
connect(game:GetService("RunService").Heartbeat, function()
    update_clock()
    if os.clock() - balance_at >= 1 then balance_at = os.clock(); sample_balances() end
end)

task.spawn(function()
    local failures = 0
    while running do
        update_clock()
        sequence += 1
        local coin_balance, candy_balance = sample_balances()
        local payload = {
            user_id = player.UserId,
            username = player.Name,
            display_name = player.DisplayName,
            session_id = session_id,
            balance = coin_balance,
            candy_balance = candy_balance,
            candy_farmed = math.max(candy_farmed, balance_candy_farmed),
            candy_key = candy_key,
            farmed = math.max(farmed, balance_farmed),
            client_version = CLIENT_VERSION,
            farm_api_known = api_known,
            last_event_kind = last_event_kind,
            active_seconds = math.floor(active_seconds),
            farming = farm_enabled(),
            sequence = sequence,
        }
        local ok, response = pcall(send_request, {
            Url = config.url:gsub("/+$", "") .. "/api/heartbeat",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "Mozilla/5.0",
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
        task.wait(math.min(12 * (2 ^ math.min(failures, 3)), 180))
    end
end)

print("MYTHIC Monitor: envio ativo. Apenas nick, UserId, saldo e estatisticas de farm sao enviados.")
