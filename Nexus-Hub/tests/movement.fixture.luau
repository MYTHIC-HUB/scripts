-- Headless movement checks. This does not emulate Roblox physics or rendering.
local vectorMethods = {}
local vectorMeta = {}
local function vector(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, vectorMeta) end
function vectorMeta.__add(a, b) return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
function vectorMeta.__sub(a, b) return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
function vectorMeta.__mul(a, b) return vector(a.X * b, a.Y * b, a.Z * b) end
function vectorMeta.__index(a, key)
    if key == "Magnitude" then return math.sqrt(a.X ^ 2 + a.Y ^ 2 + a.Z ^ 2) end
    if key == "Unit" then return a * (1 / a.Magnitude) end
    return vectorMethods[key]
end
local Vector3 = { new = vector, zero = vector(), one = vector(1, 1, 1) }
local frameMeta = {}
local function frame(position) return setmetatable({ Position = position or vector() }, frameMeta) end
function frameMeta.__mul(a) return frame(a.Position) end
function frameMeta.__index(a, key) if key == "Rotation" then return frame() end end
local CFrame = { new = frame, Angles = function() return frame() end }
local Color3 = { fromRGB = function() return {} end }
local Workspace = { FallenPartsDestroyHeight = -500 }
local services = { Workspace = Workspace }
local game = { GetService = function(_, name) services[name] = services[name] or {}; return services[name] end }

-- INSERT_GAME_MODULE

local limits = { Fast = 24, ["Under Map"] = 22 }
for method, maximum in pairs(limits) do
    for _, stepTime in ipairs({ 1 / 120, 1 / 30, 0.2 }) do
        local character = {}
        local humanoid = { Health = 100 }
        local root = setmetatable({ Position = vector(0, 20, 0), Parent = character }, {
            __newindex = function(object, key, value)
                if key == "CFrame" then rawset(object, "Position", value.Position)
                else rawset(object, key, value) end
            end,
        })
        function root:IsA(name) return name == "BasePart" end
        function character:IsDescendantOf(object) return object == Workspace end
        function character:FindFirstChild(name) if name == "HumanoidRootPart" then return root end end
        function character:FindFirstChildOfClass(name) if name == "Humanoid" then return humanoid end end
        local player = { Character = character }
        local settings = { ["farm.enabled"] = true, ["farm.speed"] = 999 }
        local instance = setmetatable({
            player = player, alive = true,
            farmTarget = { Parent = {}, Position = vector(1000, 20, 0) },
            farmSession = { root = root, humanoid = humanoid, character = character, method = method,
                clock = 0, rotation = frame(), position = {}, orientation = {} },
        }, Game)
        function instance:_get(id, fallback)
            local value = settings[id]
            if value == nil then return fallback end
            return value
        end
        local cancelled = false
        function instance:_cancelFarm() cancelled = true; self.farmSession = nil end
        local origin, traveled, elapsed = root.Position, 0, 0
        for _ = 1, 90 do
            local before = root.Position
            instance:_stepFarm(stepTime)
            traveled += (root.Position - before).Magnitude
            elapsed += stepTime
            assert(traveled <= maximum * elapsed + 0.00001, method .. " exceeded its movement cap")
            assert(not cancelled and root.Position.X == root.Position.X, "Unexpected cancellation or NaN")
        end
        assert((root.Position - origin).Magnitude > 0, method .. " never moved")
        settings["player.fly"] = true
        instance:_stepFarm(stepTime)
        assert(cancelled and instance.farmSession == nil, "Fly must cancel conflicting farm constraints")
    end
end
print("PASS: continuous Fast/Under Map stepping obeys speed caps across frame rates and cancels for Fly")
