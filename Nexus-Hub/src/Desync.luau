-- Temporary client pose window, followed by restoration before camera updates.
-- Source mechanism: mm2-source.lua 873-987, inspected as data, never executed.
-- Remote replication and effectiveness require a separate multiplayer test.
local Desync = {}
Desync.__index = Desync

local ROOT = "player.antiAim"
local MANAGED = {
    [ROOT] = true, [ROOT .. ".mode"] = true, [ROOT .. ".direction"] = true,
    [ROOT .. ".strength"] = true, [ROOT .. ".smartPause"] = true,
    [ROOT .. ".spoofVelocity"] = true, [ROOT .. ".spoofMoveDirection"] = true,
    [ROOT .. ".sideProfile"] = true,
}
local DEFAULTS = {
    [ROOT] = false, [ROOT .. ".mode"] = "Desync", [ROOT .. ".direction"] = "Random",
    [ROOT .. ".strength"] = 10, [ROOT .. ".smartPause"] = true,
    [ROOT .. ".spoofVelocity"] = true, [ROOT .. ".spoofMoveDirection"] = true,
    [ROOT .. ".sideProfile"] = true,
}

function Desync.new(context)
    local services = context.services
    local players = services and services.Players or game:GetService("Players")
    local runService = services and services.RunService or game:GetService("RunService")
    local input = services and services.UserInputService or game:GetService("UserInputService")
    local workspace = services and services.Workspace or game:GetService("Workspace")
    local self = setmetatable({
        context = context, settings = context.settings or {}, player = players.LocalPlayer,
        runService = runService, input = input, workspace = workspace,
        alive = true, connections = {}, snapshot = nil,
        random = context.random or Random.new(),
    }, Desync)
    assert(self.player, "Desync requer um cliente com LocalPlayer.")
    self.renderName = "NexusDesync_" .. tostring(self)
    table.insert(self.connections, runService.Heartbeat:Connect(function() self:_pulse() end))
    table.insert(self.connections, self.player.CharacterRemoving:Connect(function() self:_restore() end))
    runService:BindToRenderStep(self.renderName, Enum.RenderPriority.Camera.Value - 1, function() self:_restore() end)
    return self
end

function Desync:_get(id, fallback)
    local value = self.settings[id]
    if value == nil and self.context.get then value = self.context.get(id) end
    if value == nil then value = DEFAULTS[id] end
    if value == nil then return fallback end
    return value
end

function Desync:_parts()
    local character = self.player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if character and character:IsDescendantOf(self.workspace) and root and root:IsA("BasePart")
        and root.Parent and humanoid and humanoid.Health > 0 then return character, root, humanoid end
    return nil
end

function Desync:_restore()
    local saved = self.snapshot
    self.snapshot = nil
    if not saved or self.player.Character ~= saved.character or not saved.root.Parent then return end
    local root, humanoid = saved.root, saved.humanoid
    -- A server correction or another feature takes precedence over this snapshot.
    if root.CFrame == saved.appliedPose then root.CFrame = saved.pose end
    if saved.appliedLinear and root.AssemblyLinearVelocity == saved.appliedLinear then
        root.AssemblyLinearVelocity = saved.linear
    end
    if saved.appliedAngular and root.AssemblyAngularVelocity == saved.appliedAngular then
        root.AssemblyAngularVelocity = saved.angular
    end
    if saved.appliedMove and humanoid.Parent and humanoid.MoveDirection == saved.appliedMove then
        humanoid:Move(saved.move, false)
    end
end

function Desync:_paused(root, humanoid)
    if root.Anchored or humanoid.Sit or humanoid.PlatformStand then return true end
    -- These modes own pose or movement constraints, independently of Smart Pause.
    if self:_get("farm.enabled", false) or self:_get("player.fly", false) or self:_get("player.spin", false) then return true end
    if self:_get(ROOT .. ".smartPause", true) then
        if humanoid.MoveDirection.Magnitude > 0.05 or self.input:GetFocusedTextBox() then return true end
    end
    return false
end

function Desync:_pulse()
    self:_restore()
    if not self.alive or not self:_get(ROOT, false) then return end
    local character, root, humanoid = self:_parts()
    if not character or self:_paused(root, humanoid) then return end
    local strength = tonumber(self:_get(ROOT .. ".strength", 10)) or 10
    if strength ~= strength or math.abs(strength) == math.huge then strength = 10 end
    strength = math.clamp(strength, 0, 10)
    if strength == 0 then return end
    local angle = self.random:NextNumber(-math.pi, math.pi)
    local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))
    local offset = direction * strength
    local yaw = self:_get(ROOT .. ".sideProfile", true) and (angle >= 0 and math.pi / 2 or -math.pi / 2) or 0
    local saved = {
        character = character, root = root, humanoid = humanoid, pose = root.CFrame,
        linear = root.AssemblyLinearVelocity, angular = root.AssemblyAngularVelocity,
        move = humanoid.MoveDirection,
    }
    self.snapshot = saved
    root.CFrame = saved.pose * CFrame.new(offset) * CFrame.Angles(0, yaw, 0)
    saved.appliedPose = root.CFrame
    if self:_get(ROOT .. ".spoofVelocity", true) then
        root.AssemblyLinearVelocity = saved.linear + direction * (strength * 6)
        root.AssemblyAngularVelocity = Vector3.new(0, yaw >= 0 and strength or -strength, 0)
        saved.appliedLinear, saved.appliedAngular = root.AssemblyLinearVelocity, root.AssemblyAngularVelocity
    end
    if self:_get(ROOT .. ".spoofMoveDirection", true) then
        humanoid:Move(direction, false)
        saved.appliedMove = humanoid.MoveDirection
    end
end

function Desync:Supports(id)
    if not MANAGED[id] then return nil end
    if not self.alive then return false, "Desync encerrado." end
    return true
end

function Desync:Set(id, value)
    local supported, reason = self:Supports(id)
    if supported ~= true then return false, reason or "Controle de Desync desconhecido." end
    if id == ROOT .. ".mode" and value ~= "Desync" then return false, "Somente o modo Desync foi mostrado." end
    if id == ROOT .. ".direction" and value ~= "Random" then return false, "Somente a direcao Random foi mostrada." end
    if id == ROOT .. ".strength" then
        value = tonumber(value)
        if not value or value ~= value or math.abs(value) == math.huge then return false, "Intensidade invalida." end
        value = math.clamp(value, 0, 10)
    elseif id ~= ROOT .. ".mode" and id ~= ROOT .. ".direction" and type(value) ~= "boolean" then
        return false, "Este controle espera verdadeiro ou falso."
    end
    self:_restore()
    if id == ROOT and value and not self:_parts() then return false, "Aguarde o personagem carregar." end
    self.settings[id] = value
    return true
end

function Desync:Action()
    return false, "Use o interruptor Anti Aim e suas configuracoes."
end

function Desync:Destroy()
    if not self.alive then return end
    self.alive = false
    self:_restore()
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    table.clear(self.connections)
    self.runService:UnbindFromRenderStep(self.renderName)
end

return Desync
