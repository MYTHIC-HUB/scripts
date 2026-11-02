-- Checks state transitions only; no networking, physics or rendering is simulated.
local vectorMeta, frameMeta = {}, {}
local function vector(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, vectorMeta) end
function vectorMeta.__add(a, b) return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
function vectorMeta.__sub(a, b) return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
function vectorMeta.__mul(a, b) return vector(a.X * b, a.Y * b, a.Z * b) end
function vectorMeta.__eq(a, b) return a.X == b.X and a.Y == b.Y and a.Z == b.Z end
function vectorMeta.__index(a, key) if key == "Magnitude" then return math.sqrt(a.X ^ 2 + a.Y ^ 2 + a.Z ^ 2) end end
local function frame(position, yaw) return setmetatable({ Position = position or vector(), Yaw = yaw or 0 }, frameMeta) end
function frameMeta.__mul(a, b) return frame(a.Position + b.Position, a.Yaw + b.Yaw) end
function frameMeta.__eq(a, b) return a.Position == b.Position and a.Yaw == b.Yaw end
local Vector3 = { new = vector, zero = vector() }
local CFrame = { new = frame, Angles = function(_, yaw) return frame(vector(), yaw) end }
local Enum = { RenderPriority = { Camera = { Value = 200 } } }
local function signal()
    local result = { listeners = {} }
    function result:Connect(callback)
        local connection = { connected = true }
        function connection:Disconnect() self.connected = false end
        table.insert(self.listeners, { callback = callback, connection = connection })
        return connection
    end
    function result:Fire(...)
        for _, entry in ipairs(self.listeners) do if entry.connection.connected then entry.callback(...) end end
    end
    return result
end
local heartbeat = signal()
local runService = { Heartbeat = heartbeat, bindings = {} }
function runService:BindToRenderStep(name, priority, callback)
    assert(priority < 200, "Restoration must run before the camera")
    self.bindings[name] = callback
end
function runService:UnbindFromRenderStep(name) self.bindings[name] = nil end
function runService:Render() for _, callback in pairs(self.bindings) do callback() end end
local workspace = {}
local function characterAt(x)
    local character = {}
    local root = { CFrame = frame(vector(x, 5, 0)), Parent = character,
        AssemblyLinearVelocity = vector(1, 2, 3), AssemblyAngularVelocity = vector(4, 5, 6), Anchored = false }
    function root:IsA(name) return name == "BasePart" end
    local humanoid = { Parent = character, Health = 100, MoveDirection = vector(), Sit = false, PlatformStand = false }
    function humanoid:Move(direction) self.MoveDirection = direction end
    function character:FindFirstChild(name) if name == "HumanoidRootPart" then return root end end
    function character:FindFirstChildOfClass(name) if name == "Humanoid" then return humanoid end end
    function character:IsDescendantOf(object) return object == workspace end
    return character, root, humanoid
end
local character, root, humanoid = characterAt(10)
local player = { Character = character, CharacterRemoving = signal() }
local settings = { ["player.antiAim"] = true, ["player.antiAim.strength"] = 10 }
local input = { GetFocusedTextBox = function() return nil end }

-- INSERT_DESYNC_MODULE

local instance = Desync.new({ settings = settings, random = { NextNumber = function() return 0 end },
    services = { Players = { LocalPlayer = player }, RunService = runService,
        UserInputService = input, Workspace = workspace } })
local original, linear, angular = root.CFrame, root.AssemblyLinearVelocity, root.AssemblyAngularVelocity
heartbeat:Fire()
assert(root.CFrame ~= original and (root.CFrame.Position - original.Position).Magnitude <= 10, "Pose offset must be real and bounded")
assert(root.AssemblyLinearVelocity ~= linear and humanoid.MoveDirection.Magnitude > 0, "Enabled flags must change velocity and movement")
runService:Render()
assert(root.CFrame == original and root.AssemblyLinearVelocity == linear and root.AssemblyAngularVelocity == angular,
    "Rendering must see restored state")
assert(humanoid.MoveDirection == vector(), "Movement direction must be restored")
heartbeat:Fire()
heartbeat:Fire()
assert((root.CFrame.Position - original.Position).Magnitude == 10, "Missed render must not accumulate offsets")
assert(instance:Set("player.antiAim", false))
assert(root.CFrame == original and instance.snapshot == nil, "OFF must restore an in-flight frame")
assert(instance:Set("player.antiAim", true))
heartbeat:Fire()
local teleported = frame(vector(500, 5, 0))
root.CFrame, root.AssemblyLinearVelocity = teleported, vector(100, 0, 0)
runService:Render()
assert(root.CFrame == teleported and root.AssemblyLinearVelocity == vector(100, 0, 0), "External corrections must win")
settings["farm.enabled"] = true
heartbeat:Fire()
assert(instance.snapshot == nil and root.CFrame == teleported, "Farm constraints must pause Desync")
settings["farm.enabled"] = false
humanoid.MoveDirection = vector(1, 0, 0)
heartbeat:Fire()
assert(instance.snapshot == nil, "Smart Pause must preserve live movement")
humanoid.MoveDirection = vector()
assert(instance:Set("player.antiAim.spoofVelocity", false))
assert(instance:Set("player.antiAim.spoofMoveDirection", false))
assert(instance:Set("player.antiAim.sideProfile", false))
local priorVelocity = root.AssemblyLinearVelocity
heartbeat:Fire()
assert(root.AssemblyLinearVelocity == priorVelocity and humanoid.MoveDirection == vector() and root.CFrame.Yaw == 0,
    "Disabled subfeatures must not write their properties")
runService:Render()
assert(not instance:Set("player.antiAim.strength", 0 / 0))
assert(not instance:Set("player.antiAim.mode", "invented"))
assert(instance:Set("player.antiAim.strength", 100) and settings["player.antiAim.strength"] == 10)
heartbeat:Fire()
local nextCharacter, nextRoot = characterAt(900)
player.Character = nextCharacter
local nextPose = nextRoot.CFrame
runService:Render()
assert(nextRoot.CFrame == nextPose and instance.snapshot == nil, "Stale frames must not touch a new character")
heartbeat:Fire()
instance:Destroy()
assert(nextRoot.CFrame == nextPose and next(runService.bindings) == nil, "Unload must restore and unbind")
instance:Destroy()
heartbeat:Fire()
assert(not instance:Set("player.antiAim", true), "Destroyed modules must stay inactive")
print("PASS: Desync frame restoration, pause flags, bounded offsets, external corrections, respawn and unload")
