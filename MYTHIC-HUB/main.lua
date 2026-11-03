-- MYTHIC-HUB - loader oficial da copia publicada neste repositorio.
-- Recupera 35 blocos do codigo (12.468.912 bytes) do proprio GitHub.
local avatarBase64 = [==[/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAwADADASIAAhEBAxEB/8QAGgAAAgMBAQAAAAAAAAAAAAAABAYBAwUCB//EAC4QAAEDAgQGAQMEAwAAAAAAAAECAwQFEQASITEGEyJBUXFhQoGxIyQyUmORof/EABgBAAMBAQAAAAAAAAAAAAAAAAIEBQED/8QAKBEAAQMDAQgCAwAAAAAAAAAAAQIDEQAEMSESE0FRcbHB8GGBkaHR/9oADAMBAAIRAxEAPwDweHDfmyW48dpTjizZKUjU49GpnAC4RRz4zLr4UA67LcsyyfHLT1KPuw/OLeAo1PpbKnZT8mLLU0HFvst5lMpUejsbA7k27pwZxXxUukM0+G0VqmhkrdLpJKSVEAqO5VYC99cWUMItWS6sSrtNVGrdLTW2rU9q7rHCcNlLaHeKhAddR0oEdDLV/GVKrgfOuFOrKqnCzCILqmJDr4Ky4tIebW3oBlKgRfe9tRtjFnVeTKmqkvvKdd/iSfqHj84Li1SRUGBGmOcxmKOc0XR1ItYED4Omnxpha3vFuLKCc4NAlRJInWpLFMrkZDEeIIFVQkqVlX+g6Br31QrfuR6wtvMOMOqbdQUrSbEHDwmupER2XHgUxtoHq5URGa+ibgKJO/8A3XGVUnhXWpkwp/cskOKVlCQUHSwSNBlNvtfBuW5cTgBUTnI940C2SoCQAc9RW81UHKdKcqbKnI0sS1RxJUSUBsIAS2pP9SP9WxmVl5XEVZK5gTGmuKCVLQklFgLAADYetNb40p8tmS67HlrU5FqDSHo7zZylLmwC9NQLkebEa4x88uFFlU4XZmJskHL15e6Uq3CTft+DjH7jdPLaeEoJkadqqOoC0iBp55fY1B44oOFUnKRFqEBdJhOyXQpoyJCMy2biyspvb79sVw34jMRSJSXOapdw41lJCbWtqfODaDJcQ6YqaOZkhAWVtqQOnYgm4OoIUNR9Xm2O+Kk1h2JGkToUWLHZWphpLB2v1WtfCTbu7VtIqGFlCpFVSFU5UdEeJKUgaK/XZCSV/Kwo+r2GnjE8OpdZqrjbrGZpxpyO7mGgzJIv8WNj9sLvbuL/ABhzo0uYuHNdbbSIDcXmyHQ2FEECyRm+klVhpripavB5YLmkRjlTbC0uLBXpFB0SoIn0pmnLOSZEc5kVdh1pJ6mz9+oH2MCKnRyl5mWp+WqOstRiFWPLuSc3e3ceNcL6FqbUFJNiMMMSoUaegpq7TzMrQomRwDc/5EH+XsWPvCZWm4aDazBHPj/Kxm5MATBHPB8aVQZ8lDy323I7IdFlltsKNj9Wu53131PnA78l2U4VOvPyVDXO6sqt9thucFCkIfnBqNVISmVKslbjvLsL981rY3XhDpzyGYs+jssMJsXAC8txX9tjc+O2OrFiTJWQAOh/GsViWVOEqcMef3FDtsRYNNDyGWpsxRyuMrQSGyT0626jbe3rFNY4idRw6mgpbaaKni9J5SAnXsjTe1r+/WId4ych092FTUJzvXDsxxtPNVcWsnToHrX5wqElRuTc47Xl42E7pnER780VxcpCdhrER770r//Z]==]

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
            Image=avatarAsset or "",ScaleType=Enum.ScaleType.Crop,ZIndex=6,
        })
        make("UICorner",avatar,{CornerRadius=UDim.new(1,0)})
        if not avatarAsset then
            make("TextLabel",avatar,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
                Text="M",Font=Enum.Font.GothamBlack,TextSize=90,TextColor3=white,ZIndex=7})
        end
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
mythicReplaceOnce([=[Logo = "rbxassetid://102076719808486"]=], [=[Logo = (function()
            local ok, result = pcall(function()
                return environment.getcustomasset("PulseHub/nova/mythic_avatar_logo.jpg")
            end)
            return ok and result or nil
        end)()]=], "logo")

mythicReplaceOnce("local EMBEDDED_FILES = {", 'local EMBEDDED_FILES = {\n    ["PulseHub/nova/mythic_avatar_logo.jpg"] = [=[' .. avatarBase64 .. ']=],', "foto")
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
			chip.Position = UDim2.new(1, -14, 0, 74)
			chip.Size = UDim2.fromOffset(176, 34)
			chip.BackgroundColor3 = Color3.fromRGB(23, 12, 40)
			chip.BackgroundTransparency = 0.08
			chip.BorderSizePixel = 0
			chip.Parent = onlineGui
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 12)
			corner.Parent = chip
			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(158, 59, 245)
			stroke.Thickness = 1.5
			stroke.Transparency = .24
			stroke.Parent = chip
			uiText = Instance.new("TextLabel")
			uiText.Size = UDim2.fromScale(1,1)
			uiText.BackgroundTransparency = 1
			uiText.Font = Enum.Font.GothamBold
			uiText.TextSize = 12
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
-- MYTHIC MUSIC & AVATAR PRESETS v3.0

mythicReplaceOnce([====[local BOOMBOX_TRACKS = {]====], [====[local BOOMBOX_TRACKS = {
	{id = "pending:claudete", name = "Ei Claudete", lang = "Falta ID Roblox"},
	{id = "pending:mentalista", name = "Coisas Que Eu Sei (O Mentalista)", lang = "Falta ID Roblox"},
	{id = "pending:montagem", name = "Montagem Coma", lang = "Falta ID Roblox"},
	{id = "pending:passo", name = "Passo Bem Solto (Slowed)", lang = "Falta ID Roblox"},
	{id = "pending:pos", name = "Pós (Ao Vivo)", lang = "Falta ID Roblox"},
	{id = "pending:mega", name = "Mega Hair (Ao Vivo)", lang = "Falta ID Roblox"},
	{id = "pending:mentira", name = "Mentira ou Verdade", lang = "Falta ID Roblox"},]====], "My Songs: sete musicas sugeridas")

mythicReplaceOnce([====[if settings.random == nil then settings.random = false end]====], [====[if settings.random == nil then settings.random = false end
	if settings.repeatMode ~= "loop" then settings.repeatMode = "once" end]====], "Modo repeticao configuracao")

mythicReplaceOnce([====[if settings.song == "" then settings.song = BOOMBOX_TRACKS[1].id end]====], [====[if settings.song == "" then
		for _, track in ipairs(BOOMBOX_TRACKS) do
			if tostring(track.id):match("^%d+$") then settings.song = track.id; break end
		end
	end]====], "Escolha inicial de audio valido")

mythicReplaceOnce([====[if not remote or not id or tostring(id) == "" then return false end]====], [====[if not remote or not id or not tostring(id):match("^%d+$") then return false end]====], "Evitar tentativa de reproduzir sugestao sem ID")

mythicReplaceOnce([====[if state.settings.random and #tracks > 0 then return tracks[math.random(1, #tracks)].id end]====], [====[local available = {}
	for _, track in ipairs(tracks) do if tostring(track.id):match("^%d+$") then table.insert(available, track) end end
	if state.settings.random and #available > 0 then return available[math.random(1, #available)].id end]====], "Shuffle somente audios cadastrados")

mythicReplaceOnce([====[state.settings.song = tostring(id)
	if state.context.player:GetAttribute("Radio") then Boombox.play(state, id)]====], [====[state.settings.song = tostring(id)
	if not state.settings.song:match("^%d+$") then
		pcall(function() state.context.window:Notify({Title = "MYTHIC-HUB Music", Text = "Falta vincular um ID de audio Roblox a esta musica.", Kind = "warning", Duration = 4}) end)
		if state.update then state.update() end
		return
	end
	if state.context.player:GetAttribute("Radio") then Boombox.play(state, id)]====], "Aviso para sugestao sem ID")

mythicReplaceOnce([====[function Boombox.fetchInfo(state, id)
	id = tostring(id)]====], [====[function Boombox.fetchInfo(state, id)
	id = tostring(id)
	if not id:match("^%d+$") then return end]====], "Nao buscar metadados de ID ausente")

mythicReplaceOnce([====[section:Slider({Text = "Volume (local)", Min = 0, Max = 100, Default = 50, Decimals = 0, Suffix = "%", Callback = function(value)
		settings.volume = value
		pcall(Boombox.volume, state)
	end})]====], [====[local volumeSlider = section:Slider({Text = "Volume (local)", Min = 0, Max = 100, Default = settings.volume, Decimals = 0, Suffix = "%", Callback = function(value)
		settings.volume = value
		pcall(Boombox.volume, state)
	end})
	local function adjustVolume(delta)
		settings.volume = math.clamp((tonumber(settings.volume) or 50) + delta, 0, 100)
		if volumeSlider and type(volumeSlider.SetSilent) == "function" then
			pcall(function() volumeSlider.SetSilent(settings.volume) end)
		end
		pcall(Boombox.volume, state)
	end
	section:Button({Text = "Volume -10%", Callback = function() adjustVolume(-10) end})
	section:Button({Text = "Volume +10%", Callback = function() adjustVolume(10) end})
	section:Toggle({Text = "Mudo (local)", Default = false, Callback = function(value)
		state.muted = not not value
		pcall(Boombox.volume, state)
	end})
	section:Dropdown({Text = "Repeticao", Options = {{code = "once", label = "Tocar 1 vez"}, {code = "loop", label = "Repetir infinito"}}, Default = settings.repeatMode, NoSave = true, Callback = function(value)
		settings.repeatMode = value == "loop" and "loop" or "once"
		local sound = Boombox.radio(state)
		if sound then pcall(function() sound.Looped = settings.repeatMode == "loop" end) end
	end})]====], "Controles volume, mute e repeticao")

mythicReplaceOnce([====[if sound then sound.Volume = state.settings.volume / 100 end]====], [====[if sound then sound.Volume = state.muted and 0 or state.settings.volume / 100 end]====], "Mudo sem alterar volume salvo")

mythicReplaceOnce([====[if sound and sound.IsPlaying and math.abs(sound.Volume - settings.volume / 100) > 0.01 then Boombox.volume(state) end]====], [====[if sound then
			if sound.IsPlaying and math.abs(sound.Volume - (state.muted and 0 or settings.volume / 100)) > 0.01 then Boombox.volume(state) end
			if sound.Looped ~= (settings.repeatMode == "loop") then pcall(function() sound.Looped = settings.repeatMode == "loop" end) end
		end]====], "Loop infinito e volume no heartbeat")

mythicReplaceOnce([====[section:Header("My Songs")]====], [====[section:Header("My Songs")
	section:Note({Text = "Faixas em destaque: precisam de um ID de audio autorizado no Roblox para tocar."})
	local suggested = {
		{code = "pending:claudete", label = "Ei Claudete"},
		{code = "pending:mentalista", label = "Coisas Que Eu Sei (O Mentalista)"},
		{code = "pending:montagem", label = "Montagem Coma"},
		{code = "pending:passo", label = "Passo Bem Solto (Slowed)"},
		{code = "pending:pos", label = "Pós (Ao Vivo)"},
		{code = "pending:mega", label = "Mega Hair (Ao Vivo)"},
		{code = "pending:mentira", label = "Mentira ou Verdade"},
	}
	local suggestedChoice = suggested[1].code
	section:Dropdown({Text = "Musica TikTok", Options = suggested, Default = suggestedChoice, NoSave = true, Callback = function(value)
		suggestedChoice = tostring(value)
	end})
	local typedSongId = ""
	local musicNative = section:LastSection()
	if musicNative and musicNative.Input then musicNative:Input({Text = "ID de audio Roblox", Live = true, Callback = function(value)
		typedSongId = tostring(value or "")
	end}) end
	section:Button({Text = "Vincular ID e adicionar a My Songs", Callback = function()
		local value = typedSongId:match("(%d%d%d%d%d+)")
		if not value then
			pcall(function() context.window:Notify({Title = "MYTHIC-HUB Music", Text = "Informe um Sound ID valido do Roblox.", Kind = "warning"}) end)
			return
		end
		local chosenName
		for _, item in ipairs(suggested) do if item.code == suggestedChoice then chosenName = item.label; break end end
		if not chosenName then return end
		local added = Boombox.add(state, value, chosenName)
		if not added then
			pcall(function() context.window:Notify({Title = "MYTHIC-HUB Music", Text = "Este ID ja esta cadastrado ou e invalido.", Kind = "warning"}) end)
			return
		end
		settings.hidden[suggestedChoice] = true
		settings.song = value
		if state.refreshList then state.refreshList() end
		pcall(function() context.window:Notify({Title = "MYTHIC-HUB Music", Text = chosenName .. " adicionada. Depende da permissao do audio no Roblox.", Kind = "success"}) end)
	end})]====], "Lista editavel de musicas TikTok")

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

mythicReplaceOnce([====[AnimationFeature.catalog(state, "skin")]====], [====[section:Note({Text = "Use Presets para os 9 avatares MYTHIC-HUB, ou digite outro Username acima."})]====], "Remover catalogo antigo de Skin")

setStatus("MYTHIC-HUB: iniciando menu...")
local fn, parseError = loadstring(source)
if not fn then
    failLoader("erro ao compilar Lua: " .. tostring(parseError))
end
local ok, result = pcall(fn)
if not ok then failLoader("falha ao iniciar o menu: " .. tostring(result)) end
if statusGui then pcall(function() statusGui:Destroy() end) end
return result
