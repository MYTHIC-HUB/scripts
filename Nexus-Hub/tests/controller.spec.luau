local Controller = require("../src/Controller")

local function expect(value, message)
    assert(value, message)
end
local catalog = { {
    id = "test", sections = { { controls = {
        { id = "test.enabled", type = "toggle", default = false },
        { id = "test.value", type = "slider", default = 10, min = 0, max = 20, step = 2 },
        { id = "test.mode", type = "select", default = "A", options = { "A", "B" } },
        { id = "test.text", type = "input", default = "", maxLength = 4 },
        { id = "test.blocked", type = "toggle", default = false },
        { id = "test.failure", type = "toggle", default = false },
        { id = "ui.scale", type = "slider", default = 1, min = 0.4, max = 2 },
    } } },
} }
local applied, destroyed, unloaded = {}, false, false
local toggleAvailable = true
local onSet
local handler = {}
function handler:Supports(id)
    if id == "test.blocked" then return false, "Sem integracao" end
    if id == "test.enabled" and not toggleAvailable then return false, "Ferramenta removida" end
    if string.sub(id, 1, 5) == "test." then return true end
    return nil
end
function handler:Set(id, value)
    if onSet then return onSet(id, value) end
    if id == "test.failure" then error("Falha simulada") end
    applied[id] = value
    return true
end
function handler:Action(id, payload)
    return true, payload and payload.value
end
function handler:GetStats() return { confirmed = 3 } end
function handler:GetPlayers() return { { userId = 42 } } end
function handler:Destroy() destroyed = true end
local controller = Controller.new(catalog, {
    unload = function() unloaded = true end,
    set = function() return nil end,
})
controller:SetHandlers({ handler })
expect(controller:Get("test.enabled") == false, "Boolean false must survive Get")
expect(controller:Set("test.enabled", true), "Supported toggle")
expect(applied["test.enabled"] == true, "Setting must reach runtime")
expect(not controller:Set("test.enabled", "true"), "Reject non-boolean toggle")
expect(controller:Set("test.value", 19), "Numeric update")
expect(controller:Get("test.value") == 20, "Round to step")
expect(controller:Set("test.value", -30) and controller:Get("test.value") == 0, "Clamp below range")
expect(not controller:Set("test.value", 0 / 0), "Reject NaN")
expect(not controller:Set("test.value", math.huge), "Reject infinity")
expect(not controller:Set("test.mode", "invented"), "Reject unverified dropdown option")
expect(controller:Set("test.mode", "B"), "Accept listed option")
expect(controller:Set("test.text", "abcdef") and controller:Get("test.text") == "abcd", "Bound text")
expect(not controller:Set("test.blocked", true), "Unavailable control must not activate")
expect(controller:Get("test.blocked") == false, "Unavailable control retains previous state")
expect(not controller:Set("test.failure", true), "Catch runtime failure")
expect(controller:Get("test.failure") == false, "Rollback failed update")
expect(controller:Set("ui.scale", 0.6), "Native UI setting")
expect(controller:GetStats().confirmed == 3, "Expose confirmed stats")
expect(controller:GetPlayers()[1].userId == 42, "Expose player list")
expect(controller:Action("test.action", { value = "ok" }), "Dispatch action")
onSet = function(id, value)
    onSet = nil
    expect(id == "test.value" and value == 18, "Reentrant fixture")
    expect(controller:Set("test.value", 4), "Newer setting completes first")
    return false, "Earlier load failed after the newer update"
end
expect(not controller:Set("test.value", 18), "Obsolete request reports replacement")
expect(controller:Get("test.value") == 4 and applied["test.value"] == 4,
    "An earlier failure must not overwrite a newer setting")
toggleAvailable = false
expect(controller:IsSupported("test.enabled"), "Keep OFF accessible after capability disappears")
expect(not controller:Set("test.enabled", true), "Missing capability cannot activate or reapply")
expect(controller:Set("test.enabled", false), "Deactivate after capability disappears")
expect(controller:Get("test.enabled") == false and applied["test.enabled"] == false,
    "Deactivation must reach runtime even with unavailable capability")
toggleAvailable = true
expect(controller:Set("test.enabled", true), "Reactivate when capability returns")
expect(controller:Reset(), "Reset supported settings")
expect(controller:Get("test.enabled") == false and applied["test.enabled"] == false, "Reset reaches runtime")
expect(controller:Action("unload") and unloaded, "Unload callback")
local direct = Controller.new(catalog)
direct:SetHandlers({ handler })
expect(direct:Set("test.enabled", true) and applied["test.enabled"] == true,
    "Runtime dispatch without an optional UI setter")
direct:Destroy()
controller:Destroy()
controller:Destroy()
expect(destroyed, "Destroy runtime")
expect(not controller:Set("test.enabled", true), "No mutations after unload")
print("PASS: controller validation, dispatch, rollback, reset and lifecycle")
