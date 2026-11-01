local Controller = require("../src/Controller")
local Catalog = require("../src/Catalog")
local applied, rejectMethod = {}, false
local runtime = {}
function runtime:Supports() return true end
function runtime:Set(id, value)
    if id == "farm.method" and rejectMethod then return false, "Simulated rejection" end
    applied[id] = value
    return true
end
function runtime:Destroy() end
local controller = Controller.new(Catalog)
controller:SetHandlers({ runtime })
for method, maximum in pairs({ Fast = 24, ["Under Map"] = 22, Teleport = 26 }) do
    assert(controller:Set("farm.method", method))
    local minimum, limit = controller:GetBounds("farm.speed")
    assert(minimum == 1 and limit == maximum, "Wrong bound for " .. method)
    assert(controller:Set("farm.speed", 999))
    assert(controller:Get("farm.speed") == maximum and applied["farm.speed"] == maximum,
        "Runtime received a speed beyond the " .. method .. " limit")
end
assert(controller:Set("farm.method", "Teleport"))
assert(controller:Set("farm.speed", 26))
assert(controller:Set("farm.method", "Under Map"))
assert(controller:Get("farm.speed") == 22, "Method changes must immediately clamp the current speed")
assert(controller:Set("farm.method", "Teleport"))
assert(controller:Set("farm.speed", 26))
rejectMethod = true
assert(not controller:Set("farm.method", "Under Map"))
assert(controller:Get("farm.method") == "Teleport" and controller:Get("farm.speed") == 26,
    "Failed method changes must restore both the method and speed")
rejectMethod = false
assert(controller:Set("farm.method", "Under Map"))
assert(controller:Reset())
assert(controller:Get("farm.method") == "Fast" and controller:Get("farm.speed") == 24,
    "Reset must respect dependency order")
assert(controller:Set("player.spinSpeed", 999))
assert(controller:Get("player.spinSpeed") == 100)
assert(controller:Set("player.spinSpeed", -1))
assert(controller:Get("player.spinSpeed") == 0)
assert(not controller:Set("farm.speed", 0 / 0))
assert(not controller:Set("farm.speed", math.huge))
print("PASS: Fast 24, Under Map 22, Teleport 26, Spin 0-100, rollback and reset")
