-- Native catalog APIs and replicated weapon models; no downloaded Lua is run.
-- Sources: create.roblox.com/docs/animation/using and /docs/characters/emotes.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AvatarEditorService = game:GetService("AvatarEditorService")

local Assets = {}
Assets.__index = Assets

local PACKS = {
    { name = "Zombie", idle = 616158929, walk = 616168032, run = 616163682,
        jump = 616161997, fall = 616157476, climb = 616156119, swim = 616165109 },
    { name = "Robot", idle = 616088211, walk = 616095330, run = 616091570,
        jump = 616090535, fall = 616087089, climb = 616086039, swim = 616092998 },
    { name = "Ninja", idle = 656117400, walk = 656121766, run = 656118852,
        jump = 656117878, fall = 656115606, climb = 656114359, swim = 656119721 },
}
local EMOTES = {
    { name = "Hello", id = "3576686446", kind = "Emote" },
    { name = "Stadium", id = "3360686498", kind = "Emote" },
    { name = "Shrug", id = "3576968026", kind = "Emote" },
    { name = "Point", id = "3576823880", kind = "Emote" },
    { name = "Salute", id = "3360689775", kind = "Emote" },
    { name = "Tilt", id = "3360692915", kind = "Emote" },
}
local OBSERVED = {
    celestial = { "Knife", "Ancient" }, batwing = { "Knife", "Ancient" },
    elderwoodscythe = { "Knife", "Ancient" }, gingerscythe = { "Knife", "Ancient" },
    enma = { "Knife", "NEXUS" }, onikatana = { "Knife", "NEXUS" },
    gingerscope = { "Gun", "Ancient" }, bonereaper = { "Gun", "NEXUS" },
    dragonlore = { "Gun", "NEXUS" }, ejdervandal = { "Gun", "NEXUS" },
    hydrakrnl = { "Gun", "NEXUS" }, kawaiipop = { "Gun", "NEXUS" },
    pinkroyale = { "Gun", "NEXUS" }, bauble = { "Gun", "Godly" },
    blaster = { "Gun", "Godly" }, blizzard = { "Gun", "Godly" },
    blossom = { "Gun", "Godly" }, borealis = { "Gun", "Godly" },
    constellation = { "Gun", "Godly" },
}
local STATES = { idle = true, walk = true, run = true, jump = true, fall = true, climb = true, swim = true }
local SKIN_IDS = {
    ["skins.enabled"] = true, ["skins.belt"] = true, ["skins.knife"] = true,
    ["skins.gun"] = true, ["skins.reset"] = true, ["skins.rarity"] = true,
    ["skins.filter"] = true, ["skins.catalog"] = true,
}
local function normalized(value)
    return tostring(value or ""):lower():gsub("[^%w]", "")
end
local function valueOf(payload)
    if type(payload) ~= "table" then return payload end
    if type(payload.item) == "table" then
        return payload.item.id or payload.item.userId or payload.item.value or payload.id or payload.value
    end
    return payload.id or payload.value or payload.userId
end
local function partOf(object)
    if object:IsA("BasePart") then return object end
    local handle = object:FindFirstChild("Handle", true)
    if handle and handle:IsA("BasePart") then return handle end
    if object:IsA("Model") and object.PrimaryPart then return object.PrimaryPart end
    return object:FindFirstChildWhichIsA("BasePart", true)
end
local function classify(object, root)
    local observed = OBSERVED[normalized(object.Name)]
    local kind = object:GetAttribute("ItemType") or object:GetAttribute("WeaponType") or object:GetAttribute("Type")
    local current = object
    while current and current ~= root.Parent do
        local name = normalized(kind or current.Name)
        if name == "knife" or name == "knives" then return "Knife", observed end
        if name == "gun" or name == "guns" then return "Gun", observed end
        kind, current = nil, current.Parent
    end
    return observed and observed[1] or nil, observed
end

function Assets.new(context)
    local self = setmetatable({
        context = context, settings = context.settings or {}, alive = true,
        connections = {}, characterConnections = {}, models = {}, byId = {},
        emotes = {}, descriptions = {}, ownVisuals = {}, originalProperties = {},
        scanAt = 0, searchGeneration = 0, elapsed = 0, emoteStarted = 0, emoteGeneration = 0,
    }, Assets)
    self.player = Players.LocalPlayer
    for _, entry in ipairs(EMOTES) do table.insert(self.emotes, table.clone(entry)) end
    self:_scanModels()
    self:_bindCharacter(self.player.Character)
    table.insert(self.connections, self.player.CharacterAdded:Connect(function(character)
        self:_stopEmote()
        self:_restoreDescriptions()
        self:_bindCharacter(character)
    end))
    table.insert(self.connections, self.player.CharacterRemoving:Connect(function()
        self:_stopEmote()
        self:_clearVisuals()
        self:_restoreDescriptions()
    end))
    table.insert(self.connections, ReplicatedStorage.DescendantAdded:Connect(function(object)
        if object:IsA("BasePart") or object:IsA("Model") or object:IsA("Tool") then self.scanAt = 0 end
    end))
    table.insert(self.connections, RunService.Heartbeat:Connect(function(delta)
        if not self.alive then return end
        self.elapsed += delta
        if self.elapsed < 0.2 then return end
        self.elapsed = 0
        if self.emoteTrack then
            self.emoteTrack:AdjustSpeed(math.clamp(tonumber(self:_get("animations.emoteSpeed", 1)) or 1, 0.1, 3))
            if self:_get("animations.emoteHold", false) and not self.emoteTrack.IsPlaying
                and os.clock() - self.emoteStarted > 0.3 then
                self.emoteStarted = os.clock()
                self.emoteTrack:Play()
            end
        end
    end))
    return self
end
function Assets:_get(id, fallback)
    local value = self.context.get and self.context.get(id) or self.settings[id]
    if value == nil then return fallback end
    return value
end
function Assets:_notify(message)
    if self.context.notify then self.context.notify(message) end
end
function Assets:_bindCharacter(character)
    for _, connection in ipairs(self.characterConnections) do connection:Disconnect() end
    table.clear(self.characterConnections)
    self:_clearVisuals()
    if not character then return end
    local function changed(child)
        if child:IsA("Tool") or child.Name == "KnifeDisplay" or child.Name == "GunDisplay"
            or child.Name == "LowerTorso" or child.Name == "Torso" then
            task.defer(function() if self.alive and self.player.Character == character then self:_refreshVisuals() end end)
        end
    end
    table.insert(self.characterConnections, character.ChildAdded:Connect(changed))
    table.insert(self.characterConnections, character.ChildRemoved:Connect(changed))
    table.insert(self.characterConnections, character.DescendantAdded:Connect(function(object)
        if self.visualRefreshQueued or object:FindFirstAncestor("NexusWeaponVisual") then return end
        if object:IsA("BasePart") and object:FindFirstAncestorOfClass("Tool") then
            self.visualRefreshQueued = true
            task.defer(function()
                self.visualRefreshQueued = false
                if self.alive and self.player.Character == character then self:_refreshVisuals() end
            end)
        end
    end))
    self:_refreshVisuals()
end
function Assets:_scanModels()
    if os.clock() < self.scanAt then return end
    self.scanAt = os.clock() + 5
    local roots = {}
    for _, name in ipairs({ "Weapons", "WeaponModels" }) do
        local root = ReplicatedStorage:FindFirstChild(name)
        if root then table.insert(roots, root) end
    end
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    local weapons = assets and assets:FindFirstChild("Weapons")
    if weapons then table.insert(roots, weapons) end
    local entries, byId = {}, {}
    for _, root in ipairs(roots) do
        for _, object in ipairs(root:GetDescendants()) do
            if #entries >= 500 then break end
            if (object:IsA("Model") or object:IsA("Tool") or object:IsA("BasePart")) and partOf(object) then
                local parent = object.Parent
                local nested = parent and parent ~= root and (parent:IsA("Model") or parent:IsA("Tool")) and partOf(parent)
                local kind, observed = classify(object, root)
                if kind and not nested then
                    local id = object:GetFullName()
                    local rarity = object:GetAttribute("Rarity") or (observed and observed[2]) or "Replicated"
                    local entry = { id = id, name = object.Name, kind = kind, rarity = tostring(rarity), source = object }
                    table.insert(entries, entry)
                    byId[id], byId[normalized(object.Name)] = entry, entry
                end
            end
        end
    end
    table.sort(entries, function(a, b) return a.name:lower() < b.name:lower() end)
    self.models, self.byId = entries, byId
end
function Assets:_model(value, kind)
    self:_scanModels()
    local item = self.byId[tostring(value or "")] or self.byId[normalized(value)]
    if item and item.source.Parent and (not kind or item.kind == kind) then return item end
    for _, entry in ipairs(self.models) do
        if entry.source.Parent and (not kind or entry.kind == kind) and normalized(entry.name) == normalized(value) then return entry end
    end
    return nil
end
function Assets:_override(object, property, value)
    local features = self.context.features
    if features and features._override then
        features:_override("assets.weaponSkins", object, property, value)
        return
    end
    self.originalProperties[object] = self.originalProperties[object] or {}
    if not self.originalProperties[object][property] then
        self.originalProperties[object][property] = { original = object[property], applied = value }
    end
    object[property] = value
end
function Assets:_clearVisuals()
    for _, visual in ipairs(self.ownVisuals) do visual:Destroy() end
    table.clear(self.ownVisuals)
    local features = self.context.features
    if features and features._release then features:_release("assets.weaponSkins") end
    for object, properties in pairs(self.originalProperties) do
        if object.Parent then
            for property, saved in pairs(properties) do
                if object[property] == saved.applied then object[property] = saved.original end
            end
        end
    end
    table.clear(self.originalProperties)
end
function Assets:_hide(object)
    local descendants = object:GetDescendants()
    table.insert(descendants, object)
    for _, child in ipairs(descendants) do
        if child:IsA("BasePart") then self:_override(child, "LocalTransparencyModifier", 1)
        elseif child:IsA("Decal") or child:IsA("Texture") then self:_override(child, "Transparency", 1)
        elseif child:IsA("ParticleEmitter") or child:IsA("Trail") or child:IsA("Beam") then
            self:_override(child, "Enabled", false)
        end
    end
end
function Assets:_copyVisual(entry, anchor, offset, parent)
    local source = entry.source
    local origin = partOf(source)
    if not origin then return false, "O modelo selecionado nao possui uma parte visual." end
    local model = Instance.new("Model")
    model.Name = "NexusWeaponVisual"
    table.insert(self.ownVisuals, model)
    model.Parent = parent
    local parts = source:GetDescendants()
    if source:IsA("BasePart") then table.insert(parts, source) end
    local count = 0
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            local copy = part:Clone()
            if not copy then model:Destroy(); return false, "Este modelo nao permite clonagem local." end
            for _, child in ipairs(copy:GetDescendants()) do
                if child:IsA("LuaSourceContainer") or child:IsA("JointInstance") or child:IsA("Constraint")
                    or child:IsA("BodyMover") or child:IsA("BasePart") then child:Destroy() end
            end
            copy.Anchored, copy.CanCollide, copy.CanTouch, copy.CanQuery, copy.Massless = false, false, false, false, true
            copy.LocalTransparencyModifier = 0
            copy.CFrame = anchor.CFrame * (offset or CFrame.identity) * origin.CFrame:ToObjectSpace(part.CFrame)
            copy.Parent = model
            local weld = Instance.new("WeldConstraint")
            weld.Part0, weld.Part1, weld.Parent = anchor, copy, copy
            count += 1
        end
    end
    if count == 0 then model:Destroy(); return false, "O modelo selecionado nao possui geometria." end
    return true
end
function Assets:_refreshVisuals()
    self:_clearVisuals()
    if not self:_get("skins.enabled", false) then return true end
    local character = self.player.Character
    if not character then return true end
    for _, tool in ipairs(character:GetChildren()) do
        local kind = tool:IsA("Tool") and (normalized(tool.Name) == "knife" and "Knife" or normalized(tool.Name) == "gun" and "Gun")
        if kind then
            local entry = self:_model(self:_get(kind == "Knife" and "skins.knife" or "skins.gun"), kind)
            local anchor = partOf(tool)
            if entry and anchor then
                local ok, problem = self:_copyVisual(entry, anchor, nil, tool)
                if not ok then self:_clearVisuals(); return false, problem end
                -- Hide only original geometry; our visual was just added as a child.
                local visual = self.ownVisuals[#self.ownVisuals]
                for _, child in ipairs(tool:GetChildren()) do if child ~= visual then self:_hide(child) end end
            end
        end
    end
    if self:_get("skins.belt", false) then
        local entry = self:_model(self:_get("skins.knife"), "Knife")
        local torso = character:FindFirstChild("LowerTorso") or character:FindFirstChild("Torso")
        if entry and torso and torso:IsA("BasePart") then
            local existing = character:FindFirstChild("KnifeDisplay")
            local existingPart = existing and partOf(existing)
            local offset = existingPart and torso.CFrame:ToObjectSpace(existingPart.CFrame)
                or CFrame.new(0.8, -0.45, 0.4) * CFrame.Angles(0, 0, math.rad(20))
            local ok, problem = self:_copyVisual(entry, torso, offset, character)
            if not ok then self:_clearVisuals(); return false, problem end
            if existing then self:_hide(existing) end
        end
    end
    return true
end
function Assets:_stopEmote()
    self.emoteGeneration += 1
    if self.emoteTrack then self.emoteTrack:Stop(0.1); self.emoteTrack = nil end
end
function Assets:_restoreDescriptions()
    for description, saved in pairs(self.descriptions) do
        if description.Parent then
            pcall(function()
                local current = description:GetEmotes()
                for name, original in pairs(saved.names) do
                    local applied = current[name]
                    if type(applied) == "table" and #applied == 1 and applied[1] == original.applied then
                        current[name] = original.before
                    end
                end
                description:SetEmotes(current)
            end)
        end
    end
    table.clear(self.descriptions)
end
function Assets:_playEmote(payload)
    local value = valueOf(payload)
    local id = tonumber(value)
    if not id then
        for _, entry in ipairs(self.emotes) do if normalized(entry.name) == normalized(value) then id = tonumber(entry.id); break end end
    end
    if not id or id < 1 or id ~= math.floor(id) then return false, "Selecione um emote ou informe seu ID de catalogo." end
    local character = self.player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local description = humanoid and humanoid:FindFirstChildOfClass("HumanoidDescription")
    local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
    if not humanoid or not description or not animator then return false, "Aguarde o personagem e sua descricao carregarem." end
    if humanoid.RigType ~= Enum.HumanoidRigType.R15 then return false, "Os emotes de catalogo exigem um personagem R15." end
    self:_stopEmote()
    local generation = self.emoteGeneration
    local ok, result = pcall(function()
        if not self.descriptions[description] then
            self.descriptions[description] = { names = {} }
        end
        if self.context.features then self.context.features:Action("animations.stopEmote") end
        local before = {}
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do before[track] = true end
        local name = "Nexus_" .. tostring(id)
        if not self.descriptions[description].names[name] then
            self.descriptions[description].names[name] = { before = description:GetEmotes()[name], applied = id }
        end
        description:AddEmote(name, id)
        local played = humanoid:PlayEmote(name)
        if not played then return false end
        if not self.alive or self.emoteGeneration ~= generation or self.player.Character ~= character then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do if not before[track] then track:Stop(0) end end
            self:_restoreDescriptions()
            return false
        end
        for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
            if not before[track] then self.emoteTrack = track; self.emoteStarted = os.clock(); break end
        end
        return true
    end)
    if not ok then return false, "O cliente nao conseguiu carregar este emote de catalogo." end
    return result == true, result and "Emote de catalogo iniciado." or "Este emote nao pode ser reproduzido neste personagem."
end
function Assets:_searchEmotes(query)
    query = tostring(query or "")
    if tonumber(query) then return self:_playEmote(query) end
    self.searchGeneration += 1
    local generation = self.searchGeneration
    local ok, pages = pcall(function()
        local parameters = CatalogSearchParams.new()
        parameters.AssetTypes = { Enum.AvatarAssetType.EmoteAnimation }
        parameters.SearchKeyword = query
        parameters.Limit = 30
        return AvatarEditorService:SearchCatalogAsync(parameters)
    end)
    if not ok then return false, "A busca de emotes do Roblox nao esta disponivel neste cliente." end
    if not self.alive or generation ~= self.searchGeneration then return false, "Busca encerrada." end
    local items, seen = {}, {}
    local pageOk, page = pcall(function() return pages:GetCurrentPage() end)
    if not pageOk then return false, "A busca nao retornou uma pagina valida." end
    for _, item in ipairs(page) do
        local id = tonumber(item.Id or item.id)
        if id and type(item.Name or item.name) == "string" and not seen[id] then
            seen[id] = true
            table.insert(items, { id = tostring(id), name = item.Name or item.name, kind = "Emote", assetId = id })
        end
    end
    if #items == 0 then return false, "Nenhum emote encontrado para esta busca." end
    self.emotes = items
    return true, tostring(#items) .. " emotes encontrados no catalogo Roblox."
end

function Assets:Supports(id)
    if not self.alive then return false, "Catalogo encerrado." end
    local state = id:match("^animations%.(%w+)$")
    if state and STATES[state] then return self.context.features ~= nil, "Modulo de animacoes ainda nao foi conectado." end
    if id == "animations.emoteCatalog" or id == "animations.searchEmotes" or id == "animations.skinCatalog" or id == "animations.stopEmote" then return true end
    if not SKIN_IDS[id] then return nil end
    if id == "skins.reset" or id == "skins.rarity" or id == "skins.filter" then return true end
    self:_scanModels()
    return #self.models > 0, "Nenhum modelo de arma replicado foi encontrado em Weapons ou Assets.Weapons."
end
function Assets:Set(id, value)
    local supported, reason = self:Supports(id)
    if supported ~= true and not (SKIN_IDS[id] and value == false) then return false, reason end
    local state = id:match("^animations%.(%w+)$")
    if state and STATES[state] then return self.context.features:Set(id, value) end
    if id == "skins.knife" or id == "skins.gun" then
        if not self:_model(value, id == "skins.knife" and "Knife" or "Gun") then return false, "Este modelo nao esta replicado no cliente atual." end
    end
    if id == "skins.enabled" and value then
        if not self:_model(self:_get("skins.knife"), "Knife") and not self:_model(self:_get("skins.gun"), "Gun") then
            return false, "Selecione primeiro uma arma do catalogo de modelos disponiveis."
        end
    end
    self.settings[id] = value
    if SKIN_IDS[id] then return self:_refreshVisuals() end
    return true
end
function Assets:Action(id, payload)
    if not self.alive then return false, "Catalogo encerrado." end
    if id == "animations.emoteCatalog" then return self:_playEmote(payload) end
    if id == "animations.searchEmotes" then return self:_searchEmotes(self:_get("animations.emoteSearch", "")) end
    if id == "animations.stopEmote" then
        self:_stopEmote()
        if self.context.features then self.context.features:Action("animations.stopEmote") end
        return true, "Emote encerrado."
    end
    if id == "animations.skinCatalog" then
        if not self.context.features then return false, "Modulo de aparencia ainda nao foi conectado." end
        return self.context.features:Action("animations.wearSkin", valueOf(payload))
    end
    local state = id:match("^animations%.(%w+)$")
    if state and STATES[state] then
        local value = valueOf(payload)
        if value == "default" then value = "" end
        return self.context.features:Set(id, tostring(value or ""))
    end
    if id == "skins.reset" then
        self.settings["skins.enabled"], self.settings["skins.belt"] = false, false
        self:_clearVisuals()
        return true, "Armas visuais originais restauradas."
    end
    if id == "skins.catalog" then
        local entry = self:_model(valueOf(payload))
        if not entry then return false, "Selecione um modelo replicado disponivel." end
        self.settings[entry.kind == "Knife" and "skins.knife" or "skins.gun"] = entry.id
        if self:_get("skins.enabled", false) then return self:_refreshVisuals() end
        return true, "Modelo selecionado. Ative Weapon Skin Changer para aplicar."
    end
    return false, "Acao de catalogo desconhecida."
end
function Assets:GetCatalog(id)
    if id == "animations.emoteCatalog" then return self.emotes end
    if id == "animations.skinCatalog" then
        local entries = {}
        for _, player in ipairs(Players:GetPlayers()) do
            table.insert(entries, { id = tostring(player.UserId), userId = player.UserId,
                name = player.DisplayName .. " @" .. player.Name, kind = "Avatar",
                thumbnail = "rbxthumb://type=Avatar&id=" .. tostring(player.UserId) .. "&w=150&h=150" })
        end
        return entries
    end
    local state = id:match("^animations%.(%w+)$")
    if state and STATES[state] then
        local entries = { { id = "default", name = "Default", kind = "Animation" } }
        for _, pack in ipairs(PACKS) do
            table.insert(entries, { id = tostring(pack[state]), assetId = pack[state], name = pack.name, kind = "Animation" })
        end
        return entries
    end
    if id == "skins.catalog" then
        self:_scanModels()
        local entries = {}
        local kind, rarity = self:_get("skins.filter", "All"), self:_get("skins.rarity", "Any")
        for _, entry in ipairs(self.models) do
            if (kind == "All" or entry.kind == kind) and (rarity == "Any" or entry.rarity == rarity) then
                table.insert(entries, { id = entry.id, name = entry.name, kind = entry.kind, rarity = entry.rarity })
            end
        end
        return entries
    end
    return {}
end
function Assets:Destroy()
    if not self.alive then return end
    self.alive = false
    self.searchGeneration += 1
    self:_stopEmote()
    self:_restoreDescriptions()
    self:_clearVisuals()
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    for _, connection in ipairs(self.characterConnections) do connection:Disconnect() end
    table.clear(self.connections)
    table.clear(self.characterConnections)
    table.clear(self.models)
    table.clear(self.byId)
end

return Assets
