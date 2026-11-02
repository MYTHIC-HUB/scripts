-- Headless state/command checks; this does not emulate Roblox or its server.
local now = 10
local realOs = os
local os = setmetatable({ clock = function() return now end }, { __index = realOs })
local nativeTypeof = typeof
local function typeof(value)
    if type(value) == "table" and value._mockPart then return "Instance" end
    return nativeTypeof(value)
end
local vectorMeta = {}
local function vector(x, y, z) return setmetatable({ X = x or 0, Y = y or 0, Z = z or 0 }, vectorMeta) end
function vectorMeta.__add(a, b) return vector(a.X + b.X, a.Y + b.Y, a.Z + b.Z) end
function vectorMeta.__sub(a, b) return vector(a.X - b.X, a.Y - b.Y, a.Z - b.Z) end
function vectorMeta.__mul(a, b) return vector(a.X * b, a.Y * b, a.Z * b) end
function vectorMeta.__div(a, b) return a * (1 / b) end
function vectorMeta.__index(a, key)
    if key == "Magnitude" then return math.sqrt(a.X ^ 2 + a.Y ^ 2 + a.Z ^ 2) end
    if key == "Unit" then return a / a.Magnitude end
end
local Vector3 = { new = vector, zero = vector() }
local frameMeta = {}
local function frame(x, y, z)
    return setmetatable({ Position = type(x) == "table" and x or vector(x, y, z) }, frameMeta)
end
function frameMeta.__mul(a, b) return frame(a.Position + b.Position) end
function frameMeta.__add(a, b) return frame(a.Position + b) end
function frameMeta.__index(_, key) if key == "Rotation" then return frame() end end
local CFrame = { new = frame, Angles = function() return frame() end }
local Color3 = { fromRGB = function() return {} end }
local Enum = {
    PositionAlignmentMode = { OneAttachment = "OneAttachment" },
    OrientationAlignmentMode = { OneAttachment = "OneAttachment" },
    HumanoidStateType = { GettingUp = "GettingUp" },
}
local createdClasses = {}
local Instance = { new = function(class)
    table.insert(createdClasses, class)
    return { ClassName = class, Destroy = function(self) self.Parent = nil; self.destroyed = true end }
end }
local Workspace = { FallenPartsDestroyHeight = -500, CurrentCamera = { CFrame = frame(5, 10, 15) } }
local services = { Workspace = Workspace, CollectionService = { GetTagged = function() return {} end } }
local game = { GetService = function(_, name) services[name] = services[name] or {}; return services[name] end }
local task = { defer = function(callback) callback() end, spawn = function(callback) callback() end }

-- INSERT_GAME_MODULE

local function same(a, b, message) assert((a - b).Magnitude < 0.000001, message) end
local function actor(position)
    local character = { tools = {} }
    local humanoid = { Parent = character, Health = 100, AutoRotate = true, PlatformStand = false }
    function humanoid:ChangeState() end
    function humanoid:EquipTool(tool)
        assert(not self.failEquip, "Tool disappeared while equipping")
        tool.Parent = character
    end
    local root = setmetatable({ Parent = character, Position = position, CanCollide = true,
        AssemblyLinearVelocity = vector(), AssemblyAngularVelocity = vector(), _pose = frame(position), writes = 0 }, {
        __index = function(self, key) if key == "CFrame" then return rawget(self, "_pose") end end,
        __newindex = function(self, key, value)
            if key == "CFrame" then
                rawset(self, "_pose", value); rawset(self, "Position", value.Position)
                rawset(self, "writes", self.writes + 1)
            else rawset(self, key, value) end
        end,
    })
    function root:IsA(name) return name == "BasePart" end
    function character:IsDescendantOf(object) return object == Workspace end
    function character:FindFirstChild(name) if name == "HumanoidRootPart" then return root end end
    function character:FindFirstChildOfClass(name) if name == "Humanoid" then return humanoid end end
    function character:GetChildren() return self.tools end
    function character:GetDescendants() return { root } end
    local backpack = { GetChildren = function() return {} end }
    local player = { Character = character }
    function player:FindFirstChildOfClass(name) if name == "Backpack" then return backpack end end
    return player, root, humanoid
end
local function fixture(settings)
    local player, root, humanoid = actor(vector(0, 23, 0))
    local instance = setmetatable({ player = player, alive = true, settings = settings or {}, context = {},
        adapters = {}, visited = {}, moves = 0, circle = {} }, Game)
    local lobby = { CFrame = frame(0, 20, 0), Parent = Workspace }
    function instance:_mapSpawn() return lobby end
    function instance:_updateMarkers() end
    function instance:_notify(message) self.lastNotice = message end
    return instance, root, humanoid
end
local function drop(position)
    local part = { Parent = Workspace, Position = position, _mockPart = true, Transparency = 1,
        attributes = { CoinID = "Candy" }, touch = {}, Name = "Coin_Server" }
    function part:IsA(name) return name == "BasePart" end
    function part:GetAttribute(name) return self.attributes[name] end
    function part:FindFirstChild(name) if name == "CoinVisual" then return self.visual end end
    function part:FindFirstChildWhichIsA(name) if name == "TouchTransmitter" then return self.touch end end
    return part
end

-- Teleport performs one lobby wait, one brief coin visit, then returns to lobby.
do
    local instance, root = fixture({ ["farm.enabled"] = true, ["farm.method"] = "Teleport", ["farm.speed"] = 26 })
    local coin = drop(vector(150, 20, 70))
    local lobby = root.Position
    assert(instance:_beginTeleport(coin, root))
    same(root.Position, lobby, "Teleport must wait in the lobby")
    local due = instance.teleportCycle.due
    now = due - 0.001; instance:_stepTeleport()
    same(root.Position, lobby, "Teleport left before the configured interval")
    now = due; instance:_stepTeleport()
    same(root.Position, coin.Position + vector(0, 1, 0), "Teleport did not visit its coin")
    assert(instance.moves == 1 and instance.teleportCycle.phase == "contact")
    now = instance.teleportCycle.due + 0.001; instance:_stepTeleport()
    same(root.Position, lobby, "Teleport did not return to the lobby")
    assert(instance.teleportCycle == nil and instance.visited[coin] > now)
    assert(math.abs(instance.nextFarmAt - now - 0.005) < 0.000001, "Return added a second speed interval")
    local fastest = instance:_teleportInterval()
    instance.settings["farm.speed"] = 13
    assert(instance:_teleportInterval() == fastest * 2)
    instance.settings["farm.speed"] = 999
    assert(instance:_teleportInterval() == fastest, "Teleport speed must cap at 26")
    instance:_beginTeleport(coin, root)
    instance.context.integrations = { bag = { full = true } }
    now = instance.teleportCycle.due; instance:_stepTeleport()
    same(root.Position, lobby, "Full bag must keep Teleport in the lobby")
    assert(instance.teleportCycle == nil)
    instance.context.integrations.bag.full = false
    instance:_beginTeleport(coin, root)
    now = instance.teleportCycle.due; instance:_stepTeleport()
    local replacement, replacementRoot = actor(vector(70, 40, 0))
    instance.player.Character = replacement.Character
    now += 1; instance:_stepTeleport()
    same(replacementRoot.Position, vector(70, 40, 0), "Old Teleport cycle moved a respawned character")
    assert(instance.teleportCycle == nil)
end

-- Pickup begins a bounded movement route, including when replacing Under Map.
do
    local instance, root, humanoid = fixture({ ["farm.enabled"] = true, ["farm.method"] = "Under Map", ["farm.speed"] = 22 })
    root.CFrame = frame(20, -5, 0)
    instance:_startFarmSession(root, humanoid, "Under Map")
    instance.farmSession.surface = frame(20, 23, 0)
    local gun = drop(vector(100, 20, 0))
    function instance:_gunPart() return gun end
    local origin, writes = root.Position, root.writes
    assert(instance:_pickup(true)); assert(instance:_servicePickup())
    same(root.Position, origin, "Starting automatic pickup teleported the character")
    assert(root.writes == writes and instance.farmTargetKind == "gun")
    instance.context.integrations = { bag = { full = true } }
    instance:_stepFarm(1 / 60)
    assert((root.Position - origin).Magnitude > 0, "Full bag blocked the pickup route")
    assert((root.Position - origin).Magnitude <= 22 / 60 + 0.000001, "Pickup exceeded Under Map speed")
    -- Disabling the last automatic pickup option clears its pending route.
    instance.settings["farm.pickup"] = true
    assert(instance:Set("farm.pickup", false))
    assert(instance.pickupRoute == nil and instance.farmTargetKind == nil)

    -- Manual pickup while farm is off must replace Under Map without restoring surface.
    instance.settings["farm.enabled"] = false
    local before, beforeWrites = root.Position, root.writes
    assert(instance:_pickup(false)); assert(instance:_servicePickup())
    same(root.Position, before, "Replacing Under Map with manual pickup jumped to the surface")
    assert(root.writes == beforeWrites and instance.farmSession.method == "Fast")
    assert(instance:Set("sheriff.autoPickup", false))
    assert(instance.pickupRoute ~= nil, "An unrelated automatic toggle cancelled manual pickup")
    local tool = { Name = "Gun", Parent = instance.player.Character, IsA = function(_, name) return name == "Tool" end }
    instance.player.Character.tools = { tool }
    instance:_servicePickup()
    same(root.Position, before, "Finishing pickup jumped the character")
    assert(instance.pickupRoute == nil and instance.farmSession == nil)
end

-- Bag shots use one deferred RPC and never touch the character pose or camera.
do
    local function shotFixture()
        local instance, root, humanoid = fixture({ ["sheriff.resolver"] = false })
        local target, targetRoot = actor(vector(80, 23, 0))
        local gun = { Parent = instance.player.Character }
        local queue, calls = {}, {}
        local remote = { InvokeServer = function(_, ...) table.insert(calls, { ... }) end }
        instance.context.spawn = function(callback) table.insert(queue, callback) end
        function instance:_target() return target end
        function instance:_weaponRemote() return remote, gun end
        return instance, root, humanoid, target, targetRoot, gun, queue, calls
    end
    local instance, root, _, _, targetRoot, _, queue, calls = shotFixture()
    local pose, camera, writes = root.CFrame, Workspace.CurrentCamera.CFrame, root.writes
    assert(instance:ShootFromFarm())
    assert(not instance:ShootFromFarm() and #queue == 1, "Concurrent shot escaped its lock")
    queue[1]()
    assert(#calls == 1 and calls[1][1] == 1 and calls[1][3] == "AH2")
    same(calls[1][2], targetRoot.Position, "Wrong gun RPC target")
    assert(not instance.gunInFlight and not instance.farmShotInFlight)
    assert(root.CFrame == pose and root.writes == writes and Workspace.CurrentCamera.CFrame == camera,
        "Bag shot changed the camera or character pose")
    for _, cancellation in ipairs({ "unload", "targetRespawn", "selfRespawn", "gunRemoved", "equipError" }) do
        local current, _, humanoid, target, _, gun, pending, dispatched = shotFixture()
        if cancellation == "equipError" then gun.Parent = {}; humanoid.failEquip = true end
        assert(current:ShootFromFarm())
        if cancellation == "unload" then current.alive = false
        elseif cancellation == "targetRespawn" then target.Character = actor(vector()).Character
        elseif cancellation == "selfRespawn" then current.player.Character = actor(vector()).Character
        elseif cancellation == "gunRemoved" then gun.Parent = nil end
        local ok, problem = pcall(pending[1])
        assert(ok, tostring(problem))
        assert(#dispatched == 0, cancellation .. " still invoked the gun RPC")
        assert(not current.gunInFlight and not current.farmShotInFlight, cancellation .. " leaked the shot lock")
    end
end
-- Native collection states can change while the trigger remains parented.
do
    local instance = fixture()
    local coin = drop(vector(0, 20, 0))
    assert(instance:_coinReady(coin), "A transparent Candy trigger with TouchInterest is collectible")
    coin.touch = nil
    assert(coin.Parent and not instance:_coinReady(coin), "A parented trigger with removed touch was incorrectly revisited")
    local hidden = drop(vector(0, 20, 0))
    hidden.visual = { Transparency = 1, IsA = function(_, name) return name == "BasePart" end }
    assert(not instance:_coinReady(hidden), "A hidden CoinVisual must be skipped even if its trigger stays parented")
    hidden.visual.Transparency = 0
    assert(instance:_coinReady(hidden), "An uncollected native coin was filtered out")
end

-- Equal-height coin rows stay monotonic, including when the server keeps touched triggers alive.
for _, method in ipairs({ "Fast", "Under Map" }) do
    local maximum = method == "Fast" and 24 or 22
    local instance, root, humanoid = fixture({ ["farm.enabled"] = true, ["farm.method"] = method, ["farm.speed"] = maximum })
    local baseline = method == "Fast" and 21 or 17.5
    root.CFrame = frame(0, baseline, 0)
    instance.coins = {}
    local coins = {}
    for _, x in ipairs({ 15, 30, 45 }) do
        local coin = drop(vector(x, 20, 0)); instance.coins[coin] = true; table.insert(coins, coin)
    end
    table.clear(createdClasses)
    local lastX = root.Position.X
    for _ = 1, 300 do
        now += 1 / 60
        instance:_farm(); instance:_stepFarm(1 / 60)
        assert(root.Position.X >= lastX - 0.000001, method .. " went backwards toward an already contacted coin")
        assert(math.abs(root.Position.Y - baseline) < 0.000001, "Under Map rose and descended for each coin")
        assert(root.Position.X - lastX <= maximum / 60 + 0.000001, "Continuous contact flow exceeded its cap")
        lastX = root.Position.X
    end
    assert(root.Position.X > 44 and instance.moves == 3, "Continuous route did not contact all three available coins")
    for _, class in ipairs(createdClasses) do
        assert(class ~= "AlignPosition" and class ~= "AlignOrientation", "A competing physics mover was created")
    end
    assert(humanoid.PlatformStand and not humanoid.AutoRotate, "Humanoid movement can still fight the farm controller")
    local session, writes = instance.farmSession, root.writes
    assert(instance:Set("farm.speed", maximum - 1))
    assert(instance.farmSession == session and root.writes == writes, "Moving the speed slider restarted or surfaced the route")
    local baseRotation = session.rotation
    local otherMethod = method == "Fast" and "Under Map" or "Fast"
    assert(instance:Set("farm.method", otherMethod))
    instance:_startFarmSession(root, humanoid, otherMethod, false)
    assert(instance.farmSession.rotation == baseRotation, "Changing method captured the already tilted Under Map pose")
    assert(instance:Set("farm.method", method))
    instance:_startFarmSession(root, humanoid, method, false)
    assert(instance.farmSession.rotation == baseRotation, "Under/Fast switching accumulated a second 90-degree rotation")
    instance.coins = {}
    now += 1; instance:_farm()
    assert(root.writes == writes, "Losing all coins restored a stale surface pose")
    assert(not humanoid.PlatformStand and humanoid.AutoRotate, "Cancelling an empty route did not restore the humanoid")
end

-- Lobby spawn discovery tolerates nested Spawns containers and declared SpawnLocations.
do
    local function container(name, class, children)
        local object = { Name = name, class = class, children = children or {} }
        function object:IsA(kind) return kind == self.class or (kind == "BasePart" and self.class == "SpawnLocation") end
        function object:GetChildren() return self.children end
        function object:GetDescendants()
            local result = {}
            for _, value in ipairs(self.children) do
                table.insert(result, value)
                if value.GetDescendants then for _, nested in ipairs(value:GetDescendants()) do table.insert(result, nested) end end
            end
            return result
        end
        function object:FindFirstChild(query, recursive)
            for _, value in ipairs(self.children) do if value.Name == query then return value end end
            if recursive then for _, value in ipairs(self.children) do if value.FindFirstChild then local result = value:FindFirstChild(query, true); if result then return result end end end end
        end
        return object
    end
    local originalFind, originalChildren = Workspace.FindFirstChild, Workspace.GetChildren
    local spawn = container("SpawnA", "BasePart")
    local world = container("Workspace", "Workspace", { container("RegularLobby", "Model", {
        container("Spawns", "Folder", { container("Nested", "Folder", { spawn }) }),
    }) })
    Workspace.FindFirstChild = function(_, ...) return world:FindFirstChild(...) end
    Workspace.GetChildren = function() return world.children end
    local instance = fixture(); instance._mapSpawn = nil
    assert(instance:_mapSpawn(true) == spawn, "Nested lobby spawns were not discovered")
    local alternate = container("LobbySpawn", "SpawnLocation")
    world.children = { container("Lobby", "Model", { alternate }) }
    assert(instance:_mapSpawn(true) == alternate, "A declared lobby SpawnLocation was not discovered")
    world.children = { alternate }
    assert(instance:_mapSpawn(true) == alternate, "Top-level SpawnLocation was not discovered")
    world.children = { container("ActiveMap", "Model", { container("Spawns", "Folder", { spawn }) }) }
    assert(instance:_mapSpawn(true) == nil, "Map spawns were incorrectly accepted as the lobby")
    Workspace.FindFirstChild, Workspace.GetChildren = originalFind, originalChildren
end
print("PASS: stable Fast/Under contact flow, collection-state filtering, no competing movers, Teleport lobby variants, pickup and bag-shot lifecycle")
