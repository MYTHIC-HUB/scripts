-- MYTHIC-HUB - loader oficial da copia publicada neste repositorio.
-- Recupera 35 blocos do codigo (12.468.912 bytes) do proprio GitHub.
-- MYTHIC HUB: nao exibir arquivos temporarios de recursos na galeria Android.
-- As pastas antigas so recebem .nomedia se ja existirem. Nenhum arquivo pessoal e apagado.
local function mythicProtectGallery()
    if type(writefile) ~= "function" then return end
    local function protect(folder, create)
        local exists = false
        if type(isfolder) == "function" then
            local ok, value = pcall(isfolder, folder)
            exists = ok and value == true
        end
        if not exists and create and type(makefolder) == "function" then
            local ok = pcall(makefolder, folder)
            exists = ok or exists
        end
        if not exists then return end
        local marker = folder .. "/.nomedia"
        if type(isfile) == "function" then
            local ok, present = pcall(isfile, marker)
            if ok and present then return end
        end
        pcall(writefile, marker, "")
    end
    protect("MYTHIC-HUB", true)
    protect("MYTHIC-HUB/Assets", true)
    protect("PulseHub", false) -- pasta legada de versoes anteriores
    protect("PulseHubOffline", false) -- pasta legada de versoes anteriores
end
mythicProtectGallery()

local avatarBase64 = [==[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]==]

-- MYTHIC INTRO ANIMATED 3S v1.9: apresentacao visual independente das funcoes do hub.
local function showMythicIntro3s()
    local introForCleanup
    local ok, problem = pcall(function()
        local TweenService = game:GetService("TweenService")
        local Players = game:GetService("Players")
        local parent
        if type(gethui) == "function" then pcall(function() parent = gethui() end) end
        if not parent and Players.LocalPlayer then
            parent = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
                or Players.LocalPlayer:WaitForChild("PlayerGui", 1)
        end
        if not parent then parent = game:GetService("CoreGui") end
        if not parent then return end

        local avatarAsset
        if type(writefile) == "function" then
            pcall(function()
                if type(makefolder) == "function" then
                    pcall(makefolder, "MYTHIC-HUB")
                    pcall(makefolder, "MYTHIC-HUB/Assets")
                end
                local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
                local map = {}
                for i = 1, #alphabet do map[alphabet:sub(i, i)] = i - 1 end
                local decoded = {}
                for i = 1, #avatarBase64, 4 do
                    local a, b = map[avatarBase64:sub(i,i)] or 0, map[avatarBase64:sub(i+1,i+1)] or 0
                    local c, d = map[avatarBase64:sub(i+2,i+2)] or 0, map[avatarBase64:sub(i+3,i+3)] or 0
                    local n = a*262144 + b*4096 + c*64 + d
                    decoded[#decoded+1] = string.char(math.floor(n/65536)%256)
                    if avatarBase64:sub(i+2,i+2) ~= "=" then
                        decoded[#decoded+1] = string.char(math.floor(n/256)%256)
                    end
                    if avatarBase64:sub(i+3,i+3) ~= "=" then
                        decoded[#decoded+1] = string.char(n%256)
                    end
                end
                local file = "MYTHIC-HUB/Assets/mythic_avatar_logo.jpg"
                writefile(file, table.concat(decoded))
                local getAsset = getcustomasset or getsynasset
                if type(getAsset) == "function" then avatarAsset = getAsset(file) end
            end)
        end

        local previous = parent:FindFirstChild("MYTHIC_HUB_INTRO_3S")
        if previous then previous:Destroy() end
        local function make(kind, owner, properties)
            local object = Instance.new(kind)
            for key, value in pairs(properties) do object[key] = value end
            object.Parent = owner
            return object
        end
        local function animate(object, seconds, properties, style, direction, repeats, reversing)
            local info = TweenInfo.new(seconds, style or Enum.EasingStyle.Quart,
                direction or Enum.EasingDirection.Out, repeats or 0, reversing or false)
            local animation = TweenService:Create(object, info, properties)
            animation:Play()
            return animation
        end
        local white = Color3.fromRGB(255, 255, 255)
        local purple = Color3.fromRGB(172, 65, 255)
        local dark = Color3.fromRGB(15, 7, 29)
        local intro = make("ScreenGui", parent, {
            Name = "MYTHIC_HUB_INTRO_3S", ResetOnSpawn = false,
            IgnoreGuiInset = true, DisplayOrder = 100000,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        introForCleanup = intro
        local veil = make("Frame", intro, {
            Name = "Backdrop", Size = UDim2.fromScale(1,1),
            BackgroundColor3 = Color3.fromRGB(5, 2, 15), BorderSizePixel = 0,
        })
        make("UIGradient", veil, {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 4, 14)),
                ColorSequenceKeypoint.new(.5, Color3.fromRGB(31, 7, 48)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 3, 16)),
            }), Rotation = 18,
        })
        local scale = 1
        pcall(function()
            local viewport = workspace.CurrentCamera.ViewportSize
            scale = math.max(.43, math.min(1, (viewport.X-30)/660, (viewport.Y-30)/360))
        end)
        local shadow = make("Frame", veil, {
            Size = UDim2.fromOffset(652, 312), AnchorPoint = Vector2.new(.5,.5),
            Position = UDim2.new(.5,0,.5,14), BackgroundColor3 = Color3.fromRGB(89,20,160),
            BackgroundTransparency = .76, BorderSizePixel = 0, ZIndex = 2,
        })
        make("UICorner",shadow,{CornerRadius=UDim.new(0,26)})
        make("UIScale",shadow,{Scale=scale})
        local panel = make("Frame", veil, {
            Name = "PremiumCard", Size = UDim2.fromOffset(652,312),
            Position = UDim2.fromScale(.5,.5), AnchorPoint = Vector2.new(.5,.5),
            BackgroundColor3 = dark, BorderSizePixel = 0, ClipsDescendants=true, ZIndex=3,
        })
        make("UIScale", panel, {Scale=scale*.88})
        make("UICorner",panel,{CornerRadius=UDim.new(0,24)})
        make("UIStroke",panel,{Color=purple,Transparency=.23,Thickness=2})
        make("UIGradient",panel,{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(33,15,54)),
                ColorSequenceKeypoint.new(.56,Color3.fromRGB(13,9,25)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(43,12,64)),
            }),Rotation=14,
        })
        local topLine=make("Frame",panel,{
            Position=UDim2.fromOffset(36,18),Size=UDim2.fromOffset(580,2),
            BackgroundColor3=purple,BorderSizePixel=0,ZIndex=4,
        })
        make("UIGradient",topLine,{Color=ColorSequence.new(Color3.fromRGB(100,41,255),Color3.fromRGB(246,117,255))})
        local badge=make("TextLabel",panel,{
            Position=UDim2.fromOffset(39,32),Size=UDim2.fromOffset(355,24),
            BackgroundTransparency=1,Font=Enum.Font.GothamBold,TextSize=12,
            Text="✦  MYTHIC PREMIUM EXPERIENCE",TextColor3=Color3.fromRGB(207,156,255),
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
        })
        local orb=make("Frame",panel,{
            Position=UDim2.fromOffset(39,76),Size=UDim2.fromOffset(174,174),
            BackgroundColor3=Color3.fromRGB(71,24,118),BackgroundTransparency=.1,
            BorderSizePixel=0,ZIndex=5,
        })
        make("UICorner",orb,{CornerRadius=UDim.new(1,0)})
        local rim=make("UIStroke",orb,{Color=Color3.fromRGB(222,83,255),Thickness=4,Transparency=.05})
        local orbit=make("UIGradient",rim,{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(83,61,255)),
                ColorSequenceKeypoint.new(.5,Color3.fromRGB(255,148,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(125,40,255)),
            }),Rotation=0,
        })
        local avatar=make("ImageLabel",orb,{
            Position=UDim2.fromOffset(8,8),Size=UDim2.fromOffset(158,158),
            BackgroundColor3=Color3.fromRGB(21,11,39),BorderSizePixel=0,
            Image=avatarAsset or (function()
                local p=Players.LocalPlayer
                local ok,url=pcall(function()
                    return Players:GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.AvatarThumbnail,Enum.ThumbnailSize.Size420x420)
                end)
                return ok and url or "rbxassetid://102076719808486"
            end)(),ScaleType=Enum.ScaleType.Fit,ZIndex=6,
        })
        make("UICorner",avatar,{CornerRadius=UDim.new(1,0)})
        -- Sem letra M sobreposta ao icone em alta resolucao.
        local title=make("TextLabel",panel,{
            Position=UDim2.fromOffset(239,82),Size=UDim2.fromOffset(380,76),
            BackgroundTransparency=1,Font=Enum.Font.GothamBlack,TextSize=48,
            Text="MYTHIC-HUB",TextColor3=white,TextXAlignment=Enum.TextXAlignment.Left,
            TextTransparency=1,TextStrokeTransparency=.7,ZIndex=5,
        })
        make("UIGradient",title,{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,white),
                ColorSequenceKeypoint.new(.65,Color3.fromRGB(227,190,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(176,86,255)),
            }),Rotation=0,
        })
        local subtitle=make("TextLabel",panel,{
            Position=UDim2.fromOffset(242,158),Size=UDim2.fromOffset(370,28),
            BackgroundTransparency=1,Text="MURDER MYSTERY 2",
            Font=Enum.Font.GothamBold,TextSize=18,TextColor3=Color3.fromRGB(211,166,252),
            TextXAlignment=Enum.TextXAlignment.Left,TextTransparency=1,ZIndex=5,
        })
        local status=make("TextLabel",panel,{
            Position=UDim2.fromOffset(242,205),Size=UDim2.fromOffset(335,26),
            BackgroundTransparency=1,Text="INICIALIZANDO SEU HUB...",
            Font=Enum.Font.GothamMedium,TextSize=13,
            TextColor3=Color3.fromRGB(177,171,193),TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
        })
        make("TextLabel",panel,{
            Position=UDim2.fromOffset(560,205),Size=UDim2.fromOffset(47,26),
            BackgroundTransparency=1,Text="v1.9",Font=Enum.Font.GothamBold,TextSize=12,
            TextColor3=purple,ZIndex=5,
        })
        local track=make("Frame",panel,{
            Position=UDim2.fromOffset(42,274),Size=UDim2.fromOffset(565,5),
            BackgroundColor3=Color3.fromRGB(63,42,84),BorderSizePixel=0,ZIndex=5,
        })
        make("UICorner",track,{CornerRadius=UDim.new(1,0)})
        local bar=make("Frame",track,{
            Size=UDim2.fromScale(.02,1),BackgroundColor3=purple,
            BorderSizePixel=0,ZIndex=6,
        })
        make("UICorner",bar,{CornerRadius=UDim.new(1,0)})
        make("UIGradient",bar,{Color=ColorSequence.new(Color3.fromRGB(115,64,255),Color3.fromRGB(255,131,255))})
        for i = 1, 10 do
            local spark=make("Frame",panel,{
                Size=UDim2.fromOffset(i%3+2,i%3+2),
                Position=UDim2.fromOffset(35 + ((i*67)%565), 55 + ((i*37)%196)),
                BackgroundColor3=i%2==0 and Color3.fromRGB(245,155,255) or purple,
                BackgroundTransparency=.24,BorderSizePixel=0,ZIndex=4,
            })
            make("UICorner",spark,{CornerRadius=UDim.new(1,0)})
            animate(spark,2.15,{Position=UDim2.fromOffset(35 + ((i*67)%565), 33 + ((i*37)%196)),BackgroundTransparency=1},
                Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
        end
        animate(panel:FindFirstChildOfClass("UIScale"),.64,{Scale=scale},Enum.EasingStyle.Back)
        animate(title,.72,{TextTransparency=0})
        animate(subtitle,.96,{TextTransparency=0})
        animate(orbit,2.85,{Rotation=360},Enum.EasingStyle.Linear)
        animate(bar,2.55,{Size=UDim2.fromScale(1,1)},Enum.EasingStyle.Sine)
        animate(orb,1.05,{BackgroundColor3=Color3.fromRGB(122,30,182)},
            Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,1,true)
        task.delay(2.6,function()
            if not intro.Parent then return end
            animate(veil,.37,{BackgroundTransparency=1})
            for _,part in ipairs(intro:GetDescendants()) do
                if part:IsA("TextLabel") then
                    animate(part,.37,{TextTransparency=1,TextStrokeTransparency=1})
                elseif part:IsA("ImageLabel") then
                    animate(part,.37,{ImageTransparency=1,BackgroundTransparency=1})
                elseif part:IsA("Frame") then
                    animate(part,.37,{BackgroundTransparency=1})
                elseif part:IsA("UIStroke") then
                    animate(part,.37,{Transparency=1})
                end
            end
        end)
        task.delay(3.02,function()
            if intro and intro.Parent then intro:Destroy() end
        end)
    end)
    if not ok then
        if introForCleanup then pcall(function() introForCleanup:Destroy() end) end
        warn("MYTHIC-HUB intro: "..tostring(problem))
    end
end
showMythicIntro3s()

-- MYTHIC FAST LOADER v3.0: cache preparado + downloads concorrentes.
-- Ao alterar qualquer bloco ou patch, atualize CACHE_VERSION para invalidar o cache antigo.
local base = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/chunks/part-"
local SEGMENT_COUNT, EXPECTED_BYTES = 35, 12468912
local CACHE_VERSION = "public_20261113_v69_teleport_candy_pause_2s"
local CACHE_FILE = "MYTHIC-HUB/prepared_" .. CACHE_VERSION .. ".lua"
-- MYTHIC SILENT LOADER: sem faixa de "baixando" ou "compilando" na tela.
-- Cache mantido para evitar baixar novamente os 35 blocos.
local loaderStartedAt = os.clock()
local function failLoader(message)
    warn("MYTHIC-HUB: " .. tostring(message))
    error("MYTHIC-HUB: " .. tostring(message), 0)
end
-- Remover barra que possa ter sobrado de execucao anterior.
pcall(function()
    local parents = {}
    if type(gethui) == "function" then
        local ok, ui = pcall(gethui)
        if ok and ui then table.insert(parents, ui) end
    end
    local player = game:GetService("Players").LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if playerGui then table.insert(parents, playerGui) end
    table.insert(parents, game:GetService("CoreGui"))
    for _, parent in ipairs(parents) do
        local old = parent:FindFirstChild("MYTHIC_HUB_LOADING")
        if old then old:Destroy() end
    end
end)

local source, fromCache = nil, false
if type(readfile) == "function" then
    local ok, saved = pcall(readfile, CACHE_FILE)
    if ok and type(saved) == "string" and
        #saved > EXPECTED_BYTES - 100000 and #saved < EXPECTED_BYTES + 100000 then
        source, fromCache = saved, true
    end
end

if not fromCache then
    local segments = {}
    local nextIndex, finished, firstError = 1, 0, nil
    local startedAt, cancelled = os.clock(), false
    local MAX_WORKERS = 4 -- Baixa 35 partes em paralelo sem criar 35 requisicoes simultaneas.
    local function downloadWorker()
        while not cancelled and not firstError do
            local index = nextIndex
            nextIndex += 1
            if index > SEGMENT_COUNT then break end
            local url = base .. string.format("%03d", index) .. ".txt"
            local body
            for attempt = 1, 3 do
                local ok, response = pcall(function() return game:HttpGet(url) end)
                if ok and type(response) == "string" and #response > 1024 then
                    body = response
                    break
                end
                if attempt < 3 then task.wait(0.2 * attempt) end
            end
            if not body then
                firstError = "falha ao carregar parte " .. index .. "/" .. SEGMENT_COUNT
                break
            end
            segments[index] = body
            finished += 1
        end
    end
    for _ = 1, MAX_WORKERS do task.spawn(downloadWorker) end
    while finished < SEGMENT_COUNT and not firstError and os.clock() - startedAt < 90 do
        task.wait(0.08)
    end
    cancelled = true
    if firstError then failLoader(firstError .. ". Verifique a conexao.") end
    if finished ~= SEGMENT_COUNT then failLoader("limite de tempo no download. Verifique a conexao.") end
    source = table.concat(segments)
    if #source ~= EXPECTED_BYTES then
        failLoader("download incompleto (" .. #source .. "/" .. EXPECTED_BYTES .. " bytes).")
    end
end

if not fromCache then
-- MYTHIC CUSTOM PATCH: substitui logo e remove a categoria Chat.
-- As substituicoes sao agrupadas para evitar dezenas de copias de um codigo de 12 MB.
local queuedPatches = {}
local function mythicFlushPatches()
    if #queuedPatches == 0 then return end
    table.sort(queuedPatches, function(a, b) return a.start < b.start end)
    local pieces, cursor = {}, 1
    for _, patch in ipairs(queuedPatches) do
        pieces[#pieces + 1] = string.sub(source, cursor, patch.start - 1)
        pieces[#pieces + 1] = patch.replacement
        cursor = patch.start + patch.length
    end
    pieces[#pieces + 1] = string.sub(source, cursor)
    source = table.concat(pieces)
    table.clear(queuedPatches)
end
local function mythicReplaceOnce(needle, replacement, label)
    local first = string.find(source, needle, 1, true)
    local conflict = first == nil
    for _, patch in ipairs(queuedPatches) do
        if first and first < patch.start + patch.length and patch.start < first + #needle then
            conflict = true
        end
        if not conflict and string.find(patch.replacement, needle, 1, true) then
            conflict = true
        end
        if conflict then break end
    end
    if conflict then
        mythicFlushPatches()
        first = string.find(source, needle, 1, true)
    end
    if not first then
        warn("MYTHIC-HUB: ajuste opcional nao aplicado: " .. tostring(label))
        return false
    end
    queuedPatches[#queuedPatches + 1] = {start = first, length = #needle, replacement = replacement}
    return true
end
-- MYTHIC HUB: recurso virtual com nome legado, mas salvo na pasta MYTHIC-HUB.
mythicReplaceOnce(
    [=[return "PulseHubOffline/" .. OfflineFiles._pathKey(path)]=],
    [=[local logical = OfflineFiles._pathKey(path)
    local relative = logical:gsub("^PulseHub/", "")
    relative = relative:gsub("^PulseHub", "MythicHub"):gsub("^Pulse", "Mythic")
    return "MYTHIC-HUB/Assets/" .. relative]=],
    "Arquivos locais em MYTHIC-HUB/Assets")
-- MYTHIC HUB: a aparencia usa o novo nome; codigos internos das opcoes permanecem compativeis.
mythicReplaceOnce(
    [=[Options = {{code = "Pulse", label = "Pulse"}, {code = "Glass", label = "Glass"}, {code = "Compact", label = "Compact"}}]=],
    [=[Options = {{code = "Pulse", label = "MYTHIC"}, {code = "Glass", label = "Glass"}, {code = "Compact", label = "Compact"}}]=],
    "Tema mobile MYTHIC")
mythicReplaceOnce(
    [=[for _, value in values do table.insert(options, {code = value, label = value}) end]=],
    [=[for _, value in values do table.insert(options, {code = value, label = value == "Pulse" and "MYTHIC" or value}) end]=],
    "ESP visual - MYTHIC")
mythicReplaceOnce(
    [=[EspFeature.slider(state, {field = "pulseSpeed", text = "Pulse Speed", min = 0.2, max = 4, decimals = 1})]=],
    [=[EspFeature.slider(state, {field = "pulseSpeed", text = "Animation Speed", min = 0.2, max = 4, decimals = 1})]=],
    "ESP Animation Speed")
mythicReplaceOnce(
    [=[toggle("Cursor Pulse", "cursorPulse", function() slider("Pulse Speed", "cursorPulseSpd", 1, 10); slider("Pulse Size", "cursorPulseAmt", 5, 80, "%") end)]=],
    [=[toggle("Cursor Effect", "cursorPulse", function() slider("Effect Speed", "cursorPulseSpd", 1, 10); slider("Effect Size", "cursorPulseAmt", 5, 80, "%") end)]=],
    "Cursor Effect")
mythicReplaceOnce(
    [=[if type(sync.Rarities) == "table" and not sync.Rarities.Pulse then sync.Rarities.Pulse = {Name = "Pulse", Hex = "#2ef2ff", Sort = 60, Color = {r = 46, g = 242, b = 255}} end]=],
    [=[if type(sync.Rarities) == "table" and not sync.Rarities.Pulse then sync.Rarities.Pulse = {Name = "MYTHIC", Hex = "#2ef2ff", Sort = 60, Color = {r = 46, g = 242, b = 255}} end]=],
    "Raridade MYTHIC")
-- MYTHIC FARM: Fast Speed 25 como padrao e limite maximo.
mythicReplaceOnce(
    [=[local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 24, 8, 24)]=],
    [=[local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 25, 8, 25)]=],
    "Fast Speed operacional 25")
mythicReplaceOnce(
    [=[{"Fast Speed", "fastSpeed", 8, 24, 24}]=],
    [=[{"Fast Speed", "fastSpeed", 20, 25, 25}]=],
    "Fast Speed slider 25")
-- Atualiza somente o valor antigo padrao de 24; escolhas personalizadas sao preservadas.
mythicReplaceOnce(
    [==[local section, settings, environment = context.section, context.configuration.farm, context.environment
	section:Header("Stats")]==],
    [==[local section, settings, environment = context.section, context.configuration.farm, context.environment
	settings.fastSpeed = 25
	section:Header("Stats")]==],
    "Fast Speed migrar 24/26 para 25")

-- MYTHIC FARM: Under Map Speed 23 (padrao e limite), independente do Fast 24.
mythicReplaceOnce(
    [=[{"Farm Speed", "speed", 8, 22, 21}]=],
    [=[{"Farm Speed", "speed", 8, 23, 23}]=],
    "Under Map: slider 8-23")
mythicReplaceOnce(
    [==[local section, settings, environment = context.section, context.configuration.farm, context.environment
	settings.fastSpeed = 25
	section:Header("Stats")]==],
    [==[local section, settings, environment = context.section, context.configuration.farm, context.environment
	settings.fastSpeed = 25
	if settings.speed == nil or tonumber(settings.speed) == 21 or tonumber(settings.speed) == 24 or tonumber(settings.speed) == 25 then settings.speed = 23 end
	section:Header("Stats")]==],
    "Under Map: velocidade padrao 23")
-- MYTHIC FARM: Fast maximo 25 com intervalo nao bloqueante de 0.22s.
-- Confirmacao de moeda em 0.01s e retentativas a cada 0.22s, sem duplicar chamadas por frame.
mythicReplaceOnce(
    [==[if distance < 4 then FarmMotion.touch(context, character, target) end
	if distance < 1 then
		motion.dwellFrom = motion.dwellFrom or now
		if now - motion.dwellFrom >= (target == gun and 0.25 or 0.05) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then motion.pending[target] = {t = now + 0.9} end
			motion.coin, motion.dwellFrom = nil, nil
		end
		return
	end]==],
    [==[-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	if not inContact then motion.fastContactCoin = nil end
	if distance < 4 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= 0.22) then
		FarmMotion.touch(context, character, target)
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance < 1 then
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		if now - motion.dwellFrom >= (target == gun and 0.25 or 0.01) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Moeda ainda nao confirmada: liberar nova tentativa apos 0.22s.
				motion.pending[target] = {t = now + 0.22, fast = true}
			end
			-- Proxima busca sem espera; o modo adaptativo continua cuidando dos alvos ativos.
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil]==],
    "Fast: confirmacao 0.01s e retentativas nao bloqueantes 0.22s")

mythicReplaceOnce(
    [====[local function queueOnTeleport(_source) end]====],
    [====[local nativeQueue = lookup("queue_on_teleport") or lookup("queueonteleport")
	if type(nativeQueue) ~= "function" then
		local nativeSyn = lookup("syn")
		if type(nativeSyn) == "table" then
			nativeQueue = nativeSyn.queue_on_teleport or nativeSyn.queueonteleport
		end
	end
	local function queueOnTeleport(payload)
		if type(nativeQueue) ~= "function" or type(payload) ~= "string" or payload == "" then return false end
		local success, result = pcall(nativeQueue, payload)
		return success and result ~= false
	end]====],
    "Auto Rejoin: usar queue_on_teleport real quando disponivel")

mythicReplaceOnce(
    [====[function FarmRuntime.installRejoin(context, api)
	local environment, globals = context.environment, context.environment.getgenv()
	local state = {busy = false, tries = 0}
	globals.__pulseRejoin = state
	state.key = function()
		local key = rawget(globals, "script_key")
		if type(key) ~= "string" or key == "" then key = rawget(environment._G or {}, "script_key") end
		if type(key) == "string" and key ~= "" then return key end
		return nil
	end
	state.queue = function()
		local queue = environment.syn and environment.syn.queue_on_teleport or environment.queue_on_teleport
			or environment.queueonteleport or environment.fluxus and environment.fluxus.queue_on_teleport
		if type(queue) ~= "function" then return false end
		local key = state.key()
		local prefix = key and string.format("script_key = %q\npcall(function() getgenv().script_key = %q end)\n", key, key) or ""
		local source = prefix .. 'if not game:IsLoaded() then game.Loaded:Wait() end\ntask.wait(1)\nif getgenv().PulseMM2HubState then return end\nloadstring(game:HttpGet("offline://raw.githubusercontent.com/PulseZax/Loader/refs/heads/main/.lua"))()'
		return pcall(queue, source)
	end
	state.onKick = function(message)
		pcall(function()
			local webhook = rawget(globals, "__pulseFarmWebhook")
			if type(webhook) == "table" and type(webhook.onKick) == "function" then environment.task.spawn(webhook.onKick, message) end
		end)
		if state.busy or context.configuration.farm.rejoin == false or not api.getEnabled() then return end
		local text = tostring(message or ""):lower()
		for _, blocked in {"same account", "another device", "different device", "banned", "anti stealer"} do
			if text:find(blocked, 1, true) then return end
		end
		state.busy, state.msg, state.queued = true, tostring(message or ""), state.queue()
		environment.task.spawn(function()
			while true do
				state.tries += 1
				pcall(function()
					if state.tries <= 2 then
						context.teleport:TeleportToPlaceInstance(environment.game.PlaceId, environment.game.JobId, context.player)
						return
					end
					context.teleport:Teleport(environment.game.PlaceId, context.player)
				end)
				local wait = state.tries <= 6 and 10 or (state.tries <= 12 and 30 or 60)
				environment.task.wait(wait)
			end
		end)
	end
	if context.guiService.ErrorMessageChanged then
		context.connect(context.guiService.ErrorMessageChanged, function(message)
			if type(message) == "string" and message ~= "" then state.onKick(message) end
		end)
	end
	environment.task.spawn(function()
		local overlay
		pcall(function() overlay = context.coreGui:WaitForChild("RobloxPromptGui", 20):WaitForChild("promptOverlay", 20) end)
		if not overlay or not context.isAlive() then return end
		context.connect(overlay.ChildAdded, function(prompt)
			if prompt.Name ~= "ErrorPrompt" then return end
			environment.task.wait(0.5)
			local message = ""
			pcall(function() message = context.guiService:GetErrorMessage() end)
			if message == "" then
				pcall(function()
					for _, label in prompt:GetDescendants() do
						if label:IsA("TextLabel") and #label.Text > #message then message = label.Text end
					end
				end)
			end
			state.onKick(message ~= "" and message or "disconnected")
		end)
	end)
	return state
end
]====],
    [====[function FarmRuntime.installRejoin(context, api)
	local environment, globals = context.environment, context.environment.getgenv()
	local previous = rawget(globals, "__pulseRejoin")
	if type(previous) == "table" and type(previous.stop) == "function" then pcall(previous.stop) end
	local state = {busy = false, tries = 0, teleporting = false, exhausted = false, stopped = false, status = "ready"}
	state.stop = function() state.stopped = true end
	globals.__pulseRejoin = state
	state.key = function()
		local key = rawget(globals, "script_key")
		if type(key) ~= "string" or key == "" then key = rawget(environment._G or {}, "script_key") end
		return type(key) == "string" and key ~= "" and key or nil
	end
	state.queue = function()
		local queue = environment.syn and environment.syn.queue_on_teleport or environment.queue_on_teleport
			or environment.queueonteleport or environment.fluxus and environment.fluxus.queue_on_teleport
		if type(queue) ~= "function" then return false end
		local key = state.key()
		local prefix = key and string.format("script_key = %q\npcall(function() getgenv().script_key = %q end)\n", key, key) or ""
		local script = prefix .. 'if not game:IsLoaded() then game.Loaded:Wait() end\ntask.wait(1)\nif getgenv().PulseMM2HubState then return end\nloadstring(game:HttpGet("https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/main.lua"))()'
		local ok, queued = pcall(queue, script)
		return ok and queued ~= false
	end
	local function networkError(message)
		local lower = tostring(message or ""):lower()
		-- A developer kick / ban is not a recoverable network failure.
		if lower:find("267", 1, true) or lower:find("268", 1, true)
			or lower:find("600", 1, true) or lower:find("kicked", 1, true)
			or lower:find("expulso", 1, true) or lower:find("banido", 1, true)
			or lower:find("banned", 1, true) then return false end
		return lower:find("266", 1, true) ~= nil
			or lower:find("277", 1, true) ~= nil
			or lower:find("279", 1, true) ~= nil
			or lower:find("connection lost", 1, true) ~= nil
			or lower:find("disconnected", 1, true) ~= nil
			or lower:find("desconectado", 1, true) ~= nil
	end
	pcall(function()
		context.connect(context.player.OnTeleport, function(teleportState)
			if state.stopped then return end
			if teleportState == environment.Enum.TeleportState.Started
				or teleportState == environment.Enum.TeleportState.InProgress then
				state.teleporting, state.status = true, "teleporting"
			elseif teleportState == environment.Enum.TeleportState.Failed then
				state.teleporting, state.status = false, "teleport_failed"
			end
		end)
	end)
	pcall(function()
		context.connect(context.teleport.TeleportInitFailed, function(player)
			if not state.stopped and player == context.player then
				state.teleporting, state.status = false, "teleport_failed"
			end
		end)
	end)
	state.onKick = function(message)
		state.msg = tostring(message or "")
		if not networkError(message) then
			state.status = "no_retry_for_kick"
			-- Error 267 is an experience-side removal; no client-side teleport can guarantee a return.
			if tostring(message or ""):find("267", 1, true) then
				environment.warn("MYTHIC HUB: erro 267 (expulsao pelo jogo). Auto Rejoin nao pode restaurar uma sessao banida. Mensagem: " .. tostring(message))
			end
			return
		end
		if state.busy or state.stopped or state.exhausted or state.teleporting
			or context.configuration.farm.rejoin == false or not context.isAlive() then return end
		state.busy, state.status, state.queued = true, "reconnecting", state.queue()
		environment.task.spawn(function()
			for attempt = 1, 2 do
				if state.stopped or state.teleporting or not context.isAlive()
					or context.configuration.farm.rejoin == false then break end
				state.tries = attempt
				-- Generic place teleport: never explicitly target the disconnected JobId.
				local success, problem = pcall(function()
					context.teleport:Teleport(environment.game.PlaceId, context.player)
				end)
				if not success then environment.warn("MYTHIC Rejoin (rede): " .. tostring(problem)) end
				environment.task.wait(12)
			end
			state.busy = false
			if not state.teleporting then
				state.exhausted, state.status = true, "reconnect_unavailable"
			end
		end)
	end
	if context.guiService.ErrorMessageChanged then
		context.connect(context.guiService.ErrorMessageChanged, function(message)
			if state.stopped or type(message) ~= "string" or message == "" then return end
			state.onKick(message)
		end)
	end
	environment.task.spawn(function()
		local overlay
		pcall(function() overlay = context.coreGui:WaitForChild("RobloxPromptGui", 20):WaitForChild("promptOverlay", 20) end)
		if not overlay or state.stopped or not context.isAlive() then return end
		context.connect(overlay.ChildAdded, function(prompt)
			if state.stopped or prompt.Name ~= "ErrorPrompt" then return end
			environment.task.wait(0.5)
			if state.stopped then return end
			local message = ""
			pcall(function() message = context.guiService:GetErrorMessage() end)
			if message == "" then
				pcall(function()
					for _, label in prompt:GetDescendants() do
						if label:IsA("TextLabel") and #label.Text > #message then message = label.Text end
					end
				end)
			end
			state.onKick(message ~= "" and message or "unknown connection error")
		end)
	end)
	return state
end
]====],
    "Auto Rejoin: maximo 4 tentativas e loader MYTHIC")

mythicReplaceOnce(
    [====[function FarmMotion.reset(context, motion, character)
	pcall(function()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root then
			for _, name in {"PulseFarmBV", "PulseFarmBG"} do local object = root:FindFirstChild(name); if object then object:Destroy() end end
		end
		if humanoid and humanoid.PlatformStand then
			humanoid.PlatformStand = false
			if humanoid.Health > 0 then humanoid:ChangeState(context.environment.Enum.HumanoidStateType.GettingUp) end
		end
	end)
	if motion.ctRestore then pcall(motion.ctRestore) end
	motion.phase, motion.coin, motion.hold = "idle", nil, nil
end
]====],
    [====[function FarmMotion.reset(context, motion, character)
	pcall(function()
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if root then
			for _, name in {"PulseFarmBV", "PulseFarmBG"} do local object = root:FindFirstChild(name); if object then object:Destroy() end end
		end
		if humanoid and humanoid.PlatformStand then
			humanoid.PlatformStand = false
			if humanoid.Health > 0 then humanoid:ChangeState(context.environment.Enum.HumanoidStateType.GettingUp) end
		end
	end)
	if motion.ctRestore then pcall(motion.ctRestore) end
	motion.phase, motion.coin, motion.hold = "idle", nil, nil
	-- Referencias a moedas e mapas de rodadas antigas impediam o GC de liberar memoria.
	motion.info, motion.skip, motion.pending, motion.att, motion.tp = {}, {}, {}, {}, {}
	motion.containers, motion.containerAt, motion.filterAt, motion.rayParams = {}, 0, 0, nil
	motion.fastTouchedCoin, motion.fastDwellTarget, motion.gunSeen = nil, nil, nil
	motion.fastContactCoin, motion.fastMisses = nil, {}
	motion.gunTarget, motion.dwellFrom, motion.zCur, motion.zfs = nil, nil, nil, nil
end
]====],
    "Farm: liberar referencias de moedas a cada rodada")

mythicReplaceOnce(
    [====[context.connect(context.runService.Stepped, function()
		if not active() or motion.phase == "idle" then return end]====],
    [====[local lastNoclipScan = -1
	context.connect(context.runService.Stepped, function()
		if not active() or motion.phase == "idle" then return end
		local scanNow = environment.os.clock()
		if scanNow - lastNoclipScan < 0.05 then return end
		lastNoclipScan = scanNow]====],
    "Farm: limitar custo de noclip a 20 varreduras/s")

mythicReplaceOnce(
    [====[function FarmMotion.choose(context, state, motion, position, murderer, now)
	local chosen, lowest
	for _, container in FarmMotion.containers(context, state, motion, now) do
		if not container.Parent then continue end
		for _, coin in container:GetChildren() do
			if not FarmState.validCoin(context, state, coin) or (motion.skip[coin] or 0) >= now or motion.pending[coin] then continue end
			local info = FarmMotion.coinInfo(context, state, motion, coin, now)
			local score = (info.hide - position).Magnitude + math.max(0, coin.Position.Y - info.hide.Y) * 1.2
			if info.exposed then score += 25 end
			score += FarmMotion.murderPenalty(state, coin.Position, murderer)
			if not lowest or score < lowest then chosen, lowest = coin, score end
		end
	end
	if chosen and state.avoidMurder and lowest >= 1000000 then return nil end
	return chosen, lowest
end
]====],
    [====[function FarmMotion.coinScore(state, position, coin, murderer)
	local displacement = coin.Position - position
	-- Movimento sob o mapa prioriza a distancia horizontal; a altura ainda tem custo moderado.
	local horizontal = math.sqrt(displacement.X * displacement.X + displacement.Z * displacement.Z)
	local vertical = math.min(math.abs(displacement.Y), 80)
	return horizontal + vertical * 0.2 + FarmMotion.murderPenalty(state, coin.Position, murderer)
end

function FarmMotion.choose(context, state, motion, position, murderer, now)
	local chosen, lowest
	for _, container in FarmMotion.containers(context, state, motion, now) do
		if not container.Parent then continue end
		for _, coin in container:GetChildren() do
			if not FarmState.validCoin(context, state, coin) or (motion.skip[coin] or 0) >= now or motion.pending[coin] then continue end
			local score = FarmMotion.coinScore(state, position, coin, murderer)
			if not lowest or score < lowest then chosen, lowest = coin, score end
		end
	end
	if chosen and state.avoidMurder and lowest >= 1000000 then return nil end
	return chosen, lowest
end
]====],
    "Farm Under Map: prioridade por proximidade real sem penalidade de 25 studs")

mythicReplaceOnce(
    [====[if not coin or motion.phase == "go" and now - (motion.pickT or 0) > 0.3 then
			motion.pickT = now
			local candidate, score = FarmMotion.choose(context, state, motion, root.Position, murderer, now)
			if candidate and candidate ~= coin then
				local current
				if coin and FarmState.validCoin(context, state, coin) then
					local info = FarmMotion.coinInfo(context, state, motion, coin, now)
					current = (info.hide - root.Position).Magnitude + math.max(0, coin.Position.Y - info.hide.Y) * 1.2
						+ (info.exposed and 25 or 0) + FarmMotion.murderPenalty(state, coin.Position, murderer)
				end
				if not current or score + 6 < current then
					motion.coin, motion.phase, motion.goT, motion.tries, coin = candidate, "go", now, motion.tries + 1, candidate
				end
			end
		end]====],
    [====[if (not coin and now - (motion.pickT or 0) >=
				math.min(((motion.adaptive and motion.adaptive.pickInterval) or 0.2), 0.12))
			or (coin and motion.phase == "go" and now - (motion.pickT or 0) >=
				((motion.adaptive and motion.adaptive.pickInterval) or 0.2)) then
			motion.pickT = now
			local candidate, score = FarmMotion.choose(context, state, motion, root.Position, murderer, now)
			if candidate and candidate ~= coin then
				local current
				if coin and FarmState.validCoin(context, state, coin) and not motion.pending[coin]
					and (motion.skip[coin] or 0) < now then
					current = FarmMotion.coinScore(state, root.Position, coin, murderer)
				end
				-- Histerese pequena: muda para uma moeda realmente mais proxima sem oscilar entre iguais.
				if not current or score + ((motion.adaptive and motion.adaptive.switchMargin) or 1.5) < current then
					motion.coin, motion.phase, motion.goT, motion.tries, coin = candidate, "go", now, motion.tries + 1, candidate
				end
			end
		end]====],
    "Farm Under Map: selecionar proxima moeda de forma adaptativa ao FPS")

mythicReplaceOnce(
    [====[if not coin or now - (motion.pickT or 0) > 0.3 then
			motion.pickT = now
			local best, lowest
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate) or (motion.skip[candidate] or 0) >= now or motion.pending[candidate] then continue end
					local score = (candidate.Position - root.Position).Magnitude + FarmMotion.murderPenalty(state, candidate.Position, murderer)
					if not lowest or score < lowest then best, lowest = candidate, score end
				end
			end
			if best and state.avoidMurder and lowest >= 1000000 then best = nil end
			if best and best ~= coin and (not coin or lowest + 6 < (coin.Position - root.Position).Magnitude + FarmMotion.murderPenalty(state, coin.Position, murderer)) then
				motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
			end
		end]====],
    [====[-- Sempre conferir as moedas proximas, mesmo perto de outro alvo.
		if now - (motion.pickT or 0) >=
			(coin and ((motion.adaptive and motion.adaptive.pickInterval) or 0.2)
			or math.min(((motion.adaptive and motion.adaptive.pickInterval) or 0.2), 0.12)) then
			motion.pickT = now
			local best, lowest
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate) or (motion.skip[candidate] or 0) >= now or motion.pending[candidate] then continue end
					local score = (candidate.Position - root.Position).Magnitude + FarmMotion.murderPenalty(state, candidate.Position, murderer)
					if not lowest or score < lowest then best, lowest = candidate, score end
				end
			end
			if best and state.avoidMurder and lowest >= 1000000 then best = nil end
			if best and best ~= coin then
				local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
				local currentScore = coin and (currentDistance
					+ FarmMotion.murderPenalty(state, coin.Position, murderer)) or math.huge
				-- Permite trocar por outra realmente mais proxima sem alternar a cada frame.
				local dangerous = state.avoidMurder and currentScore >= 1000000
				local canSwitch = not coin or dangerous or
					(now - (motion.fastSwitchedAt or 0) >= 0.12
					and lowest + math.max(1.5, currentDistance * 0.08) < currentScore)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
				end
			end
		end]====],
    "Farm Fast: priorizar moeda proxima com frequencia de busca adaptativa")

mythicReplaceOnce(
    [====[function FarmMotion.containers(context, state, motion, now)
	if now - motion.containerAt > 1 then]====],
    [====[function FarmMotion.containers(context, state, motion, now)
	if now - motion.containerAt > ((motion.adaptive and motion.adaptive.containerInterval) or 0.5) then]====],
    "Farm: atualizar contêineres com intervalo adaptativo por FPS")

-- MYTHIC FARM ADAPTIVE FPS v1: ajusta somente busca/decisao; movimento e ESP seguem por quadro.
mythicReplaceOnce(
    [====[local runtime = {roundAt = 0, gunAt = 0}
	context.connect(context.runService.Heartbeat, function(delta)
		if not active() then return end
		local ok, message = pcall(FarmRuntime.tick, context, state, motion, runtime, delta)]====],
    [====[local runtime = {roundAt = 0, gunAt = 0}
	-- Media exponencial de tempo por quadro: leitura leve para aparelhos de 10-40 FPS.
	local adaptive = {averageFrame = 1 / 25, fps = 25, pickInterval = 0.21,
		switchMargin = 2.25, containerInterval = 0.65, updatedAt = 0}
	motion.adaptive = adaptive
	context.connect(context.runService.Heartbeat, function(delta)
		if not active() then return end
		local frameTime = tonumber(delta)
		if frameTime and frameTime > 0 then
			frameTime = math.clamp(frameTime, 1 / 120, 0.2)
			adaptive.averageFrame = adaptive.averageFrame * 0.85 + frameTime * 0.15
		end
		local now = environment.os.clock()
		if now - adaptive.updatedAt >= 0.7 then
			adaptive.updatedAt = now
			local fps = math.clamp(1 / math.max(adaptive.averageFrame, 1 / 120), 5, 120)
			adaptive.fps = math.floor(fps + 0.5)
			if fps <= 15 then
				adaptive.pickInterval, adaptive.switchMargin, adaptive.containerInterval = 0.18, 2.25, 0.75
			elseif fps <= 25 then
				adaptive.pickInterval, adaptive.switchMargin, adaptive.containerInterval = 0.15, 1.75, 0.60
			elseif fps <= 35 then
				adaptive.pickInterval, adaptive.switchMargin, adaptive.containerInterval = 0.12, 1.50, 0.50
			else
				adaptive.pickInterval, adaptive.switchMargin, adaptive.containerInterval = 0.10, 1.25, 0.40
			end
		end
		local ok, message = pcall(FarmRuntime.tick, context, state, motion, runtime, delta)]====],
    "Farm: regulador FPS com media temporal e quatro faixas")

-- MYTHIC FARM NEAREST v5: evita espera apos coleta, diminui bloqueio de moedas e reduz mudancas de rota.
mythicReplaceOnce(
    [====[if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin = nil, nil
	end]====],
    [====[if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end]====],
    "Farm Fast: remover atraso quando moeda desaparece")

mythicReplaceOnce(
    [====[function FarmMotion.murderPenalty(state, position, murderer)
	if not murderer then return 0 end
	local distance = (position - murderer).Magnitude
	if distance < 24 then return state.avoidMurder and 1000000 or 300 end
	if distance < 48 then return (48 - distance) * 2 end
	return 0
end]====],
    [====[function FarmMotion.murderPenalty(state, position, murderer)
	if not murderer or not state.avoidMurder then return 0 end
	local distance = (position - murderer).Magnitude
	if distance < 24 then return 1000000 end
	if distance < 48 then return (48 - distance) * 2 end
	return 0
end]====],
    "Farm: respeitar configuracao Evitar Murderer sem desviar quando desligada")

mythicReplaceOnce([=[{name = "Config Hub", icon = "library", group = "System", desc = "Browse and share configs"},]=], "", "Config Hub/aba vazia")
mythicReplaceOnce([=[System = {"Mobile", "Config Hub", "Settings", "Server"}]=], [=[System = {"Mobile", "Settings", "Server"}]=], "Config Hub/ordem System")
mythicReplaceOnce([=[{name = "Chat", icon = "messages-square", group = "Fun", desc = "Chat exclusivo para usuarios MYTHIC", badge = "LOCK"},]=], "", "Chat/aba")
mythicReplaceOnce([=[Fun = {"Animations", "Troll", "Music", "Chat", "MYTHIC Users"}]=], [=[Fun = {"Animations", "Troll", "Music", "MYTHIC Users"}]=], "Chat/ordem")
mythicReplaceOnce([=[local mythicChat = PulseTab.create(environment, hub, "Chat", "messages-square", context)
	mythicChat:Group({Title = "MYTHIC CHAT", Side = "Left"})
	mythicChat:Note({Text = "Exclusivo para usuarios do MYTHIC HUB."})
	mythicChat:Note({Text = "Chat temporariamente indisponivel: servico autenticado ainda nao configurado."})
	mythicChat:Note({Text = "As mensagens nao sao enviadas ao chat publico do Roblox."})]=], "", "Chat/inicializacao")
-- Logo: personagem da segunda referencia, renderizado a 160x160 (em vez da miniatura 48x48).
-- MYTHIC LOGO HD 320x320: personagem do usuario de bone cinza e tema neon roxo.
mythicReplaceOnce([=[Logo = "rbxassetid://102076719808486"]=], [=[Logo = (function()
    local assetFunc=environment.getcustomasset or environment.getsynasset or getcustomasset or getsynasset
    local ok,id=pcall(function()
        return type(assetFunc)=="function" and assetFunc("MYTHIC-HUB/Assets/mythic_avatar_logo.jpg")
    end)
    if ok and type(id)=="string" and id~="" then return id end
    local p=game:GetService("Players").LocalPlayer
    local fallbackOk,fallback=pcall(function()
        return game:GetService("Players"):GetUserThumbnailAsync(p.UserId,Enum.ThumbnailType.AvatarThumbnail,Enum.ThumbnailSize.Size420x420)
    end)
    return fallbackOk and fallback or "rbxassetid://102076719808486"
end)()]=], "Logo MYTHIC personagem roxo HD")
-- MYTHIC UI ORDER PATCH: categorias seguem as referencias visuais.
mythicReplaceOnce(
    [=[{name = "Sheriff", icon = "shield", group = "Combat", desc = "Silent aim, aimbot and gun tools"},
			{name = "Murderer", icon = "swords", group = "Combat", desc = "Kill aura, knife throws and targets"}]=],
    [=[{name = "Murderer", icon = "swords", group = "Combat", desc = "Kill aura, knife throws and targets"},
			{name = "Sheriff", icon = "shield", group = "Combat", desc = "Silent aim, aimbot and gun tools"}]=], "ordem Murderer e Sheriff")
mythicReplaceOnce([=[{name = "Player", icon = "user-round", group = "Player", desc = "Movement, speed and protection"},
			]=], "", "Player posicao")
mythicReplaceOnce(
    [=[{name = "Farm", icon = "coins", group = "Economy", desc = "Auto farm, session stats and trading", subs = {]=],
    [=[{name = "Player", icon = "user-round", group = "Player", desc = "Movement, speed and protection"},
			{name = "Farm", icon = "coins", group = "Economy", desc = "Auto farm, session stats and trading", subs = {]=], "Player apos Visuals")
mythicReplaceOnce([=[{name = "Teleport", icon = "map-pin", group = "Economy", desc = "Jump to roles and players"},
			]=], "", "Teleport posicao")
mythicReplaceOnce(
    [=[{name = "Farm", icon = "coins", group = "Economy", desc = "Auto farm, session stats and trading", subs = {]=],
    [=[{name = "Teleport", icon = "map-pin", group = "Economy", desc = "Jump to roles and players"},
			{name = "Farm", icon = "coins", group = "Economy", desc = "Auto farm, session stats and trading", subs = {]=], "Teleport antes de Farm")
mythicReplaceOnce([=[{name = "Troll", icon = "party-popper", group = "Fun", desc = "Pranks, flings, toys and emotes"},
			]=], "", "Troll posicao")
mythicReplaceOnce(
    [=[{name = "Music", icon = "music", group = "Fun", desc = "Play your songs in the round", subs = {]=],
    [=[{name = "Troll", icon = "party-popper", group = "Fun", desc = "Pranks, flings, toys and emotes"},
			{name = "Music", icon = "music", group = "Fun", desc = "Play your songs in the round", subs = {]=], "Troll apos Animations")
-- MYTHIC UI FUNCTION FIX v1.3: aplica itens das referencias de Sheriff e Player.
mythicReplaceOnce([==[main:Group({Title = "Movement", Side = "Right"})]==], [==[main:Group({Title = "Movement", Side = "Left"})]==], "Player Movement esquerda")
mythicReplaceOnce([==[section:Header("Anti-Aim")]==], [==[section:Header("Anti-Aim", "Right")]==], "Anti Aim direita")
mythicReplaceOnce([==[SheriffSection._createGeneralControls(context)
	SheriffSection._createTiming(context)
	context.section:Header("AimBot")]==], [==[SheriffSection._createGeneralControls(context)
	SheriffSection._createTiming(context)
	context.section:Header("AimBot", "Right")]==], "Restaurar Wallbang e controles Sheriff")
mythicReplaceOnce([==[context.section:Toggle({Text = "Auto Pickup Gun", Default = context.defaults.sheriff.autoGun,]==], [==[context.section:Header("Sheriff", "Left")
	context.section:Toggle({Text = "Auto Pickup Gun", Default = context.defaults.sheriff.autoGun,]==], "Sheriff seção")
mythicReplaceOnce([==[	context.section:Keybind({Text = "Pick Up Gun", Default = key, Callback = function(value)
		key = value
		settings.grabKey = value and value.Name or ""
	end})
	context.connect(context.inputService.InputBegan, function(input)]==], [==[	context.section:Keybind({Text = "Pick Up Gun", Default = key, Callback = function(value)
		key = value
		settings.grabKey = value and value.Name or ""
	end})
	context.section:Toggle({Text = "Silent Aim", Default = context.defaults.sheriff.silentAim,
		Callback = function(enabled)
			settings.silentAim = not not enabled
			local aim = globals.__pulseAim or {}
			aim.on = settings.silentAim or settings.aimType == "Flick Shot"
			if settings.silentAim and aim.installHook then pcall(aim.installHook) end
		end})
	context.connect(context.inputService.InputBegan, function(input)]==], "Silent Aim botão")
mythicReplaceOnce([==[if window.SetKeybindList and window.State.get("keybindList", window.IsTouch == true) == true then window:SetKeybindList(true) end]==], [==[if window.SetKeybindList then window:SetKeybindList(false) end]==], "Ocultar Keybinds padrão")
-- MYTHIC LABEL CLEANUP: corrigir caracteres ilegíveis dos atalhos.
mythicReplaceOnce([==[typeof(bind.Key) == "EnumItem" and nova.keyName(bind.Key) or "вЂ”"]==], [==[typeof(bind.Key) == "EnumItem" and nova.keyName(bind.Key) or "-"]==], "atalhos 1")
mythicReplaceOnce([==[Name = "Key", Text = "вЂ”", AutoButtonColor = false]==], [==[Name = "Key", Text = "-", AutoButtonColor = false]==], "atalhos 2")
mythicReplaceOnce([==[local text = item.key and nova.keyName(item.key) or "вЂ”"]==], [==[local text = item.key and nova.keyName(item.key) or "-"]==], "atalhos 3")
-- MYTHIC VISUALS ROLES LABEL: mantem ESP e destaca cargos.
mythicReplaceOnce([==[EspFeature.toggle(state, "on", "Enable ESP")
	for _, option in {{"murderer", "Show Murderer"}]==], [==[EspFeature.toggle(state, "on", "Enable ESP")
	section:Note({Text = "Show Roles"})
	for _, option in {{"murderer", "Show Murderer"}]==], "ESP Show Roles")
-- MYTHIC REFERENCE LAYOUT FIX v1.4: organiza os modulos existentes com base nas 42 referencias.
mythicReplaceOnce([==[GunFeature.installAuto({environment = environment, configuration = settings, defaults = defaults, section = combat,
		player = players.LocalPlayer, roles = roles, drops = gunDrops, runService = runService,
		inputService = inputService, connect = connect, isAlive = function() return not window.Destroyed end})
	local aimContext = ]==], [==[GunFeature.installAuto({environment = environment, configuration = settings, defaults = defaults, section = combat,
		player = players.LocalPlayer, roles = roles, drops = gunDrops, runService = runService,
		inputService = inputService, connect = connect, isAlive = function() return not window.Destroyed end})
	-- Adiciona os controles extras ainda na seção Sheriff, antes de Anti-Aim mover o contexto visual para Player.
	SheriffSection._createGeneralControls({section = combat, configuration = settings, defaults = defaults})
	local aimContext = ]==], "Controles Sheriff dentro da própria aba")
mythicReplaceOnce([==[SheriffSection._createGeneralControls(context)
	SheriffSection._createTiming(context)
	context.section:Header("AimBot", "Right")]==], [==[context.section:Header("AimBot", "Right")
	SheriffSection._createTiming(context)]==], "Não misturar Sheriff em Anti-Aim/Player")
mythicReplaceOnce([==[section:Header("AimBot FOV")]==], [==[section:Header("AimBot FOV", "Left")]==], "AimBot FOV no lado esquerdo de Sheriff")
mythicReplaceOnce([==[section:Header("Bullet Tracers")]==], [==[section:Header("Bullet Tracers", "Left")]==], "Bullet Tracers no lado esquerdo de Sheriff")
-- MYTHIC MOBILE SHOT STABILITY v1.5: precaucoes contra conflitos de disparo e fling.
mythicReplaceOnce([==[aim.installHook = function()
		if installNamecall() then return true end]==], [==[aim.installHook = function()
		-- Tenta primeiro o hook com verificacao de compatibilidade do proprio runtime.
		-- Se indisponivel, o codigo original usa o fallback de posicao.
		if installNamecall() then return true end]==], "Safe Silent Aim on mobile")
mythicReplaceOnce([==[local canFling = context.configuration.autoFlingSheriff and active and humanoid and ownRoot and humanoid.Health > 0]==], [==[local canFling = context.configuration.autoFlingSheriff and active and humanoid and ownRoot and humanoid.Health > 0
				and not (own and own:FindFirstChild("Gun"))]==], "No new fling while gun is equipped")
mythicReplaceOnce([==[if not ok or method ~= "FireServer" or not current or not current.on or current.bypass or globals.__pulseAimGen ~= generation then]==], [==[if not ok or method ~= "FireServer" or not current or not current.on or current.bypass or globals.__pulseAimGen ~= generation or (settings.silentAim and settings.wallbang) then]==], "Skip intercepted shot if incompatible pair")
-- MYTHIC AUTO SHOOT STABILITY v1.6: desacelera tentativas automaticas e bloqueia combinacoes instaveis.
mythicReplaceOnce([==[local interval = rapid and (aim.dsGap or 0.04) or 0.2]==], [==[local interval = rapid and math.max(tonumber(aim.dsGap) or 0.04, 0.12) or 0.2]==], "Auto Shoot estabilidade 1")
mythicReplaceOnce([==[if not settings.autoShoot or now - lastAuto <= interval or not SheriffRuntime.gun(context) then return end]==], [==[if not settings.autoShoot or settings.silentAim or settings.wallbang or now - lastAuto <= interval or not SheriffRuntime.gun(context) then return end]==], "Auto Shoot estabilidade 2")
-- MYTHIC WALL PATH FIX v1.7: habilita ramo existente de busca de trajeto apos obstaculo sem reativar hooks instaveis.
mythicReplaceOnce([==[if requireSight and not AimTarget.visible(context, state, character) then return nil, nil, "no line of sight" end
	state.shift = AimCalibration.lagOf(context, state, character)]==], [==[if requireSight and not AimTarget.visible(context, state, character) then return nil, nil, "no line of sight" end
	-- A configuracao ativa o calculo de trajetorias apos o primeiro obstaculo.
	-- A validacao de impactos pelo servidor permanece autoritativa.
	state.wallStart = context.configuration.sheriff.wallbang == true
	state.shift = AimCalibration.lagOf(context, state, character)]==], "ligar Wallbang ao planejador de tiro")
-- MYTHIC CONCURRENT FEATURES FIX v1.8: toggles independentes, disparos serializados e Fling coordenado.
mythicReplaceOnce([==[if not settings.autoShoot or settings.silentAim or settings.wallbang or now - lastAuto <= interval or not SheriffRuntime.gun(context) then return end]==], [==[if autoBusy or not settings.autoShoot or now - lastAuto <= interval or not SheriffRuntime.gun(context) then return end]==], "Auto Shoot com todas funcoes ligadas")
mythicReplaceOnce([==[local lastAuto, lastEquip = 0, 0
	context.connect(context.runService.Heartbeat, function()]==], [==[local lastAuto, lastEquip, autoBusy = 0, 0, false
	context.connect(context.runService.Heartbeat, function()]==], "Auto Shoot trava contra sobreposicao")
mythicReplaceOnce([==[if not player or not character then return end
		pcall(function()
			if not allowed(character) then return end]==], [==[if not player or not character then return end
		-- Todas as opcoes continuam ligadas; a execucao concorrente espera a operacao anterior.
		if globals.__pulseManualFling or globals.__pulseTouchFlinging then return end
		lastAuto, autoBusy = now, true
		local ok, err = pcall(function()
			if not allowed(character) then return end]==], "Auto Shoot aguarda operacoes de Fling")
mythicReplaceOnce([==[			shoot(character, false)
		end)
		lastAuto = now]==], [==[			shoot(character, false)
		end)
		autoBusy = false
		if not ok then warn("MYTHIC-HUB: erro no Auto Shoot: " .. tostring(err)) end
		lastAuto = now]==], "Auto Shoot libera trava mesmo com erro")
mythicReplaceOnce([==[and not (own and own:FindFirstChild("Gun"))
				and environment.tick() - roundAt >= 2 and not state.active]==], [==[and not globals.__pulseManualFling and not globals.__pulseTouchFlinging
				and environment.os.clock() > (tonumber(globals.__pulseShotHold) or 0) + 0.35
				and environment.tick() - roundAt >= 2 and not state.active]==], "Auto Fling sequenciado sem desativar com arma")
mythicReplaceOnce([==[globals.__pulseAimGen ~= generation or (settings.silentAim and settings.wallbang) then]==], [==[globals.__pulseAimGen ~= generation then]==], "Silent Aim + Wallbang sem bloqueio artificial")
-- MYTHIC ONLINE COUNTER v3.0: contagem de contas declaradas sem duplicar varias execucoes.
mythicReplaceOnce([====[mythicUsers:Group({Title = "MYTHIC USERS", Side = "Left"})]====], [====[mythicUsers:Group({Title = "MYTHIC USERS", Side = "Left"})
	-- MYTHIC ONLINE COUNTER v2.0: contagem de sessoes ativas sem nomes, usuarios ou servidores.
	mythicUsers:Group({Title = "Online agora", Side = "Right"})
	local onlineLabel = mythicUsers:Note({Text = "MYTHIC-HUB online: conectando..."})
	mythicUsers:Note({Text = "Estima contas distintas online. Atualiza a cada 30s; identidades Roblox nao sao verificadas."})
	local stopMythicOnline = (function()
		local serviceUrl = "https://bpgovdwdigwrrzokqvlh.supabase.co/functions/v1/mythic-online"
		local active, token, onlineGui = true, nil, nil
		local uiText
		local runner = environment.task
		local function updateDisplay(value)
			local caption = value == nil and "MYTHIC ONLINE: --" or ("MYTHIC ONLINE: " .. tostring(value))
			pcall(function() onlineLabel.Text = caption end)
			pcall(function() if uiText then uiText.Text = caption end end)
		end
		pcall(function()
			local guiParent = players.LocalPlayer and players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
			if not guiParent then return end
			local oldGui = guiParent:FindFirstChild("MYTHIC_ONLINE_BADGE")
			if oldGui then oldGui:Destroy() end
			onlineGui = Instance.new("ScreenGui")
			onlineGui.Name = "MYTHIC_ONLINE_BADGE"
			onlineGui.ResetOnSpawn = false
			onlineGui.IgnoreGuiInset = true
			onlineGui.DisplayOrder = 850
			onlineGui.Parent = guiParent
			local chip = Instance.new("Frame")
			chip.AnchorPoint = Vector2.new(1, 0)
			chip.Position = UDim2.new(1, -10, 0, 54)
			chip.Size = UDim2.fromOffset(134, 25)
			chip.BackgroundColor3 = Color3.fromRGB(23, 12, 40)
			chip.BackgroundTransparency = 0.08
			chip.BorderSizePixel = 0
			chip.Parent = onlineGui
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 9)
			corner.Parent = chip
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(158, 59, 245)
			stroke.Thickness = 1
			stroke.Transparency = .24
			stroke.Parent = chip
			uiText = Instance.new("TextLabel")
			uiText.Size = UDim2.fromScale(1,1)
			uiText.BackgroundTransparency = 1
			uiText.Font = Enum.Font.GothamBold
			uiText.TextSize = 10
			uiText.TextColor3 = Color3.fromRGB(235,213,255)
			uiText.Text = "MYTHIC ONLINE: --"
			uiText.Parent = chip
		end)
		local function alive()
			return active and not hub.dead and not window.Destroyed
		end
		local function send(data)
			if type(mythicRequest) ~= "function" then return nil end
			local okJson, encoded = pcall(function() return actualHttp:JSONEncode(data) end)
			if not okJson then return nil end
			local ok, reply = pcall(mythicRequest, {
				Url = serviceUrl, Method = "POST",
				Headers = {["Content-Type"] = "application/json", ["Accept"] = "application/json"},
				Body = encoded
			})
			if not ok or type(reply) ~= "table" then return nil end
			local code = tonumber(reply.StatusCode or reply.Status or 0)
			if not code or code < 200 or code >= 300 then return nil end
			local good, payload = pcall(function() return actualHttp:JSONDecode(tostring(reply.Body or "")) end)
			if good and type(payload) == "table" and payload.ok == true then return payload end
			return nil
		end
		local function stop()
			if not active then return end
			active = false
			local oldToken = token
			token = nil
			if onlineGui then pcall(function() onlineGui:Destroy() end) end
			if oldToken then runner.spawn(function() send({action = "stop", token = oldToken}) end) end
		end
		local previous = environment.getgenv().__mythicOnlineStop
		if type(previous) == "function" then pcall(previous) end
		environment.getgenv().__mythicOnlineStop = stop
		if type(mythicRequest) ~= "function" then
			updateDisplay(nil)
			pcall(function() onlineLabel.Text = "Contador indisponivel: HTTP nao suportado" end)
		else
			runner.spawn(function()
				while alive() do
					local response
					if token then response = send({action = "ping", token = token}) end
					if not response then
						local nextSession = send({action = "start", user_id = players.LocalPlayer.UserId})
						if not alive() then
							if nextSession and nextSession.token then send({action = "stop", token = nextSession.token}) end
							break
						end
						token = nextSession and nextSession.token or nil
						response = nextSession
					end
					if alive() then
						updateDisplay(response and tonumber(response.online) or nil)
					end
					runner.wait(30)
				end
			end)
		end
		return stop
	end)()
    -- USER MYTHIC: modulo isolado para nao alterar as outras ferramentas do hub.
    local stopMythicBadges=function() end
    pcall(function()
        local url="https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/mythic-badges.lua"
        local module=loadstring(game:HttpGet(url))()
        if type(module)=="function" then
            stopMythicBadges=module({section=mythicUsers,hub=hub,window=window,request=mythicRequest})
        end
    end)]====], "online badge and heartbeat")
mythicReplaceOnce([====[		pcall(stopMythicUsers)]====], [====[		pcall(stopMythicUsers)
		pcall(stopMythicOnline)
		pcall(stopMythicBadges)]====], "online cleanup on destroy")
-- Corrige o destino dos controles SoundCloud na aba Music.
mythicReplaceOnce([====[["Troll Fun/SoundCloud"] = {"Music", "SoundCloud"},]====], [====[["Troll Fun/SoundCloud:*"] = {"Music", "SoundCloud"},
			["Troll Fun/SoundCloud"] = {"Music", "SoundCloud"},]====], "SoundCloud: Music > SoundCloud")

-- MYTHIC AVATAR PRESETS + SOUNDCloud SHORTCUTS v3.1
mythicReplaceOnce([====[local presets = {{code = "163620952", label = "Iysglimt"}, {code = "8990346215", label = "runeaid"},
		{code = "89003145", label = "7788s"}, {code = "1219722", label = "coldness"},
		{code = "1195061435", label = "reaizsym"}, {code = "887330563", label = "aurqzv"}}]====], [====[local presets = {
		{code = "tty486o", label = "tty486o"},
		{code = "itzSavvii", label = "itzSavvii"},
		{code = "polaxired", label = "polaxired"},
		{code = "Du1chy", label = "Du1chy"},
		{code = "Lascothat", label = "Lascothat"},
		{code = "vir1e", label = "vir1e"},
		{code = "Rotanix", label = "Rotanix"},
		{code = "AlreadyLazy", label = "AlreadyLazy"},
		{code = "Cezeeys", label = "Cezeeys"},
	}]====], "Nove avatares Roblox")
mythicReplaceOnce([====[AnimationFeature.catalog(state, "skin")]====], [====[section:Note({Text = "Use Presets para os 9 avatares MYTHIC-HUB, ou digite outro Username acima."})]====], "Retirar catalogo Skin antigo")
mythicReplaceOnce([====[	local _, stopBoombox = Boombox.install(]====], [====[
	-- MYTHIC-HUB SoundCloud: atalhos para busca oficial (sem Sound ID do Roblox).
	-- A versao atual do hub nao incorpora um player web; nao promete tocar in-game.
	-- MYTHIC MUSIC: apenas um player funcional e selecao enxuta de tendencias.
	fun:Sub("SoundCloud")
	fun:Header("SoundCloud")
	fun:Note({Text="Reproducao local dos arquivos instalados no executor."})
	fun:Note({Text="Escolha uma das 5 musicas enviadas. Todas precisam estar na workspace."})
    -- MYTHIC MUSIC: somente arquivos de audio enviados pelo dono.
    local mymCraudeteService=game:GetService("SoundService")
    local mymCraudeteSound=nil
    local mymCraudeteGeneration=0
    local mymCraudeteVolume,mymCraudeteLoop,mymCraudeteMuted=.6,false,false
    local function mymCraudeteInfo(message,kind)
        pcall(function()
            window:Notify({Title="MYTHIC-HUB | Musica",Text=tostring(message),Kind=kind or "info",Duration=7})
        end)
    end
    local function mymCraudeteAPI(name)
        local ok,env=pcall(getfenv)
        if ok and type(env)=="table" and type(env[name])=="function" then return env[name] end
        if type(getgenv)=="function" then
            local yes,globals=pcall(getgenv)
            if yes and type(globals)=="table" and type(globals[name])=="function" then
                return globals[name]
            end
        end
        return nil
    end
    local function mymCraudeteStop()
        mymCraudeteGeneration+=1
        if mymCraudeteSound then
            pcall(function()
                mymCraudeteSound:Stop()
                mymCraudeteSound:Destroy()
            end)
            mymCraudeteSound=nil
        end
    end
    local earlier=mymCraudeteService:FindFirstChild("MYTHIC_CRAUDETE_LOCAL")
    if earlier then pcall(function() earlier:Destroy() end) end
    fun:Button({Text="Pausar / Continuar",Callback=function()
        if not mymCraudeteSound then mymCraudeteInfo("Toque em Tocar primeiro.");return end
        local ok=pcall(function()
            if mymCraudeteSound.IsPlaying then mymCraudeteSound:Pause()
            else mymCraudeteSound:Resume()end
        end)
        if not ok then mymCraudeteInfo("Falha ao pausar ou continuar.","warning")end
    end})
    fun:Button({Text="Parar",Callback=mymCraudeteStop})
    fun:Dropdown({Text="Repeticao",Options={
        {code="once",label="Tocar 1 vez"},{code="loop",label="Repetir infinito"}
    },Default="once",NoSave=true,Callback=function(v)
        mymCraudeteLoop=v=="loop"
        if mymCraudeteSound then mymCraudeteSound.Looped=mymCraudeteLoop end
    end})
    fun:Slider({Text="Volume",Min=0,Max=100,Default=60,Decimals=0,NoSave=true,Callback=function(v)
        mymCraudeteVolume=math.clamp(tonumber(v) or 60,0,100)/100
        if mymCraudeteSound then mymCraudeteSound.Volume=mymCraudeteMuted and 0 or mymCraudeteVolume end
    end})
    
    fun:Header("Library")
    local mymTrending = {
        {code="audio-enviado-01",label="I NON MI INNAMORERÒ",file="i-non-mi-innamorero.mp3",localOnly=true},
        {code="music-thing-hoodtrap",label="1 Thing hoodtrap",file="1-thing-hoodtrap.mp3",localOnly=true},
        {code="music-sou-favela",label="Sou favela",file="sou-favela.mp3",localOnly=true},
        {code="music-tseluy",label="tseluy",file="tseluy.mp3",localOnly=true},
        {code="music-amor-emmanuel",label="amor Emmanuel",file="amor-emmanuel.mp3",localOnly=true},
        {code="music-craudete",label="Claudete - Brancoala",file="craudete-brancoala.mp3",url="https://palcocdn.akamaized.net/5/d/4/f/brancoala-craudete-ab35bc.mp3",localOnly=true},
    }
    local mymOptions, mymSelected = {}, mymTrending[1].code
    for _,item in ipairs(mymTrending) do
        table.insert(mymOptions,{code=item.code,label=item.label})
    end
    fun:Dropdown({Text="Escolha a musica",Options=mymOptions,Default=mymSelected,NoSave=true,
        Callback=function(code) mymSelected=code end})
    -- Usa somente arquivos locais: nao tenta tocar audios aleatorios do catalogo Roblox.
    -- MYTHIC MUSIC v7: cache local e download automatico de fontes autorizadas.
    -- MP3s nao estao publicados: o dono precisa ter direito de distribuicao.
    local mymRemoteBase="https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/approved-audio/"
    local function mymValidMP3(data)
        if type(data)~="string" or #data<128 or #data>10485760 then return false end
        if data:sub(1,3)=="ID3" then
            local ver=data:byte(4)
            return ver~=nil and ver>=2 and ver<=4
        end
        local a,b=data:byte(1,2)
        return a==255 and b~=nil and math.floor(b/32)==7
            and math.floor(b/8)%4~=1 and math.floor(b/2)%4~=0
    end
    local function mymRequestAudio(url)
        local req=mymCraudeteAPI("request") or mymCraudeteAPI("http_request")
        if not req then
            local e=getfenv()
            if type(e.syn)=="table" then req=e.syn.request end
            if not req and type(e.http)=="table" then req=e.http.request end
        end
        if req then
            local ok,res=pcall(req,{Url=url,Method="GET",Timeout=20})
            if not ok or type(res)~="table" then
                return nil,"Falha de conexao ao baixar o MP3."
            end
            local status=tonumber(res.StatusCode or res.Status or 0)
            if status==404 then return nil,"MP3 indisponivel na fonte." end
            if status<200 or status>=300 then
                return nil,"Servidor de audio respondeu HTTP "..tostring(status)
            end
            return res.Body or res.body
        end
        local ok,body=pcall(function() return game:HttpGet(url) end)
        if ok and type(body)=="string" then return body end
        return nil,"O executor nao permite baixar o audio automaticamente."
    end
    fun:Button({Text="Tocar selecionada",Callback=function()
        local song
        for _,item in ipairs(mymTrending) do
            if item.code==mymSelected then song=item break end
        end
        if not song then return end
        mymCraudeteStop()
        local generation=mymCraudeteGeneration
        task.spawn(function()
            local check=mymCraudeteAPI("isfile")
            local read=mymCraudeteAPI("readfile")
            local write=mymCraudeteAPI("writefile")
            local mkdir=mymCraudeteAPI("makefolder")
            local asset=mymCraudeteAPI("getcustomasset") or mymCraudeteAPI("getsynasset")
            if not check or not asset then
                mymCraudeteInfo("Seu executor precisa de isfile e getcustomasset para musica local.", "warning")
                return
            end
            local relative="MYTHIC-HUB/audio/"..song.file
            local files={relative,"workspace/"..relative}
            local sourcePath=nil
            for _,file in ipairs(files) do
                local ok,exists=pcall(check,file)
                if ok and exists then
                    local valid=true
                    if read then
                        local readOk,bytes=pcall(read,file)
                        valid=readOk and mymValidMP3(bytes)
                    end
                    if valid then sourcePath=file break end
                end
            end
            if not sourcePath then
                if not write or not mkdir then
                    mymCraudeteInfo("Sem cache. Executor sem writefile/makefolder para baixar MP3 automaticamente.", "warning")
                    return
                end
                mymCraudeteInfo("Baixando automaticamente: "..song.label)
                local data,problem=mymRequestAudio(song.url or (mymRemoteBase..song.file))
                if generation~=mymCraudeteGeneration then return end
                if not data then
                    mymCraudeteInfo(song.label..": "..tostring(problem or "Download indisponivel"),"warning")
                    return
                end
                if not mymValidMP3(data) then
                    mymCraudeteInfo(song.label..": servidor nao forneceu um MP3 valido.","warning")
                    return
                end
                pcall(mkdir,"MYTHIC-HUB")
                pcall(mkdir,"MYTHIC-HUB/audio")
                local ok,err=pcall(write,relative,data)
                if not ok then
                    mymCraudeteInfo("Falha ao salvar audio no cache: "..tostring(err),"warning")
                    return
                end
                sourcePath=relative
            end
            if generation~=mymCraudeteGeneration then return end
            local loaded,soundId=pcall(asset,sourcePath)
            if not loaded or type(soundId)~="string" or soundId=="" then
                mymCraudeteInfo("O executor nao conseguiu abrir o MP3 salvo.","warning")
                return
            end
            local sound=Instance.new("Sound")
            sound.Name="MYTHIC_CRAUDETE_LOCAL"
            sound.Parent=mymCraudeteService
            mymCraudeteSound=sound
            local configured,reason=pcall(function()
                sound.SoundId=soundId
                sound.Volume=mymCraudeteMuted and 0 or mymCraudeteVolume
                sound.Looped=mymCraudeteLoop
            end)
            if not configured then
                mymCraudeteInfo("Erro ao preparar MP3: "..tostring(reason),"warning")
                mymCraudeteStop()
                return
            end
            local timeout=os.clock()+12
            while generation==mymCraudeteGeneration and sound.Parent and not sound.IsLoaded and os.clock()<timeout do
                task.wait(.1)
            end
            if generation~=mymCraudeteGeneration then return end
            if not sound.IsLoaded then
                mymCraudeteInfo(song.label..": MP3 salvo, mas nao carregou no Roblox.","warning")
                mymCraudeteStop()
                return
            end
            local played,problem=pcall(function()
                sound.TimePosition=0
                sound:Play()
            end)
            if played and sound.IsPlaying then
                mymCraudeteInfo(song.label..": tocando!","success")
            else
                mymCraudeteInfo(song.label..": falha ao reproduzir: "..tostring(problem or ""), "warning")
                mymCraudeteStop()
            end
        end)
    end})
    fun:Note({Text="6 musicas no menu. As 5 enviadas estao hospedadas no GitHub; Claudete usa uma fonte externa. Download automatico e cache dependem do suporte do executor."})

		local _, stopBoombox = Boombox.install(]====], "SoundCloud TikTok 2026: links oficiais sem ID Roblox")

mythicReplaceOnce([====[		pcall(stopBoombox)]====], [====[		pcall(stopBoombox)
		pcall(mymCraudeteStop)]====], "Music: liberar audio ao fechar")


-- MYTHIC FARM FIX: somente resetar depois de coleta confirmada e rodada valida.
mythicReplaceOnce([====[function FarmState.roundStart(state, now, coinsStarted)
	state.round, state.skipped = true, {}
	if not coinsStarted then state.collected = {} end
	table.clear(state.full)
	state.forcedFull, state.coinsStarted, state.knownRound = false, coinsStarted and now or 0, true
	if not coinsStarted then state.active = false end
end

]====], [====[function FarmState.roundStart(state, now, coinsStarted)
	state.round, state.skipped = true, {}
	-- O servidor pode manter contadores/GUI antigos entre RoundStart e CoinsStarted.
	state.collected = {}
	table.clear(state.full)
	state.roundStarted = now
	state.forcedFull, state.coinsStarted, state.knownRound = false, coinsStarted and now or 0, true
	state.respawnPending = false
	if not coinsStarted then state.active = false end
end

]====], "Reset FullBag: round start")
mythicReplaceOnce([====[function FarmState.roundEnd(state)
	state.round, state.active, state.collected, state.forcedFull, state.coinsStarted = false, false, {}, false, 0
end

]====], [====[function FarmState.roundEnd(state)
	state.round, state.active, state.collected, state.forcedFull, state.coinsStarted = false, false, {}, false, 0
	state.roundStarted = nil
	state.respawnPending = false
	table.clear(state.full)
end

]====], "Reset FullBag: round end")
mythicReplaceOnce([====[if type(kind) == "string" and type(count) == "number" and type(maximum) == "number" then state.full[kind] = count >= maximum end]====], [====[if type(kind) == "string" and type(count) == "number" and type(maximum) == "number" then
		-- Evita tratar valores 0/0 ou contadores minimos como bolsa de moedas cheia.
		state.full[kind] = maximum >= 10 and maximum <= 500 and count > 0
			and count >= maximum and count <= maximum
	end]====], "Reset FullBag: valid counter")
mythicReplaceOnce([====[function FarmState.isFull(context, state, now)
	if state.forcedFull then return true end
	if state.coinsStarted == 0 then return false end
	local any, all = false, true
	for _, full in state.full do any = true; if not full then all = false end end
	if any and all then return true end
	if now - state.coinsStarted < 2 then return false end
	if not state.bag or not state.bag.Parent or now - state.bagAt > 2 then
		state.bagAt = now
		FarmState.refreshBag(context, state)
	end
	if not state.bag or not state.bag.Visible then return false end
	for _, item in state.bagItems do if item.Parent and item.Visible then return true end end
	return false
end

]====], [====[function FarmState.isFull(context, state, now)
	if state.forcedFull then return true end
	if not state.round or state.coinsStarted == 0 then return false end
	if now - (state.roundStarted or state.coinsStarted) < 3 then return false end
	for _, full in state.full do
		if full == true then return true end
	end
	-- GuiObject "Full" pode ficar visivel antes da primeira coleta:
	-- somente contador de CoinCollected com maximo valido libera o reset.
	return false
end

]====], "Reset FullBag: verified fullness only")
mythicReplaceOnce([====[if not handled and state.respawnOnFull and not state.forcedFull and not state.respawnPending and tickTime - (state.lastRespawn or 0) > 3 then
			state.respawnPending = true
			environment.task.delay(0.4, function()
				state.respawnPending = false
				if not FarmState.isFull(context, state, environment.tick()) or state.forcedFull then return end
				local current = context.player.Character
				local currentHumanoid = current and current:FindFirstChildOfClass("Humanoid")
				if not currentHumanoid or currentHumanoid.Health <= 0 then return end
				state.active, currentHumanoid.Health, state.lastRespawn, state.forcedFull = false, 0, environment.tick(), true
				table.clear(state.full)
			end)
		end]====], [====[if not handled and state.respawnOnFull and not isMurderer
			and not state.forcedFull and not state.respawnPending
			and tickTime - (state.lastRespawn or 0) > 3 then
			local queuedCharacter = character
			local queuedRound = state.roundStarted or state.coinsStarted
			state.respawnPending = true
			environment.task.delay(0.4, function()
				state.respawnPending = false
				if not state.respawnOnFull or not state.enabled or not state.round
					or not state.active or state.forcedFull
					or (state.roundStarted or state.coinsStarted) ~= queuedRound then return end
				if context.player.Character ~= queuedCharacter then return end
				if not FarmState.isFull(context, state, environment.tick()) then return end
				local roleOk, latestRoles = pcall(context.roles)
				local latestRole = roleOk and type(latestRoles) == "table" and latestRoles[context.player.Name]
				if not latestRole or not latestRole.Role or
					tostring(latestRole.Role):lower():find("murder", 1, true) then return end
				local currentHumanoid = queuedCharacter and queuedCharacter:FindFirstChildOfClass("Humanoid")
				if not currentHumanoid or currentHumanoid.Health <= 0 then return end
				state.active, currentHumanoid.Health, state.lastRespawn, state.forcedFull = false, 0, environment.tick(), true
				table.clear(state.full)
			end)
		end]====], "Reset FullBag: queued respawn recheck")

-- MYTHIC MOBILE STUTTER FIX: reduzir picos sincronizados sem diminuir atualizacao de movimento.
mythicReplaceOnce(
    [====[function FarmMotion.parts(character)
	local parts = {}
	if not character then return parts end
	local head = character:FindFirstChild("Head")
	if head then table.insert(parts, head) end
	for _, child in character:GetChildren() do
		if not child:IsA("Accessory") then continue end
		local handle = child:FindFirstChild("Handle")
		if handle then table.insert(parts, handle) end
	end
	for _, name in {"UpperTorso", "Torso", "HumanoidRootPart", "LowerTorso"} do
		local part = character:FindFirstChild(name)
		if part then table.insert(parts, part) end
	end
	return parts
end]====],
    [====[function FarmMotion.parts(character)
	local parts = {}
	if not character then return parts end
	-- Limita firetouchinterest aos membros principais: acessorios custam dezenas de chamadas.
	for _, name in {"HumanoidRootPart", "UpperTorso", "Torso", "LowerTorso", "Head"} do
		local part = character:FindFirstChild(name)
		if part and part:IsA("BasePart") then table.insert(parts, part) end
	end
	return parts
end]====],
    "Farm: reduzir custo dos toques ao ignorar acessórios do avatar")

mythicReplaceOnce(
    [====[function FarmState.containers(context, state, now)
	if now - state.containersAt < 0.5 then return state.containers end]====],
    [====[function FarmState.containers(context, state, now)
	-- Inventario de contêineres do mapa muda raramente; evite GetTagged e Workspace:GetChildren a cada 0.5s.
	local hasLive = false
	for _, container in state.containers do
		if container.Parent and container:IsDescendantOf(context.workspace) then hasLive = true; break end
	end
	if now - state.containersAt < (hasLive and 1.5 or 0.45) then return state.containers end]====],
    "Farm: reduzir varreduras globais de contêineres")

mythicReplaceOnce(
    [====[function FarmRuntime.MapFarm.sample(farm)
	local map = farm.map()
	local container = map and map:FindFirstChild("CoinContainer")
	if not container then return end
	local positions = {}
	for _, coin in container:GetChildren() do
		if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") and not coin:GetAttribute("Collected") then
			table.insert(positions, coin.Position)
		end
	end
	if #positions < 8 then return end]====],
    [====[function FarmRuntime.MapFarm.sample(farm)
	local map = farm.map()
	local container = map and map:FindFirstChild("CoinContainer")
	if not container then return end
	local positions, children = {}, container:GetChildren()
	-- Amostra distribuída: no máximo 32 moedas => no máximo 992 distâncias analisadas.
	local stride = math.max(1, math.ceil(#children / 32))
	for index = 1, #children, stride do
		local coin = children[index]
		if coin:IsA("BasePart") and coin:FindFirstChild("TouchInterest") and not coin:GetAttribute("Collected") then
			table.insert(positions, coin.Position)
		end
	end
	if #positions < 8 then return end]====],
    "Farm: limitar análise quadrática de distâncias a 32 moedas")

mythicReplaceOnce(
    [====[while active() do
			environment.task.wait(3)
			pcall(FarmRuntime.MapFarm.sample, farm)
			if environment.os.clock() - saved > 20 then]====],
    [====[while active() do
			environment.task.wait(5)
			local api = rawget(environment.getgenv(), "__pulseFarmAPI")
			if api and type(api.getEnabled) == "function" and api.getEnabled() then
				pcall(FarmRuntime.MapFarm.sample, farm)
			end
			if environment.os.clock() - saved > 40 then]====],
    "Farm: amostrar mapa a cada 5s apenas quando farm ativo")

mythicReplaceOnce(
    [====[local now, tickTime = environment.os.clock(), environment.tick()
	local character = context.player.Character]====],
    [====[local now, tickTime = environment.os.clock(), environment.tick()
	-- Context.roles pode consultar o estado da partida; evita repetir a mesma consulta por quadro.
	if now - (runtime.rolesAt or -1e9) >= 0.18 then
		runtime.rolesAt = now
		runtime.rolesOk, runtime.roles = pcall(context.roles)
	end
	local character = context.player.Character]====],
    "Farm: memoizar consulta de cargos por 0.18s")

mythicReplaceOnce(
    [====[local ok, roles = pcall(context.roles)
		state.active = state.enabled and alive and ok and FarmState.canFarm(context, state, roles) or false]====],
    [====[local ok, roles = runtime.rolesOk, runtime.roles
		state.active = state.enabled and alive and ok and FarmState.canFarm(context, state, roles) or false]====],
    "Farm: usar cargos em cache para ativação da rodada")

mythicReplaceOnce(
    [====[FarmMotion.updatePending(context, state, motion, now)
	local ok, roles = pcall(context.roles)
	local murderer]====],
    [====[if now - (motion.pendingCheckAt or 0) >= 0.10 then
		motion.pendingCheckAt = now
		FarmMotion.updatePending(context, state, motion, now)
	end
	local ok, roles = runtime.rolesOk, runtime.roles
	local murderer]====],
    "Farm: reduzir trabalho repetido de pendências e consulta de cargos")

mythicReplaceOnce(
    [====[if isMurderer and state.killAura then
			pcall(FarmRuntime.killAll, context)
			handled = true]====],
    [====[if isMurderer and state.killAura then
			-- A primeira execução é imediata; evita varredura de todos os jogadores a cada Heartbeat.
			if now - (motion.killAllAt or -1e9) >= 0.4 then
				motion.killAllAt = now
				pcall(FarmRuntime.killAll, context)
			end
			handled = true]====],
    "Farm: impedir varredura de Kill All em todo quadro")

-- MYTHIC FAST CONTACT FIX: liberar moedas nao confirmadas sem perder prioridade proxima.
mythicReplaceOnce(
    [====[if now > entry.t then
				motion.pending[coin] = nil
				motion.gapT, motion.miss = math.max(1, motion.gapT - 0.25), (motion.miss or 0) + 1
			end
			continue
		end
		motion.pending[coin] = nil
		motion.gapT, motion.ok = math.min(6, motion.gapT + 0.08), (motion.ok or 0) + 1]====],
    [====[if now >= entry.t then
				motion.pending[coin] = nil
				if entry.fast then
					motion.fastMisses = motion.fastMisses or {}
					local failed = (motion.fastMisses[coin] or 0) + 1
					if failed >= 4 then
						-- Evitar ciclo infinito com uma moeda fora de alcance; retorno curto.
						motion.skip[coin], motion.fastMisses[coin] = now + 1.25, nil
					else
						motion.fastMisses[coin] = failed
					end
				end
				motion.gapT, motion.miss = math.max(1, motion.gapT - 0.25), (motion.miss or 0) + 1
			end
			continue
		end
		motion.pending[coin] = nil
		if motion.fastMisses then motion.fastMisses[coin] = nil end
		motion.gapT, motion.ok = math.min(6, motion.gapT + 0.08), (motion.ok or 0) + 1]====],
    "Fast: retentativa real em 0.22s com limite de falhas")

-- MYTHIC FAST SAFE25 v4n: rota estavel e velocidade comandada visivel no painel.
-- Sem boost 26/27: o servidor pode expulsar mesmo com o controle de velocidade.
mythicReplaceOnce(
    [====[FarmMotion.jump(context, motion, root, target.Position, force, now)
	local distance = FarmMotion.move(context, root, velocity, gyro, target.Position, options.delta, speed)]====],
    [====[-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Observa mudanca de posicao contra o trajeto: sinal de puxao/correcao.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 0.5 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5 and
			displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			motion.fastRollbackUntil = now + 1.25
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Mantem a velocidade programada dentro do limite de 25 para reduzir correcoes do servidor.
	local actualSpeed = math.min(speed, 25)
	-- Indica velocidade solicitada, nao velocidade efetivamente validada pelo servidor.
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Suaviza mudancas de direcao evitando arrancadas bruscas.
	if distance > 3 then
		local desired = velocity.Velocity
		local factor = math.clamp((tonumber(options.delta) or 1 / 30) * 13, 0.28, 1)
		if motion.fastLastVelocity then velocity.Velocity = motion.fastLastVelocity:Lerp(desired, factor) end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end]====],
    "Fast: velocidade maxima 25 com rota estavel e comando visivel")

-- FAST HUD: mostra velocidade comandada no grid de estatisticas (atualiza no loop existente).
mythicReplaceOnce(
    [====[for _, options in {{"Session", "Accent", "timer"}, {"Coins / day", "Warning", "coins"},
		{"Total", "Info", "wallet"}, {"Status", "Success", "activity"}} do]====],
    [====[for _, options in {{"Session", "Accent", "timer"}, {"Coins / day", "Warning", "coins"},
		{"Total", "Info", "wallet"}, {"Status", "Success", "activity"},
		{"Fast comando", "Info", "gauge"}} do]====],
    "Fast: indicador no painel de estatisticas")
mythicReplaceOnce(
    [====[local values = {Session = format(api.getSession()), ["Coins / day"] = format(api.getRate() * 1440),
					Total = format(api.getTotal()), Status = context.translation.tr(labels[api.getStatus()] or api.getStatus())}]====],
    [====[local motion = rawget(environment.getgenv(), "__pulseFarmUF")
				local command = api.getEnabled() and settings.method == "Fast"
					and motion and motion.fastSpeedApplied or nil
				local values = {Session = format(api.getSession()), ["Coins / day"] = format(api.getRate() * 1440),
					Total = format(api.getTotal()), Status = context.translation.tr(labels[api.getStatus()] or api.getStatus()),
					["Fast comando"] = command and tostring(command) or "-"}]====],
    "Fast: leitura da velocidade comandada no painel")

-- MYTHIC SERVER MAP CONTROLS v4m: controles claros + auto vote unico.
mythicReplaceOnce(
    [====[function ServerIdentity.MapVote.priorityRow(state, parent, map)
	local context, environment = state.context, state.context.environment
	local create, enum = context.create, environment.Enum
	local row = create("Frame", {Name = "Map_" .. map.key, Size = environment.UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = environment.Color3.fromRGB(34, 37, 45), BorderSizePixel = 0, ZIndex = 3}, parent)
	context.corner(row, 8)
	local rank = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(4, 0),
		Size = environment.UDim2.fromOffset(20, 32), Text = "", Font = enum.Font.GothamBold, TextSize = 12,
		TextColor3 = environment.Color3.fromRGB(214, 68, 88), ZIndex = 4}, row)
	local image = create("ImageLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(28, 4),
		Size = environment.UDim2.fromOffset(44, 24), Image = "", ScaleType = enum.ScaleType.Crop, ZIndex = 4}, row)
	context.corner(image, 6)
	local label = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(80, 0),
		Size = environment.UDim2.new(1, -168, 1, 0), Text = map.name, Font = enum.Font.GothamSemibold, TextSize = 12,
		TextXAlignment = enum.TextXAlignment.Left, TextTruncate = enum.TextTruncate.AtEnd,
		TextColor3 = environment.Color3.new(1, 1, 1), ZIndex = 4}, row)
	local function button(text, offset, callback)
		local object = create("TextButton", {AnchorPoint = environment.Vector2.new(1, 0.5),
			Position = environment.UDim2.new(1, offset, 0.5, 0), Size = environment.UDim2.fromOffset(20, 24),
			Text = text, Font = enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1,
			TextColor3 = environment.Color3.fromRGB(170, 175, 188), ZIndex = 5}, row)
		context.connect(object.MouseButton1Click, callback)
		return object
	end
	local function move(delta)
		local order = state.cfg.order
		local index = table.find(order, map.key)
		local target = index and index + delta
		if not target or target < 1 or target > #order then return end
		order[index], order[target] = order[target], order[index]
		ServerIdentity.MapVote.renderPriority(state)
	end
	local up = button("в†‘", -64, function() move(-1) end)
	local down = button("в†“", -42, function() move(1) end)
	local toggle = button("", -8, function()
		state.cfg.off[map.key] = state.cfg.off[map.key] ~= true and true or nil
		ServerIdentity.MapVote.renderPriority(state)
	end)
	return {frame = row, rank = rank, image = image, label = label, up = up, down = down, toggle = toggle}
end
]====],
    [====[function ServerIdentity.MapVote.priorityRow(state, parent, map)
	local context, environment = state.context, state.context.environment
	local create, enum = context.create, environment.Enum
	local row = create("Frame", {Name = "Map_" .. map.key, Size = environment.UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = environment.Color3.fromRGB(34, 37, 45), BorderSizePixel = 0, ZIndex = 3}, parent)
	context.corner(row, 8)
	local rank = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(4, 0),
		Size = environment.UDim2.fromOffset(20, 44), Text = "", Font = enum.Font.GothamBold, TextSize = 12,
		TextColor3 = environment.Color3.fromRGB(214, 68, 88), ZIndex = 4}, row)
	local image = create("ImageLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(24, 6),
		Size = environment.UDim2.fromOffset(32, 32), Image = "", ScaleType = enum.ScaleType.Crop, ZIndex = 4}, row)
	context.corner(image, 6)
	local label = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(63, 0),
		Size = environment.UDim2.new(1, -185, 1, 0), Text = map.name, Font = enum.Font.GothamSemibold, TextSize = 12,
		TextXAlignment = enum.TextXAlignment.Left, TextTruncate = enum.TextTruncate.AtEnd,
		TextColor3 = environment.Color3.new(1, 1, 1), ZIndex = 4}, row)
	local function button(text, offset, width, callback)
		local object = create("TextButton", {AnchorPoint = environment.Vector2.new(1, 0.5),
			Position = environment.UDim2.new(1, offset, 0.5, 0), Size = environment.UDim2.fromOffset(width, 32),
			Text = text, Font = enum.Font.GothamBold, TextSize = 12, BackgroundTransparency = 0,
			BackgroundColor3 = environment.Color3.fromRGB(54, 43, 75), BorderSizePixel = 0,
			TextColor3 = environment.Color3.fromRGB(170, 175, 188), ZIndex = 5}, row)
		context.corner(object, 7)
		context.connect(object.MouseButton1Click, callback)
		return object
	end
	local function move(delta)
		local order = state.cfg.order
		local index = table.find(order, map.key)
		local target = index and index + delta
		if not target or target < 1 or target > #order then return end
		order[index], order[target] = order[target], order[index]
		ServerIdentity.MapVote.renderPriority(state)
	end
	local up = button("▲", -94, 30, function() move(-1) end)
	local down = button("▼", -60, 30, function() move(1) end)
	local toggle = button("", -6, 48, function()
		state.cfg.off[map.key] = state.cfg.off[map.key] ~= true and true or nil
		ServerIdentity.MapVote.renderPriority(state)
	end)
	return {frame = row, rank = rank, image = image, label = label, up = up, down = down, toggle = toggle}
end
]====],
    "Server: botoes mobile para subir, descer e ativar mapas")

mythicReplaceOnce(
    [====[		row.up.TextTransparency = index == 1 and 0.7 or 0
		row.down.TextTransparency = index == #state.cfg.order and 0.7 or 0
		row.toggle.Text = off and "в—‹" or "в—Џ"]====],
    [====[		row.up.TextTransparency = index == 1 and 0.7 or 0
		row.down.TextTransparency = index == #state.cfg.order and 0.7 or 0
		row.toggle.Text = off and "NAO" or "SIM"
		row.toggle.BackgroundColor3 = off and environment.Color3.fromRGB(77, 41, 49)
			or environment.Color3.fromRGB(83, 47, 145)
		row.toggle.TextColor3 = environment.Color3.new(1, 1, 1)]====],
    "Server: indicadores SIM ou NAO na prioridade")

mythicReplaceOnce(
    [====[	section:Button({Text = "Reset Priority", Callback = function() vote.resetPriority(state) end})]====],
    [====[	section:Note({Text = "▲ Subir | ▼ Descer | SIM Selecionado | NAO Desmarcado."})
	section:Button({Text = "Selecionar todos", Callback = function()
		state.cfg.off = {}
		vote.renderPriority(state)
	end})
	section:Button({Text = "Desmarcar todos", Callback = function()
		for _, key in state.cfg.order do state.cfg.off[key] = true end
		vote.renderPriority(state)
	end})
	section:Button({Text = "Reset Priority", Callback = function() vote.resetPriority(state) end})]====],
    "Server: selecionar e desmarcar todos os mapas")

mythicReplaceOnce(
    [====[if selected then state.sel = selected; vote.start(state, selected) end]====],
    [====[if selected then
		state.sel = selected
		-- Auto Vote usa somente um voto; nao executa multiplos respawns automaticamente.
		context.environment.task.spawn(vote.run, state, selected, 1)
	end]====],
    "Server: voto automatico unico sem respawns repetidos")

-- Sem botao de boost: o modo Fast utiliza o limite estavel de 25.

-- MYTHIC FAST EFFICIENCY v4o: economia de busca, recuperacao curta de moedas e limpeza por rodada.
mythicReplaceOnce(
    [====[if now - (motion.goT or now) > distance / speed + 4 then
		FarmMotion.skip(context, state, target)
		if target == gun then motion.gunTarget = nil end
		motion.coin, motion.fails = nil, motion.fails + 1
	end]====],
    [====[-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.5 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end]====],
    "Fast: retry de moeda travada apos 5s em vez de 30s")

mythicReplaceOnce(
    [====[function FarmRuntime.resetMotion(motion)
	FarmMotion.restoreTouch(motion)
	motion.coin, motion.hold, motion.gunTarget = nil, nil, nil
	motion.info, motion.skip, motion.pending, motion.att, motion.tp = {}, {}, {}, {}, {}
	if motion.phase ~= "idle" then motion.phase = "go" end
end]====],
    [====[function FarmRuntime.resetMotion(motion)
	FarmMotion.restoreTouch(motion)
	motion.coin, motion.hold, motion.gunTarget = nil, nil, nil
	motion.info, motion.skip, motion.pending, motion.att, motion.tp = {}, {}, {}, {}, {}
	-- Libera refs de moedas e dados de travessia da rodada anterior (importante em sessoes longas).
	motion.fastMisses = {}
	motion.fastTouchedCoin, motion.fastContactCoin, motion.fastDwellTarget = nil, nil, nil
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = nil, nil, nil
	motion.fastSwitchedAt, motion.fastTouchAt, motion.fastRollbackUntil = nil, nil, nil
	motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt, motion.fastLastVelocity = nil, nil, nil, nil
	motion.dwellFrom, motion.pickT, motion.pendingCheckAt = nil, 0, 0
	motion.containers, motion.containerAt, motion.filterAt, motion.rayParams = {}, 0, 0, nil
	if motion.phase ~= "idle" then motion.phase = "go" end
end]====],
    "Fast: liberar referencias e contadores a cada rodada")

-- MYTHIC STARTUP RESTORE v4p: controles verdadeiros sao carregados antes de modulos secundarios.
mythicReplaceOnce(
    [====[	local farm = PulseTab.create(environment, hub, "Auto Farm", "shopping-cart", context)
	farm:Sub("Coin")
	local farmContext = {environment = environment, configuration = settings, section = farm, translation = translation,
		workspace = workspace, players = players, player = players.LocalPlayer, roles = roles, drops = gunDrops,
		collection = game:GetService("CollectionService"), storage = game:GetService("ReplicatedStorage"), http = http,
		guiService = game:GetService("GuiService"), coreGui = game:GetService("CoreGui"), teleport = game:GetService("TeleportService"),
		runService = runService, connect = connect, isAlive = function() return not window.Destroyed end}
	local _, _, farmApi, stopFarm = FarmRuntime.install(farmContext)
	FarmRuntime.controls(farmContext, farmApi)
	local roleFarm, stopRoleFarm = RoleFarm.install(farmContext)
	RoleFarm.controls(farmContext, roleFarm)
	local boxes, stopBoxes = BoxFarm.install(farmContext)
	BoxFarm.controls(farmContext, boxes)
	farmContext.window = window
	context.farmWebhook, context.stopFarmWebhook = FarmRuntime.Webhook.install(farmContext)
]====],
    [====[]====],
    "Farm: remover inicializacao tardia que ficava bloqueada por erro anterior")

mythicReplaceOnce(
    [====[local stopGunEsp, gunDrops = GunFeature.installEsp({environment = environment, configuration = settings, defaults = defaults,
		section = main, connect = connect, runService = runService, workspace = workspace, coreGui = game:GetService("CoreGui"),
		players = players, player = players.LocalPlayer})
	EspFeature.boxControls(esp)]====],
    [====[local stopGunEsp, gunDrops = GunFeature.installEsp({environment = environment, configuration = settings, defaults = defaults,
		section = main, connect = connect, runService = runService, workspace = workspace, coreGui = game:GetService("CoreGui"),
		players = players, player = players.LocalPlayer})
	local farm = PulseTab.create(environment, hub, "Auto Farm", "shopping-cart", context)
	farm:Sub("Coin")
	local farmContext = {environment = environment, configuration = settings, section = farm, translation = translation,
		workspace = workspace, players = players, player = players.LocalPlayer, roles = roles, drops = gunDrops,
		collection = game:GetService("CollectionService"), storage = game:GetService("ReplicatedStorage"), http = http,
		guiService = game:GetService("GuiService"), coreGui = game:GetService("CoreGui"), teleport = game:GetService("TeleportService"),
		runService = runService, connect = connect, isAlive = function() return not window.Destroyed end}
	-- Isola falhas de inicializacao para evitar abas vazias depois do Farm.
	local okFarm, farmState, farmMotion, farmApi, stopFarm = pcall(FarmRuntime.install, farmContext)
	if okFarm and type(farmApi) == "table" then
		local okControls, errControls = pcall(FarmRuntime.controls, farmContext, farmApi)
		if not okControls then
			environment.warn("MYTHIC-HUB Farm.controls: " .. tostring(errControls))
			pcall(function()
				farm:Header("Farm")
				farm:Note({Text = "Erro nos controles do Farm. Verifique o console."})
			end)
		end
	else
		environment.warn("MYTHIC-HUB Farm.install: " .. tostring(farmState))
		pcall(function()
			farm:Header("Farm")
			farm:Note({Text = "Falha ao iniciar o Farm. Verifique o console."})
		end)
	end
	local okRole, roleFarm, stopRoleFarm = pcall(RoleFarm.install, farmContext)
	if okRole then
		local okControls, errControls = pcall(RoleFarm.controls, farmContext, roleFarm)
		if not okControls then environment.warn("MYTHIC-HUB RoleFarm.controls: " .. tostring(errControls)) end
	else
		environment.warn("MYTHIC-HUB RoleFarm.install: " .. tostring(roleFarm))
	end
	local okBoxes, boxes, stopBoxes = pcall(BoxFarm.install, farmContext)
	if okBoxes then
		local okControls, errControls = pcall(BoxFarm.controls, farmContext, boxes)
		if not okControls then environment.warn("MYTHIC-HUB BoxFarm.controls: " .. tostring(errControls)) end
	else
		environment.warn("MYTHIC-HUB BoxFarm.install: " .. tostring(boxes))
	end
	farmContext.window = window
	local okWebhook, webhook, stopWebhook = pcall(FarmRuntime.Webhook.install, farmContext)
	if okWebhook then
		context.farmWebhook, context.stopFarmWebhook = webhook, stopWebhook
	else
		environment.warn("MYTHIC-HUB FarmWebhook.install: " .. tostring(webhook))
	end
	EspFeature.boxControls(esp)]====],
    "Farm: inicializar controles antes de efeitos e Server")

mythicReplaceOnce(
    [====[	FarmRuntime.installRejoin(context, api)]====],
    [====[	local rejoinOk, rejoinErr = pcall(FarmRuntime.installRejoin, context, api)
	if not rejoinOk then environment.warn("MYTHIC-HUB Rejoin: " .. tostring(rejoinErr)) end]====],
    "Farm: Rejoin opcional nao bloqueia interface")

mythicReplaceOnce(
    [====[	local mapFarm = FarmRuntime.MapFarm.install(context, active)]====],
    [====[	local okMapFarm, mapFarm = pcall(FarmRuntime.MapFarm.install, context, active)
	if not okMapFarm then
		environment.warn("MYTHIC-HUB MapFarm: " .. tostring(mapFarm))
		mapFarm = {hop = function() end}
	end]====],
    "Farm: estatisticas de mapa nao bloqueiam interface")

mythicReplaceOnce(
    [====[	ServerIdentity.install({environment = environment, translation = translation, section = server, connect = connect,
		create = create, round = nova.U.corner, nova = nova,
		players = players, player = players.LocalPlayer, isAlive = function() return not window.Destroyed end})
	local _, stopMapVote = ServerIdentity.MapVote.install({environment = environment, configuration = settings, section = server,
		translation = translation, workspace = workspace, player = players.LocalPlayer, runService = runService,
		window = window, inputService = inputService, tweenService = game:GetService("TweenService"),
		create = create, corner = nova.U.corner, nova = nova, connect = connect,
		applyHooks = context.applyHooks, isAlive = function() return not window.Destroyed end})]====],
    [====[	local okServer, errServer = pcall(ServerIdentity.install, {environment = environment, translation = translation, section = server, connect = connect,
		create = create, round = nova.U.corner, nova = nova,
		players = players, player = players.LocalPlayer, isAlive = function() return not window.Destroyed end})
	if not okServer then environment.warn("MYTHIC-HUB Server.install: " .. tostring(errServer)) end
	local okVote, voteState, stopMapVote = pcall(ServerIdentity.MapVote.install, {environment = environment, configuration = settings, section = server,
		translation = translation, workspace = workspace, player = players.LocalPlayer, runService = runService,
		window = window, inputService = inputService, tweenService = game:GetService("TweenService"),
		create = create, corner = nova.U.corner, nova = nova, connect = connect,
		applyHooks = context.applyHooks, isAlive = function() return not window.Destroyed end})
	if not okVote then environment.warn("MYTHIC-HUB MapVote.install: " .. tostring(voteState)) end]====],
    "Server: falha de modulo isolada, nao esvazia abas seguintes")

mythicFlushPatches()

-- MYTHIC SERVER v4q: corrigir lista de prioridades, com 18 mapas incluindo Halloween.
mythicReplaceOnce(
    [====[	{key = "workplace", name = "Workplace", icon = "rbxassetid://3214479481"},
}]====],
    [====[	{key = "workplace", name = "Workplace", icon = "rbxassetid://3214479481"},
	-- Mapas do Halloween, incluidos mesmo antes de serem detectados em uma votacao.
	{key = "manor", name = "Manor"},
	{key = "hauntedhouse2", name = "Haunted House 2"},
	{key = "farmhouse", name = "Farmhouse"},
	{key = "vampirescastle", name = "Vampire's Castle"},
	{key = "spaceship", name = "Spaceship"},
	{key = "barn", name = "Barn"},
}]====],
    "Server: adicionar seis mapas Halloween aos doze ja existentes")

mythicReplaceOnce(
    [====[function ServerIdentity.MapVote.keyForIcon(state, icon, except)
	for _, map in state.mapList do]====],
    [====[function ServerIdentity.MapVote.keyForIcon(state, icon, except)
	-- Evita que um icone vazio identifique incorretamente mapas sazonais.
	if type(icon) ~= "string" or icon == "" then return nil end
	for _, map in state.mapList do]====],
    "Server: ignorar icon vazio ao associar mapa")

mythicReplaceOnce(
    [====[	section:Header("Map Priority", "Right")
	local container = section:Container()
	if container then
		local environment = context.environment
		state.priorityList = context.create("Frame", {Name = "PrioList", BackgroundTransparency = 1,
			Size = environment.UDim2.new(1, 0, 0, 0), AutomaticSize = environment.Enum.AutomaticSize.Y}, container)
		context.create("UIListLayout", {Padding = environment.UDim.new(0, 3), SortOrder = environment.Enum.SortOrder.LayoutOrder}, state.priorityList)
		vote.renderPriority(state)
	end]====],
    [====[	section:Header("Map Priority", "Right")
	local container = section:Container()
	if container then
		local environment = context.environment
		-- 280 pixels visiveis com scroll vertical independente para todos os mapas.
		local list = context.create("ScrollingFrame", {
			Name = "PrioList", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = environment.UDim2.new(1, 0, 0, 280),
			CanvasSize = environment.UDim2.fromOffset(0, math.max(1, #state.cfg.order * 47 + 8)),
			ScrollBarThickness = 5, ScrollingDirection = environment.Enum.ScrollingDirection.Y,
			ScrollingEnabled = true, Active = true, ClipsDescendants = true,
			ScrollBarImageColor3 = environment.Color3.fromRGB(156, 91, 225),
		}, container)
		state.priorityList = list
		local layout = context.create("UIListLayout", {
			Padding = environment.UDim.new(0, 3), SortOrder = environment.Enum.SortOrder.LayoutOrder,
		}, list)
		local function updateCanvas()
			if list.Parent then
				list.CanvasSize = environment.UDim2.fromOffset(0, math.max(1, layout.AbsoluteContentSize.Y + 8))
			end
		end
		context.connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), updateCanvas)
		vote.renderPriority(state)
		environment.task.defer(updateCanvas)
	end]====],
    "Server: exibir mapas com scrolling no celular")

mythicReplaceOnce(
    [====[	signature = table.concat(signature, "|")
	if signature == state.prioritySignature then return end
	state.prioritySignature = signature
	state.priorityRows = state.priorityRows or {}]====],
    [====[	signature = table.concat(signature, "|")
	if signature == state.prioritySignature then return end
	-- Nunca marcar uma lista parcial como concluida.
	state.priorityRows = state.priorityRows or {}]====],
    "Server: permitir recuperar render parcial de mapas")

mythicReplaceOnce(
    [====[		row.toggle.TextColor3 = environment.Color3.new(1, 1, 1)
	end
end

function ServerIdentity.MapVote.resetPriority(state)]====],
    [====[		row.toggle.TextColor3 = environment.Color3.new(1, 1, 1)
	end
	state.prioritySignature = signature
end

function ServerIdentity.MapVote.resetPriority(state)]====],
    "Server: finalizar assinatura depois de renderizar todas as linhas")

-- MYTHIC V4R: restaurar Server antes de carregar funcoes secundarias.
mythicFlushPatches()
mythicReplaceOnce(
    [====[function ServerIdentity.MapVote.renderPriority(state)
	if not state.priorityList then return end
	local vote = ServerIdentity.MapVote
	local signature = {}
	for _, key in state.cfg.order do
		table.insert(signature, key .. ":" .. tostring(state.cfg.off[key] == true) .. ":" .. tostring(vote.icon(state, key)))
	end
	signature = table.concat(signature, "|")
	if signature == state.prioritySignature then return end
	-- Nunca marcar uma lista parcial como concluida.
	state.priorityRows = state.priorityRows or {}
	local rank = 0
	for index, key in state.cfg.order do
		local map = state.maps[key]
		if not map then continue end
		local row = state.priorityRows[key]
		if not row then
			row = vote.priorityRow(state, state.priorityList, map)
			state.priorityRows[key] = row
		end
		local off = state.cfg.off[key] == true
		if not off then rank += 1 end
		row.frame.LayoutOrder = index
		row.rank.Text = off and "В·" or tostring(rank)
		row.image.Image = vote.icon(state, key) or ""
		row.image.ImageTransparency = off and 0.6 or 0
		row.label.TextTransparency = off and 0.5 or 0
		row.up.TextTransparency = index == 1 and 0.7 or 0
		row.down.TextTransparency = index == #state.cfg.order and 0.7 or 0
		row.toggle.Text = off and "NAO" or "SIM"
		row.toggle.BackgroundColor3 = off and environment.Color3.fromRGB(77, 41, 49)
			or environment.Color3.fromRGB(83, 47, 145)
		row.toggle.TextColor3 = environment.Color3.new(1, 1, 1)
	end
	state.prioritySignature = signature
end
]====],
    [====[function ServerIdentity.MapVote.renderPriority(state)
	local labels = state.priorityNotes
	if not labels then return end
	local order, disabled = state.cfg.order, state.cfg.off
	local markers = {}
	for _, key in order do markers[#markers + 1] = key .. ":" .. tostring(disabled[key] == true) end
	local signature = table.concat(markers, "|")
	if signature == state.prioritySignature then return end
	for index, key in order do
		local label = labels[index]
		if not label and state.prioritySection then
			label = state.prioritySection:Note({Text = "Novo mapa"})
			labels[index] = label
		end
		if label then
			local map = state.maps[key]
			label.Text = string.format("%02d  [%s]  %s", index, disabled[key] == true and "NAO" or "SIM",
				map and map.name or tostring(key))
		end
	end
	for index = #order + 1, #labels do if labels[index] then labels[index].Text = "" end end
	state.prioritySignature = signature
end
]====],
    "Server v4r: lista nativa sempre renderizada")

mythicReplaceOnce(
    [====[function ServerIdentity.MapVote.controls(state)
	local context, vote = state.context, ServerIdentity.MapVote
	local section = context.section
	section:Group({Title = "Map Vote", Side = "Left"})
	state.rows = vote.rows(state, section:Container(), false)
	state.countSlider = section:Slider({Text = "Votes to add", Min = 1, Max = 100, Default = state.cfg.count, Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 10), 1, 100) end})
	section:Button({Text = "Dupe Votes", Callback = function() vote.start(state, state.sel or 1) end})
	section:Button({Text = "Stop", Callback = function() state.stop = true end})
	state.statusLabel = section:Note({Text = "Waiting for vote"})
	section:Toggle({Text = "Vote Panel", Default = state.cfg.panel ~= false, Callback = function(value) state.cfg.panel = not not value end})
	section:Toggle({Text = "Silent Respawn", Default = state.cfg.silent ~= false, Callback = function(value) state.cfg.silent = not not value end})
	section:Group({Title = "Auto Dupe", Side = "Right"})
	section:Toggle({Text = "Auto Dupe", Default = state.cfg.auto == true, Callback = function(value)
		state.cfg.auto = not not value
		if value then context.environment.task.defer(vote.autoStart, state) end
	end})
	section:Toggle({Text = "Farm Priority", Default = state.cfg.farmSort == true, Callback = function(value)
		state.cfg.farmSort = not not value
		if value then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Toggle({Text = "Explore Maps", Default = state.cfg.explore == true, Callback = function(value)
		state.cfg.explore = not not value
		if state.cfg.farmSort then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Dropdown({Text = "Other maps", Default = state.cfg.fallback, Options = {
		{code = "skip", label = "Don't dupe"}, {code = "leading", label = "Dupe most voted"}, {code = "first", label = "Dupe first map"}},
		Callback = function(value) state.cfg.fallback = value end})
	section:Header("Map Priority", "Right")
	local container = section:Container()
	if container then
		local environment = context.environment
		-- 280 pixels visiveis com scroll vertical independente para todos os mapas.
		local list = context.create("ScrollingFrame", {
			Name = "PrioList", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = environment.UDim2.new(1, 0, 0, 280),
			CanvasSize = environment.UDim2.fromOffset(0, math.max(1, #state.cfg.order * 47 + 8)),
			ScrollBarThickness = 5, ScrollingDirection = environment.Enum.ScrollingDirection.Y,
			ScrollingEnabled = true, Active = true, ClipsDescendants = true,
			ScrollBarImageColor3 = environment.Color3.fromRGB(156, 91, 225),
		}, container)
		state.priorityList = list
		local layout = context.create("UIListLayout", {
			Padding = environment.UDim.new(0, 3), SortOrder = environment.Enum.SortOrder.LayoutOrder,
		}, list)
		local function updateCanvas()
			if list.Parent then
				list.CanvasSize = environment.UDim2.fromOffset(0, math.max(1, layout.AbsoluteContentSize.Y + 8))
			end
		end
		context.connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), updateCanvas)
		vote.renderPriority(state)
		environment.task.defer(updateCanvas)
	end
	section:Note({Text = "▲ Subir | ▼ Descer | SIM Selecionado | NAO Desmarcado."})
	section:Button({Text = "Selecionar todos", Callback = function()
		state.cfg.off = {}
		vote.renderPriority(state)
	end})
	section:Button({Text = "Desmarcar todos", Callback = function()
		for _, key in state.cfg.order do state.cfg.off[key] = true end
		vote.renderPriority(state)
	end})
	section:Button({Text = "Reset Priority", Callback = function() vote.resetPriority(state) end})
end
]====],
    [====[function ServerIdentity.MapVote.controls(state)
	local context, vote = state.context, ServerIdentity.MapVote
	local section = context.section
	section:Group({Title = "Map Vote", Side = "Left"})
	state.rows = vote.rows(state, section:Container(), false)
	state.countSlider = section:Slider({Text = "Votes to add", Min = 1, Max = 100, Default = state.cfg.count, Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 10), 1, 100) end})
	section:Button({Text = "Dupe Votes", Callback = function() vote.start(state, state.sel or 1) end})
	section:Button({Text = "Stop", Callback = function() state.stop = true end})
	state.statusLabel = section:Note({Text = "Waiting for vote"})
	section:Toggle({Text = "Vote Panel", Default = state.cfg.panel ~= false, Callback = function(value) state.cfg.panel = not not value end})
	section:Toggle({Text = "Silent Respawn", Default = state.cfg.silent ~= false, Callback = function(value) state.cfg.silent = not not value end})
	section:Group({Title = "Auto Dupe", Side = "Right"})
	section:Toggle({Text = "Auto Dupe", Default = state.cfg.auto == true, Callback = function(value)
		state.cfg.auto = not not value
		if value then context.environment.task.defer(vote.autoStart, state) end
	end})
	section:Toggle({Text = "Farm Priority", Default = state.cfg.farmSort == true, Callback = function(value)
		state.cfg.farmSort = not not value
		if value then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Toggle({Text = "Explore Maps", Default = state.cfg.explore == true, Callback = function(value)
		state.cfg.explore = not not value
		if state.cfg.farmSort then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Dropdown({Text = "Other maps", Default = state.cfg.fallback, Options = {
		{code = "skip", label = "Don't dupe"}, {code = "leading", label = "Dupe most voted"}, {code = "first", label = "Dupe first map"}},
		Callback = function(value) state.cfg.fallback = value end})
	-- UI nativa: evita linhas ocultas e incompatibilidade do painel customizado.
	section:Header("Map Priority", "Right")
	local available = {}
	for _, map in state.mapList do table.insert(available, {code = map.key, label = map.name}) end
	state.prioritySelected = state.cfg.order[1]
	section:Dropdown({Text = "Mapa selecionado", Default = state.prioritySelected, Options = available,
		Callback = function(key) state.prioritySelected = key end})
	local function move(direction)
		local order = state.cfg.order
		local from = table.find(order, state.prioritySelected)
		local to = from and from + direction
		if not to or to < 1 or to > #order then return end
		order[from], order[to] = order[to], order[from]
		vote.renderPriority(state)
	end
	section:Button({Text = "Subir mapa selecionado", Callback = function() move(-1) end})
	section:Button({Text = "Descer mapa selecionado", Callback = function() move(1) end})
	section:Button({Text = "Selecionar / desmarcar mapa", Callback = function()
		local key = state.prioritySelected
		if not key or not state.maps[key] then return end
		state.cfg.off[key] = state.cfg.off[key] ~= true and true or nil
		vote.renderPriority(state)
	end})
	section:Button({Text = "Selecionar todos", Callback = function()
		state.cfg.off = {}
		vote.renderPriority(state)
	end})
	section:Button({Text = "Desmarcar todos", Callback = function()
		for _, key in state.cfg.order do state.cfg.off[key] = true end
		vote.renderPriority(state)
	end})
	section:Button({Text = "Reset Priority", Callback = function() vote.resetPriority(state) end})
	section:Header("Lista completa de mapas", "Right")
	state.priorityNotes, state.prioritySection = {}, section
	for index = 1, #state.cfg.order do
		state.priorityNotes[index] = section:Note({Text = "Mapa " .. tostring(index)})
	end
	vote.renderPriority(state)
end
]====],
    "Server v4r: controles antigos e 18 mapas visiveis")

mythicReplaceOnce(
    [====[	local server = PulseTab.create(environment, hub, "Server", "globe-simplified", context)
	server:Columns()
	server:Group({Title = "Server", Side = "Left"})
	local okServer, errServer = pcall(ServerIdentity.install, {environment = environment, translation = translation, section = server, connect = connect,
		create = create, round = nova.U.corner, nova = nova,
		players = players, player = players.LocalPlayer, isAlive = function() return not window.Destroyed end})
	if not okServer then environment.warn("MYTHIC-HUB Server.install: " .. tostring(errServer)) end
	local okVote, voteState, stopMapVote = pcall(ServerIdentity.MapVote.install, {environment = environment, configuration = settings, section = server,
		translation = translation, workspace = workspace, player = players.LocalPlayer, runService = runService,
		window = window, inputService = inputService, tweenService = game:GetService("TweenService"),
		create = create, corner = nova.U.corner, nova = nova, connect = connect,
		applyHooks = context.applyHooks, isAlive = function() return not window.Destroyed end})
	if not okVote then environment.warn("MYTHIC-HUB MapVote.install: " .. tostring(voteState)) end
]====],
    [====[]====],
    "Server v4r: impedir instalacao tardia")

mythicReplaceOnce(
    [====[	context.connect = connect

	local main = PulseTab.create(environment, hub, "Main", "home", context)]====],
    [====[	context.connect = connect

	-- Instala Server cedo: as outras funcoes nao devem bloquear a aba.
	local server = PulseTab.create(environment, hub, "Server", "globe-simplified", context)
	server:Columns()
	server:Group({Title = "Server", Side = "Left"})
	local okServer, errServer = pcall(ServerIdentity.install, {environment = environment, translation = translation, section = server, connect = connect,
		create = create, round = nova.U.corner, nova = nova,
		players = players, player = players.LocalPlayer, isAlive = function() return not window.Destroyed end})
	if not okServer then
		environment.warn("MYTHIC-HUB Server.install: " .. tostring(errServer))
		pcall(function() server:Header("Server"); server:Note({Text = "Erro ao carregar Server. Consulte o console."}) end)
	end
	local okVote, voteState, stopMapVote = pcall(ServerIdentity.MapVote.install, {environment = environment, configuration = settings, section = server,
		translation = translation, workspace = workspace, player = players.LocalPlayer, runService = runService,
		window = window, inputService = inputService, tweenService = game:GetService("TweenService"),
		create = create, corner = nova.U.corner, nova = nova, connect = connect,
		applyHooks = context.applyHooks, isAlive = function() return not window.Destroyed end})
	if not okVote then
		environment.warn("MYTHIC-HUB MapVote.install: " .. tostring(voteState))
		pcall(function() server:Header("Map Priority"); server:Note({Text = "Erro ao carregar mapas. Consulte o console."}) end)
	end

	local main = PulseTab.create(environment, hub, "Main", "home", context)]====],
    "Server v4r: carregar antes dos efeitos e farm")
mythicFlushPatches()

-- MYTHIC v21: Fast usa somente a velocidade configurada; ciclo automatico removido.
mythicFlushPatches()

-- MYTHIC v4w: corrigir regressao da v4v. Sem bloqueio prolongado em Speed 25.
mythicFlushPatches()
mythicReplaceOnce(
    [====[				-- Permite trocar por outra realmente mais proxima sem alternar a cada frame.
				local dangerous = state.avoidMurder and currentScore >= 1000000
				local canSwitch = not coin or dangerous or
					(now - (motion.fastSwitchedAt or 0) >= 0.12
					and lowest + math.max(1.5, currentDistance * 0.08) < currentScore)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
				end]====],
    [====[				-- Prioridade real das moedas perto sem ficar alternando de rumo.
				-- Finaliza contato quando esta muito perto da moeda atual.
				local dangerous = state.avoidMurder and currentScore >= 1000000
				local hysteresis = currentDistance < 2.5 and 1.8 or math.max(1.0, currentDistance * 0.07)
				local canSwitch = not coin or dangerous or
					(now - (motion.fastSwitchedAt or 0) >= 0.18 and lowest + hysteresis < currentScore)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Um novo alvo deve receber direcao imediata, sem impulso do anterior.
					motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
				end]====],
    "Fast v4w: rota para moedas proximas sem zigzag")

mythicReplaceOnce(
    [====[	-- Suaviza mudancas de direcao evitando arrancadas bruscas.
	if distance > 3 then
		local desired = velocity.Velocity
		local factor = math.clamp((tonumber(options.delta) or 1 / 30) * 13, 0.28, 1)
		if motion.fastLastVelocity then velocity.Velocity = motion.fastLastVelocity:Lerp(desired, factor) end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end]====],
    [====[	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			local factor = math.clamp((tonumber(options.delta) or 1 / 30) * 26, 0.78, 1)
			velocity.Velocity = previous:Lerp(desired, factor)
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end]====],
    "Fast v4w: recuperar direcao e velocidade na troca de alvo")

mythicReplaceOnce(
    [====[	-- Observa mudanca de posicao contra o trajeto: sinal de puxao/correcao.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 0.5 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5 and
			displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			motion.fastRollbackUntil = now + 1.25
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now]====],
    [====[	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, nunca bloqueia 26/27.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now]====],
    "Fast v4w: evitar puxoes longos causados por resposta antiga")

mythicReplaceOnce(
    [====[		while context.isAlive() do
			environment.task.wait(0.4)
			pcall(function()
				local motion = rawget(environment.getgenv(), "__pulseFarmUF")]====],
    [====[		while context.isAlive() do
			-- Atualiza 25/26/27 no painel mais rapido que o ciclo de velocidade.
			environment.task.wait(0.15)
			pcall(function()
				local motion = rawget(environment.getgenv(), "__pulseFarmUF")]====],
    "Fast v4w: mostrar imediatamente 25 26 27 no painel")
mythicFlushPatches()

-- MYTHIC v4x: sem retorno a moeda ja tocada ou confirmada.
mythicFlushPatches()
mythicReplaceOnce(
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 25, 8, 25)
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Sempre conferir as moedas proximas, mesmo perto de outro alvo.
		if now - (motion.pickT or 0) >=
			(coin and ((motion.adaptive and motion.adaptive.pickInterval) or 0.2)
			or math.min(((motion.adaptive and motion.adaptive.pickInterval) or 0.2), 0.12)) then
			motion.pickT = now
			local best, lowest
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate) or (motion.skip[candidate] or 0) >= now or motion.pending[candidate] then continue end
					local score = (candidate.Position - root.Position).Magnitude + FarmMotion.murderPenalty(state, candidate.Position, murderer)
					if not lowest or score < lowest then best, lowest = candidate, score end
				end
			end
			if best and state.avoidMurder and lowest >= 1000000 then best = nil end
			if best and best ~= coin then
				local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
				local currentScore = coin and (currentDistance
					+ FarmMotion.murderPenalty(state, coin.Position, murderer)) or math.huge
				-- Prioridade real das moedas perto sem ficar alternando de rumo.
				-- Finaliza contato quando esta muito perto da moeda atual.
				local dangerous = state.avoidMurder and currentScore >= 1000000
				local hysteresis = currentDistance < 2.5 and 1.8 or math.max(1.0, currentDistance * 0.07)
				local canSwitch = not coin or dangerous or
					(now - (motion.fastSwitchedAt or 0) >= 0.18 and lowest + hysteresis < currentScore)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Um novo alvo deve receber direcao imediata, sem impulso do anterior.
					motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
				end
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, nunca bloqueia 26/27.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Mantem a velocidade programada dentro do limite de 25 para reduzir correcoes do servidor.
	local actualSpeed = math.min(speed, 25)
	-- Indica velocidade solicitada, nao velocidade efetivamente validada pelo servidor.
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			local factor = math.clamp((tonumber(options.delta) or 1 / 30) * 26, 0.78, 1)
			velocity.Velocity = previous:Lerp(desired, factor)
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	if not inContact then motion.fastContactCoin = nil end
	if distance < 4 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= 0.22) then
		FarmMotion.touch(context, character, target)
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance < 1 then
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		if now - motion.dwellFrom >= (target == gun and 0.25 or 0.01) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Moeda ainda nao confirmada: liberar nova tentativa apos 0.22s.
				motion.pending[target] = {t = now + 0.22, fast = true}
			end
			-- Proxima busca sem espera; o modo adaptativo continua cuidando dos alvos ativos.
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.5 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end
]====],
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 25, 8, 25)
	-- Moedas tocadas e confirmadas da rodada atual: nao retroceder depois do contato.
	motion.fastVisited = motion.fastVisited or {}
	motion.fastConfirmed = motion.fastConfirmed or {}
	motion.fastTouchedAt = motion.fastTouchedAt or {}
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Sempre conferir as moedas proximas, mesmo perto de outro alvo.
		if now - (motion.pickT or 0) >=
			(coin and ((motion.adaptive and motion.adaptive.pickInterval) or 0.2)
			or math.min(((motion.adaptive and motion.adaptive.pickInterval) or 0.2), 0.12)) then
			motion.pickT = now
			local best, lowest, retry, retryScore
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate) or (motion.skip[candidate] or 0) >= now or motion.pending[candidate] then continue end
					-- Ignora permanentemente moedas ja confirmadas pelo servidor.
					if motion.fastConfirmed[candidate] then continue end
					local score = (candidate.Position - root.Position).Magnitude + FarmMotion.murderPenalty(state, candidate.Position, murderer)
					local seen = motion.fastVisited[candidate]
					if not seen then
						if not lowest or score < lowest then best, lowest = candidate, score end
					elseif now - seen >= 6 and (not retryScore or score < retryScore) then
						-- Repetir toque falho apenas quando acabarem moedas nao visitadas.
						retry, retryScore = candidate, score
					end
				end
			end
			if not best then best, lowest = retry, retryScore end
			if best and state.avoidMurder and lowest >= 1000000 then best = nil end
			if best and best ~= coin then
				local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
				local currentScore = coin and (currentDistance
					+ FarmMotion.murderPenalty(state, coin.Position, murderer)) or math.huge
				-- Prioridade real das moedas perto sem ficar alternando de rumo.
				-- Finaliza contato quando esta muito perto da moeda atual.
				local dangerous = state.avoidMurder and currentScore >= 1000000
				local hysteresis = currentDistance < 2.5 and 1.8 or math.max(1.0, currentDistance * 0.07)
				local canSwitch = not coin or dangerous or
					(now - (motion.fastSwitchedAt or 0) >= 0.18 and lowest + hysteresis < currentScore)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Troca limpa de alvo: remove o vetor de movimento da moeda anterior.
					velocity.Velocity = context.environment.Vector3.zero
					motion.fastLastVelocity, motion.fastProgressTarget, motion.fastLastTarget = nil, nil, nil
				end
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, nunca bloqueia 26/27.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Mantem a velocidade programada dentro do limite de 25 para reduzir correcoes do servidor.
	local actualSpeed = math.min(speed, 25)
	-- Indica velocidade solicitada, nao velocidade efetivamente validada pelo servidor.
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			local factor = math.clamp((tonumber(options.delta) or 1 / 30) * 26, 0.78, 1)
			velocity.Velocity = previous:Lerp(desired, factor)
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	if not inContact then motion.fastContactCoin = nil end
	if distance < 4 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= 0.22) then
		FarmMotion.touch(context, character, target)
		if target ~= gun then motion.fastTouchedAt[target] = now end
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance < 1 then
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		if now - motion.dwellFrom >= (target == gun and 0.25 or 0.01) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Marca como visitada antes de buscar o proximo alvo.
				motion.fastVisited[target] = now
				motion.pending[target] = {t = now + 0.22, fast = true}
			end
			-- Nao continuar se movendo para a moeda antiga apos encerrar o toque.
			velocity.Velocity = context.environment.Vector3.zero
			motion.fastLastVelocity, motion.fastLastTarget = nil, nil
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.5 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end
]====],
    "Fast v4x: nunca retornar logo a moeda tocada")

mythicReplaceOnce(
    [====[			FarmState.coinCollected(state, environment.tick(), kind, count, maximum)]====],
    [====[			FarmState.coinCollected(state, environment.tick(), kind, count, maximum)
			-- Quando o servidor confirma a coleta, retira o alvo da lista ate a proxima rodada.
			if state.enabled and context.configuration.farm.method == "Fast" then
				local touched, confirmed = motion.fastTouchedAt, motion.fastConfirmed
				if touched and confirmed then
					local picked, oldest
					for candidate, lastTouchAt in touched do
						if not confirmed[candidate] and motion.evAt - lastTouchAt <= 3
							and (not oldest or lastTouchAt < oldest) then
							picked, oldest = candidate, lastTouchAt
						end
					end
					if picked then
						confirmed[picked] = true
						motion.fastVisited[picked] = motion.fastVisited[picked] or motion.evAt
						motion.pending[picked] = nil
						if motion.coin == picked then
							motion.coin, motion.pickT, motion.fastLastVelocity, motion.fastLastTarget = nil, 0, nil, nil
						end
					end
				end
			end]====],
    "Fast v4x: confirmar coleta pelo servidor e bloquear revisita")

mythicReplaceOnce(
    [====[	motion.fastMisses = {}
	motion.fastTouchedCoin, motion.fastContactCoin, motion.fastDwellTarget = nil, nil, nil]====],
    [====[	motion.fastMisses = {}
	motion.fastVisited, motion.fastConfirmed, motion.fastTouchedAt = {}, {}, {}
	motion.fastTouchedCoin, motion.fastContactCoin, motion.fastDwellTarget = nil, nil, nil]====],
    "Fast v4x: limpar memoria de moedas a cada rodada")

mythicReplaceOnce(
    [====[	motion.fastContactCoin, motion.fastMisses = nil, {}
	motion.gunTarget, motion.dwellFrom, motion.zCur, motion.zfs = nil, nil, nil, nil]====],
    [====[	motion.fastContactCoin, motion.fastMisses = nil, {}
	motion.fastVisited, motion.fastConfirmed, motion.fastTouchedAt = {}, {}, {}
	motion.fastLastVelocity, motion.fastLastTarget = nil, nil
	motion.gunTarget, motion.dwellFrom, motion.zCur, motion.zfs = nil, nil, nil, nil]====],
    "Fast v4x: limpar memoria de moedas ao reiniciar")
mythicFlushPatches()

-- MYTHIC v14: Fast 25 maximo; priorizar moedas nao visitadas e reduzir voltas.
mythicFlushPatches()
mythicReplaceOnce(
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 25, 8, 25)
	-- Moedas tocadas e confirmadas da rodada atual: nao retroceder depois do contato.
	motion.fastVisited = motion.fastVisited or {}
	motion.fastConfirmed = motion.fastConfirmed or {}
	motion.fastTouchedAt = motion.fastTouchedAt or {}
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Sempre conferir as moedas proximas, mesmo perto de outro alvo.
		if now - (motion.pickT or 0) >=
			(coin and ((motion.adaptive and motion.adaptive.pickInterval) or 0.2)
			or math.min(((motion.adaptive and motion.adaptive.pickInterval) or 0.2), 0.12)) then
			motion.pickT = now
			local best, lowest, retry, retryScore
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate) or (motion.skip[candidate] or 0) >= now or motion.pending[candidate] then continue end
					-- Ignora permanentemente moedas ja confirmadas pelo servidor.
					if motion.fastConfirmed[candidate] then continue end
					local score = (candidate.Position - root.Position).Magnitude + FarmMotion.murderPenalty(state, candidate.Position, murderer)
					local seen = motion.fastVisited[candidate]
					if not seen then
						if not lowest or score < lowest then best, lowest = candidate, score end
					elseif now - seen >= 6 and (not retryScore or score < retryScore) then
						-- Repetir toque falho apenas quando acabarem moedas nao visitadas.
						retry, retryScore = candidate, score
					end
				end
			end
			if not best then best, lowest = retry, retryScore end
			if best and state.avoidMurder and lowest >= 1000000 then best = nil end
			if best and best ~= coin then
				local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
				local currentScore = coin and (currentDistance
					+ FarmMotion.murderPenalty(state, coin.Position, murderer)) or math.huge
				-- Prioridade real das moedas perto sem ficar alternando de rumo.
				-- Finaliza contato quando esta muito perto da moeda atual.
				local dangerous = state.avoidMurder and currentScore >= 1000000
				local hysteresis = currentDistance < 2.5 and 1.8 or math.max(1.0, currentDistance * 0.07)
				local canSwitch = not coin or dangerous or
					(now - (motion.fastSwitchedAt or 0) >= 0.18 and lowest + hysteresis < currentScore)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Troca limpa de alvo: remove o vetor de movimento da moeda anterior.
					velocity.Velocity = context.environment.Vector3.zero
					motion.fastLastVelocity, motion.fastProgressTarget, motion.fastLastTarget = nil, nil, nil
				end
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, nunca bloqueia 26/27.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Mantem a velocidade programada dentro do limite de 25 para reduzir correcoes do servidor.
	local actualSpeed = math.min(speed, 25)
	-- Indica velocidade solicitada, nao velocidade efetivamente validada pelo servidor.
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			local factor = math.clamp((tonumber(options.delta) or 1 / 30) * 26, 0.78, 1)
			velocity.Velocity = previous:Lerp(desired, factor)
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	if not inContact then motion.fastContactCoin = nil end
	if distance < 4 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= 0.22) then
		FarmMotion.touch(context, character, target)
		if target ~= gun then motion.fastTouchedAt[target] = now end
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance < 1 then
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		if now - motion.dwellFrom >= (target == gun and 0.25 or 0.01) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Marca como visitada antes de buscar o proximo alvo.
				motion.fastVisited[target] = now
				motion.pending[target] = {t = now + 0.22, fast = true}
			end
			-- Nao continuar se movendo para a moeda antiga apos encerrar o toque.
			velocity.Velocity = context.environment.Vector3.zero
			motion.fastLastVelocity, motion.fastLastTarget = nil, nil
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.5 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end
]====],
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = 24
	-- Busca apenas moedas disponiveis, ordenando pela distancia REAL ao personagem.
	-- Reavalia rapidamente para nao passar direto por grupos de moedas proximas.
	motion.fastRecent = motion.fastRecent or {}
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Nao varre o mapa na aproximacao final: termina a coleta sem mudar de rota.
		local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
		local interval = coin and math.min(0.145, (motion.adaptive and motion.adaptive.pickInterval) or 0.12) or 0.045
		if currentDistance > 3.5 and now - (motion.pickT or 0) >= interval then
			motion.pickT = now
			local best, bestDistanceSq
			local origin = root.Position
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate)
						or (motion.skip[candidate] or 0) >= now or motion.pending[candidate]
						or (motion.fastRecent[candidate] or 0) > now then continue end
					-- Calcula custo de seguranca apenas para candidatas realmente mais proximas.
					local offset = candidate.Position - origin
					local d2 = offset:Dot(offset)
					if not bestDistanceSq or d2 < bestDistanceSq then
						if not state.avoidMurder or FarmMotion.murderPenalty(state, candidate.Position, murderer) < 1000000 then
							best, bestDistanceSq = candidate, d2
						end
					end
				end
			end
			if best and best ~= coin then
				local bestDistance = math.sqrt(bestDistanceSq)
				local unsafe = coin and state.avoidMurder
					and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000
				-- Perto do contato termina a coleta; longe, uma moeda mais proxima vence.
				local canSwitch = not coin or unsafe or
					(currentDistance > 3.5 and bestDistance + math.max(1.4, currentDistance * 0.10) < currentDistance
					and now - (motion.fastSwitchedAt or -1) >= 0.18)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Descartar apenas direcao antiga; nao aplicar impulso contrario.
					motion.fastLastVelocity, motion.fastProgressTarget, motion.fastLastTarget = nil, nil, nil
				end
			elseif not best and coin and state.avoidMurder
				and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000 then
				motion.coin, coin = nil, nil
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, sem impulso contrario.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Fast fixo em 24: sem oscilacao nem mudanca de velocidade durante a rota.
	-- Remove verificacoes custosas que atrasavam a coleta em alguns celulares.
	local actualSpeed = 24
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			-- Seguir diretamente a direcao atual; sem arrastar o vetor anterior.
			velocity.Velocity = desired
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	if not inContact then motion.fastContactCoin = nil end
	if distance < 4 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= 0.22) then
		FarmMotion.touch(context, character, target)
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance < 1 then
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		-- Curta confirmacao de contato, sem travar a proxima escolha.
		local coinDwell = 0.025
		if now - motion.dwellFrom >= (target == gun and 0.25 or coinDwell) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Bloqueio breve: nao retorna a moeda antiga, mas recupera toque falho.
				motion.fastRecent[target] = now + 0.45
				motion.pending[target] = {t = now + 0.22, fast = true}
			end
			-- Limpa orientacao armazenada, sem zerar o movimento no quadro.
			motion.fastLastVelocity, motion.fastLastTarget = nil, nil
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.5 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end
]====],
    "Fast v4y: remover cooldown de 6s e paradas ao virar")

mythicReplaceOnce(
    [====[FarmState.coinCollected(state, environment.tick(), kind, count, maximum)
			-- Quando o servidor confirma a coleta, retira o alvo da lista ate a proxima rodada.
			if state.enabled and context.configuration.farm.method == "Fast" then
				local touched, confirmed = motion.fastTouchedAt, motion.fastConfirmed
				if touched and confirmed then
					local picked, oldest
					for candidate, lastTouchAt in touched do
						if not confirmed[candidate] and motion.evAt - lastTouchAt <= 3
							and (not oldest or lastTouchAt < oldest) then
							picked, oldest = candidate, lastTouchAt
						end
					end
					if picked then
						confirmed[picked] = true
						motion.fastVisited[picked] = motion.fastVisited[picked] or motion.evAt
						motion.pending[picked] = nil
						if motion.coin == picked then
							motion.coin, motion.pickT, motion.fastLastVelocity, motion.fastLastTarget = nil, 0, nil, nil
						end
					end
				end
			end]====],
    [====[FarmState.coinCollected(state, environment.tick(), kind, count, maximum)]====],
    "Fast v4y: eliminar busca por moedas no evento de coleta")

mythicReplaceOnce(
    [====[	motion.fastMisses = {}
	motion.fastVisited, motion.fastConfirmed, motion.fastTouchedAt = {}, {}, {}]====],
    [====[	motion.fastMisses = {}
	motion.fastRecent = {}]====],
    "Fast v4y: reduzir memoria e reiniciar a cada rodada")

mythicReplaceOnce(
    [====[	motion.fastVisited, motion.fastConfirmed, motion.fastTouchedAt = {}, {}, {}
	motion.fastLastVelocity, motion.fastLastTarget = nil, nil]====],
    [====[	motion.fastRecent = {}
	motion.fastLastVelocity, motion.fastLastTarget = nil, nil]====],
    "Fast v4y: limpar memoria na restauracao do personagem")

mythicReplaceOnce(
    [====[-- Atualiza 25/26/27 no painel mais rapido que o ciclo de velocidade.
			environment.task.wait(0.15)]====],
    [====[-- Painel atualizado com menos frequencia para diminuir trabalho no celular.
			environment.task.wait(0.27)]====],
    "Fast v4y: reduzir atualizacoes do painel mobile")

mythicReplaceOnce(
    [====[if state.enabled then pcall(mapFarm.hop) end]====],
    [====[if state.enabled then
				-- Evita varrer mapa em cada evento CoinCollected no Fast.
				local mapNow = environment.os.clock()
				if context.configuration.farm.method ~= "Fast" or mapNow - (motion.lastMapHopAt or 0) >= 0.5 then
					motion.lastMapHopAt = mapNow
					pcall(mapFarm.hop)
				end
			end]====],
    "Fast v4y: evitar amostragem de mapa a cada moeda")

mythicReplaceOnce(
    [====[if scanNow - lastNoclipScan < 0.05 then return end]====],
    [====[if scanNow - lastNoclipScan < 0.10 then return end]====],
    "Fast v4y: reduzir custo de noclip pela metade")
mythicFlushPatches()

-- MYTHIC v4: remover NPC Trolly na ORIGEM (modelo PulseNpc), nao so ocultar.
do
    local head = "function PulseApplication.Trolly.install(context)"
    local tail = "\n\nfunction PulseApplication.installAppearance(context)"
    local a = string.find(source, head, 1, true)
    local b = a and string.find(source, tail, a + #head, true)
    if a and b then
        source = string.sub(source, 1, a - 1) ..
            "function PulseApplication.Trolly.install(context)\n    return function() end\nend" ..
            string.sub(source, b)
    else
        warn("MYTHIC-HUB: nao encontrei o instalador Trolly para desativar.")
    end
    -- Nao deixar o menu oferecer um controle que recriaria o NPC.
    local control = 'context.section:Toggle({Text = "Trolly NPC"'
    local after = "\n\tif context.window then"
    local c = string.find(source, control, 1, true)
    local d = c and string.find(source, after, c + #control, true)
    if c and d then
        source = string.sub(source, 1, c - 1) .. string.sub(source, d)
    end
    -- Configuracao padrao desligada mesmo se outras funcoes consultarem.
    mythicReplaceOnce("if settings.on == nil then settings.on = true end",
        "settings.on = false", "Trolly desligado por padrao")
    -- Limpa NPC de execucao antiga, sem tocar no avatar de jogadores.
    pcall(function()
        local players = game:GetService("Players")
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("Model") and object.Name == "PulseNpc" and
                not players:GetPlayerFromCharacter(object) then
                object:Destroy()
            end
        end
    end)
end

-- MYTHIC PERFORMANCE MOBILE v2: reduz custo visual e encerra instancias antigas.
-- ESP ativo: atualizacao nativa por frame (sem limitacao de FPS no patch).


mythicReplaceOnce([====[changer.gradientConnection = state.context.connect(state.context.runService.RenderStepped, function()
			local offset = environment.os.clock() * 0.35 % 2 - 1
			for item in changer.gradients do if item.Parent then item.Offset = environment.Vector2.new(offset, 0) end end
		end)]====], [====[local lastGradientAt = -1
		changer.gradientConnection = state.context.connect(state.context.runService.RenderStepped, function()
			local now = environment.os.clock()
			if now - lastGradientAt < 0.1 then return end
			lastGradientAt = now
			local offset = now * 0.35 % 2 - 1
			for item in changer.gradients do if item.Parent then item.Offset = environment.Vector2.new(offset, 0) end end
		end)]====], "Performance inventario: gradientes 10 FPS")
mythicReplaceOnce([====[if context.runService and context.runService.RenderStepped then
		context.connect(context.runService.RenderStepped, function()
			if next(state.rm.players) then pcall(RemoteSkins.enforce, state) end
			if next(state.displays) then pcall(WeaponSkins.renderDisplays, state) end
		end)
	end]====], [====[if context.runService and context.runService.RenderStepped then
		local lastRenderAt = -1
		context.connect(context.runService.RenderStepped, function()
			local now = environment.os.clock()
			if now - lastRenderAt < 0.1 then return end
			lastRenderAt = now
			if next(state.rm.players) then pcall(RemoteSkins.enforce, state) end
			if next(state.displays) then pcall(WeaponSkins.renderDisplays, state) end
		end)
	end]====], "Performance skins: renderizacao 10 FPS")
mythicReplaceOnce([====[function PulseApplication.start(host, game, parent)
	local hostGlobal = type(host.getgenv) == "function" and host.getgenv() or host
	-- Only the opt-in MYTHIC USERS feature uses this separately captured request function.]====], [====[function PulseApplication.start(host, game, parent)
	local hostGlobal = type(host.getgenv) == "function" and host.getgenv() or host
	local oldWindow = hostGlobal.__pulseMM2Nova
	if oldWindow and not oldWindow.Destroyed then
		pcall(function() oldWindow:Destroy() end)
	end
	-- Only the opt-in MYTHIC USERS feature uses this separately captured request function.]====], "Performance reinicio: fechar instancia anterior")

-- MYTHIC PERFORMANCE HUD v1: apenas exibicao/overlays; gameplay inalterado.
mythicReplaceOnce([====[			elapsed += delta
			if elapsed < 0.08 then return end
			elapsed = 0
			window:_kbRebuild(true)]====], [====[			elapsed += delta
			if elapsed < 0.25 then return end
			elapsed = 0
			window:_kbRebuild(true)]====], "Painel de atalhos 4x/segundo")
mythicReplaceOnce([====[		local frames, started = 0, environment.os.clock()
		utility.connect(nova.Services.RunService.RenderStepped, function()
			local now = environment.os.clock()
			if not frame.Visible then frames, started = 0, now; return end
			frames += 1
			local elapsed = now - started
			if elapsed < 0.5 then return end

			local value = math.floor(frames / elapsed + 0.5)
			frames, started = 0, now
			fps.value.Text = tostring(value)]====], [====[		local frames, started, smoothed = 0, environment.os.clock(), nil
		utility.connect(nova.Services.RunService.RenderStepped, function()
			local now = environment.os.clock()
			if not frame.Visible then frames, started, smoothed = 0, now, nil; return end
			frames += 1
			local elapsed = now - started
			if elapsed < 1.0 then return end

			local measured = frames / elapsed
			smoothed = smoothed and (smoothed * 0.55 + measured * 0.45) or measured
			local value = math.floor(smoothed + 0.5)
			frames, started = 0, now
			if fps.value.Text ~= tostring(value) then fps.value.Text = tostring(value) end]====], "FPS em media de 1 segundo e Ping 1x/segundo")

-- MYTHIC FAST LOBBY GUARD v20: manter o Fast ativo apos o spawn no mapa.
-- A deteccao deve persistir durante RoundStart/CoinsStarted e reiniciar apenas ao final da rodada.
local farmTickAnchor = [====[	local method = context.configuration.farm.method
	if method ~= "Teleport" and method ~= "Fast" then method = "Under Map" end]====]
local farmTickGated = [====[	local method = context.configuration.farm.method
	if method ~= "Teleport" and method ~= "Fast" then method = "Under Map" end
	-- Nao iniciar Fast enquanto o personagem ainda estiver no lobby.
	if method == "Fast" then
		if motion.fastGateCharacter ~= character then
			motion.fastGateCharacter, motion.fastGateOpen, motion.fastGateAt = character, false, -1
		end
		if not motion.fastGateOpen and now - (motion.fastGateAt or -1) >= 0.35 then
			motion.fastGateAt = now
			for _, container in FarmState.containers(context, state, now) do
				if container.Parent then
					-- Em mapas grandes o spawn pode ficar longe de todas as moedas.
					-- Usar o limite espacial do mapa antes de procurar moedas proximas.
					local map = container.Parent
					if map:IsA("Model") then
						local bboxOK, cf, size = pcall(function() return map:GetBoundingBox() end)
						if bboxOK and cf and size then
							local offset = cf:PointToObjectSpace(root.Position)
							if math.abs(offset.X) <= size.X * 0.5 + 12
								and math.abs(offset.Y) <= size.Y * 0.5 + 12
								and math.abs(offset.Z) <= size.Z * 0.5 + 12 then
								motion.fastGateOpen = true
								break
							end
						end
					end
					for _, coin in container:GetChildren() do
						if FarmState.validCoin(context, state, coin)
							and (coin.Position - root.Position).Magnitude <= 85 then
							motion.fastGateOpen = true
							break
						end
					end
				end
				if motion.fastGateOpen then break end
			end
		end
		if not motion.fastGateOpen then
			if motion.phase ~= "idle" then FarmMotion.reset(context, motion, character) end
			return
		end
	end]====]
if not mythicReplaceOnce(farmTickAnchor, farmTickGated, "Fast: aguardar spawn no mapa sem travar a coleta") then
    failLoader("Fast: protecao contra saida do lobby nao instalada.")
end
-- RoundStart e CoinsStarted podem ocorrer apos o personagem entrar no mapa.
-- O gate ja aberto NAO deve ser apagado por FarmRuntime.resetMotion.
if not mythicReplaceOnce(
    [====[listen("RoundEndFade", function() FarmState.roundEnd(state) end)]====],
    [====[listen("RoundEndFade", function()
			FarmState.roundEnd(state)
			motion.fastGateOpen, motion.fastGateCharacter, motion.fastGateAt = false, nil, -1
		end)]====],
    "Fast: resetar trava do lobby somente ao terminar a partida") then
    failLoader("Fast: reset ao terminar partida nao instalado.")
end

mythicFlushPatches()
-- Verificar que o ultimo patch Fast manteve 24/25 sem a oscilacao antiga.
if string.find(source, "local actualSpeed = slot == 0 and 25 or slot == 2 and 27 or 26", 1, true) then
    failLoader("Fast: patch antigo de velocidade oscilante detectado; limpeza do cache necessaria.")
end
-- Ajustar todas as cinco referencias de movimento Under Map num unico passo.
local underOld = "math.clamp(tonumber(context.configuration.farm.speed) or 21, 8, 22)"
local underNew = "math.clamp(tonumber(context.configuration.farm.speed) or 23, 8, 23)"
local underParts, underStart, underCount = {}, 1, 0
while true do
    local pos = string.find(source, underOld, underStart, true)
    if not pos then break end
    underParts[#underParts + 1] = string.sub(source, underStart, pos - 1)
    underParts[#underParts + 1] = underNew
    underStart = pos + #underOld
    underCount += 1
end
if underCount == 5 then
    underParts[#underParts + 1] = string.sub(source, underStart)
    source = table.concat(underParts)
else
    failLoader("Under Map: encontrados " .. tostring(underCount) .. " controles de velocidade; esperados 5.")
end

-- Under Map: filtro matematico de candidatos distantes antes do calculo completo.
-- FarmMotion.coinScore e sempre >= distancia horizontal porque os adicionais sao nao-negativos.
mythicReplaceOnce(
    [====[			local score = FarmMotion.coinScore(state, position, coin, murderer)
			if not lowest or score < lowest then chosen, lowest = coin, score end]====],
    [====[			local offset = coin.Position - position
			local horizontalSquared = offset.X * offset.X + offset.Z * offset.Z
			if not lowest or horizontalSquared < lowest * lowest then
				local score = FarmMotion.coinScore(state, position, coin, murderer)
				if not lowest or score < lowest then chosen, lowest = coin, score end
			end]====],
    "Under Map: ignorar candidatos incapazes de melhorar a rota")
mythicFlushPatches()

-- MYTHIC FAST 24: corrigir reescrita posterior da funcao de movimento.
-- Regras opcionais: patches posteriores podem eliminar as ancoras antigas.
local fast24Rules = {
    {"local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 25, 8, 25)",
     "local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 24, 8, 24)"},
    {"local speed = 25", "local speed = 24"},
    {'{"Fast Speed", "fastSpeed", 20, 25, 25}',
     '{"Fast Speed", "fastSpeed", 20, 24, 24}'},
    {"settings.fastSpeed = 25", "settings.fastSpeed = 24"},
    {"local actualSpeed = math.min(speed, 25)", "local actualSpeed = math.min(speed, 24)"},
    {"local actualSpeed = 25", "local actualSpeed = 24"},
}
local fast24Changes = 0
for _, rule in ipairs(fast24Rules) do
    local oldValue, newValue = rule[1], rule[2]
    local startAt = 1
    while true do
        local at = string.find(source, oldValue, startAt, true)
        if not at then break end
        queuedPatches[#queuedPatches + 1] = {start = at, length = #oldValue, replacement = newValue}
        fast24Changes += 1
        startAt = at + #oldValue
    end
end
mythicFlushPatches()
warn("MYTHIC-HUB: Fast 24 - " .. fast24Changes .. " ajustes aplicados.")
-- MYTHIC AUTO VOTE: um voto confirmado por rodada para cada mapa escolhido.
local voteHead = "function ServerIdentity.MapVote.autoStart(state)"
local voteTail = "\nfunction ServerIdentity.MapVote.observe(state)"
local voteAt = string.find(source, voteHead, 1, true)
local voteAfter = voteAt and string.find(source, voteTail, voteAt + #voteHead, true)
if voteAt and voteAfter then
    mythicReplaceOnce(string.sub(source, voteAt, voteAfter - 1), [====[
function ServerIdentity.MapVote.autoStart(state)
    if state.closed or state.autoRan or state.busy or state.cfg.auto ~= true or state.autoStarting then return end
    local vote, context = ServerIdentity.MapVote, state.context
    local clock = context.environment.os.clock
    if clock() < (state.autoRetryAt or 0) then return end
    state.autoStarting = true
    local started = clock()
    local pads, active
    repeat
        if state.closed or state.cfg.auto ~= true then
            state.autoStarting = false
            return
        end
        pads, active = vote.snapshot(state)
        local ready = false
        if active then
            for index = 1, 3 do
                local pad = pads[index]
                if pad and pad.active and not pad.idle
                    and pad.name ~= "" and pad.name ~= "MAP NAME" then
                    ready = true
                    break
                end
            end
        end
        if ready or clock() - started >= 1.2 then break end
        context.runService.Heartbeat:Wait()
    until false
    state.autoStarting = false
    if state.closed or state.autoRan or state.busy or state.cfg.auto ~= true then return end
    if not active then
        state.status = "Aguardando votacao"
        state.autoRetryAt = clock() + 0.5
        return
    end
    for index = 1, 3 do
        local pad = pads[index]
        if pad and pad.active and not pad.idle
            and pad.name ~= "" and pad.name ~= "MAP NAME" then
            vote.discover(state, pad.name, pad.icon, clock())
        end
    end
    -- Mesma prioridade e mesmas opcoes Other maps da versao original.
    if state.cfg.farmSort == true then
        pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm"))
        vote.renderPriority(state)
    end
    local chosen = vote.choose(state, pads)
    if not chosen then
        state.status = "Nenhum mapa habilitado nesta votacao"
        state.autoRetryAt = clock() + 0.5
        return
    end
    local pad = pads[chosen]
    local key = pad and (vote.keyForIcon(state, pad.icon) or vote.key(pad.name))
    state.sel, state.autoRan = chosen, true
    -- Apenas destaca o mapa preferido, sem mover, reiniciar ou votar.
    state.status = "Mapa selecionado: " .. tostring(pad and pad.name or key or chosen) .. " (sem voto)"
    vote.record(state, "mapa selecionado " .. tostring(key or chosen))
end
]====], "Auto Vote: mapa, contagem e confirmacao por rodada")
else
    warn("MYTHIC-HUB: funcao Auto Vote nao encontrada; original preservada.")
end
mythicFlushPatches()
-- Sem reinicios de personagem para somar votos. Um voto normal por rodada.
mythicReplaceOnce(
    [====[local count = math.clamp(math.floor(tonumber(state.cfg.count) or 10), 1, 100)
	state.context.environment.task.spawn(ServerIdentity.MapVote.run, state, index, count)]====],
    [====[state.context.environment.task.spawn(ServerIdentity.MapVote.run, state, index, 1)]====],
    "Map Vote: um voto no clique")
mythicReplaceOnce(
    [====[section:Button({Text = "Dupe Votes", Callback = function() vote.start(state, state.sel or 1) end})]====],
    [====[section:Button({Text = "Votar (1x)", Callback = function() vote.start(state, state.sel or 1) end})]====],
    "Map Vote: nome do botao")
mythicReplaceOnce(
    [====[section:Group({Title = "Auto Dupe", Side = "Right"})]====],
    [====[section:Group({Title = "Mapas Preferidos", Side = "Right"})]====],
    "Auto Vote: nome do grupo")
mythicReplaceOnce(
    [====[section:Toggle({Text = "Auto Dupe", Default = state.cfg.auto == true, Callback = function(value)]====],
    [====[section:Toggle({Text = "Selecionar mapa (sem TP)", Default = state.cfg.auto == true, Callback = function(value)]====],
    "Auto Vote: descricao no menu")
mythicReplaceOnce(
    [====[state.countSlider = section:Slider({Text = "Votes to add", Min = 1, Max = 100, Default = state.cfg.count, Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 10), 1, 100) end})]====],
    [====[state.countSlider = section:Slider({Text = "Selecoes por mapa", Min = 1, Max = 999, Default = math.clamp(tonumber(state.cfg.count) or 5, 1, 999), Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 5), 1, 999) end})]====],
    "Auto Vote: quantidade de rodadas por mapa")
mythicFlushPatches()
-- Auto Vote: mostrar o motivo de espera no painel quando nao existe voto ativo.
mythicReplaceOnce(
    [====[if state.busy then return translate(state.status ~= "" and state.status or "Voting") .. "  " .. state.done .. "/" .. state.want .. suffix end]====],
    [====[if state.busy then return translate(state.status ~= "" and state.status or "Voting") .. "  " .. state.done .. "/" .. state.want .. suffix end
    if state.status ~= "" and not state.idx then return tostring(state.status) .. suffix end]====],
    "Auto Vote: feedback quando nao encontra mapas selecionados")
mythicReplaceOnce(
    [====[pcall(vote.autoStart, state)]====],
    [====[local success, reason = pcall(vote.autoStart, state)
                if not success then
                    state.status = "Erro interno no Auto Vote"
                    warn("MYTHIC-HUB Auto Vote: " .. tostring(reason))
                end]====],
    "Auto Vote: registrar falhas inesperadas no console")
mythicFlushPatches()

-- HUD: evitar escritas repetidas e atualizacoes do painel quando oculto.
mythicReplaceOnce(
    [====[				vote.renderRows(state, state.rows, pads)
				local status = vote.status(state, active)
				if state.statusLabel then state.statusLabel.Text = status end
				if state.panel then
					vote.panelVisibility(state, state.cfg.panel ~= false and (active or state.busy))
					state.panelStatus.Text, state.panelCount.Text = status, tostring(state.cfg.count)
					state.panelStop.Visible = state.busy
					vote.renderRows(state, state.panelRows, pads)
				end]====],
    [====[				vote.renderRows(state, state.rows, pads)
				local status = vote.status(state, active)
				if state.statusLabel and state.statusLabel.Text ~= status then state.statusLabel.Text = status end
				if state.panel then
					local visible = state.cfg.panel ~= false and (active or state.busy)
					vote.panelVisibility(state, visible)
					if visible then
						if state.panelStatus.Text ~= status then state.panelStatus.Text = status end
						local countLabel = tostring(state.cfg.count)
						if state.panelCount.Text ~= countLabel then state.panelCount.Text = countLabel end
						state.panelStop.Visible = state.busy
						vote.renderRows(state, state.panelRows, pads)
					end
				end]====],
    "Votacao: economizar trabalho da interface oculta")
mythicFlushPatches()

-- MYTHIC FAST 24: concluir contato com menos espera, sem aumentar a velocidade.
mythicReplaceOnce(
    [====[motion.fastRecent[target] = now + 0.45]====],
    [====[motion.fastRecent[target] = now + 0.34]====],
    "Fast: retomar busca de alvo mais cedo")
mythicReplaceOnce(
    [====[local coinDwell = 0.025]====],
    [====[local coinDwell = 0.02]====],
    "Fast: tempo de confirmacao reduzido")
mythicReplaceOnce(
    [====[if distance > 3 and now - (motion.fastProgressAt or now) > 2.5 then]====],
    [====[if distance > 3 and now - (motion.fastProgressAt or now) > 2.15 then]====],
    "Fast: reavaliar alvo travado mais cedo")
mythicFlushPatches()
-- MYTHIC SERVER ORIGINAL: restaurar layout e mapas da base Pulse Hub.
-- Substituir o trecho final de cada funcao, depois dos patches visuais antigos.
local function restorePulseServerSection(beginText, nextText, originalText, label)
    local a = string.find(source, beginText, 1, true)
    local b = a and string.find(source, nextText, a + #beginText, true)
    if a and b then
        local current = string.sub(source, a, b - 1)
        if current ~= originalText then
            mythicReplaceOnce(current, originalText, label)
        end
    else
        warn("MYTHIC-HUB: restauracao opcional nao localizada: " .. label)
    end
end
restorePulseServerSection("ServerIdentity.MapVote.maps = {", "\n\nfunction ServerIdentity.MapVote.key(name)", [====[ServerIdentity.MapVote.maps = {
	{key = "bank2", name = "Bank 2", icon = "rbxassetid://3214475169"},
	{key = "biolab", name = "Bio Lab", icon = "rbxassetid://3214475802"},
	{key = "factory", name = "Factory", icon = "rbxassetid://3214476069"},
	{key = "hospital3", name = "Hospital 3", icon = "rbxassetid://3214476562"},
	{key = "hotel2", name = "Hotel 2", icon = "rbxassetid://3214477063"},
	{key = "house2", name = "House 2", icon = "rbxassetid://3214477411"},
	{key = "mansion2", name = "Mansion 2", icon = "rbxassetid://3214477676"},
	{key = "milbase", name = "Mil Base", icon = "rbxassetid://3214477899"},
	{key = "office3", name = "Office 3", icon = "rbxassetid://3214478924"},
	{key = "policestation", name = "Police Station", icon = "rbxassetid://3214479176"},
	{key = "researchfacility", name = "Research Facility", icon = "rbxassetid://4751350477"},
	{key = "workplace", name = "Workplace", icon = "rbxassetid://3214479481"},
}]====], "Pulse Server original: Mapas")
restorePulseServerSection("function ServerIdentity.MapVote.priorityRow(state, parent, map)", "\nfunction ServerIdentity.MapVote.renderPriority(state)", [====[function ServerIdentity.MapVote.priorityRow(state, parent, map)
	local context, environment = state.context, state.context.environment
	local create, enum = context.create, environment.Enum
	local row = create("Frame", {Name = "Map_" .. map.key, Size = environment.UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = environment.Color3.fromRGB(34, 37, 45), BorderSizePixel = 0, ZIndex = 3}, parent)
	context.corner(row, 8)
	local rank = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(4, 0),
		Size = environment.UDim2.fromOffset(20, 32), Text = "", Font = enum.Font.GothamBold, TextSize = 12,
		TextColor3 = environment.Color3.fromRGB(214, 68, 88), ZIndex = 4}, row)
	local image = create("ImageLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(28, 4),
		Size = environment.UDim2.fromOffset(44, 24), Image = "", ScaleType = enum.ScaleType.Crop, ZIndex = 4}, row)
	context.corner(image, 6)
	local label = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(80, 0),
		Size = environment.UDim2.new(1, -168, 1, 0), Text = map.name, Font = enum.Font.GothamSemibold, TextSize = 12,
		TextXAlignment = enum.TextXAlignment.Left, TextTruncate = enum.TextTruncate.AtEnd,
		TextColor3 = environment.Color3.new(1, 1, 1), ZIndex = 4}, row)
	local function button(text, offset, callback)
		local object = create("TextButton", {AnchorPoint = environment.Vector2.new(1, 0.5),
			Position = environment.UDim2.new(1, offset, 0.5, 0), Size = environment.UDim2.fromOffset(20, 24),
			Text = text, Font = enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1,
			TextColor3 = environment.Color3.fromRGB(170, 175, 188), ZIndex = 5}, row)
		context.connect(object.MouseButton1Click, callback)
		return object
	end
	local function move(delta)
		local order = state.cfg.order
		local index = table.find(order, map.key)
		local target = index and index + delta
		if not target or target < 1 or target > #order then return end
		order[index], order[target] = order[target], order[index]
		ServerIdentity.MapVote.renderPriority(state)
	end
	local up = button("в†‘", -64, function() move(-1) end)
	local down = button("в†“", -42, function() move(1) end)
	local toggle = button("", -8, function()
		state.cfg.off[map.key] = state.cfg.off[map.key] ~= true and true or nil
		ServerIdentity.MapVote.renderPriority(state)
	end)
	return {frame = row, rank = rank, image = image, label = label, up = up, down = down, toggle = toggle}
end
]====], "Pulse Server original: Linha da prioridade")
restorePulseServerSection("function ServerIdentity.MapVote.renderPriority(state)", "\nfunction ServerIdentity.MapVote.resetPriority(state)", [====[function ServerIdentity.MapVote.renderPriority(state)
	if not state.priorityList then return end
	local vote = ServerIdentity.MapVote
	local signature = {}
	for _, key in state.cfg.order do
		table.insert(signature, key .. ":" .. tostring(state.cfg.off[key] == true) .. ":" .. tostring(vote.icon(state, key)))
	end
	signature = table.concat(signature, "|")
	if signature == state.prioritySignature then return end
	state.priorityRows = state.priorityRows or {}
	local rank = 0
	for index, key in state.cfg.order do
		local map = state.maps[key]
		if not map then continue end
		local row = state.priorityRows[key]
		if not row then
			row = vote.priorityRow(state, state.priorityList, map)
			state.priorityRows[key] = row
		end
		local off = state.cfg.off[key] == true
		if not off then rank += 1 end
		row.frame.LayoutOrder = index
		row.rank.Text = off and "В·" or tostring(rank)
		row.image.Image = vote.icon(state, key) or ""
		row.image.ImageTransparency = off and 0.6 or 0
		row.label.TextTransparency = off and 0.5 or 0
		row.up.TextTransparency = index == 1 and 0.7 or 0
		row.down.TextTransparency = index == #state.cfg.order and 0.7 or 0
		row.toggle.Text = off and "в—‹" or "в—Џ"
	end
end
]====], "Pulse Server original: Painel de prioridade")
restorePulseServerSection("function ServerIdentity.MapVote.controls(state)", "\nfunction ServerIdentity.MapVote.install(context)", [====[function ServerIdentity.MapVote.controls(state)
	local context, vote = state.context, ServerIdentity.MapVote
	local section = context.section
	section:Group({Title = "Map Vote", Side = "Left"})
	state.rows = vote.rows(state, section:Container(), false)
	state.countSlider = section:Slider({Text = "Votes to add", Min = 1, Max = 100, Default = state.cfg.count, Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 10), 1, 100) end})
	section:Button({Text = "Dupe Votes", Callback = function() vote.start(state, state.sel or 1) end})
	section:Button({Text = "Stop", Callback = function() state.stop = true end})
	state.statusLabel = section:Note({Text = "Waiting for vote"})
	section:Toggle({Text = "Vote Panel", Default = state.cfg.panel ~= false, Callback = function(value) state.cfg.panel = not not value end})
	section:Toggle({Text = "Silent Respawn", Default = state.cfg.silent ~= false, Callback = function(value) state.cfg.silent = not not value end})
	section:Group({Title = "Auto Dupe", Side = "Right"})
	section:Toggle({Text = "Auto Dupe", Default = state.cfg.auto == true, Callback = function(value)
		state.cfg.auto = not not value
		if value then context.environment.task.defer(vote.autoStart, state) end
	end})
	section:Toggle({Text = "Farm Priority", Default = state.cfg.farmSort == true, Callback = function(value)
		state.cfg.farmSort = not not value
		if value then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Toggle({Text = "Explore Maps", Default = state.cfg.explore == true, Callback = function(value)
		state.cfg.explore = not not value
		if state.cfg.farmSort then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Dropdown({Text = "Other maps", Default = state.cfg.fallback, Options = {
		{code = "skip", label = "Don't dupe"}, {code = "leading", label = "Dupe most voted"}, {code = "first", label = "Dupe first map"}},
		Callback = function(value) state.cfg.fallback = value end})
	section:Header("Map Priority", "Right")
	local container = section:Container()
	if container then
		local environment = context.environment
		state.priorityList = context.create("Frame", {Name = "PrioList", BackgroundTransparency = 1,
			Size = environment.UDim2.new(1, 0, 0, 0), AutomaticSize = environment.Enum.AutomaticSize.Y}, container)
		context.create("UIListLayout", {Padding = environment.UDim.new(0, 3), SortOrder = environment.Enum.SortOrder.LayoutOrder}, state.priorityList)
		vote.renderPriority(state)
	end
	section:Button({Text = "Reset Priority", Callback = function() vote.resetPriority(state) end})
end
]====], "Pulse Server original: Aba Server")
mythicFlushPatches()

-- FARM v37: selecionar a moeda mais proxima, mas concluir o alvo atual
-- na aproximacao final, sem puxao, e economizar intervalos ociosos.
mythicReplaceOnce([====[local interval = coin and math.min(0.145, (motion.adaptive and motion.adaptive.pickInterval) or 0.12) or 0.045]====], [====[local interval = coin and math.min(0.105, (motion.adaptive and motion.adaptive.pickInterval) or 0.12) or 0.035]====], "Fast: busca proxima moeda logo apos o contato")
mythicReplaceOnce([====[if currentDistance > 3.5 and now - (motion.pickT or 0) >= interval then]====], [====[if currentDistance > 9 and now - (motion.pickT or 0) >= interval then]====], "Fast: travar rota na aproximacao final")
mythicReplaceOnce([====[(currentDistance > 3.5 and bestDistance + math.max(1.4, currentDistance * 0.10) < currentDistance]====], [====[(currentDistance > 9 and bestDistance + math.max(2.0, currentDistance * 0.14) < currentDistance]====], "Fast: reduzir mudancas desnecessarias de alvo")
mythicReplaceOnce([====[motion.fastRecent[target] = now + 0.34]====], [====[motion.fastRecent[target] = now + 0.22]====], "Fast: liberar moeda nao confirmada mais cedo")
mythicReplaceOnce([====[if not current or score + ((motion.adaptive and motion.adaptive.switchMargin) or 1.5) < current then]====], [====[local dx = coin and coin.Position.X - root.Position.X or math.huge
                local dz = coin and coin.Position.Z - root.Position.Z or math.huge
                local aligned = coin and dx * dx + dz * dz < 64
                if not current or (not aligned and
                    score + ((motion.adaptive and motion.adaptive.switchMargin) or 1.5) < current) then]====], "Under Map: terminar moeda alinhada antes de trocar")
mythicReplaceOnce([====[motion.pending[coin] = {t = now + 0.9, gap = gap}]====], [====[motion.pending[coin] = {t = now + 0.55, gap = gap}]====], "Under Map: retentativa de coleta com espera menor")
mythicReplaceOnce([====[if now - motion.dwellFrom >= 0.1 + (coin == gun and 0.25 or 0) then]====], [====[if now - motion.dwellFrom >= 0.08 + (coin == gun and 0.25 or 0) then]====], "Under Map: confirmacao de contato mais curta")
mythicFlushPatches()

-- v38: consolidar controle de movimento depois de todos os patches anteriores.
-- Nao sobrescrever a categoria Server restaurada.
local function mythicReplaceWholeFunction(head, nextHead, code, title)
    local a = string.find(source, head, 1, true)
    local b = a and string.find(source, nextHead, a + #head, true)
    if not a or not b then
        failLoader(title .. ": funcao nao encontrada")
        return
    end
    local previous = string.sub(source, a, b - 1)
    -- Manter o separador da proxima funcao intacto.
    mythicReplaceOnce(previous, code .. "\n", title)
end
mythicReplaceWholeFunction(
    "function FarmMotion.fast(context, state, motion, options)",
    "\nfunction FarmMotion.setTouch(context, state, motion, target, now)",
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = 24
	-- Busca apenas moedas disponiveis, ordenando pela distancia REAL ao personagem.
	-- Reavalia rapidamente para nao passar direto por grupos de moedas proximas.
	motion.fastRecent = motion.fastRecent or {}
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Nao varre o mapa na aproximacao final: termina a coleta sem mudar de rota.
		local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
		local interval = 0.035
		if not coin and now - (motion.pickT or 0) >= interval then
			motion.pickT = now
			local best, bestDistanceSq
			local origin = root.Position
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate)
						or (motion.skip[candidate] or 0) >= now or motion.pending[candidate]
						or (motion.fastRecent[candidate] or 0) > now then continue end
					-- Calcula custo de seguranca apenas para candidatas realmente mais proximas.
					local offset = candidate.Position - origin
					local d2 = offset:Dot(offset)
					if not bestDistanceSq or d2 < bestDistanceSq then
						if not state.avoidMurder or FarmMotion.murderPenalty(state, candidate.Position, murderer) < 1000000 then
							best, bestDistanceSq = candidate, d2
						end
					end
				end
			end
			if best and best ~= coin then
				local bestDistance = math.sqrt(bestDistanceSq)
				local unsafe = coin and state.avoidMurder
					and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000
				-- Perto do contato termina a coleta; longe, uma moeda mais proxima vence.
				local canSwitch = not coin or unsafe or
					(currentDistance > 3.5 and bestDistance + math.max(1.4, currentDistance * 0.10) < currentDistance
					and now - (motion.fastSwitchedAt or -1) >= 0.18)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Descartar apenas direcao antiga; nao aplicar impulso contrario.
					motion.fastLastVelocity, motion.fastProgressTarget, motion.fastLastTarget = nil, nil, nil
				end
			elseif not best and coin and state.avoidMurder
				and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000 then
				motion.coin, coin = nil, nil
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, sem impulso contrario.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Fast fixo em 24: sem oscilacao nem mudanca de velocidade durante a rota.
	-- Remove verificacoes custosas que atrasavam a coleta em alguns celulares.
	local actualSpeed = 24
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			-- Seguir diretamente a direcao atual; sem arrastar o vetor anterior.
			velocity.Velocity = desired
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	if not inContact then motion.fastContactCoin = nil end
	if distance < 4 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= 0.22) then
		FarmMotion.touch(context, character, target)
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance < 1 then
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		-- Curta confirmacao de contato, sem travar a proxima escolha.
		local coinDwell = 0.02
		if now - motion.dwellFrom >= (target == gun and 0.25 or coinDwell) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Bloqueio breve: nao retorna a moeda antiga, mas recupera toque falho.
				motion.fastRecent[target] = now + 1.25
				motion.pending[target] = {t = now + 1.10, fast = true}
			end
			-- Limpa orientacao armazenada, sem zerar o movimento no quadro.
			motion.fastLastVelocity, motion.fastLastTarget = nil, nil
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.1 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end]====],
    "Fast v38: rotas sem retarget durante movimento, sem retorno a moeda recente")
mythicReplaceWholeFunction(
    "function FarmMotion.underMap(context, state, motion, options)",
    "\nfunction FarmMotion.fast(context, state, motion, options)",
    [====[function FarmMotion.underMap(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local murderer, gun = options.murderer, options.gun
	local speed = math.clamp(tonumber(context.configuration.farm.speed) or 23, 8, 23)
	local coin = motion.coin
	if gun then coin = gun end
	if not gun then
		if coin and not FarmState.validCoin(context, state, coin) then
			if motion.phase == "rise" and motion.riseFrom then
				table.insert(motion.learn, coin.Position.Y - root.Position.Y)
				if #motion.learn > 60 then table.remove(motion.learn, 1) end
			end
			motion.got, motion.coin, motion.phase, coin = motion.got + 1, nil, "go", nil
		end
		-- Mantem a moeda atual ate terminar o toque ou detectar invalidez.
		if not coin and now - (motion.pickT or 0) >= 0.025 then
			motion.pickT = now
			local candidate = FarmMotion.choose(context, state, motion, root.Position, murderer, now)
			if candidate then
				motion.coin, motion.phase, motion.goT, motion.tries, coin =
					candidate, "go", now, motion.tries + 1, candidate
			end
		end
	end
	if not coin then
		FarmMotion.move(context, root, velocity, gyro, FarmMotion.hideAt(context, state, motion, root, now), options.delta, speed)
		motion.phase = "wait"
		return
	end
	local info = FarmMotion.coinInfo(context, state, motion, coin, now)
	if motion.phase ~= "rise" then
		if motion.phase ~= "go" then motion.phase, motion.goT = "go", now end
		local force = state.firstJump and coin ~= gun
		if force then state.firstJump = false end
		FarmMotion.jump(context, motion, root, info.hide, force, now)
		local distance = FarmMotion.move(context, root, velocity, gyro, info.hide, options.delta, speed)
		if distance < 0.7 then motion.phase, motion.riseFrom, motion.dwellFrom = "rise", now, nil; return end
		if now - (motion.goT or now) > distance / math.max(speed, 1) + 4 then
			FarmMotion.skip(context, state, coin)
			motion.coin, motion.gunTarget, motion.fails, motion.phase = nil, nil, motion.fails + 1, "go"
		end
		return
	end
	if murderer and coin ~= gun then
		local distance = context.environment.Vector3.new(coin.Position.X - murderer.X, 0, coin.Position.Z - murderer.Z).Magnitude
		if distance < 12 then motion.skip[coin], motion.coin, motion.phase = now + 3, nil, "go"; return end
	end
	local attempts = motion.att[coin] or 0
	local gap = math.max(0.6, motion.gapT - 0.45 * attempts)
	local ascent = math.min(math.max(coin.Position.Y - gap, info.hide.Y), info.surf - 2.8)
	local destination = context.environment.Vector3.new(info.hide.X, ascent, info.hide.Z)
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, speed)
	if now - (motion.touchAt or 0) >= 1 / 24 then motion.touchAt = now; FarmMotion.touch(context, character, coin) end
	if distance < 0.3 then
		motion.dwellFrom = motion.dwellFrom or now
		if now - motion.dwellFrom >= 0.045 + (coin == gun and 0.25 or 0) then
			motion.att[coin] = attempts + 1
			if attempts + 1 >= 4 then FarmMotion.skip(context, state, coin); motion.fails += 1 end
			if attempts + 1 < 4 then motion.pending[coin] = {t = now + 0.48, gap = gap} end
			if coin == gun then motion.gunTarget = nil end
			motion.coin, motion.dwellFrom, motion.phase = nil, nil, "go"
			return
		end
	end
	if now - (motion.riseFrom or now) > 1.1 then
		FarmMotion.skip(context, state, coin)
		if coin == gun then motion.gunTarget = nil end
		motion.coin, motion.fails, motion.phase = nil, motion.fails + 1, "go"
	end
end]====],
    "Under v38: seguir sob piso e selecionar moeda apenas ao concluir alvo")
mythicFlushPatches()

-- MYTHIC SERVER v39: desfazer o deslocamento da aba que impedia o layout original.
local earlyStart = "\t-- Instala Server cedo: as outras funcoes nao devem bloquear a aba."
local earlyTail = "\n\tlocal main = PulseTab.create(environment, hub, \"Main\", \"home\", context)"
local earlyA = string.find(source, earlyStart, 1, true)
local earlyB = earlyA and string.find(source, earlyTail, earlyA + #earlyStart, true)
if not earlyA or not earlyB then
    failLoader("Server: posicao antecipada da aba nao encontrada")
end
mythicReplaceOnce(string.sub(source, earlyA, earlyB - 1), "", "Server: desfazer instalacao antecipada")
mythicFlushPatches()

-- Restaurar os controles e a lista de mapas do codigo original, com rolagem mobile.
restorePulseServerSection(
    "function ServerIdentity.MapVote.controls(state)",
    "\nfunction ServerIdentity.MapVote.install(context)",
    [====[function ServerIdentity.MapVote.controls(state)
	local context, vote = state.context, ServerIdentity.MapVote
	local section = context.section
	section:Group({Title = "Map Vote", Side = "Left"})
	state.rows = vote.rows(state, section:Container(), false)
	state.countSlider = section:Slider({Text = "Votes to add", Min = 1, Max = 100, Default = state.cfg.count, Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 10), 1, 100) end})
	section:Button({Text = "Dupe Votes", Callback = function() vote.start(state, state.sel or 1) end})
	section:Button({Text = "Stop", Callback = function() state.stop = true end})
	state.statusLabel = section:Note({Text = "Waiting for vote"})
	section:Toggle({Text = "Vote Panel", Default = state.cfg.panel ~= false, Callback = function(value) state.cfg.panel = not not value end})
	section:Toggle({Text = "Silent Respawn", Default = state.cfg.silent ~= false, Callback = function(value) state.cfg.silent = not not value end})
	section:Group({Title = "Auto Dupe", Side = "Right"})
	section:Toggle({Text = "Auto Dupe", Default = state.cfg.auto == true, Callback = function(value)
		state.cfg.auto = not not value
		if value then context.environment.task.defer(vote.autoStart, state) end
	end})
	section:Toggle({Text = "Farm Priority", Default = state.cfg.farmSort == true, Callback = function(value)
		state.cfg.farmSort = not not value
		if value then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Toggle({Text = "Explore Maps", Default = state.cfg.explore == true, Callback = function(value)
		state.cfg.explore = not not value
		if state.cfg.farmSort then pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm")) end
		vote.renderPriority(state)
	end})
	section:Dropdown({Text = "Other maps", Default = state.cfg.fallback, Options = {
		{code = "skip", label = "Don't dupe"}, {code = "leading", label = "Dupe most voted"}, {code = "first", label = "Dupe first map"}},
		Callback = function(value) state.cfg.fallback = value end})
	section:Header("Map Priority", "Right")
	local container = section:Container()
	if container then
		local environment = context.environment
		-- Lista antiga por mapa, com scroll para caber na tela do celular.
		local list = context.create("ScrollingFrame", {
			Name = "PrioList", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = environment.UDim2.new(1, 0, 0, 288),
			CanvasSize = environment.UDim2.fromOffset(0, 0),
			ScrollBarThickness = 5,
			ScrollingDirection = environment.Enum.ScrollingDirection.Y,
			ScrollingEnabled = true, Active = true, ClipsDescendants = true,
			ScrollBarImageColor3 = environment.Color3.fromRGB(169, 86, 222),
		}, container)
		state.priorityList = list
		local layout = context.create("UIListLayout", {
			Padding = environment.UDim.new(0, 4),
			SortOrder = environment.Enum.SortOrder.LayoutOrder,
		}, list)
		local function refreshHeight()
			if list.Parent then
				list.CanvasSize = environment.UDim2.fromOffset(0,
					math.max(1, layout.AbsoluteContentSize.Y + 12))
			end
		end
		context.connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), refreshHeight)
		vote.renderPriority(state)
		environment.task.defer(refreshHeight)
	end
	section:Button({Text = "Reset Priority", Callback = function() vote.resetPriority(state) end})
end]====],
    "Server: controles originais do Pulse Hub com lista rolavel")
restorePulseServerSection(
    "function ServerIdentity.MapVote.priorityRow(state, parent, map)",
    "\nfunction ServerIdentity.MapVote.renderPriority(state)",
    [====[function ServerIdentity.MapVote.priorityRow(state, parent, map)
	local context, environment = state.context, state.context.environment
	local create, enum = context.create, environment.Enum
	local row = create("Frame", {Name = "Map_" .. map.key, Size = environment.UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = environment.Color3.fromRGB(34, 37, 45), BorderSizePixel = 0, ZIndex = 3}, parent)
	context.corner(row, 8)
	local rank = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(4, 0),
		Size = environment.UDim2.fromOffset(20, 32), Text = "", Font = enum.Font.GothamBold, TextSize = 12,
		TextColor3 = environment.Color3.fromRGB(214, 68, 88), ZIndex = 4}, row)
	local image = create("ImageLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(28, 4),
		Size = environment.UDim2.fromOffset(44, 24), Image = "", ScaleType = enum.ScaleType.Crop, ZIndex = 4}, row)
	context.corner(image, 6)
	local label = create("TextLabel", {BackgroundTransparency = 1, Position = environment.UDim2.fromOffset(80, 0),
		Size = environment.UDim2.new(1, -168, 1, 0), Text = map.name, Font = enum.Font.GothamSemibold, TextSize = 12,
		TextXAlignment = enum.TextXAlignment.Left, TextTruncate = enum.TextTruncate.AtEnd,
		TextColor3 = environment.Color3.new(1, 1, 1), ZIndex = 4}, row)
	local function button(text, offset, callback)
		local object = create("TextButton", {AnchorPoint = environment.Vector2.new(1, 0.5),
			Position = environment.UDim2.new(1, offset, 0.5, 0), Size = environment.UDim2.fromOffset(20, 24),
			Text = text, Font = enum.Font.GothamBold, TextSize = 14, BackgroundTransparency = 1,
			TextColor3 = environment.Color3.fromRGB(170, 175, 188), ZIndex = 5}, row)
		context.connect(object.MouseButton1Click, callback)
		return object
	end
	local function move(delta)
		local order = state.cfg.order
		local index = table.find(order, map.key)
		local target = index and index + delta
		if not target or target < 1 or target > #order then return end
		order[index], order[target] = order[target], order[index]
		ServerIdentity.MapVote.renderPriority(state)
	end
	local up = button("↑", -100, function() move(-1) end)
	local down = button("↓", -73, function() move(1) end)
	local toggle = button("", -8, function()
		state.cfg.off[map.key] = state.cfg.off[map.key] ~= true and true or nil
		ServerIdentity.MapVote.renderPriority(state)
	end)
	toggle.Size = environment.UDim2.fromOffset(44, 24)
	return {frame = row, rank = rank, image = image, label = label, up = up, down = down, toggle = toggle}
end]====],
    "Server: botoes individuais e setas legiveis")
restorePulseServerSection(
    "function ServerIdentity.MapVote.renderPriority(state)",
    "\nfunction ServerIdentity.MapVote.resetPriority(state)",
    [====[function ServerIdentity.MapVote.renderPriority(state)
	if not state.priorityList then return end
	local vote = ServerIdentity.MapVote
	local signature = {}
	for _, key in state.cfg.order do
		table.insert(signature, key .. ":" .. tostring(state.cfg.off[key] == true) .. ":" .. tostring(vote.icon(state, key)))
	end
	signature = table.concat(signature, "|")
	if signature == state.prioritySignature then return end
	state.priorityRows = state.priorityRows or {}
	local rank = 0
	for index, key in state.cfg.order do
		local map = state.maps[key]
		if not map then continue end
		local row = state.priorityRows[key]
		if not row then
			row = vote.priorityRow(state, state.priorityList, map)
			state.priorityRows[key] = row
		end
		local off = state.cfg.off[key] == true
		if not off then rank += 1 end
		row.frame.LayoutOrder = index
		row.rank.Text = off and "В·" or tostring(rank)
		row.image.Image = vote.icon(state, key) or ""
		row.image.ImageTransparency = off and 0.6 or 0
		row.label.TextTransparency = off and 0.5 or 0
		row.up.TextTransparency = index == 1 and 0.7 or 0
		row.down.TextTransparency = index == #state.cfg.order and 0.7 or 0
		row.toggle.Text = off and "NÃO" or "SIM"
	end
	state.prioritySignature = signature
end]====],
    "Server: atualizar status SIM e NAO ao clicar")
mythicFlushPatches()

-- A aba Server retorna ao local original entre MYTHIC Users e Troll Fun.
local oldFun = "\tlocal fun = PulseTab.create(environment, hub, \"Troll Fun\", \"face-winking\", context)"
if not string.find(source, oldFun, 1, true) then
    failLoader("Server: posicao original antes de Troll Fun nao encontrada")
end
mythicReplaceOnce(
    oldFun,
    [====[	local server = PulseTab.create(environment, hub, "Server", "globe-simplified", context)
	server:Columns()
	server:Group({Title = "Server", Side = "Left"})
	local okServer, errServer = pcall(ServerIdentity.install, {environment = environment, translation = translation, section = server, connect = connect,
		create = create, round = nova.U.corner, nova = nova,
		players = players, player = players.LocalPlayer, isAlive = function() return not window.Destroyed end})
	if not okServer then
		environment.warn("MYTHIC-HUB Server: " .. tostring(errServer))
		pcall(function() server:Note({Text = "Falha ao carregar controles de servidor. Confira o console."}) end)
	end
	local okVote, voteState, stopMapVote = pcall(ServerIdentity.MapVote.install, {environment = environment, configuration = settings, section = server,
		translation = translation, workspace = workspace, player = players.LocalPlayer, runService = runService,
		window = window, inputService = inputService, tweenService = game:GetService("TweenService"),
		create = create, corner = nova.U.corner, nova = nova, connect = connect,
		applyHooks = context.applyHooks, isAlive = function() return not window.Destroyed end})
	if not okVote then
		environment.warn("MYTHIC-HUB MapVote: " .. tostring(voteState))
		pcall(function() server:Note({Text = "Falha ao carregar Map Vote. Confira o console."}) end)
	end
	local fun = PulseTab.create(environment, hub, "Troll Fun", "face-winking", context)]====],
    "Server: reinstalar no lugar original depois das demais categorias")
mythicFlushPatches()

-- MYTHIC VOTE DUPE: reativar o loop de votos por respawn.
mythicReplaceOnce(
    [====[section:Button({Text = "Votar (1x)", Callback = function() vote.start(state, state.sel or 1) end})]====],
    [====[section:Button({Text = "Dupe Votes", Callback = function()
        local count = math.clamp(math.floor(tonumber(state.cfg.count) or 10), 1, 100)
        state.context.environment.task.spawn(ServerIdentity.MapVote.run, state, state.sel or 1, count)
    end})]====],
    "VoteDupe: botão")
mythicReplaceOnce(
    [====[state.countSlider = section:Slider({Text = "Selecoes por mapa", Min = 1, Max = 999, Default = math.clamp(tonumber(state.cfg.count) or 5, 1, 999), Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 5), 1, 999) end})]====],
    [====[state.countSlider = section:Slider({Text = "Votes to add", Min = 1, Max = 100, Default = state.cfg.count, Decimals = 0,
		Callback = function(value) state.cfg.count = math.clamp(math.floor(tonumber(value) or 10), 1, 100) end})]====],
    "VoteDupe: slider")
mythicReplaceOnce(
    [====[section:Toggle({Text = "Selecionar mapa (sem TP)", Default = state.cfg.auto == true, Callback = function(value)
		state.cfg.auto = not not value
		if value then context.environment.task.defer(vote.autoStart, state) end
	end})]====],
    [====[section:Toggle({Text = "Auto Dupe", Default = state.cfg.auto == true, Callback = function(value)
		state.cfg.auto = not not value
		if value then context.environment.task.defer(vote.autoStart, state) end
	end})]====],
    "VoteDupe: toggle")
local dupeHead = "function ServerIdentity.MapVote.autoStart(state)"
local dupeTail = "\nfunction ServerIdentity.MapVote.observe(state)"
local da = string.find(source, dupeHead, 1, true)
local db = da and string.find(source, dupeTail, da + #dupeHead, true)
if da and db then
    mythicReplaceOnce(string.sub(source, da, db - 1), [====[
function ServerIdentity.MapVote.autoStart(state)
    if state.closed or state.autoRan or state.busy or state.cfg.auto ~= true or state.autoStarting then return end
    local vote, context = ServerIdentity.MapVote, state.context
    local clock = context.environment.os.clock
    if clock() < (state.autoRetryAt or 0) then return end
    state.autoStarting = true
    local started = clock()
    local pads, active
    repeat
        if state.closed or state.cfg.auto ~= true then
            state.autoStarting = false
            return
        end
        pads, active = vote.snapshot(state)
        local ready = false
        if active then
            for index = 1, 3 do
                local pad = pads[index]
                if pad and pad.active and not pad.idle
                    and pad.name ~= "" and pad.name ~= "MAP NAME" then
                    ready = true
                    break
                end
            end
        end
        if ready or clock() - started >= 1.2 then break end
        context.runService.Heartbeat:Wait()
    until false
    state.autoStarting = false
    if state.closed or state.autoRan or state.busy or state.cfg.auto ~= true then return end
    if not active then
        state.status = "Aguardando votacao"
        state.autoRetryAt = clock() + 0.5
        return
    end
    for index = 1, 3 do
        local pad = pads[index]
        if pad and pad.active and not pad.idle
            and pad.name ~= "" and pad.name ~= "MAP NAME" then
            vote.discover(state, pad.name, pad.icon, clock())
        end
    end
    if state.cfg.farmSort == true then
        pcall(vote.sortFarm, state, rawget(context.environment.getgenv(), "__pulseMapFarm"))
        vote.renderPriority(state)
    end
    local chosen = vote.choose(state, pads)
    if not chosen then
        state.status = "Nenhum mapa habilitado nesta votacao"
        state.autoRetryAt = clock() + 0.5
        return
    end
    state.sel, state.autoRan = chosen, true
    local count = math.clamp(math.floor(tonumber(state.cfg.count) or 10), 1, 100)
    state.status = "Duplicando " .. tostring(count) .. " votos em " .. tostring(pads[chosen].name)
    context.environment.task.spawn(vote.run, state, chosen, count)
end
]====], "VoteDupe: autoStart volta a votar")
else
    warn("MYTHIC-HUB VoteDupe: autoStart nao encontrado; original preservada.")
end
mythicFlushPatches()
-- v41: mais contatos efetivos em ping alto sem voltar a moeda anterior.
mythicReplaceWholeFunction(
    "function FarmMotion.fast(context, state, motion, options)",
    "\nfunction FarmMotion.setTouch(context, state, motion, target, now)",
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = 24
	-- Ping informado pelo proprio cliente: amostra a cada dois segundos.
	-- Nao aumenta a velocidade do personagem nem cria movimento de retorno.
	if now - (motion.fastPingReadAt or -math.huge) >= 2 then
		motion.fastPingReadAt = now
		local success, seconds = pcall(function() return context.player:GetNetworkPing() end)
		if success and type(seconds) == "number" and seconds >= 0 then
			motion.fastPingMs = math.clamp(seconds * 2000, 0, 1200)
		end
	end
	local highPing = (motion.fastPingMs or 0) >= 180
	-- Busca apenas moedas disponiveis, ordenando pela distancia REAL ao personagem.
	-- Reavalia rapidamente para nao passar direto por grupos de moedas proximas.
	motion.fastRecent = motion.fastRecent or {}
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Nao varre o mapa na aproximacao final: termina a coleta sem mudar de rota.
		local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
		local interval = 0.035
		if not coin and now - (motion.pickT or 0) >= interval then
			motion.pickT = now
			local best, bestDistanceSq
			local origin = root.Position
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate)
						or (motion.skip[candidate] or 0) >= now or motion.pending[candidate]
						or (motion.fastRecent[candidate] or 0) > now then continue end
					-- Calcula custo de seguranca apenas para candidatas realmente mais proximas.
					local offset = candidate.Position - origin
					local d2 = offset:Dot(offset)
					if not bestDistanceSq or d2 < bestDistanceSq then
						if not state.avoidMurder or FarmMotion.murderPenalty(state, candidate.Position, murderer) < 1000000 then
							best, bestDistanceSq = candidate, d2
						end
					end
				end
			end
			if best and best ~= coin then
				local bestDistance = math.sqrt(bestDistanceSq)
				local unsafe = coin and state.avoidMurder
					and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000
				-- Perto do contato termina a coleta; longe, uma moeda mais proxima vence.
				local canSwitch = not coin or unsafe or
					(currentDistance > 3.5 and bestDistance + math.max(1.4, currentDistance * 0.10) < currentDistance
					and now - (motion.fastSwitchedAt or -1) >= 0.18)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Descartar apenas direcao antiga; nao aplicar impulso contrario.
					motion.fastLastVelocity, motion.fastProgressTarget, motion.fastLastTarget = nil, nil, nil
				end
			elseif not best and coin and state.avoidMurder
				and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000 then
				motion.coin, coin = nil, nil
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, sem impulso contrario.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Fast fixo em 24: sem oscilacao nem mudanca de velocidade durante a rota.
	-- Remove verificacoes custosas que atrasavam a coleta em alguns celulares.
	local actualSpeed = 24
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			-- Seguir diretamente a direcao atual; sem arrastar o vetor anterior.
			velocity.Velocity = desired
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	local touchInterval = highPing and 0.06 or 0.12
	if not inContact then motion.fastContactCoin = nil end
	if distance < (highPing and 3.0 or 2.8) and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= touchInterval) then
		FarmMotion.touch(context, character, target)
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance <= (highPing and 1.8 or 1.4) then
		-- Segurar o contato por alguns quadros evita atravessar a moeda em FPS baixo.
		-- Imobiliza apenas na area de contato; nao aplica velocidade oposta.
		if target ~= gun then velocity.Velocity = context.environment.Vector3.zero end
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		-- Curta confirmacao de contato, sem travar a proxima escolha.
		local coinDwell = highPing and 0.02 or 0.025
		if now - motion.dwellFrom >= (target == gun and 0.25 or coinDwell) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Bloqueio breve: nao retorna a moeda antiga, mas recupera toque falho.
				motion.fastRecent[target] = now + 1.25
				motion.pending[target] = {t = now + 1.10, fast = true}
			end
			-- Limpa orientacao armazenada, sem zerar o movimento no quadro.
			motion.fastLastVelocity, motion.fastLastTarget = nil, nil
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.1 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end]====],
    "Fast v41: tempo de contato adaptado ao ping")
mythicFlushPatches()

-- v44: moedas nas laterais e escolha de alvo proximo, mantendo Fast 24 e pausa 0,02.
mythicReplaceWholeFunction(
    "function FarmMotion.fast(context, state, motion, options)",
    "\nfunction FarmMotion.setTouch(context, state, motion, target, now)",
    [====[function FarmMotion.fast(context, state, motion, options)
	local now, root, velocity, gyro, character = options.time, options.root, options.velocity, options.gyro, options.character
	local gun, murderer = options.gun, options.murderer
	local speed = 24
	-- Busca apenas moedas disponiveis, ordenando pela distancia REAL ao personagem.
	-- Reavalia rapidamente para nao passar direto por grupos de moedas proximas.
	motion.fastRecent = motion.fastRecent or {}
	local coin = motion.coin
	if coin and coin ~= gun and (not FarmState.validCoin(context, state, coin) or motion.pending[coin]) then
		if not FarmState.validCoin(context, state, coin) then motion.got += 1 end
		motion.coin, coin, motion.pickT, motion.fastContactCoin = nil, nil, 0, nil
	end
	local target = gun
	if not target then
		-- Reavaliar tambem alvos distantes: uma moeda ao lado nao deve ficar invisivel
		-- enquanto percorremos uma rota longa. Trava perto da coleta para nao puxar.
		local currentDistance = coin and (coin.Position - root.Position).Magnitude or math.huge
		local interval = coin and 0.11 or 0.025
		local mayReview = not coin or (currentDistance > 4.2
			and now - (motion.fastSwitchedAt or -math.huge) >= 0.24)
		if mayReview and now - (motion.pickT or 0) >= interval then
			motion.pickT = now
			local best, bestDistanceSq
			local origin = root.Position
			for _, container in FarmMotion.containers(context, state, motion, now) do
				if not container.Parent then continue end
				for _, candidate in container:GetChildren() do
					if not FarmState.validCoin(context, state, candidate)
						or (motion.skip[candidate] or 0) >= now or motion.pending[candidate]
						or (motion.fastRecent[candidate] or 0) > now then continue end
					-- Calcula custo de seguranca apenas para candidatas realmente mais proximas.
					local offset = candidate.Position - origin
					-- Ignorar candidatas ja deixadas para tras; evita retorno.
					if coin and candidate ~= coin then
						local forward = coin.Position - origin
						if offset:Dot(forward) < -currentDistance then continue end
					end
					local d2 = offset:Dot(offset)
					if not bestDistanceSq or d2 < bestDistanceSq then
						if not state.avoidMurder or FarmMotion.murderPenalty(state, candidate.Position, murderer) < 1000000 then
							best, bestDistanceSq = candidate, d2
						end
					end
				end
			end
			if best and best ~= coin then
				local bestDistance = math.sqrt(bestDistanceSq)
				local unsafe = coin and state.avoidMurder
					and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000
				-- Perto do contato termina a coleta; longe, uma moeda mais proxima vence.
				local canSwitch = not coin or unsafe or
					(currentDistance > 4.2
					and bestDistance + math.max(1.25, currentDistance * 0.16) < currentDistance
					and now - (motion.fastSwitchedAt or -math.huge) >= 0.24)
				if canSwitch then
					motion.coin, motion.goT, motion.tries, coin = best, now, motion.tries + 1, best
					motion.fastSwitchedAt = now
					-- Descartar apenas direcao antiga; nao aplicar impulso contrario.
					motion.fastLastVelocity, motion.fastProgressTarget, motion.fastLastTarget = nil, nil, nil
				end
			elseif not best and coin and state.avoidMurder
				and FarmMotion.murderPenalty(state, coin.Position, murderer) >= 1000000 then
				motion.coin, coin = nil, nil
			end
		end
		target = coin
	end
	if not target then velocity.Velocity, motion.phase = context.environment.Vector3.zero, "wait"; return end
	motion.phase = "go"
	local force = state.firstJump and target ~= gun
	if force then state.firstJump = false end
	-- Sem teleporte inicial forcado no Fast: evita correcao brusca de posicao do servidor.
	if force then motion.goT = now end
	local destination = target.Position
	local distanceToTarget = (destination - root.Position).Magnitude
	-- Detecta correcoes externas sem manter a velocidade reduzida por segundos.
	if motion.fastLastTarget == target and motion.fastLastPos and motion.fastLastAt
		and now - motion.fastLastAt <= 0.35 and distanceToTarget > 1 then
		local displacement = root.Position - motion.fastLastPos
		if displacement.Magnitude > 2.5
			and displacement:Dot(destination - root.Position) < -2 * distanceToTarget then
			-- Reinicia apenas a referencia de movimento, sem impulso contrario.
			motion.fastLastVelocity, motion.fastProgressTarget = nil, nil
		end
	end
	motion.fastLastTarget, motion.fastLastPos, motion.fastLastAt = target, root.Position, now
	-- Fast fixo em 24: sem oscilacao nem mudanca de velocidade durante a rota.
	-- Remove verificacoes custosas que atrasavam a coleta em alguns celulares.
	local actualSpeed = 24
	motion.fastSpeedApplied = actualSpeed
	local distance = FarmMotion.move(context, root, velocity, gyro, destination, options.delta, actualSpeed)
	-- Capturar moedas que passam ao lado da rota sem obrigar o personagem
	-- a voltar. A confirmacao de coleta continua sendo responsabilidade do jogo.
	if target ~= gun and now - (motion.fastNearbyScanAt or -math.huge) >= 0.15 then
		motion.fastNearbyScanAt = now
		local nearby, nearbySq
		local origin = root.Position
		for _, container in FarmMotion.containers(context, state, motion, now) do
			if not container.Parent then continue end
			for _, candidate in container:GetChildren() do
				if candidate ~= target and FarmState.validCoin(context, state, candidate)
					and not motion.pending[candidate] and (motion.skip[candidate] or 0) < now
					and (motion.fastRecent[candidate] or 0) <= now then
					local offset = candidate.Position - origin
					local d2 = offset:Dot(offset)
					if d2 <= 4 and (not nearbySq or d2 < nearbySq) then
						nearby, nearbySq = candidate, d2
					end
				end
			end
		end
		if nearby then
			motion.fastNearbyTouches = motion.fastNearbyTouches or setmetatable({}, {__mode = "k"})
			if now - (motion.fastNearbyTouches[nearby] or -math.huge) >= 0.12 then
				motion.fastNearbyTouches[nearby] = now
				FarmMotion.touch(context, character, nearby)
			end
		end
	end
	-- Nao carregar direcao velha ao virar. Na mesma direcao, filtragem leve.
	if distance > 3 then
		local desired, previous = velocity.Velocity, motion.fastLastVelocity
		if previous and previous:Dot(desired) > 0 then
			-- Seguir diretamente a direcao atual; sem arrastar o vetor anterior.
			velocity.Velocity = desired
		end
		motion.fastLastVelocity = velocity.Velocity
	else
		motion.fastLastVelocity = nil
	end
	-- Primeiro toque na aproximacao e um segundo toque ao entrar em contato.
	-- Em FPS baixo, o toque feito a 4 studs pode ocorrer antes do contato real.
	local inContact = distance <= 1.75
	local touchInterval = 0.06
	if not inContact then motion.fastContactCoin = nil end
	if distance < 3.0 and (motion.fastTouchedCoin ~= target
		or (inContact and motion.fastContactCoin ~= target)
		or now - (motion.fastTouchAt or 0) >= touchInterval) then
		FarmMotion.touch(context, character, target)
		motion.fastTouchedCoin, motion.fastTouchAt = target, now
		if inContact then motion.fastContactCoin = target end
	end
	if distance <= 1.8 then
		-- Segurar o contato por alguns quadros evita atravessar a moeda em FPS baixo.
		-- Imobiliza apenas na area de contato; nao aplica velocidade oposta.
		if target ~= gun then velocity.Velocity = context.environment.Vector3.zero end
		if motion.fastDwellTarget ~= target then
			motion.fastDwellTarget, motion.dwellFrom = target, now
		end
		-- Curta confirmacao de contato, sem travar a proxima escolha.
		local coinDwell = 0.015
		if now - motion.dwellFrom >= (target == gun and 0.25 or coinDwell) then
			if target == gun then motion.gunTarget = nil end
			if target ~= gun then
				-- Bloqueio breve: nao retorna a moeda antiga, mas recupera toque falho.
				motion.fastRecent[target] = now + 1.25
				motion.pending[target] = {t = now + 1.10, fast = true}
			end
			-- Limpa orientacao armazenada, sem zerar o movimento no quadro.
			motion.fastLastVelocity, motion.fastLastTarget = nil, nil
			motion.coin, motion.dwellFrom, motion.fastDwellTarget, motion.pickT = nil, nil, nil, 0
		end
		return
	end
	motion.fastDwellTarget = nil
	motion.dwellFrom = nil
	-- Desistencia somente quando nao avanca na direcao do alvo por 2.5s.
	if motion.fastProgressTarget ~= target then
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = target, distance, now
	elseif distance + 0.55 < (motion.fastBestDistance or math.huge) then
		motion.fastBestDistance, motion.fastProgressAt = distance, now
	end
	if distance > 3 and now - (motion.fastProgressAt or now) > 2.1 then
		if target == gun then
			motion.gunTarget = nil
		else
			motion.skip[target] = now + 1
		end
		motion.coin, motion.fails, motion.pickT = nil, motion.fails + 1, 0
		motion.fastProgressTarget, motion.fastBestDistance, motion.fastProgressAt = nil, nil, nil
	end
end]====],
    "Fast v44: checar moedas proximas sem retornar")
mythicFlushPatches()

-- v49: ativacao mais responsiva depois do carregamento ou da troca de modos.
-- Mantem as condicoes existentes de rodada e cargos; nao cria movimento
-- enquanto a partida ou os objetos do mapa nao forem reconhecidos.
mythicReplaceOnce(
    [====[if now - runtime.roundAt >= 0.5 then]====],
    [====[if now - runtime.roundAt >= (state.enabled and not state.active and 0.18 or 0.5) then]====],
    "Farm: conferir inicio da rodada mais cedo ao ativar")
mythicReplaceOnce(
    [====[if now - state.containersAt < (hasLive and 1.5 or 0.45) then return state.containers end]====],
    [====[if now - state.containersAt < (hasLive and 1.5 or (state.enabled and 0.25 or 0.45)) then return state.containers end]====],
    "Farm: detectar o mapa mais cedo quando ativado")
mythicFlushPatches()

-- MYTHIC TELEPORT v52: esperar sob o mapa e encadear moedas sem voltar ao lobby.
mythicReplaceOnce(
    [====[function FarmMotion.teleport(context, state, motion, options)
	local now, root, velocity, character, gun =
		options.time, options.root, options.velocity, options.character, options.gun
	local teleport = motion.tp
	local env = context.environment

	-- Garantir que forcadores de velocidade do modo anterior nao persistam.
	for _, name in {"PulseFarmBV", "PulseFarmBG"} do
		local mover = root:FindFirstChild(name)
		if mover then mover:Destroy() end
	end
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.PlatformStand then
		humanoid.PlatformStand = false
		humanoid:ChangeState(env.Enum.HumanoidStateType.GettingUp)
	end

	-- Ponto base: onde o personagem fica esperando entre coletas.
	-- Inicializado na primeira chamada do modo Teleporte nesta rodada.
	if not teleport.base then
		teleport.base = root.CFrame
	end

	velocity.Velocity = env.Vector3.zero

	-- Atualizar a referencia de posicao usada pelo calculo de intervalo.
	FarmMotion.teleportReference(context, state, motion, root, now, options.tickTime)

	-- Voltar para a base silenciosamente (sem animacao).
	local function returnBase(phase)
		motion.phase = phase or "wait"
		root.CFrame = teleport.base
		root.AssemblyLinearVelocity = env.Vector3.zero
	end

	-- Verificar se a moeda atual foi coletada ou ficou invalida.
	local coin = teleport.coin
	if coin then
		local isGun = coin == gun
		local collected = isGun
			and (coin.Parent == nil or options.hasGun)
			or (not isGun and not FarmState.validCoin(context, state, coin))

		if collected then
			-- Registrar latencia real para calibrar o proximo intervalo.
			if not isGun and teleport.touching then
				if now > teleport.lastAt then teleport.lastAt = now end
				teleport.lastPos = coin.Position
				local lat = now - (teleport.at or now)
				if lat > 0 and lat < 0.6 then
					motion.tpLat = math.clamp(
						(motion.tpLat or 0.1) * 0.8 + lat * 0.2, 0.03, 0.3)
				end
				-- Pausa entre coletas: evita kicks por posicao invalida.
				-- Speed 26 = ~0.18s de espera; Speed 10 = ~0.46s.
				local speed = math.clamp(
					tonumber(context.configuration.farm.tpSpeed) or 26, 10, 26)
				teleport.nextAt = now + math.max(0.12, (27 - speed) * 0.017)
			end
			if isGun then motion.gunTarget = nil end
			if not isGun and coin:GetAttribute("Collected") then motion.got += 1 end
			teleport.coin, teleport.touching = nil, false
			returnBase("wait")
			return
		end

		-- Timeout: moeda valida mas nao coletada depois de 0.9s de toque.
		if teleport.touching and now - teleport.at > 0.9 then
			FarmMotion.skip(context, state, coin)
			motion.fails += 1
			if isGun then motion.gunTarget = nil end
			teleport.coin, teleport.touching = nil, false
			returnBase("wait")
			return
		end

		-- Sheriff pegou a arma em paralelo.
		if gun and not isGun then
			teleport.coin, teleport.touching = nil, false
			returnBase("wait")
			return
		end
	end

	-- Bolsa cheia: voltar para a posicao original do personagem.
	if options.full and not gun then
		local home = FarmMotion.home(context, motion, now) or teleport.start
		motion.phase = "full"
		if home then root.CFrame = home end
		root.AssemblyLinearVelocity = env.Vector3.zero
		return
	end

	-- Respeitar o intervalo entre coletas.
	if not gun and now < (teleport.nextAt or 0) then
		returnBase("wait")
		return
	end

	-- Escolher proxima moeda se nao houver alvo.
	if not teleport.coin then
		local target = gun or FarmMotion.teleportPick(
			context, state, motion, now, options.murderer, teleport.lastPos)
		if not target then
			returnBase("wait")
			return
		end
		local info = target == gun
			and {hide = target.Position}
			or FarmMotion.coinInfo(context, state, motion, target, now)
		teleport.coin     = target
		teleport.touching = false
		teleport.at       = now
		teleport.hide     = info.hide
		motion.tries     += 1
		FarmMotion.setTouch(context, state, motion, target, now)
		teleport.ctAt = now
	end

	coin = teleport.coin
	local isGun = coin == gun

	-- Manter o toque ativo enquanto espera confirmacao.
	if now - (teleport.ctAt or 0) > 0.1 then
		teleport.ctAt = now
		FarmMotion.setTouch(context, state, motion, coin, now)
	end

	-- Trocar para moeda mais proxima enquanto ainda nao tocou.
	if not isGun and not teleport.touching and now - (teleport.rpAt or 0) > 0.2 then
		teleport.rpAt = now
		local candidate, score, currentScore = FarmMotion.teleportPick(
			context, state, motion, now, options.murderer, teleport.lastPos, coin)
		if candidate and candidate ~= coin
			and (not currentScore or score + 2 < currentScore) then
			coin              = candidate
			teleport.coin     = candidate
			teleport.at       = now
			local info = FarmMotion.coinInfo(context, state, motion, candidate, now)
			teleport.hide     = info.hide
			FarmMotion.setTouch(context, state, motion, candidate, now)
			teleport.ctAt = now
		end
	end

	-- Salto instantaneo para a posicao subterranea da moeda.
	-- Este e o unico CFrame do modo; o personagem fica fixo aqui ate coletar.
	root.CFrame = env.CFrame.new(teleport.hide)
	root.AssemblyLinearVelocity = env.Vector3.zero

	-- Registrar toque e marcar como "tocando".
	if not teleport.touching then
		teleport.touching = true
		teleport.at       = now
	end
	teleport.touchC = coin
	teleport.touchT = now
	FarmMotion.touch(context, character, coin)
	motion.phase = "tp"
end
	local isGun = coin == gun
	if not isGun and not teleport.touching and now - (teleport.rpAt or 0) > 0.2 then
		teleport.rpAt = now
		local target, score, currentScore = FarmMotion.teleportPick(context, state, motion, now, options.murderer, teleport.lastPos, coin)
		if target and target ~= coin and (not currentScore or score + 2 < currentScore) then
			coin, teleport.coin, teleport.at = target, target, now
			teleport.hide = FarmMotion.coinInfo(context, state, motion, target, now).hide
			FarmMotion.setTouch(context, state, motion, target, now)
			teleport.ctAt = now
		end
	end
	local arrival = now
	if not isGun and teleport.lastPos and (coin.Position - teleport.lastPos).Magnitude < 1000 then
		local speed = math.clamp(tonumber(context.configuration.farm.tpSpeed) or 25, 10, 26)
		arrival = math.max(teleport.lastAt, teleport.lastAt + (coin.Position - teleport.lastPos).Magnitude / speed - 0.4 * (motion.tpLat or 0.1))
	end
	if not teleport.touching and now < arrival - 0.35 then returnHome("wait"); return end
	root.CFrame = context.environment.CFrame.new(teleport.hide)
	root.AssemblyLinearVelocity = context.environment.Vector3.zero
	if teleport.touching or now >= arrival then
		if not teleport.touching then teleport.touching, teleport.at = true, now end
		teleport.touchC, teleport.touchT = coin, now
		FarmMotion.touch(context, character, coin)
		motion.phase = "tp"
		return
	end
	motion.phase = "wait"
end
]====],
    [====[function FarmMotion.teleport(context, state, motion, options)
	local now, root, velocity, character, gun = options.time, options.root, options.velocity, options.character, options.gun
	local teleport = motion.tp
	local home = FarmMotion.home(context, motion, now) or teleport.start
	teleport.start = teleport.start or root.CFrame
	velocity.Velocity = context.environment.Vector3.zero
	FarmMotion.teleportReference(context, state, motion, root, now, options.tickTime)
	local function returnHome(phase, force)
		motion.phase = phase
		if home and (force or (root.Position - home.Position).Magnitude > 6) then root.CFrame = home end
		root.AssemblyLinearVelocity = context.environment.Vector3.zero
	end
	-- A espera entre moedas permanece no mapa, na posicao subterranea do alvo.
	local function waitUnderMap()
		motion.phase = "wait"
		if teleport.hide then root.CFrame = context.environment.CFrame.new(teleport.hide) end
		root.AssemblyLinearVelocity = context.environment.Vector3.zero
	end
	local coin = teleport.coin
	if coin then
		local isGun = coin == gun
		local collected = isGun and (coin.Parent == nil or options.hasGun) or not isGun and not FarmState.validCoin(context, state, coin)
		local done = false
		if collected then
			if isGun then motion.gunTarget = nil end
			if not isGun and coin:GetAttribute("Collected") then motion.got += 1 end
			if not isGun and teleport.touching then
				if now > teleport.lastAt then teleport.lastAt = now end
				teleport.lastPos = coin.Position
				local latency = now - (teleport.at or now)
				if latency > 0 and latency < 0.6 then motion.tpLat = math.clamp((motion.tpLat or 0.1) * 0.8 + latency * 0.2, 0.03, 0.3) end
			end
			done = true
		end
		if not collected then
			if teleport.touching and now - teleport.at > (isGun and 0.9 or 0.30) then
				if isGun then
					FarmMotion.skip(context, state, coin)
				else
					-- Liberar o alvo cedo; permitir nova tentativa apos um intervalo curto.
					motion.skip[coin] = now + 2
				end
				motion.fails += 1
				if isGun then motion.gunTarget = nil end
				done = true
			end
			if gun and not isGun then done = true end
		end
		if done then
			teleport.coin, teleport.touching = nil, false
			if isGun then returnHome("home", true); return end
			-- Seleciona a proxima moeda no mesmo quadro, sem viagem ao lobby.
		end
	end
	if options.full and not gun then returnHome("full"); return end
	if not teleport.coin then
		local target = gun or FarmMotion.teleportPick(context, state, motion, now, options.murderer, teleport.lastPos)
		if not target then waitUnderMap(); return end
		teleport.coin, teleport.touching, teleport.at = target, false, now
		teleport.hide = target == gun and target.Position or FarmMotion.coinInfo(context, state, motion, target, now).hide
		motion.tries += 1
		FarmMotion.setTouch(context, state, motion, target, now)
		teleport.ctAt = now
	end
	coin = teleport.coin
	if now - (teleport.ctAt or 0) > 0.1 then
		teleport.ctAt = now
		FarmMotion.setTouch(context, state, motion, coin, now)
	end
	local isGun = coin == gun
	if not isGun and not teleport.touching and now - (teleport.rpAt or 0) > 0.2 then
		teleport.rpAt = now
		local target, score, currentScore = FarmMotion.teleportPick(context, state, motion, now, options.murderer, teleport.lastPos, coin)
		if target and target ~= coin and (not currentScore or score + 2 < currentScore) then
			coin, teleport.coin, teleport.at = target, target, now
			teleport.hide = FarmMotion.coinInfo(context, state, motion, target, now).hide
			FarmMotion.setTouch(context, state, motion, target, now)
			teleport.ctAt = now
		end
	end
	local arrival = now
	if not isGun and teleport.lastPos and (coin.Position - teleport.lastPos).Magnitude < 1000 then
		local speed = math.clamp(tonumber(context.configuration.farm.tpSpeed) or 26, 10, 26)
		arrival = math.max(teleport.lastAt, teleport.lastAt + (coin.Position - teleport.lastPos).Magnitude / speed - 0.4 * (motion.tpLat or 0.1))
	end
	-- Mantem o ritmo e a espera inicial ja existentes antes de tentar coletar.
	if not isGun and teleport.cold then arrival = math.max(arrival, teleport.cold) end
	if not teleport.touching and now < arrival - 0.35 then waitUnderMap(); return end
	root.CFrame = context.environment.CFrame.new(teleport.hide)
	root.AssemblyLinearVelocity = context.environment.Vector3.zero
	if teleport.touching or now >= arrival then
		if not teleport.touching then teleport.touching, teleport.at = true, now end
		teleport.touchC, teleport.touchT = coin, now
		FarmMotion.touch(context, character, coin)
		motion.phase = "tp"
		return
	end
	motion.phase = "wait"
end
]====],
    "Teleport: coleta continua sob o mapa")
mythicFlushPatches()

-- MYTHIC TELEPORT v66: controle real 10-26 e busca linear pela moeda mais proxima.
mythicReplaceOnce([========[{"Teleport Speed", "tpSpeed", 10, 26, 25}]========], [========[{"Teleport Speed", "tpSpeed", 10, 26, 26}]========], "Teleport v56: slider")
mythicReplaceOnce([========[tpSpeed = 25, tpDelay = 3,]========], [========[tpSpeed = 26, tpDelay = 3,]========], "Teleport v56: default")
mythicReplaceOnce([========[local section, settings, environment = context.section, context.configuration.farm, context.environment]========], [========[local section, settings, environment = context.section, context.configuration.farm, context.environment
	-- Migrar o teste fixo para um controle real; manter escolhas apos a migracao.
	if settings.tpSpeedRevision ~= "v66" then
		settings.tpSpeed, settings.tpSpeedRevision = 26, "v66"
	end]========], "Teleport v56: migration")
mythicReplaceOnce([========[function FarmMotion.teleportPick(context, state, motion, now, murderer, previous, current)
	local coins, teleport = {}, motion.tp
	for _, container in FarmMotion.containers(context, state, motion, now) do
		if not container.Parent then continue end
		for _, coin in container:GetChildren() do
			if not FarmState.validCoin(context, state, coin) or (motion.skip[coin] or 0) >= now then continue end
			table.insert(coins, coin)
			teleport.valid = teleport.valid or setmetatable({}, {__mode = "k"})
			teleport.valid[coin] = true
		end
	end
	if #coins == 0 then return nil end
	if previous and (coins[1].Position - previous).Magnitude > 1000 then previous = nil end
	local best, lowest, currentScore
	for _, coin in coins do
		local nearest, second, third = math.huge, math.huge, math.huge
		for _, other in coins do
			if other == coin then continue end
			local distance = (other.Position - coin.Position).Magnitude
			if distance < nearest then nearest, second, third = distance, nearest, second; continue end
			if distance < second then second, third = distance, second; continue end
			if distance < third then third = distance end
		end
		local score = previous and ((coin.Position - previous).Magnitude + 0.25 * (math.min(nearest, 120) + math.min(second, 120)))
			or math.min(nearest, 300) + math.min(second, 300) + math.min(third, 300)
		score += FarmMotion.murderPenalty(state, coin.Position, murderer)
		if coin == current then currentScore = score end
		if not lowest or score < lowest then best, lowest = coin, score end
	end
	if best and state.avoidMurder and lowest >= 1000000 then return nil end
	return best, lowest, currentScore
end
]========], [========[function FarmMotion.teleportPick(context, state, motion, now, murderer, previous, current)
	local teleport = motion.tp
	local character = context.player and context.player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local origin = previous or (root and root.Position) or (current and current.Position) or teleport.hide
	local best, lowest, currentScore
	teleport.valid = teleport.valid or setmetatable({}, {__mode = "k"})
	for _, container in FarmMotion.containers(context, state, motion, now) do
		if not container.Parent then continue end
		for _, coin in container:GetChildren() do
			if not FarmState.validCoin(context, state, coin) or (motion.skip[coin] or 0) >= now then continue end
			teleport.valid[coin] = true
			local score = origin and (coin.Position - origin).Magnitude or 0
			score += FarmMotion.murderPenalty(state, coin.Position, murderer)
			if coin == current then currentScore = score end
			if not lowest or score < lowest then best, lowest = coin, score end
		end
	end
	if best and state.avoidMurder and lowest >= 1000000 then return nil end
	return best, lowest, currentScore
end
]========], "Teleport v56: picker")
mythicFlushPatches()

-- MYTHIC v65: Fast e Under Map limitados a 24; Teleport preservado.
mythicFlushPatches()
mythicReplaceOnce(
    "math.clamp(tonumber(context.configuration.farm.speed) or 23, 8, 23)",
    "math.clamp(tonumber(context.configuration.farm.speed) or 24, 8, 24)",
    "Under Map: velocidade 24")
mythicFlushPatches()
do
    local a = assert(string.find(source, "function FarmMotion.fast(", 1, true), "Fast ausente")
    local b = assert(string.find(source, "\nfunction FarmMotion.setTouch", a, true), "Fim Fast ausente")
    local original = string.sub(source, a, b - 1)
    local changed, count = string.gsub(original, "local speed = 24", "local speed = math.clamp(tonumber(context.configuration.farm.fastSpeed) or 24, 20, 24)", 1)
    assert(count == 1, "Velocidade Fast inesperada")
    changed, count = string.gsub(changed, "local actualSpeed = 24", "local actualSpeed = speed", 1)
    assert(count == 1, "Movimento Fast inesperado")
    mythicReplaceOnce(original, changed, "Fast: velocidade real do slider")
end
mythicReplaceOnce('{"Farm Speed", "speed", 8, 23, 23}', '{"Farm Speed", "speed", 8, 24, 24}', "Under Map: slider 26")
mythicReplaceOnce('{"Fast Speed", "fastSpeed", 20, 24, 24}', '{"Fast Speed", "fastSpeed", 20, 24, 24}', "Fast: slider 26")
mythicReplaceOnce("settings.fastSpeed = 24",
    [====[if settings.motionSpeedRevision ~= "v65" then
        settings.speed, settings.fastSpeed, settings.motionSpeedRevision = 24, 24, "v65"
    end]====], "Under Map e Fast: iniciar em 26")
mythicFlushPatches()

-- Ajustar tambem os trajetos secundários (espera, bolsa cheia e troca de modo)
-- que ainda usam o limite antigo de 23, sem mudar os tempos de coleta.
do
    local from = "math.clamp(tonumber(context.configuration.farm.speed) or 23, 8, 23)"
    local to = "math.clamp(tonumber(context.configuration.farm.speed) or 24, 8, 24)"
    local pattern = from:gsub("(%W)", "%%%1")
    local updated, count = source:gsub(pattern, to)
    if count > 0 then source = updated end
end

-- v67: retirar saltos instantaneos do Teleporte (sem simular posicao nem mascarar kicks).
-- Preservar os modos Fast/Under Map e o seletor de moedas ja existente.
mythicReplaceWholeFunction(
    "function FarmMotion.teleport(context, state, motion, options)",
    "\nfunction FarmMotion.ensureMover(context, root, humanoid, withoutGyro)",
    [====[function FarmMotion.teleport(context, state, motion, options)
    local now, root, character = options.time, options.root, options.character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 or not root then return end
    local teleport = motion.tp
    -- Nunca aplicar forcadores de velocidade ou reposicionar CFrame neste modo.
    for _, name in {"PulseFarmBV", "PulseFarmBG"} do
        local mover = root:FindFirstChild(name)
        if mover then mover:Destroy() end
    end
    if humanoid.PlatformStand then
        humanoid.PlatformStand = false
        humanoid:ChangeState(context.environment.Enum.HumanoidStateType.GettingUp)
    end
    motion.phase = "idle" -- evita o noclip global usado nos modos de movimento forcado
    if options.full then
        teleport.walkTarget = nil
        humanoid:MoveTo(root.Position)
        return
    end
    local target = teleport.walkTarget
    if options.gun and options.gun.Parent then
        target = options.gun
    elseif target and (not FarmState.validCoin(context, state, target)
        or (motion.skip[target] or 0) >= now) then
        target = nil
    end
    if not target then
        target = FarmMotion.teleportPick(context, state, motion, now,
            options.murderer, root.Position)
        teleport.walkTarget = target
        teleport.walkCommandAt, teleport.walkCommandTarget = nil, nil
        teleport.walkProgressAt, teleport.walkBestDistance = now, math.huge
    end
    if not target then
        humanoid:MoveTo(root.Position)
        return
    end
    local distance = (target.Position - root.Position).Magnitude
    if target ~= teleport.walkProgressTarget then
        teleport.walkProgressTarget, teleport.walkProgressAt, teleport.walkBestDistance =
            target, now, distance
    elseif distance + 0.5 < (teleport.walkBestDistance or math.huge) then
        teleport.walkProgressAt, teleport.walkBestDistance = now, distance
    elseif distance > 4 and now - (teleport.walkProgressAt or now) > 4 then
        motion.skip[target] = now + 2
        teleport.walkTarget, teleport.walkCommandTarget, teleport.walkProgressTarget = nil, nil, nil
        return
    end
    if target ~= teleport.walkCommandTarget
        or now - (teleport.walkCommandAt or -math.huge) >= 0.6 then
        teleport.walkCommandTarget, teleport.walkCommandAt = target, now
        humanoid:MoveTo(target.Position)
    end
    -- Coleta apenas por contato fisico normal com o coletavel.
end]====],
    "Teleport: usar movimento normal em vez de CFrame instantaneo")
mythicReplaceOnce(
    [====[local velocity, gyro = FarmMotion.ensureMover(context, root, humanoid, shooting)]====],
    [====[-- O modo Teleporte nao deve criar BodyVelocity/PlatformStand.
    if method == "Teleport" then
        FarmMotion.teleport(context, state, motion, {
            time = now, root = root, character = character, gun = gun,
            murderer = murderer, full = full, hasGun = hasGun
        })
        return
    end
    local velocity, gyro = FarmMotion.ensureMover(context, root, humanoid, shooting)]====],
    "Teleport: evitar forcadores de movimento")
mythicFlushPatches()

-- v68: ao mudar para Teleporte, restaurar colisoes alteradas pelo noclip anterior.
-- Isso nao muda posicao do personagem nem tenta contornar a verificacao do servidor.
mythicReplaceOnce(
    [====[for _, part in parts do if part.Parent and part.CanCollide then part.CanCollide = false end end]====],
    [====[motion.noclipOriginal = motion.noclipOriginal or setmetatable({}, {__mode = "k"})
        for _, part in parts do
            if part.Parent and part.CanCollide then
                motion.noclipOriginal[part] = true
                part.CanCollide = false
            end
        end]====],
    "Teleport: registrar colisoes para restaurar ao trocar de modo")
mythicReplaceOnce(
    [====[-- O modo Teleporte nao deve criar BodyVelocity/PlatformStand.
    if method == "Teleport" then
        FarmMotion.teleport(context, state, motion, {]====],
    [====[-- O modo Teleporte nao deve criar BodyVelocity/PlatformStand.
    if method == "Teleport" then
        if motion.lastMethod ~= "Teleport" then
            -- Limpa o movimento forcado do modo anterior apenas na transicao.
            FarmMotion.reset(context, motion, character)
            motion.lastMethod = "Teleport"
            -- Repor as colisoes que a rotina de noclip da farm alterou.
            if motion.noclipOriginal then
                for part, oldCollision in motion.noclipOriginal do
                    if part.Parent and part:IsDescendantOf(character) then
                        part.CanCollide = oldCollision
                    end
                end
                motion.noclipOriginal = nil
            end
        end
        FarmMotion.teleport(context, state, motion, {]====],
    "Teleport: restaurar movimento e colisao ao entrar no modo")
mythicFlushPatches()

-- v69: intervalo de dois segundos apos cada doce confirmado no modo Teleporte.
-- Nao reativa saltos de CFrame nem altera Fast ou Under Map.
mythicReplaceOnce(
    [====[    elseif target and (not FarmState.validCoin(context, state, target)
        or (motion.skip[target] or 0) >= now) then
        target = nil
    end
    if not target then]====],
    [====[    elseif target and (not FarmState.validCoin(context, state, target)
        or (motion.skip[target] or 0) >= now) then
        -- Pausa apenas depois de um doce efetivamente marcado como coletado.
        local coinId = target:GetAttribute("CoinID")
        local confirmed = target:GetAttribute("Collected") == true
            or (coinId ~= nil and state.full[coinId] == true)
        if confirmed then teleport.nextCandyAt = now + 2.0 end
        teleport.walkTarget = nil
        target = nil
    end
    if not options.gun and now < (teleport.nextCandyAt or 0) then
        humanoid:MoveTo(root.Position)
        return
    end
    if not target then]====],
    "Teleport: aguardar 2s apos cada doce coletado")
mythicFlushPatches()

end -- final do preparo: com cache, ignorar todos os patches.

local fn, parseError = loadstring(source)
if not fn then
    failLoader("erro ao compilar Lua: " .. tostring(parseError))
end
local ok, result = pcall(fn)
if not ok then failLoader("falha ao iniciar o menu: " .. tostring(result)) end
if type(result) == "table" and type(result.errors) == "table" and #result.errors > 0 then
	local details = tostring(result.errors[#result.errors])
	warn("MYTHIC-HUB: falha parcial na montagem da interface: " .. details)
	return result
end
if not fromCache and type(writefile) == "function" then
    -- Gravar depois da abertura evita bloquear o primeiro carregamento com IO de disco.
    local prepared = source
    task.defer(function()
        local ok, problem = pcall(function()
            if type(makefolder) == "function" then pcall(makefolder, "MYTHIC-HUB") end
            writefile(CACHE_FILE, prepared)
        end)
        if not ok then warn("MYTHIC-HUB: cache indisponivel: " .. tostring(problem)) end
    end)
end
warn(string.format("MYTHIC-HUB: %s concluido em %.2fs", fromCache and "cache" or "primeiro carregamento",
    os.clock() - loaderStartedAt))
-- MYTHIC MONITOR: envio automatico de nick, saldo e estatisticas ao painel privado.
-- Nenhuma credencial do painel e distribuida com o hub.
task.spawn(function()
    print("MYTHIC HUB: monitor ativo; nick, saldo e ganhos sao enviados ao painel do hub.")
    local ok, problem = pcall(function()
        local monitor_url = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/mythic-monitor-auto.lua"
        local body = game:HttpGet(monitor_url)
        local monitor, parse_error = loadstring(body)
        if not monitor then error(parse_error) end
        monitor(getfenv(fn))
    end)
    if not ok then warn("MYTHIC Monitor: falha ao iniciar: " .. tostring(problem)) end
end)
return result
