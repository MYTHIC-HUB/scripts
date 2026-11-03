-- MYTHIC-HUB - loader oficial da copia publicada neste repositorio.
-- Recupera 35 blocos do codigo (12.468.912 bytes) do proprio GitHub.
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
                    pcall(makefolder, "PulseHub")
                    pcall(makefolder, "PulseHub/nova")
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
                local file = "PulseHub/nova/mythic_avatar_logo.jpg"
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
            Image=avatarAsset or "rbxassetid://102076719808486",ScaleType=Enum.ScaleType.Crop,ZIndex=6,
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

-- MYTHIC FAST LOADER v2.1: baixa os mesmos 35 blocos em paralelo, sem alterar sua ordem.
local base = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/chunks/part-"
local SEGMENT_COUNT, EXPECTED_BYTES = 35, 12468912
local statusGui, statusLabel
local function setStatus(message, isError)
    if statusLabel then
        pcall(function()
            statusLabel.Text = tostring(message)
            if isError then
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 125)
                statusLabel.Size = UDim2.fromOffset(320, 65)
                statusLabel.TextScaled = true
            end
        end)
    end
end
local function failLoader(message)
    setStatus("MYTHIC-HUB: " .. tostring(message), true)
    warn("MYTHIC-HUB: " .. tostring(message))
    error("MYTHIC-HUB: " .. tostring(message), 0)
end
do
    pcall(function()
        local plr = game:GetService("Players").LocalPlayer
        local parent
        if type(gethui) == "function" then pcall(function() parent = gethui() end) end
        if not parent and plr then parent = plr:FindFirstChildOfClass("PlayerGui") end
        if not parent then parent = game:GetService("CoreGui") end
        local old = parent:FindFirstChild("MYTHIC_HUB_LOADING")
        if old then old:Destroy() end
        local gui = Instance.new("ScreenGui")
        gui.Name = "MYTHIC_HUB_LOADING"
        gui.IgnoreGuiInset = true
        gui.ResetOnSpawn = false
        gui.DisplayOrder = 100001
        gui.Parent = parent
        local label = Instance.new("TextLabel")
        label.Name = "LoadStatus"
        label.AnchorPoint = Vector2.new(0.5, 1)
        label.Position = UDim2.new(0.5, 0, 1, -12)
        label.Size = UDim2.fromOffset(220, 26)
        label.BackgroundColor3 = Color3.fromRGB(14, 7, 24)
        label.BackgroundTransparency = 0.08
        label.BorderSizePixel = 0
        label.TextColor3 = Color3.fromRGB(228, 193, 255)
        label.TextScaled = false
        label.TextSize = 11
        label.TextWrapped = true
        label.Font = Enum.Font.GothamBold
        label.Text = "MYTHIC-HUB: carregando 0/35..."
        label.Parent = gui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = label
        statusGui, statusLabel = gui, label
    end)
end
local segments = {}
local nextIndex, finished, firstError = 1, 0, nil
local startedAt = os.clock()
local cancelled = false
local MAX_WORKERS = 4 -- Limite conservador para executores mobile.
local function downloadWorker()
    while not cancelled and not firstError do
        local i = nextIndex
        nextIndex = nextIndex + 1
        if i > SEGMENT_COUNT then break end
        local url = base .. string.format("%03d", i) .. ".txt"
        local result
        for attempt = 1, 2 do
            local ok, body = pcall(function() return game:HttpGet(url) end)
            if ok and type(body) == "string" and #body > 0 then
                result = body
                break
            end
            if attempt < 2 then task.wait(0.25) end
        end
        if not result then
            firstError = "MYTHIC-HUB: falha ao carregar bloco " .. i .. "/35. Verifique internet e executor."
            break
        end
        segments[i] = result
        finished = finished + 1
        setStatus("MYTHIC-HUB: carregando " .. finished .. "/35...")
    end
end
for _ = 1, MAX_WORKERS do
    task.spawn(downloadWorker)
end
while finished < SEGMENT_COUNT and not firstError and (os.clock() - startedAt) < 90 do
    task.wait(0.05)
end
cancelled = true
if firstError then failLoader(firstError) end
if finished ~= SEGMENT_COUNT then
    failLoader("tempo limite do carregamento. Verifique sua conexão.")
end
local source = table.concat(segments)
if #source ~= EXPECTED_BYTES then
    failLoader("arquivo incompleto (" .. #source .. " bytes, esperado " .. EXPECTED_BYTES .. ").")
end
-- MYTHIC CUSTOM PATCH: substitui logo e remove a categoria Chat.
local function mythicReplaceOnce(needle, replacement, label)
    local first = string.find(source, needle, 1, true)
    if not first then
        warn("MYTHIC-HUB: ajuste opcional nao aplicado: " .. label)
        return false
    end
    source = string.sub(source, 1, first - 1) .. replacement .. string.sub(source, first + #needle)
end
mythicReplaceOnce([=[{name = "Chat", icon = "messages-square", group = "Fun", desc = "Chat exclusivo para usuarios MYTHIC", badge = "LOCK"},]=], "", "Chat/aba")
mythicReplaceOnce([=[Fun = {"Animations", "Troll", "Music", "Chat", "MYTHIC Users"}]=], [=[Fun = {"Animations", "Troll", "Music", "MYTHIC Users"}]=], "Chat/ordem")
mythicReplaceOnce([=[local mythicChat = PulseTab.create(environment, hub, "Chat", "messages-square", context)
	mythicChat:Group({Title = "MYTHIC CHAT", Side = "Left"})
	mythicChat:Note({Text = "Exclusivo para usuarios do MYTHIC HUB."})
	mythicChat:Note({Text = "Chat temporariamente indisponivel: servico autenticado ainda nao configurado."})
	mythicChat:Note({Text = "As mensagens nao sao enviadas ao chat publico do Roblox."})]=], "", "Chat/inicializacao")
-- Logo: personagem da segunda referencia, renderizado a 160x160 (em vez da miniatura 48x48).
mythicReplaceOnce([=[Logo = "rbxassetid://102076719808486"]=], [=[Logo = (function()
    local fn = environment.getcustomasset or environment.getsynasset or getcustomasset or getsynasset
    local ok, id = pcall(function()
        return type(fn) == "function" and fn("PulseHub/nova/mythic_avatar_logo.jpg")
    end)
    return ok and type(id) == "string" and id ~= "" and id or "rbxassetid://102076719808486"
end)()]=], "Logo personagem roxo")

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
-- MYTHIC ONLINE COUNTER v2.0: integra backend anonimo de presenca no MYTHIC Users e topo da tela.
mythicReplaceOnce([====[mythicUsers:Group({Title = "MYTHIC USERS", Side = "Left"})]====], [====[mythicUsers:Group({Title = "MYTHIC USERS", Side = "Left"})
	-- MYTHIC ONLINE COUNTER v2.0: contagem de sessoes ativas sem nomes, usuarios ou servidores.
	mythicUsers:Group({Title = "Online agora", Side = "Right"})
	local onlineLabel = mythicUsers:Note({Text = "MYTHIC-HUB online: conectando..."})
	mythicUsers:Note({Text = "Estimativa de sessoes ativas. Atualiza a cada 30 segundos; nao verifica contas Roblox."})
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
						local nextSession = send({action = "start"})
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
	end)()]====], "online badge and heartbeat")
mythicReplaceOnce([====[		pcall(stopMythicUsers)]====], [====[		pcall(stopMythicUsers)
		pcall(stopMythicOnline)]====], "online cleanup on destroy")
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
	fun:Header("MYTHIC Music | 2026")
	fun:Note({Text="Reproducao local sem abrir navegador ou copiar links."})
	fun:Header("Craudete - Brancoala")
    fun:Note({Text="Toque para ouvir no proprio Roblox, sem Sound ID e sem copiar link. Usa o cache local do executor."})
    local mymCraudeteUrl="https://palcocdn.akamaized.net/5/d/4/f/brancoala-craudete-ab35bc.mp3"
    local mymCraudeteCache="MYTHIC-HUB/audio/craudete-brancoala.mp3"
    local mymCraudeteService=game:GetService("SoundService")
    local mymCraudeteSound,mymCraudeteResource=nil,nil
    local mymCraudeteBusy,mymCraudeteGeneration=false,0
    local mymCraudeteVolume,mymCraudeteLoop,mymCraudeteMuted=.6,false,false
    local function mymCraudeteInfo(message,kind)
        pcall(function()window:Notify({Title="MYTHIC-HUB | Craudete",Text=tostring(message),Kind=kind or "info",Duration=6})end)
    end
    local function mymCraudeteAPI(name)
        local env=getfenv()
        if type(env[name])=="function" then return env[name] end
        if type(getgenv)=="function" then
            local ok,globals=pcall(getgenv)
            if ok and type(globals)=="table" and type(globals[name])=="function" then return globals[name] end
        end
        return nil
    end
    local function mymCraudeteRequest()
        local direct=mymCraudeteAPI("request") or mymCraudeteAPI("http_request")
        if direct then return direct end
        local env=getfenv()
        if type(env.syn)=="table" and type(env.syn.request)=="function" then return env.syn.request end
        if type(env.http)=="table" and type(env.http.request)=="function" then return env.http.request end
        return nil
    end
    local function mymCraudeteValid(body)
        if type(body)~="string" or #body<128 or #body>10485760 then return false end
        if body:sub(1,3)=="ID3" and body:byte(4)>=2 and body:byte(4)<=4 then return true end
        local a,b=body:byte(1,2)
        return a==255 and b and math.floor(b/32)==7
            and math.floor(b/8)%4~=1 and math.floor(b/2)%4~=0
    end
    local function mymCraudeteResolve()
        if mymCraudeteResource then return mymCraudeteResource end
        local asset=mymCraudeteAPI("getcustomasset") or mymCraudeteAPI("getsynasset")
        if not asset then return nil,"O executor nao oferece getcustomasset/getsynasset." end
        local file=mymCraudeteCache
        local check,read=mymCraudeteAPI("isfile"),mymCraudeteAPI("readfile")
        local valid=false
        if check and read then
            for _,p in ipairs({mymCraudeteCache,"NexusHub/audio/craudete.mp3"}) do
                local ok,present=pcall(check,p)
                if ok and present then
                    local loaded,bytes=pcall(read,p)
                    if loaded and mymCraudeteValid(bytes) then file=p;valid=true;break end
                end
            end
        end
        if not valid then
            local request,write,mkdir=mymCraudeteRequest(),mymCraudeteAPI("writefile"),mymCraudeteAPI("makefolder")
            if not request or not write or not mkdir then
                return nil,"O executor precisa de request, writefile e makefolder para o primeiro carregamento."
            end
            local ok,response=pcall(request,{Url=mymCraudeteUrl,Method="GET",Timeout=20})
            if not ok or type(response)~="table" then return nil,"Nao foi possivel baixar o MP3 do artista." end
            local status=tonumber(response.StatusCode or response.Status)
            if not status or status<200 or status>=300 then return nil,"Servidor do artista retornou HTTP "..tostring(status or "?") end
            local bytes=response.Body or response.body
            if not mymCraudeteValid(bytes) then return nil,"Conteudo MP3 invalido ou maior que 10 MB." end
            pcall(mkdir,"MYTHIC-HUB")
            pcall(mkdir,"MYTHIC-HUB/audio")
            local saved,problem=pcall(write,mymCraudeteCache,bytes)
            if not saved then return nil,"Nao foi possivel guardar audio no cache: "..tostring(problem) end
        end
        local ok,id=pcall(asset,file)
        if not ok or type(id)~="string" or id=="" then return nil,"O executor nao conseguiu criar um asset de audio local." end
        mymCraudeteResource=id
        return id
    end
    local function mymCraudeteStop()
        mymCraudeteGeneration+=1
        mymCraudeteBusy=false
        if mymCraudeteSound then
            pcall(function()mymCraudeteSound:Stop();mymCraudeteSound:Destroy()end)
            mymCraudeteSound=nil
        end
    end
    local earlier=mymCraudeteService:FindFirstChild("MYTHIC_CRAUDETE_LOCAL")
    if earlier then pcall(function()earlier:Destroy()end) end
    local function mymCraudetePlay()
        if mymCraudeteBusy then mymCraudeteInfo("Carregando...");return end
        mymCraudeteGeneration+=1
        local generation=mymCraudeteGeneration
        mymCraudeteBusy=true
        task.spawn(function()
            local called,asset,problem=pcall(mymCraudeteResolve)
            if generation~=mymCraudeteGeneration then return end
            if not called or not asset then
                mymCraudeteBusy=false
                mymCraudeteInfo(called and (problem or "Falha de audio") or tostring(asset),"warning")
                return
            end
            local sound=mymCraudeteSound
            if not sound or not sound.Parent then
                sound=Instance.new("Sound")
                sound.Name="MYTHIC_CRAUDETE_LOCAL"
                sound.Parent=mymCraudeteService
                mymCraudeteSound=sound
            end
            local configured,reason=pcall(function()
                sound.SoundId=asset
                sound.Volume=mymCraudeteMuted and 0 or mymCraudeteVolume
                sound.Looped=mymCraudeteLoop
            end)
            if not configured then
                mymCraudeteBusy=false
                mymCraudeteInfo("Audio nao suportado: "..tostring(reason),"warning")
                return
            end
            local deadline=os.clock()+10
            while generation==mymCraudeteGeneration and sound.Parent and not sound.IsLoaded and os.clock()<deadline do
                task.wait(.1)
            end
            if generation~=mymCraudeteGeneration then return end
            mymCraudeteBusy=false
            if not sound.IsLoaded then
                mymCraudeteInfo("MP3 nao carregou. O executor pode bloquear audio local.","warning")
                return
            end
            local ok,err=pcall(function()sound.TimePosition=0;sound:Play()end)
            if ok then mymCraudeteInfo("Craudete - Brancoala: tocando!","success")
            else mymCraudeteInfo("Erro ao reproduzir: "..tostring(err),"warning")end
        end)
    end
    fun:Button({Text="Tocar Craudete - Brancoala",Callback=mymCraudetePlay})
    fun:Button({Text="Pausar / Continuar Craudete",Callback=function()
        if not mymCraudeteSound then mymCraudeteInfo("Toque em Tocar primeiro.");return end
        local ok=pcall(function()
            if mymCraudeteSound.IsPlaying then mymCraudeteSound:Pause()
            else mymCraudeteSound:Resume()end
        end)
        if not ok then mymCraudeteInfo("Falha ao pausar ou continuar.","warning")end
    end})
    fun:Button({Text="Parar Craudete",Callback=mymCraudeteStop})
    fun:Dropdown({Text="Repeticao Craudete",Options={
        {code="once",label="Tocar 1 vez"},{code="loop",label="Repetir infinito"}
    },Default="once",NoSave=true,Callback=function(v)
        mymCraudeteLoop=v=="loop"
        if mymCraudeteSound then mymCraudeteSound.Looped=mymCraudeteLoop end
    end})
    fun:Slider({Text="Volume Craudete",Min=0,Max=100,Default=60,Decimals=0,NoSave=true,Callback=function(v)
        mymCraudeteVolume=math.clamp(tonumber(v) or 60,0,100)/100
        if mymCraudeteSound then mymCraudeteSound.Volume=mymCraudeteMuted and 0 or mymCraudeteVolume end
    end})
    
    fun:Header("Trends 2026 | Trades e edits")
    local mymTrending = {
        {code="mentalista",label="O Mentalista",file="o-mentalista.mp3"},
        {code="montagem-coma",label="MONTAGEM COMA",file="montagem-coma.mp3"},
        {code="passo-solto",label="PASSO BEM SOLTO (Slowed)",file="passo-bem-solto-slowed.mp3"},
        {code="noite-perfeita",label="NOITE PERFEITA",file="noite-perfeita.mp3"},
        {code="pos-ao-vivo",label="Pós (Ao Vivo)",file="pos-ao-vivo.mp3"},
        {code="mega-hair",label="Mega Hair (Ao Vivo)",file="mega-hair.mp3"},
        {code="mentira-verdade",label="Mentira ou Verdade",file="mentira-ou-verdade.mp3"},
        {code="que-foda",label="Que Foda Foi Essa",file="que-foda-foi-essa.mp3"},
        {code="rebola-soldado",label="Rebola pro Teu Soldado",file="rebola-pro-teu-soldado.mp3"},
        {code="geme-baixo",label="Geme Baixo",file="geme-baixo.mp3"},
        {code="tatuagem",label="Tatuagem No Corpo",file="tatuagem-no-corpo.mp3"},
        {code="que-loucura",label="QUE LOUCURA",file="que-loucura.mp3"},
        {code="no-batidao",label="NO BATIDÃO",file="no-batidao.mp3"},
        {code="acelerada",label="ACELERADA",file="acelerada.mp3"},
    }
    local mymOptions, mymSelected = {}, mymTrending[1].code
    for _,item in ipairs(mymTrending) do
        table.insert(mymOptions,{code=item.code,label=item.label})
    end
    fun:Dropdown({Text="Escolha a musica",Options=mymOptions,Default=mymSelected,NoSave=true,
        Callback=function(code) mymSelected=code end})
    fun:Button({Text="Tocar selecionada",Callback=function()
        local song
        for _,item in ipairs(mymTrending) do
            if item.code==mymSelected then song=item break end
        end
        if not song then return end
        local file="MYTHIC-HUB/audio/"..song.file
        local isfile=mymCraudeteAPI("isfile")
        local asset=mymCraudeteAPI("getcustomasset") or mymCraudeteAPI("getsynasset")
        if not isfile or not asset then
            mymCraudeteInfo("Seu executor nao permite musica por arquivo local.","warning")
            return
        end
        local ok,exists=pcall(isfile,file)
        if not ok or not exists then
            mymCraudeteInfo(song.label..": arquivo de audio ainda nao disponivel.","warning")
            return
        end
        local loaded,soundId=pcall(asset,file)
        if not loaded or type(soundId)~="string" or soundId=="" then
            mymCraudeteInfo("Nao foi possivel abrir este audio.","warning")
            return
        end
        mymCraudeteStop()
        local sound=Instance.new("Sound")
        sound.Name="MYTHIC_CRAUDETE_LOCAL"
        sound.Parent=mymCraudeteService
        mymCraudeteSound=sound
        local prepared,problem=pcall(function()
            sound.SoundId=soundId
            sound.Volume=mymCraudeteMuted and 0 or mymCraudeteVolume
            sound.Looped=mymCraudeteLoop
            sound:Play()
        end)
        if not prepared then
            mymCraudeteInfo("Erro ao tocar: "..tostring(problem),"warning")
            mymCraudeteStop()
            return
        end
        task.delay(7,function()
            if mymCraudeteSound==sound and sound.Parent and not sound.IsLoaded then
                mymCraudeteInfo("O executor nao carregou o audio selecionado.","warning")
            end
        end)
    end})
    fun:Note({Text="Trends verificadas em novembro de 2026. Só tocam no Roblox com arquivo de audio local autorizado."})

		local _, stopBoombox = Boombox.install(]====], "SoundCloud TikTok 2026: links oficiais sem ID Roblox")

mythicReplaceOnce([====[		pcall(stopBoombox)]====], [====[		pcall(stopBoombox)
		pcall(mymCraudeteStop)]====], "Music: liberar audio ao fechar")

-- Remover visualmente apenas NPC Trolly para este cliente.
do
    local ok,err=pcall(function()
        local players=game:GetService("Players")
        local world=game:GetService("Workspace")
        local globals=(type(getgenv)=="function" and getgenv()) or _G
        if type(globals.__mythicHideTrollyStop)=="function" then
            pcall(globals.__mythicHideTrollyStop)
        end
        local function isTrolly(model)
            if not model or not model:IsA("Model") then return false end
            if players:GetPlayerFromCharacter(model) then return false end
            local hum=model:FindFirstChildOfClass("Humanoid")
            if not hum then return false end
            local name=string.lower(model.Name)
            local display=string.lower(hum.DisplayName or "")
            return name=="trolly" or display=="trolly"
        end
        local function hideItem(obj)
            if obj:IsA("BasePart") then
                obj.LocalTransparencyModifier=1
                obj.CanCollide=false
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency=1
            elseif obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("ProximityPrompt") then
                obj.Enabled=false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                obj.Enabled=false
            end
        end
        local function hideModel(model)
            for _,obj in ipairs(model:GetDescendants()) do hideItem(obj) end
        end
        for _,obj in ipairs(world:GetDescendants()) do
            if isTrolly(obj) then hideModel(obj) end
        end
        local connection=world.DescendantAdded:Connect(function(obj)
            local model=obj:IsA("Model") and obj or obj:FindFirstAncestorOfClass("Model")
            if model and isTrolly(model) then
                task.defer(function()
                    if model.Parent and isTrolly(model) then hideModel(model) end
                end)
            end
        end)
        globals.__mythicHideTrollyStop=function() connection:Disconnect() end
    end)
    if not ok then warn("MYTHIC-HUB: falha ao ocultar Trolly: "..tostring(err)) end
end

setStatus("MYTHIC-HUB: iniciando menu...")
local fn, parseError = loadstring(source)
if not fn then
    failLoader("erro ao compilar Lua: " .. tostring(parseError))
end
local ok, result = pcall(fn)
if not ok then failLoader("falha ao iniciar o menu: " .. tostring(result)) end
if statusGui then pcall(function() statusGui:Destroy() end) end
return result
