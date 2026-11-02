local Integrations = require("../src/Integrations")
local calls, queued = 0, {}
local entry = { id = "Box", dataType = "MysteryBox", prices = { Coins = 1000 } }
local function instance()
    local settings = { ["boxes.box"] = "Box", ["boxes.currency"] = "Coins", ["boxes.auto"] = true }
    local object = setmetatable({
        alive = true, settings = settings, entries = { entry }, crates = { Box = entry },
        context = { spawn = function(callback) queued[#queued + 1] = callback end },
        profile = { Coins = 2000 }, items = { Reward = { ItemName = "Reward item" } },
        opened = 0, lastDrop = "-", boxGeneration = 0, boxInFlight = false, nextBoxAt = 0,
        connections = {}, eventConnections = {}, modules = {}, survivalGeneration = 0,
    }, Integrations)
    function object:_remote()
        return { InvokeServer = function(_, id, dataType, currency)
            assert(id == "Box" and dataType == "MysteryBox" and currency == "Coins")
            calls += 1
            return "Reward"
        end }
    end
    return object
end

local object = instance()
assert(object:_open())
assert(object.boxInFlight and #queued == 1 and calls == 0)
assert(object:Set("boxes.auto", false))
assert(object:Set("boxes.auto", true))
assert(not object:_open(), "OFF/ON must not release the existing request lock")
assert(#queued == 1)
table.remove(queued, 1)()
assert(calls == 1 and object.opened == 1 and object.lastDrop == "Reward item")
assert(not object.boxInFlight)
object:Destroy()

local cancelled = instance()
assert(cancelled:_open(true))
assert(cancelled:Set("boxes.auto", false))
table.remove(queued, 1)()
assert(calls == 1 and cancelled.opened == 0 and not cancelled.boxInFlight,
    "Turning off must cancel an automatic request that has not started")
cancelled:Destroy()

local selected = instance()
assert(selected:_open(true))
assert(selected:Set("boxes.box", ""), "A box selection must be clearable even with Coins selected")
table.remove(queued, 1)()
assert(calls == 1 and selected.opened == 0 and not selected.settings["boxes.auto"],
    "Clearing the selected box must cancel its queued automatic purchase")
assert(selected.settings["boxes.currency"] == "Auto")
selected:Destroy()

local changedCurrency = instance()
assert(changedCurrency:_open(true))
assert(changedCurrency:Set("boxes.currency", "Auto"))
table.remove(queued, 1)()
assert(calls == 1 and changedCurrency.opened == 0,
    "Changing payment currency must invalidate an older queued automatic purchase")
changedCurrency.pathLoading = true
local previousGeneration = changedCurrency.survivalGeneration
changedCurrency:_characterChanged()
assert(not changedCurrency.pathLoading and changedCurrency.survivalGeneration > previousGeneration,
    "Respawn must unblock pathfinding and invalidate the previous character's route")
changedCurrency:Destroy()

local closed = instance()
assert(closed:_open())
closed:Destroy()
table.remove(queued, 1)()
assert(calls == 1 and closed.opened == 0, "An unloaded hub must never start a queued purchase")
print("PASS: one crate request, OFF/ON lock, queued cancellation and unload")
