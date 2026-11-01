-- Local features for Nexus Hub. Game-specific remotes live in the game adapter.
local Features = {}
Features.__index = Features

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local DEFAULTS = {
    ["player.speed"] = 24, ["player.jump"] = 65,
    ["player.spinSpeed"] = 20,
    ["player.gravity"] = 196.2, ["player.hipHeight"] = 2,
    ["animations.speed"] = 1, ["animations.emoteSpeed"] = 1,
    ["music.volume"] = 50, ["music.speed"] = 1, ["music.pitch"] = 0,
    ["music.bass"] = 0, ["music.gameVolume"] = 100,
}
local ANIMATION_STATES = { idle = true, walk = true, run = true, jump = true, fall = true, climb = true, swim = true }
local MANAGED = {}
for _, id in ipairs({
    "player.speedEnabled", "player.speed", "player.jumpEnabled", "player.jump",
    "player.gravityEnabled", "player.gravity", "player.hipHeightEnabled", "player.hipHeight",
    "player.noclip", "player.cameraNoclip", "player.infiniteJump", "player.bhop", "player.spin", "player.spinSpeed",
    "player.fly", "player.antiFling", "player.invisible", "player.antiCoin", "player.bombJump",
    "player.wallHop", "player.speedGlitch", "player.antiAim", "player.antiAim.mode",
    "player.antiAim.direction", "player.antiAim.strength", "player.antiAim.smartPause",
    "player.antiAim.spoofVelocity", "player.antiAim.spoofMoveDirection", "player.antiAim.sideProfile",
    "perf.noShadows", "perf.noLights", "perf.noPostEffects", "perf.noParticles", "perf.noTextures",
    "perf.plastic", "perf.antiGlare", "perf.fpsUnlock", "perf.lowGraphics", "perf.simplePlayers",
    "perf.stopAnimations", "perf.backgroundSaver", "perf.disable3d", "general.antiAfk",
    "troll.fakeHeadless", "troll.fakeKorblox", "troll.orbit", "troll.target",
    "music.id", "music.name", "music.add", "music.play", "music.pause", "music.previous",
    "music.next", "music.shuffle", "music.repeat", "music.volume", "music.remove", "music.autoPlay", "music.songs",
    "music.effect", "music.speed", "music.pitch", "music.bass", "music.gameVolume",
    "music.shotSound", "music.killSound", "music.soundVolume", "music.previewShot", "music.previewKill",
    "music.roleRoll", "music.roleReveal", "music.victory", "music.previewRoles", "music.previewVictory",
    "music.onScreen", "music.soundcloudGenre", "music.soundcloudTrack", "music.soundcloudPlay", "music.soundcloudPrevious",
    "music.soundcloudNext", "music.soundcloudShuffle", "music.soundcloudRepeat", "music.soundcloudLike",
    "animations.speed", "animations.autoLoad", "animations.reset", "animations.clear",
    "animations.idle", "animations.walk", "animations.run", "animations.jump", "animations.fall",
    "animations.climb", "animations.swim", "animations.emoteSpeed", "animations.emoteHold",
    "animations.stopEmote", "animations.emoteSearch", "animations.searchEmotes", "animations.emoteCatalog", "animations.playEmote",
    "animations.emoteId", "animations.skinUser", "animations.wearSkin", "animations.removeSkin",
    "animations.skinCatalog", "animations.favorites",
}) do MANAGED[id] = true end

local UNAVAILABLE = {
    ["player.cameraNoclip"] = "Invisicam altera a oclusao; isso nao comprova o No Clip Camera do original.",
    ["player.antiCoin"] = "O filtro de coleta de moedas depende do adaptador do mapa.",
    ["player.bombJump"] = "A imagem nao especifica o mecanismo de Bomb Jump.",
    ["player.wallHop"] = "O comportamento de Wall Hop do original nao foi demonstrado.",
    ["player.speedGlitch"] = "O glitch de velocidade depende da versao do cliente e do jogo.",
    ["player.antiAim"] = "Desync e spoof de rede nao sao equivalentes a um efeito local.",
    ["troll.orbit"] = "A selecao de alvo de Orbit nao foi mostrada nas imagens.",
    ["music.autoPlay"] = "A reproducao por inicio de rodada requer um evento de rodada verificado.",
    ["music.shotSound"] = "Os eventos de disparo e IDs de efeitos do jogo ainda nao foram vinculados.",
    ["music.killSound"] = "Os eventos de eliminacao e IDs de efeitos ainda nao foram vinculados.",
    ["music.roleRoll"] = "A troca dos sons de sorteio depende dos sons reais do jogo.",
    ["music.roleReveal"] = "A troca dos sons de papel depende dos sons reais do jogo.",
    ["music.victory"] = "A troca da musica de vitoria depende do evento real da rodada.",
    ["music.previewShot"] = "A foto nao contem IDs dos sons de disparo.",
    ["music.previewKill"] = "A foto nao contem IDs dos sons de eliminacao.",
    ["music.previewRoles"] = "A foto nao contem IDs dos sons de papel.",
    ["music.previewVictory"] = "A foto nao contem IDs da musica de vitoria.",
    ["music.soundVolume"] = "O volume destes efeitos depende dos sons de jogo vinculados.",
    ["music.onScreen"] = "O player flutuante e fornecido pela interface.",
    ["animations.emoteCatalog"] = "As imagens nao fornecem os IDs do catalogo; use um ID de animacao.",
    ["animations.skinCatalog"] = "As imagens nao fornecem os IDs dos usuarios dos presets.",
    ["animations.favorites"] = "Nenhum favorito ou ID foi fornecido nas imagens.",
}

-- Roblox asset 139607718: Korblox Deathspeaker Right Leg (creator Roblox).
-- https://economy.roblox.com/v2/assets/139607718/details
local KORBLOX_LEG = 139607718
local RIGHT_LEG_PARTS = { "RightUpperLeg", "RightLowerLeg", "RightFoot" }
local AVATAR_SCALES = { "BodyTypeScale", "DepthScale", "HeadScale", "HeightScale", "ProportionScale", "WidthScale", "RightLegColor" }

local function assetId(value)
    local digits = string.match(tostring(value or ""), "^%s*(%d+)%s*$")
        or string.match(tostring(value or ""), "rbxassetid://(%d+)")
        or string.match(tostring(value or ""), "[?&]id=(%d+)")
    if digits and tonumber(digits) and tonumber(digits) > 0 then
        return "rbxassetid://" .. digits
    end
    return nil
end

local function payloadValue(value)
    if type(value) == "table" then return value.value or value.id or value.userId or value.username end
    return value
end

local function safely(callback)
    local ok, result = pcall(callback)
    if not ok then return false, tostring(result) end
    return true, result
end

function Features.new(context)
    local self = setmetatable({
        context = context, settings = context.settings or {}, alive = true,
        connections = {}, overrides = {}, activeSources = {}, serial = 0, flight = nil,
        playlist = {}, playlistIndex = 0, paused = false, audioEffects = {},
        animationSpeeds = {}, animationIds = {}, stoppedTracks = {},
        emote = nil, emoteAnimation = nil, emoteStarted = 0,
        skinDescription = nil, skinHumanoid = nil, skinGeneration = 0,
        background = false, fpsOriginal = nil, renderDisabled = false,
        jumpingUntil = 0, lastHumanoid = nil, lastCharacter = nil,
        korbloxGeneration = 0, korblox = nil, korbloxLoading = nil,
    }, Features)
    self.player = Players.LocalPlayer
    assert(self.player, "Features requer execucao no cliente.")
    self.sound = Instance.new("Sound")
    self.sound.Name = "NexusHubLocalMusic"
    self.sound.Volume = 0.5
    self.sound.Parent = SoundService
    self:_connect(UserInputService.JumpRequest, function()
        local humanoid = self:_humanoid()
        if self:_get("player.fly") then self.jumpingUntil = os.clock() + 0.25 end
        if humanoid and self:_get("player.infiniteJump") then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    self:_connect(Workspace.DescendantAdded, function(object)
        if self.alive then
            self:_applyPerformanceObject(object)
            self:_applyGameSound(object)
            local character = self.player.Character
            if character and object:IsDescendantOf(character) then
                self:_applyCharacterVisualObject(object, character)
                self:_applyKorbloxObject(object, character)
                if object:IsA("Animation") and self:_get("animations.autoLoad") then
                    task.defer(function() if self.alive then self:_applyAnimationIds() end end)
                end
            end
        end
    end)
    self:_connect(Lighting.DescendantAdded, function(object)
        if self.alive then self:_applyPerformanceObject(object) end
    end)
    self:_connect(Workspace.DescendantRemoving, function(object) self:_forgetObject(object) end)
    self:_connect(Lighting.DescendantRemoving, function(object) self:_forgetObject(object) end)
    self:_connect(SoundService.DescendantAdded, function(object)
        if self.alive then self:_applyGameSound(object) end
    end)
    self:_connect(SoundService.DescendantRemoving, function(object) self:_forgetObject(object) end)
    self:_connect(UserInputService.WindowFocusReleased, function()
        self.background = true
        self:_refreshFps()
    end)
    self:_connect(UserInputService.WindowFocused, function()
        self.background = false
        self:_refreshFps()
    end)
    self:_connect(self.player.Idled, function()
        if self:_get("general.antiAfk") then
            local camera = Workspace.CurrentCamera
            safely(function()
                local virtualUser = game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:Button2Down(Vector2.new(), camera and camera.CFrame or CFrame.new())
                virtualUser:Button2Up(Vector2.new(), camera and camera.CFrame or CFrame.new())
            end)
        end
    end)
    self:_connect(self.sound.Ended, function()
        if self:_get("music.repeat") then
            self.sound.TimePosition = 0
            self.sound:Play()
        elseif #self.playlist > 1 then
            self:_advance(1)
        end
    end)
    self:_connect(RunService.Stepped, function()
        local character = self.player.Character
        if self:_get("player.noclip") and character then
            for _, object in ipairs(character:GetDescendants()) do
                if object:IsA("BasePart") then self:_override("noclip", object, "CanCollide", false) end
            end
        end
    end)
    local elapsed = 0
    self:_connect(RunService.Heartbeat, function(delta)
        if not self.alive then return end
        self:_stepFlight()
        self:_stepSpin(delta)
        self:_stepOrbit(delta)
        self:_stepAudioSpatial(delta)
        elapsed += delta
        if elapsed >= 0.15 then
            elapsed = 0
            self:_stepCharacter()
            self:_stepAnimations()
        end
    end)
    self:_refreshAudioEffects()
    self:_refreshGameSounds()
    self:_refreshPerformance()
    self:_stepCharacter()
    return self
end

function Features:_get(id)
    local value = self.settings[id]
    if value == nil and self.context.get then value = self.context.get(id) end
    if value == nil then return DEFAULTS[id] end
    return value
end

function Features:_notify(message)
    if self.context.notify then self.context.notify(message) end
end

function Features:_connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.connections, connection)
    return connection
end

function Features:_humanoid()
    local character = self.player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

function Features:_root()
    local character = self.player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    return root and root:IsA("BasePart") and root or nil
end

-- Multiple effects may own the same property; release preserves remaining owners.
function Features:_override(source, object, property, value)
    if not object or not object.Parent then return false, "Objeto removido." end
    local ok, current = pcall(function() return object[property] end)
    if not ok then return false, tostring(current) end
    local assigned, applied = pcall(function() object[property] = value; return object[property] end)
    if not assigned then return false, tostring(applied) end
    local properties = self.overrides[object]
    if not properties then properties = {}; self.overrides[object] = properties end
    local saved = properties[property]
    if not saved then
        saved = { original = current, owners = {} }
        properties[property] = saved
    end
    self.serial += 1
    self.activeSources[source] = true
    saved.owners[source] = { value = applied, serial = self.serial }
    saved.applied = applied
    return true
end

function Features:_original(object, property)
    local properties = self.overrides[object]
    local saved = properties and properties[property]
    if saved then return saved.original end
    return object[property]
end

function Features:_forgetObject(object)
    local properties = self.overrides[object]
    if not properties then return end
    for property, saved in pairs(properties) do
        pcall(function() if object[property] == saved.applied then object[property] = saved.original end end)
    end
    self.overrides[object] = nil
end

function Features:_release(source)
    if source and not self.activeSources[source] then return end
    for object, properties in pairs(self.overrides) do
        for property, saved in pairs(properties) do
            if source == nil or saved.owners[source] then
                if source then saved.owners[source] = nil else table.clear(saved.owners) end
                local owner
                for _, candidate in pairs(saved.owners) do
                    if not owner or candidate.serial > owner.serial then owner = candidate end
                end
                pcall(function()
                    if object.Parent and (owner or object[property] == saved.applied) then
                        if owner then object[property] = owner.value else object[property] = saved.original end
                    end
                end)
                if owner then saved.applied = owner.value else properties[property] = nil end
            end
        end
        if next(properties) == nil or not object.Parent then self.overrides[object] = nil end
    end
    if source then self.activeSources[source] = nil else table.clear(self.activeSources) end
end

function Features:_applyPerformanceObject(object)
    local low = self:_get("perf.lowGraphics")
    if object:IsA("Light") and (self:_get("perf.noLights") or low) then
        self:_override("performance", object, "Enabled", false)
    elseif object:IsA("PostEffect") and not string.find(string.lower(object.Name), "nexus", 1, true)
        and (self:_get("perf.noPostEffects") or low) then
        self:_override("performance", object, "Enabled", false)
    elseif (object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
        or object:IsA("Fire") or object:IsA("Smoke") or object:IsA("Sparkles"))
        and (self:_get("perf.noParticles") or low) then
        self:_override("performance", object, "Enabled", false)
    elseif (object:IsA("Decal") or object:IsA("Texture")) and (self:_get("perf.noTextures") or low) then
        self:_override("performance", object, "Transparency", 1)
    elseif object:IsA("BasePart") then
        if self:_get("perf.plastic") or low then
            self:_override("performance", object, "Material", Enum.Material.SmoothPlastic)
        end
        if self:_get("perf.antiGlare") or low then self:_override("performance", object, "Reflectance", 0) end
        if self:_get("perf.noShadows") or low then self:_override("performance", object, "CastShadow", false) end
        if object:IsA("MeshPart") and (self:_get("perf.noTextures") or low) then
            self:_override("performance", object, "TextureID", "")
        end
    end
    if self:_get("perf.simplePlayers") then
        local model = object:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then
            if object:IsA("BasePart") then
                self:_override("performance", object, "Material", Enum.Material.SmoothPlastic)
                if object.Parent:IsA("Accessory") then self:_override("performance", object, "LocalTransparencyModifier", 1) end
            elseif object:IsA("Decal") then
                self:_override("performance", object, "Transparency", 1)
            end
        end
    end
end

function Features:_refreshPerformance()
    self:_release("performance")
    local low = self:_get("perf.lowGraphics")
    if self:_get("perf.noShadows") or low then self:_override("performance", Lighting, "GlobalShadows", false) end
    if self:_get("perf.antiGlare") or low then
        self:_override("performance", Lighting, "EnvironmentSpecularScale", 0)
        self:_override("performance", Lighting, "EnvironmentDiffuseScale", 0)
    end
    for _, object in ipairs(Workspace:GetDescendants()) do self:_applyPerformanceObject(object) end
    for _, object in ipairs(Lighting:GetDescendants()) do self:_applyPerformanceObject(object) end
end

function Features:_applyGameSound(object)
    if object:IsA("Sound") and object ~= self.sound and self:_get("music.gameVolume") ~= 100 then
        self:_override("gameAudio", object, "Volume", self:_original(object, "Volume")
            * math.clamp(tonumber(self:_get("music.gameVolume")) or 100, 0, 200) / 100)
    end
end

function Features:_refreshGameSounds()
    self:_release("gameAudio")
    for _, object in ipairs(Workspace:GetDescendants()) do self:_applyGameSound(object) end
    for _, object in ipairs(SoundService:GetDescendants()) do self:_applyGameSound(object) end
end

function Features:_refreshFps()
    local setCap, getCap = setfpscap, getfpscap
    if type(setCap) ~= "function" or type(getCap) ~= "function" then return end
    local active = self:_get("perf.fpsUnlock") or (self.background and self:_get("perf.backgroundSaver"))
    if active then
        if not self.fpsOriginal then
            local ok, value = pcall(getCap)
            if not ok or type(value) ~= "number" then return end
            self.fpsOriginal = value
        end
        pcall(setCap, self.background and self:_get("perf.backgroundSaver") and 15 or 9999)
    elseif self.fpsOriginal then
        pcall(setCap, self.fpsOriginal)
        self.fpsOriginal = nil
    end
end

function Features:_clearFlight()
    if self.flight then
        for _, object in ipairs(self.flight.objects) do object:Destroy() end
        self.flight = nil
    end
    self:_release("flight")
end

function Features:_stepFlight()
    local root, humanoid = self:_root(), self:_humanoid()
    if not self:_get("player.fly") or not root or not humanoid or humanoid.Health <= 0 then
        if self.flight then self:_clearFlight() end
        return
    end
    if self.flight and self.flight.root ~= root then self:_clearFlight() end
    if not self.flight then
        local attachment = Instance.new("Attachment")
        attachment.Name = "NexusFlightAttachment"
        attachment.Parent = root
        local velocity = Instance.new("LinearVelocity")
        velocity.Name = "NexusFlightVelocity"
        velocity.Attachment0 = attachment
        velocity.RelativeTo = Enum.ActuatorRelativeTo.World
        velocity.MaxForce = math.huge
        velocity.VectorVelocity = Vector3.zero
        velocity.Parent = root
        local orientation = Instance.new("AlignOrientation")
        orientation.Name = "NexusFlightOrientation"
        orientation.Attachment0 = attachment
        orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
        orientation.MaxTorque = math.huge
        orientation.Responsiveness = 20
        orientation.Parent = root
        self.flight = { root = root, velocity = velocity, orientation = orientation,
            objects = { velocity, orientation, attachment } }
        self:_override("flight", humanoid, "AutoRotate", false)
    end
    local camera = Workspace.CurrentCamera
    if not camera then return end
    local move = humanoid.MoveDirection
    local look = camera.CFrame.LookVector
    local flat = Vector3.new(look.X, 0, look.Z)
    if flat.Magnitude < 0.01 then flat = Vector3.new(0, 0, -1) else flat = flat.Unit end
    local right = camera.CFrame.RightVector
    local direction = look * move:Dot(flat) + right * move:Dot(Vector3.new(right.X, 0, right.Z))
    local vertical = os.clock() < self.jumpingUntil and 1 or 0
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then vertical += 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vertical -= 1 end
    end
    direction += Vector3.new(0, math.clamp(vertical, -1, 1), 0)
    if direction.Magnitude > 1 then direction = direction.Unit end
    self.flight.velocity.VectorVelocity = direction * math.max(8, tonumber(self:_get("player.speed")) or 24)
    self.flight.orientation.CFrame = CFrame.lookAt(Vector3.zero, flat)
end

function Features:_stepSpin(delta)
    local root, humanoid = self:_root(), self:_humanoid()
    if self.spinHumanoid ~= humanoid then
        self:_release("spin")
        self.spinHumanoid = humanoid
    end
    local speed = tonumber(self:_get("player.spinSpeed")) or 20
    if speed ~= speed then speed = 20 end
    speed = math.clamp(speed, 0, 100)
    if self:_get("player.spin") and root and humanoid and humanoid.Health > 0
        and not self:_get("player.fly") and not self:_get("farm.enabled") and speed > 0 then
        self:_override("spin", humanoid, "AutoRotate", false)
        -- Spin speed is angular velocity in radians per second.
        root.CFrame *= CFrame.Angles(0, speed * math.clamp(delta, 0, 0.1), 0)
    else self:_release("spin") end
end

function Features:_stepOrbit(delta)
    if not self:_get("troll.orbit") then return end
    local targetId = tonumber(self:_get("troll.target"))
    local target = targetId and Players:GetPlayerByUserId(targetId)
    local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    local root = self:_root()
    if not targetRoot or not root or target == self.player then return end
    self.orbitAngle = (self.orbitAngle or 0) + math.min(delta, 0.1) * 1.5
    local position = targetRoot.Position + Vector3.new(math.cos(self.orbitAngle) * 7, 1, math.sin(self.orbitAngle) * 7)
    root.CFrame = CFrame.lookAt(position, targetRoot.Position)
end

function Features:_applyCharacterVisualObject(object, character)
    local head = character:FindFirstChild("Head")
    local headless = self:_get("troll.fakeHeadless") and (object == head or (head and object:IsDescendantOf(head)))
    if self:_get("player.invisible") or headless then
        if object:IsA("BasePart") then self:_override("characterVisuals", object, "LocalTransparencyModifier", 1)
        elseif object:IsA("Decal") or object:IsA("Texture") then
            self:_override("characterVisuals", object, "Transparency", 1)
        end
    end
end

function Features:_korbloxCurrent(character)
    local state = self.korblox
    if not state or state.character ~= character or not state.folder.Parent then return false end
    for name, part in pairs(state.originals) do
        if character:FindFirstChild(name) ~= part then return false end
    end
    return true
end

function Features:_clearKorblox()
    self.korbloxGeneration += 1
    self.korbloxLoading = nil
    local state = self.korblox
    self.korblox = nil
    self:_release("korblox")
    if state then state.folder:Destroy() end
end

function Features:_applyKorbloxObject(object, character)
    local state = self.korblox
    if not state or state.character ~= character or object:IsDescendantOf(state.folder) then return end
    local hidden = false
    for _, part in pairs(state.originals) do
        if object == part or object:IsDescendantOf(part) then hidden = true; break end
    end
    local accessory = object:FindFirstAncestorOfClass("Accessory")
    if accessory and accessory.AccessoryType == Enum.AccessoryType.RightShoe then hidden = true end
    if hidden then
        if object:IsA("BasePart") then self:_override("korblox", object, "LocalTransparencyModifier", 1)
        elseif object:IsA("Decal") or object:IsA("Texture") then self:_override("korblox", object, "Transparency", 1) end
    end
end

function Features:_buildKorblox(character)
    if self:_korbloxCurrent(character) then return true end
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        return false, "Fake Korblox requer um personagem R15."
    end
    local originals = {}
    for _, name in ipairs(RIGHT_LEG_PARTS) do
        local part = character:FindFirstChild(name)
        if not part or not part:IsA("BasePart") then return false, "Aguarde as tres partes da perna R15 carregarem." end
        originals[name] = part
    end
    if self.korbloxLoading then return false, "A perna Korblox esta carregando." end
    self:_clearKorblox()
    local generation = self.korbloxGeneration
    self.korbloxLoading = generation
    local description, donor, folder
    local ok, message = pcall(function()
        local current = humanoid:GetAppliedDescription()
        description = Instance.new("HumanoidDescription")
        for _, property in ipairs(AVATAR_SCALES) do description[property] = current[property] end
        current:Destroy()
        description.RightLeg = KORBLOX_LEG
        -- Generate detached geometry, keeping the live rig and all its joints intact.
        donor = Players:CreateHumanoidModelFromDescriptionAsync(description, Enum.HumanoidRigType.R15)
        if not self.alive or self.korbloxGeneration ~= generation or self.player.Character ~= character
            or self:_humanoid() ~= humanoid or not self:_get("troll.fakeKorblox") then
            error("A carga da perna Korblox foi cancelada.")
        end
        for name, original in pairs(originals) do
            if character:FindFirstChild(name) ~= original then error("O personagem mudou durante a carga.") end
        end
        folder = Instance.new("Folder")
        folder.Name = "NexusKorbloxVisual"
        for _, name in ipairs(RIGHT_LEG_PARTS) do
            local source = donor:FindFirstChild(name)
            if not source or not source:IsA("BasePart") then error("O asset Korblox nao retornou a perna R15 completa.") end
            local visual = source:Clone()
            visual.Name = "Nexus" .. name
            for _, child in ipairs(visual:GetDescendants()) do
                if child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("WeldConstraint")
                    or child:IsA("Constraint") or child:IsA("TouchTransmitter") then child:Destroy() end
            end
            visual.Anchored, visual.CanCollide, visual.CanTouch, visual.CanQuery, visual.Massless = false, false, false, false, true
            visual.CFrame = originals[name].CFrame
            visual.LocalTransparencyModifier = 0
            visual.Parent = folder
            local weld = Instance.new("WeldConstraint")
            weld.Name, weld.Part0, weld.Part1, weld.Parent = "NexusKorbloxWeld", originals[name], visual, visual
        end
        -- Commit only after every visual part exists; failed loads never hide the leg.
        self.korblox = { character = character, folder = folder, originals = originals }
        folder.Parent = character
        for _, object in ipairs(character:GetDescendants()) do
            self:_applyKorbloxObject(object, character)
            self:_applyCharacterVisualObject(object, character)
        end
    end)
    if description then description:Destroy() end
    if donor then donor:Destroy() end
    if self.korbloxLoading == generation then self.korbloxLoading = nil end
    if not ok then
        if self.korblox and self.korblox.folder == folder then self:_clearKorblox()
        elseif folder then folder:Destroy() end
        return false, tostring(message)
    end
    return true, "Perna Korblox local aplicada; rig e juntas originais preservados."
end

function Features:_queueKorblox(character)
    if self.korbloxLoading or self.korbloxQueued then return end
    for _, name in ipairs(RIGHT_LEG_PARTS) do
        if not character:FindFirstChild(name) then return end
    end
    local token = {}
    self.korbloxQueued = token
    task.defer(function()
        if self.korbloxQueued ~= token then return end
        self.korbloxQueued = nil
        if not self.alive or self.player.Character ~= character or not self:_get("troll.fakeKorblox") then return end
        local ok, message = self:_buildKorblox(character)
        if not ok and self.alive and self.player.Character == character and self:_get("troll.fakeKorblox") then
            self.settings["troll.fakeKorblox"] = false
            self:_clearKorblox()
            self:_notify(message)
        end
    end)
end

function Features:_refreshCharacterVisuals()
    self:_release("characterVisuals")
    local character = self.player.Character
    if not character then return end
    for _, object in ipairs(character:GetDescendants()) do self:_applyCharacterVisualObject(object, character) end
end

function Features:_stepCharacter()
    local humanoid, root = self:_humanoid(), self:_root()
    local character = self.player.Character
    if character ~= self.lastCharacter then
        self:_clearKorblox()
        self.lastCharacter = character
        self:_stopEmote()
        self.skinGeneration += 1
        if self.skinDescription and not self.skinBusy then
            self.skinDescription:Destroy(); self.skinDescription = nil; self.skinHumanoid = nil
        end
        self:_refreshCharacterVisuals()
    end
    if self:_get("troll.fakeKorblox") and character and humanoid and humanoid.Health > 0
        and not self:_korbloxCurrent(character) then self:_queueKorblox(character) end
    if humanoid ~= self.lastHumanoid then
        self:_stopEmote()
        self:_release("speed")
        self:_release("jump")
        self:_release("hip")
        self.jumpProperty = nil
        self.lastHumanoid = humanoid
        if self:_get("animations.autoLoad") then self:_applyAnimationIds() end
    end
    if humanoid and humanoid.Health > 0 then
        if self:_get("player.speedEnabled") then
            self:_override("speed", humanoid, "WalkSpeed", math.clamp(tonumber(self:_get("player.speed")) or 24, 0, 250))
        else self:_release("speed") end
        if self:_get("player.jumpEnabled") then
            local power = math.clamp(tonumber(self:_get("player.jump")) or 65, 0, 250)
            local property = humanoid.UseJumpPower and "JumpPower" or "JumpHeight"
            if property ~= self.jumpProperty then self:_release("jump"); self.jumpProperty = property end
            if humanoid.UseJumpPower then self:_override("jump", humanoid, "JumpPower", power)
            elseif Workspace.Gravity > 0 then self:_override("jump", humanoid, "JumpHeight", power ^ 2 / (2 * Workspace.Gravity)) end
        else self:_release("jump") end
        if self:_get("player.hipHeightEnabled") then
            self:_override("hip", humanoid, "HipHeight", math.clamp(tonumber(self:_get("player.hipHeight")) or 2, -5, 20))
        else self:_release("hip") end
        if self:_get("player.bhop") and humanoid.MoveDirection.Magnitude > 0.05
            and humanoid.FloorMaterial ~= Enum.Material.Air and not humanoid.Sit then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        if root and self:_get("player.antiFling") then
            if root.AssemblyLinearVelocity.Magnitude > 180 then root.AssemblyLinearVelocity = Vector3.zero end
            if root.AssemblyAngularVelocity.Magnitude > 100 then root.AssemblyAngularVelocity = Vector3.zero end
        end
    end
    if self:_get("player.gravityEnabled") then
        self:_override("gravity", Workspace, "Gravity", math.clamp(tonumber(self:_get("player.gravity")) or 196.2, 0, 1000))
    else self:_release("gravity") end
end

function Features:_stepAnimations()
    local humanoid = self:_humanoid()
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    local rate = math.clamp(tonumber(self:_get("animations.speed")) or 1, 0, 5)
    for track in pairs(self.animationSpeeds) do
        if not track.IsPlaying then self.animationSpeeds[track] = nil end
    end
    for track in pairs(self.stoppedTracks) do
        if not track.IsPlaying then self.stoppedTracks[track] = nil end
    end
    if animator then
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if track ~= self.emote and rate ~= 1 then
                if not self.animationSpeeds[track] then self.animationSpeeds[track] = track.Speed end
                track:AdjustSpeed(rate)
            end
        end
    end
    if rate == 1 then
        for track, speed in pairs(self.animationSpeeds) do pcall(function() track:AdjustSpeed(speed) end) end
        table.clear(self.animationSpeeds)
    end
    if self.emote then
        self.emote:AdjustSpeed(math.clamp(tonumber(self:_get("animations.emoteSpeed")) or 1, 0, 5))
        if self:_get("animations.emoteHold") and not self.emote.IsPlaying and humanoid and humanoid.Health > 0 then
            if os.clock() - self.emoteStarted > 0.25 then
                self.emoteStarted = os.clock()
                self.emote:Play()
            end
        end
    end
    if self:_get("perf.stopAnimations") then
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= self.player then
                local otherHumanoid = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
                local otherAnimator = otherHumanoid and otherHumanoid:FindFirstChildOfClass("Animator")
                if otherAnimator then
                    for _, track in ipairs(otherAnimator:GetPlayingAnimationTracks()) do
                        if not self.stoppedTracks[track] then self.stoppedTracks[track] = track.Speed end
                        track:AdjustSpeed(0)
                    end
                end
            end
        end
    else
        for track, speed in pairs(self.stoppedTracks) do pcall(function() track:AdjustSpeed(speed) end) end
        table.clear(self.stoppedTracks)
    end
end

function Features:_applyAnimationIds()
    local character = self.player.Character
    local animate = character and character:FindFirstChild("Animate")
    if not animate then return false, "O personagem ainda nao possui Animate." end
    local changed, configured = 0, 0
    for _, state in ipairs({ "idle", "walk", "run", "jump", "fall", "climb", "swim" }) do
        local id = assetId(self:_get("animations." .. state))
        local container = animate:FindFirstChild(state)
        local source = "animationIds." .. state
        if id then configured += 1 else self:_release(source) end
        if id and container then
            for _, animation in ipairs(container:GetDescendants()) do
                if animation:IsA("Animation") then
                    self:_override(source, animation, "AnimationId", id)
                    changed += 1
                end
            end
        end
    end
    local ok = changed > 0 or configured == 0
    return ok, ok and "Animacoes locais atualizadas." or "Os estados escolhidos nao existem neste personagem."
end

function Features:_stopEmote()
    if self.emote then self.emote:Stop(0.1); self.emote:Destroy(); self.emote = nil end
    if self.emoteAnimation then self.emoteAnimation:Destroy(); self.emoteAnimation = nil end
end

function Features:_playEmote(value)
    local id = assetId(payloadValue(value) or self:_get("animations.emoteId") or self:_get("animations.emoteSearch"))
    if not id then return false, "Informe o ID numerico de uma animacao." end
    local humanoid = self:_humanoid()
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not animator then return false, "Aguarde o personagem carregar." end
    self:_stopEmote()
    local animation = Instance.new("Animation")
    animation.AnimationId = id
    self.emoteAnimation = animation
    local ok, track = pcall(function() return animator:LoadAnimation(animation) end)
    if not ok then animation:Destroy(); self.emoteAnimation = nil; return false, tostring(track) end
    self.emote = track
    self.emoteStarted = os.clock()
    track.Priority = Enum.AnimationPriority.Action
    track.Looped = true
    track:Play(0.15, 1, math.clamp(tonumber(self:_get("animations.emoteSpeed")) or 1, 0, 5))
    return true, "Animacao local iniciada; o asset deve permitir uso nesta experiencia."
end

function Features:_wearSkin(value)
    if self.skinBusy then return false, "Aguarde a operacao de aparencia atual." end
    local input = tostring(payloadValue(value) or self:_get("animations.skinUser") or "")
    if input == "" then return false, "Informe um nome de usuario ou UserId." end
    local humanoid = self:_humanoid()
    if not humanoid then return false, "Aguarde o personagem carregar." end
    self.skinGeneration += 1
    local generation = self.skinGeneration
    self.skinBusy = true
    local ok, description = pcall(function()
        local userId = tonumber(input) or Players:GetUserIdFromNameAsync(input)
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if not ok then
        self.skinBusy = false
        if self.skinRestorePending then self:_removeSkin() end
        return false, tostring(description)
    end
    if not self.alive or self.skinGeneration ~= generation or self:_humanoid() ~= humanoid then
        description:Destroy()
        self.skinBusy = false
        if self.skinRestorePending then self:_removeSkin() end
        return false, "O personagem mudou durante a consulta."
    end
    if not self.skinDescription or self.skinHumanoid ~= humanoid then
        if self.skinDescription then self.skinDescription:Destroy() end
        local captured, original = pcall(function() return humanoid:GetAppliedDescription() end)
        if not captured then
            self.skinBusy = false
            description:Destroy()
            self.skinDescription, self.skinHumanoid = nil, nil
            return false, tostring(original)
        end
        self.skinDescription = original
        self.skinHumanoid = humanoid
    end
    local applied, message = pcall(function() humanoid:ApplyDescription(description) end)
    description:Destroy()
    self.skinBusy = false
    if not self.alive or self.skinGeneration ~= generation or self.skinRestorePending then
        self:_removeSkin()
        return false, "A operacao foi encerrada e a aparencia foi restaurada."
    end
    if applied then self:_notify("Aparencia aplicada apenas ao personagem local.") end
    return applied, applied and "Aparencia local aplicada." or tostring(message)
end

function Features:_removeSkin()
    self.skinGeneration += 1
    if self.skinBusy then self.skinRestorePending = true; return true, "Restauracao de aparencia agendada." end
    self.skinRestorePending = false
    if not self.skinDescription then return true, "Nenhuma aparencia local aplicada." end
    local original, humanoid = self.skinDescription, self.skinHumanoid
    self.skinDescription, self.skinHumanoid = nil, nil
    local ok, message = true, "Aparencia local restaurada."
    if humanoid and humanoid.Parent then
        self.skinBusy = true
        ok, message = safely(function() humanoid:ApplyDescription(original) end)
        self.skinBusy = false
    end
    original:Destroy()
    self.skinRestorePending = false
    return ok, ok and "Aparencia local restaurada." or message
end

function Features:_refreshAudioEffects()
    for _, object in ipairs(self.audioEffects) do object:Destroy() end
    table.clear(self.audioEffects)
    local preset = tostring(self:_get("music.effect") or "Original")
    local speed = math.clamp(tonumber(self:_get("music.speed")) or 1, 0.1, 3)
    local semitones = math.clamp(tonumber(self:_get("music.pitch")) or 0, -12, 12)
    local bass = math.clamp(tonumber(self:_get("music.bass")) or 0, -20, 20)
    local function effect(className, properties)
        local object = Instance.new(className)
        for key, value in pairs(properties) do object[key] = value end
        object.Parent = self.sound
        table.insert(self.audioEffects, object)
    end
    if preset == "Nightcore" then speed *= 1.25
    elseif preset == "Slowed + Reverb" then speed *= 0.8; effect("ReverbSoundEffect", { DecayTime = 2.5, WetLevel = -9 })
    elseif preset == "Vaporwave" then speed *= 0.75; effect("ChorusSoundEffect", { Depth = 0.2, Mix = 0.3 })
    elseif preset == "Bass Boost" then bass = math.max(bass, 12)
    elseif preset == "8D" then
        if not self.audioEmitter then
            local emitter = Instance.new("Part")
            emitter.Name = "NexusHubMusicEmitter"
            emitter.Size = Vector3.new(0.1, 0.1, 0.1)
            emitter.Anchored, emitter.CanCollide, emitter.CanTouch, emitter.CanQuery = true, false, false, false
            emitter.Transparency = 1
            emitter.Parent = Workspace
            self.audioEmitter = emitter
        end
        self.sound.Parent = self.audioEmitter
    elseif preset == "Concert" then effect("ReverbSoundEffect", { DecayTime = 3, WetLevel = -6 })
    elseif preset == "Muffled" then effect("EqualizerSoundEffect", { HighGain = -25, MidGain = -8, LowGain = 3 })
    elseif preset == "Chipmunk" then semitones = math.min(12, semitones + 7)
    elseif preset == "Demon" then semitones = math.max(-12, semitones - 7) end
    if semitones ~= 0 then effect("PitchShiftSoundEffect", { Octave = 2 ^ (semitones / 12) }) end
    if bass ~= 0 then
        effect("EqualizerSoundEffect", { LowGain = math.min(bass, 10) })
        if bass > 10 then effect("EqualizerSoundEffect", { LowGain = bass - 10 }) end
    end
    self.sound.PlaybackSpeed = math.clamp(speed, 0.1, 3)
    self.sound.Volume = math.clamp(tonumber(self:_get("music.volume")) or 50, 0, 100) / 100
    if preset ~= "8D" and self.audioEmitter then
        self.sound.Parent = SoundService
        self.audioEmitter:Destroy()
        self.audioEmitter = nil
    end
end

function Features:_stepAudioSpatial(delta)
    if not self.audioEmitter or not Workspace.CurrentCamera then return end
    self.audioAngle = (self.audioAngle or 0) + math.min(delta, 0.1) * 0.65
    self.audioEmitter.CFrame = Workspace.CurrentCamera.CFrame
        * CFrame.new(math.cos(self.audioAngle) * 6, 0, math.sin(self.audioAngle) * 6)
end

function Features:_advance(direction)
    if #self.playlist == 0 then return false, "Adicione uma musica por Sound ID." end
    if self:_get("music.shuffle") and #self.playlist > 1 then
        local nextIndex = math.random(1, #self.playlist - 1)
        self.playlistIndex = nextIndex >= self.playlistIndex and nextIndex + 1 or nextIndex
    else self.playlistIndex = ((self.playlistIndex - 1 + direction) % #self.playlist) + 1 end
    local item = self.playlist[self.playlistIndex]
    self.sound.SoundId = item.id
    self.sound.TimePosition = 0
    self.sound:Play()
    self.paused = false
    self:_notify("Musica local: " .. item.name)
    return true, "Reproducao local iniciada."
end

function Features:Supports(id)
    if not MANAGED[id] then return nil end
    if UNAVAILABLE[id] then return false, UNAVAILABLE[id] end
    if string.sub(id, 1, 15) == "player.antiAim." then return false, UNAVAILABLE["player.antiAim"] end
    if string.sub(id, 1, 16) == "music.soundcloud" then
        return false, "As fotos nao fornecem a integracao nem o acesso de streaming do SoundCloud."
    end
    if id == "perf.fpsUnlock" or id == "perf.backgroundSaver" then
        if type(setfpscap) ~= "function" or type(getfpscap) ~= "function" then
            return false, "Este cliente nao expoe setfpscap e getfpscap para restaurar o limite."
        end
    end
    return true
end

function Features:Set(id, value)
    if not self.alive then return false, "O hub foi encerrado." end
    local supported, reason = self:Supports(id)
    if supported == nil then return false, "Controle nao gerenciado pelo modulo local." end
    if not supported then return false, reason end
    if id == "player.spinSpeed" then
        value = tonumber(value)
        if not value or value ~= value or math.abs(value) == math.huge then return false, "Velocidade de Spin invalida." end
        value = math.clamp(value, 0, 100)
    elseif ANIMATION_STATES[string.sub(id, 12)] and string.sub(id, 1, 11) == "animations." then
        if tostring(value or "") ~= "" and not assetId(value) then return false, "Informe um ID de animacao valido." end
    elseif id == "troll.fakeKorblox" and value then
        local character = self.player.Character
        if not character or not character:FindFirstChild("RightLowerLeg") then
            return false, "O efeito local Fake Korblox requer um personagem R15."
        end
        local ok, message = self:_buildKorblox(character)
        if not ok then return false, message end
    elseif id == "general.antiAfk" and value then
        local ok, message = safely(function() game:GetService("VirtualUser"):CaptureController() end)
        if not ok then return false, message end
    elseif id == "perf.disable3d" then
        local ok, message = safely(function() RunService:Set3dRenderingEnabled(not value) end)
        if not ok then return false, message end
        self.renderDisabled = value == true
    end
    self.settings[id] = value
    if string.sub(id, 1, 5) == "perf." then
        if id == "perf.fpsUnlock" or id == "perf.backgroundSaver" then self:_refreshFps()
        elseif id == "perf.disable3d" then
            -- Applied before storing the value so capability errors are transactional.
        else self:_refreshPerformance() end
    elseif id == "music.gameVolume" then self:_refreshGameSounds()
    elseif id == "music.volume" or id == "music.speed" or id == "music.pitch" or id == "music.bass" or id == "music.effect" then
        self:_refreshAudioEffects()
    elseif id == "player.noclip" and not value then self:_release("noclip")
    elseif id == "player.invisible" or id == "troll.fakeHeadless" or id == "troll.fakeKorblox" then
        if id == "troll.fakeKorblox" and not value then
            self.korbloxQueued = nil
            self:_clearKorblox()
        end
        self:_refreshCharacterVisuals()
        if value then self:_notify("Este efeito de aparencia e local.") end
    elseif string.match(id, "^animations%.") then
        if ANIMATION_STATES[string.sub(id, 12)] then return self:_applyAnimationIds() end
    end
    if id == "player.spin" or id == "player.spinSpeed" or id == "player.fly" then self:_stepSpin(0) end
    if string.sub(id, 1, 7) == "player." then self:_stepCharacter() end
    return true
end

function Features:Action(id, payload)
    if not self.alive then return false, "O hub foi encerrado." end
    local supported, reason = self:Supports(id)
    if supported == nil then return false, "Acao nao gerenciada pelo modulo local." end
    if not supported then return false, reason end
    if id == "music.add" then
        local value = payloadValue(payload)
        local idValue = assetId(value or self:_get("music.id"))
        if not idValue then return false, "Informe um Sound ID numerico ou link de asset Roblox." end
        table.insert(self.playlist, { id = idValue, name = tostring(self:_get("music.name") or idValue) })
        if self.playlistIndex == 0 then self.playlistIndex = 1 end
        return true, "Musica adicionada a playlist local."
    elseif id == "music.play" then
        if self.sound.IsPlaying then self.sound:Pause(); self.paused = true; return true, "Pausado." end
        if self.paused and self.sound.SoundId ~= "" then self.sound:Resume(); self.paused = false; return true end
        if #self.playlist == 0 then
            local valid = assetId(self:_get("music.id"))
            if not valid then return false, "Adicione uma musica por Sound ID." end
            self.playlist[1] = { id = valid, name = tostring(self:_get("music.name") or valid) }
            self.playlistIndex = 1
        end
        self.playlistIndex = math.max(1, self.playlistIndex)
        local item = self.playlist[self.playlistIndex]
        self.sound.SoundId = item.id
        self.sound:Play()
        return true, "Reproducao local iniciada."
    elseif id == "music.pause" then self.sound:Pause(); self.paused = true; return true
    elseif id == "music.next" then return self:_advance(1)
    elseif id == "music.previous" then return self:_advance(-1)
    elseif id == "music.remove" then
        local index = tonumber(payload) or self.playlistIndex
        if not self.playlist[index] then return false, "Escolha uma musica da playlist." end
        table.remove(self.playlist, index)
        self.playlistIndex = math.min(self.playlistIndex, #self.playlist)
        self.sound:Stop()
        return true, "Musica removida."
    elseif id == "animations.stopEmote" then self:_stopEmote(); return true
    elseif id == "music.songs" then
        local value = payloadValue(payload)
        local index = type(payload) == "table" and tonumber(payload.index) or nil
        index = index or tonumber(value)
        if not index or not self.playlist[index] then
            index = nil
            for candidate, song in ipairs(self.playlist) do
                if assetId(value) == song.id or tostring(value) == song.name then index = candidate; break end
            end
        end
        if not index or not self.playlist[index] then return false, "Selecione uma musica da playlist." end
        self.playlistIndex = index
        self.sound.SoundId = self.playlist[index].id
        self.sound.TimePosition = 0
        self.sound:Play()
        self.paused = false
        return true, "Reproducao local iniciada."
    elseif id == "animations.playEmote" or id == "animations.emoteSearch" or id == "animations.searchEmotes" then
        return self:_playEmote(payload)
    elseif id == "animations.wearSkin" then return self:_wearSkin(payload)
    elseif id == "animations.removeSkin" then return self:_removeSkin()
    elseif id == "animations.reset" or id == "animations.clear" then
        for _, state in ipairs({ "idle", "walk", "run", "jump", "fall", "climb", "swim" }) do
            self:_release("animationIds." .. state)
            self.settings["animations." .. state] = ""
        end
        self.settings["animations.speed"] = 1
        self:_stepAnimations()
        return true, "Animacoes locais restauradas."
    end
    return false, "Este controle armazena um valor; use Set."
end

function Features:GetSongs()
    local items = {}
    for index, song in ipairs(self.playlist) do
        table.insert(items, { name = song.name, id = tostring(index), value = tostring(index), assetId = song.id,
            index = index, selected = self.playlistIndex == index })
    end
    return items
end

function Features:Destroy()
    if not self.alive then return end
    self.alive = false
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    table.clear(self.connections)
    self:_clearFlight()
    self:_clearKorblox()
    self:_stopEmote()
    self:_removeSkin()
    for track, speed in pairs(self.animationSpeeds) do pcall(function() track:AdjustSpeed(speed) end) end
    for track, speed in pairs(self.stoppedTracks) do pcall(function() track:AdjustSpeed(speed) end) end
    table.clear(self.animationSpeeds)
    table.clear(self.stoppedTracks)
    self:_release(nil)
    if self.fpsOriginal and type(setfpscap) == "function" then pcall(setfpscap, self.fpsOriginal) end
    if self.renderDisabled then pcall(function() RunService:Set3dRenderingEnabled(true) end) end
    self.sound:Destroy()
    if self.audioEmitter then self.audioEmitter:Destroy(); self.audioEmitter = nil end
end

return Features
