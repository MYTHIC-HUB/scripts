local Integrations = require("../src/Integrations")
local calls, resets, legacyCalls, killAccesses = 0, 0, 0, 0
local now = 10
local character = {}
local player = setmetatable({ Character = character }, {
    __index = function(_, key)
        if key == "Kill" then killAccesses += 1; error("Player.Kill must never be accessed") end
    end,
})
local gameFeatures = { farmSession = {}, gunInFlight = false }
function gameFeatures:_target() return {} end
function gameFeatures:ShootFromFarm() calls += 1; return true end
function gameFeatures:_shoot() legacyCalls += 1; error("The legacy camera path must not run during Under Map") end
function gameFeatures:_killAll() return true end
local function fixture(settings)
    local object = setmetatable({
        alive = true, player = player, settings = settings or {}, bagActions = {},
        inRound = true, roundEnded = false, round = 0, survivalGeneration = 0,
        context = { gameFeatures = gameFeatures, clock = function() return now end,
            adapters = { ResetCharacter = function() resets += 1; return true end } },
        connections = {}, eventConnections = {}, modules = {}, boxGeneration = 0,
    }, Integrations)
    object:_acceptBag({ kind = "Candy", current = 50, maximum = 50, full = true })
    return object
end

local full = { kind = "Candy", current = 50, maximum = 50, full = true }
local shot = fixture({ ["farm.shootFull"] = true, ["farm.respawnFull"] = false })
shot:_tickBag("hero")
assert(calls == 1 and resets == 0 and legacyCalls == 0 and killAccesses == 0)
for _ = 1, 20 do
    now += 1
    shot:_acceptBag(full)
    shot:_tickBag("hero")
end
assert(calls == 1, "Repeated full bag events must not repeat the shot")
shot:_acceptBag({ kind = "Candy", current = 0, maximum = 50, full = false })
shot:_acceptBag(full)
shot:_tickBag("hero")
assert(calls == 2, "A newly filled bag can request one new shot")

local both = fixture({ ["farm.shootFull"] = true, ["farm.respawnFull"] = true })
both:_tickBag("hero")
assert(calls == 3 and resets == 0, "Shoot and reset must not run together")
both:_tickBag("hero")
assert(calls == 3 and resets == 0)

local waiting = fixture({ ["farm.shootFull"] = true, ["farm.respawnFull"] = true })
waiting:_tickBag("innocent")
assert(calls == 3 and resets == 0, "Waiting for a gun must never fall through to reset")
gameFeatures.gunInFlight = true
waiting:_tickBag("hero")
assert(waiting.bagFlow.attempts == 0, "An existing request must not consume a retry or start another shot")
gameFeatures.gunInFlight = false
waiting:_tickBag("hero")
assert(calls == 4 and resets == 0)

local failures = fixture({ ["farm.shootFull"] = true })
local failedAttempts = 0
function gameFeatures:ShootFromFarm() failedAttempts += 1; return false end
for _ = 1, 20 do now += 2; failures:_tickBag("hero") end
assert(failedAttempts == 3, "Unsuccessful bag actions must have bounded retries")
function gameFeatures:ShootFromFarm() calls += 1; return true end

local respawned = fixture({ ["farm.shootFull"] = true })
player.Character = {}
respawned:_tickBag("hero")
assert(calls == 4 and not respawned.inRound and respawned.bag == nil,
    "An old full bag must not act on a new character")
local ended = fixture({ ["farm.shootFull"] = true })
ended:_roundChanged(false)
assert(not ended:_acceptBag(full), "A late CoinCollected must not reactivate an ended round")
ended:_tickBag("hero")
assert(calls == 4)
ended:_roundChanged(true)
ended:_acceptBag(full)
ended:_tickBag("hero")
assert(calls == 5)

local removed = fixture({ ["farm.shootFull"] = true })
removed:Destroy()
removed:_tickBag("hero")
assert(calls == 5 and killAccesses == 0, "Unload must cancel all pending full-bag actions")

local resetOnly = fixture({ ["farm.respawnFull"] = true })
resetOnly:_tickBag("innocent")
resetOnly:_tickBag("innocent")
assert(resets == 1, "An explicit reset adapter can run only once per full bag")
local absent = fixture({ ["farm.respawnFull"] = true })
absent.context.adapters = {}
absent:_tickBag("innocent")
assert(resets == 1 and killAccesses == 0, "No reset protocol means no synthetic Player.Kill call")
print("PASS: one full-bag action, shoot priority, bounded retries, round/character cancellation and no synthetic reset")
