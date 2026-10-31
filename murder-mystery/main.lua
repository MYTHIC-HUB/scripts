-- MURDER MYSTERY V2.1 — painel roxo/verde claro.
-- Auto farm fast / Under mapa deitado / ações de bolsa 50 / ESP / pickup.
-- Velocidade 15..29 somente no deslocamento automático.
-- Compilado com Luau oficial. Sem teste ao vivo no Delta/Roblox/MM2.
-- Coleta e ataques dependem do protocolo e da validação do servidor.

-- CONFIGURAÇÃO: os nomes de objetos podem variar entre versões do jogo.
local CONFIG = {
    MinSpeed = 15, MaxSpeed = 29, DefaultSpeed = 15,
    UnderMapDepth = 5, NormalHeightAboveCoin = 3,
    ContactSeconds = 0.04, RetrySeconds = 2,
    BagLimit = 50, RoleRemoteName = "GetPlayerData",
    RoleRefreshSeconds = 1, RoleCacheSeconds = 3,
    BagAttributeNames = {"BagCount", "CandyBag", "CandiesCollected", "CollectedCandies", "CoinsCollected"},
    BagValuePaths = {}, -- Ex.: { {"RoundData", "BagCount"} }, relativo ao Player.
    CoinNames = {Coin_Server = true, Coin = true, CoinPart = true,
        Candy = true, Candy_Server = true, CandyToken = true},
    CoinTag = "FarmCoin",
    GunDropNames = {GunDrop = true, DroppedGun = true, GunPickup = true},
    CorrectionDistance = 18, MaxCorrections = 2, CorrectionWindow = 3,
    -- ShootAdapter / KnifeAdapter podem ser definidos para outro protocolo do jogo.
}

if not game:IsLoaded() then game.Loaded:Wait() end

local function createUI(callbacks, initialSpeed)
    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")
    local player = Players.LocalPlayer
    while not player do
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
        player = Players.LocalPlayer
    end
    callbacks = callbacks or {}
    local connections, api, toggles = {}, {}, {}
    local alive, minimized = true, false
    local mode, speed = "Auto farm fast", 15
    local values = {farm = false, esp = false, reset = false, shoot = false,
        killall = false, pickup = false, names = true, distance = false}
    local sliding, sliderInput, dragging, dragInput, dragStart, startPosition
    local cameraConnection
    local colors = {
        bg = Color3.fromRGB(26, 16, 41), sidebar = Color3.fromRGB(34, 22, 52),
        row = Color3.fromRGB(46, 30, 67), selected = Color3.fromRGB(70, 43, 98),
        text = Color3.fromRGB(245, 239, 255), muted = Color3.fromRGB(174, 159, 194),
        purple = Color3.fromRGB(177, 115, 247), lime = Color3.fromRGB(193, 249, 143),
        line = Color3.fromRGB(77, 48, 105),
    }
    local function connect(signal, callback)
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end
    local function make(class, properties, parent)
        local instance = Instance.new(class)
        for key, value in pairs(properties) do instance[key] = value end
        instance.Parent = parent
        return instance
    end
    local function round(object, radius)
        make("UICorner", {CornerRadius = UDim.new(0, radius or 9)}, object)
    end
    local function label(parent, text, position, size, sizeText, color)
        return make("TextLabel", {Position = position, Size = size,
            BackgroundTransparency = 1, Font = Enum.Font.Gotham,
            Text = text, TextSize = sizeText or 13, TextColor3 = color or colors.text,
            TextXAlignment = Enum.TextXAlignment.Left}, parent)
    end
    local function button(parent, text, position, size)
        local object = make("TextButton", {Position = position, Size = size,
            BackgroundColor3 = colors.row, BorderSizePixel = 0,
            Font = Enum.Font.GothamMedium, Text = text, TextSize = 13,
            TextColor3 = colors.text, AutoButtonColor = true}, parent)
        round(object)
        return object
    end
    local function emit(name, value)
        if alive and type(callbacks[name]) == "function" then callbacks[name](value) end
    end
    local gui = make("ScreenGui", {Name = "MMFarmPanelV1", ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 40},
        player:WaitForChild("PlayerGui"))
    local cleanup = make("BindableEvent", {Name = "Cleanup"}, gui)
    local panel = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(600, 430),
        BackgroundColor3 = colors.bg, BorderSizePixel = 0}, gui)
    round(panel, 16)
    make("UIStroke", {Color = colors.line, Thickness = 1.5}, panel)
    local scale = make("UIScale", {Scale = 1}, panel)
    local header = make("Frame", {Size = UDim2.new(1, 0, 0, 60),
        BackgroundTransparency = 1}, panel)
    local icon = label(header, "MM", UDim2.fromOffset(14, 12), UDim2.fromOffset(38, 36), 15, colors.bg)
    icon.BackgroundTransparency, icon.BackgroundColor3 = 0, colors.lime
    icon.TextXAlignment, icon.Font = Enum.TextXAlignment.Center, Enum.Font.GothamBold
    round(icon, 11)
    local title = label(header, "MURDER MYSTERY", UDim2.fromOffset(64, 10), UDim2.fromOffset(390, 23), 18)
    title.Font = Enum.Font.GothamBold
    label(header, "FARM  /  COMBATE  /  VISUAL", UDim2.fromOffset(65, 33), UDim2.fromOffset(385, 18), 10, colors.purple)
    local dragHandle = make("Frame", {Size = UDim2.new(1, -95, 1, 0),
        BackgroundTransparency = 1, Active = true}, header)
    local minimize = button(header, "−", UDim2.new(1, -82, 0, 15), UDim2.fromOffset(30, 30))
    local close = button(header, "×", UDim2.new(1, -44, 0, 15), UDim2.fromOffset(30, 30))
    local body = make("Frame", {Position = UDim2.fromOffset(12, 70),
        Size = UDim2.new(1, -24, 0, 304), BackgroundTransparency = 1}, panel)
    local sidebar = make("Frame", {Size = UDim2.fromOffset(136, 304),
        BackgroundColor3 = colors.sidebar, BorderSizePixel = 0}, body)
    round(sidebar, 11)
    local content = make("Frame", {Position = UDim2.fromOffset(152, 0),
        Size = UDim2.new(1, -152, 1, 0), BackgroundTransparency = 1}, body)
    local pages, tabs = {}, {}
    local descriptions = {
        ["Auto farm"] = "Escolhe o modo e ajusta a rota automática.",
        Combate = "Ações automáticas conforme tua função e bolsa.",
        Visual = "Identifica os jogadores através das paredes.",
        Ajustes = "Como funcionam as automações do painel.",
    }
    for index, name in ipairs({"Auto farm", "Combate", "Visual", "Ajustes"}) do
        tabs[name] = button(sidebar, "", UDim2.fromOffset(8, 8 + (index - 1) * 48), UDim2.fromOffset(120, 40))
        local tabLabel = label(tabs[name], name, UDim2.fromOffset(12, 0), UDim2.new(1, -20, 1, 0), 13)
        tabLabel.Font = Enum.Font.GothamMedium
        local page = make("Frame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false}, content)
        local heading = label(page, string.upper(name), UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 23), 17)
        heading.Font = Enum.Font.GothamBold
        label(page, descriptions[name], UDim2.fromOffset(0, 27), UDim2.new(1, 0, 0, 24), 11, colors.muted)
        pages[name] = page
        connect(tabs[name].Activated, function()
            for pageName, item in pairs(pages) do
                item.Visible = pageName == name
                tabs[pageName].BackgroundColor3 = pageName == name and colors.selected or colors.row
                tabs[pageName]:FindFirstChildOfClass("TextLabel").TextColor3 = pageName == name and colors.lime or colors.text
            end
        end)
    end
    pages["Auto farm"].Visible = true
    tabs["Auto farm"].BackgroundColor3 = colors.selected
    tabs["Auto farm"]:FindFirstChildOfClass("TextLabel").TextColor3 = colors.lime
    label(sidebar, "TUA FUNÇÃO", UDim2.fromOffset(12, 218), UDim2.fromOffset(112, 17), 9, colors.muted)
    local roleLabel = label(sidebar, "Desconhecido", UDim2.fromOffset(12, 238), UDim2.fromOffset(112, 22), 12, colors.lime)
    roleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    local bagLabel = label(sidebar, "Bolsa: -- / 50", UDim2.fromOffset(12, 269), UDim2.fromOffset(112, 20), 11, colors.purple)
    local status = label(panel, "Pronto.", UDim2.fromOffset(16, 385), UDim2.new(1, -32, 0, 33), 11, colors.muted)
    status.TextWrapped, status.TextYAlignment = true, Enum.TextYAlignment.Top

    local function paintToggle(key)
        local row = toggles[key]
        if not row then return end
        local enabled = values[key] == true
        row.pill.Text = enabled and "ON" or "OFF"
        row.pill.BackgroundColor3 = enabled and colors.lime or colors.selected
        row.pill.TextColor3 = enabled and colors.bg or colors.muted
        row.title.TextColor3 = enabled and colors.lime or colors.text
    end
    local function toggle(parent, text, y, key, callback)
        local row = button(parent, "", UDim2.fromOffset(0, y), UDim2.new(1, 0, 0, 38))
        local textLabel = label(row, text, UDim2.fromOffset(12, 0), UDim2.new(1, -82, 1, 0), 12)
        local pill = label(row, "OFF", UDim2.new(1, -61, 0, 8), UDim2.fromOffset(49, 22), 10)
        pill.BackgroundTransparency, pill.BackgroundColor3 = 0, colors.selected
        pill.TextXAlignment, pill.Font = Enum.TextXAlignment.Center, Enum.Font.GothamBold
        round(pill, 7)
        toggles[key] = {title = textLabel, pill = pill}
        paintToggle(key)
        connect(row.Activated, function()
            values[key] = not values[key]
            paintToggle(key)
            emit(callback, values[key])
        end)
    end
    local farmPage = pages["Auto farm"]
    toggle(farmPage, "Auto farm", 58, "farm", "onFarm")
    local fastButton = button(farmPage, "Auto farm fast", UDim2.fromOffset(0, 104), UDim2.new(0.5, -4, 0, 38))
    local underButton = button(farmPage, "Under mapa", UDim2.new(0.5, 4, 0, 104), UDim2.new(0.5, -4, 0, 38))
    toggle(farmPage, "Auto reset · bolsa 50", 150, "reset", "onResetBag50")
    label(farmPage, "Velocidade do farm · 15 a 29", UDim2.fromOffset(0, 204), UDim2.new(1, -66, 0, 26), 12, colors.muted)
    local speedBox = make("TextBox", {Position = UDim2.new(1, -54, 0, 204), Size = UDim2.fromOffset(54, 27),
        BackgroundColor3 = colors.row, BorderSizePixel = 0, Font = Enum.Font.GothamMedium,
        TextSize = 14, TextColor3 = colors.lime, ClearTextOnFocus = false, Text = "15"}, farmPage)
    round(speedBox, 7)
    local slider = make("Frame", {Position = UDim2.fromOffset(0, 239), Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1, Active = true}, farmPage)
    local track = make("Frame", {Position = UDim2.new(0, 8, 0.5, -3), Size = UDim2.new(1, -16, 0, 6),
        BackgroundColor3 = colors.selected, BorderSizePixel = 0}, slider)
    round(track, 3)
    local fill = make("Frame", {Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = colors.lime, BorderSizePixel = 0}, track)
    round(fill, 3)
    local knob = make("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(16, 16), BackgroundColor3 = colors.lime, BorderSizePixel = 0}, track)
    round(knob, 8)
    label(farmPage, "A velocidade altera apenas o deslocamento do farm.", UDim2.fromOffset(0, 274), UDim2.new(1, 0, 0, 22), 10, colors.muted)
    toggle(pages.Combate, "Auto shoot Murder · bolsa 50", 58, "shoot", "onShootMurderBag50")
    toggle(pages.Combate, "Auto kill all Murder · bolsa 50", 108, "killall", "onKillAllBag50")
    toggle(pages.Combate, "Auto pickup gun", 158, "pickup", "onPickupGun")
    local combatNote = label(pages.Combate, "Bolsa 50: Xerife atira no Assassino; Assassino tenta eliminar os demais. A identificação da função controla cada ação.", UDim2.fromOffset(0, 220), UDim2.new(1, 0, 0, 76), 11, colors.muted)
    combatNote.TextWrapped, combatNote.TextYAlignment = true, Enum.TextYAlignment.Top
    toggle(pages.Visual, "ESP por função", 58, "esp", "onESP")
    toggle(pages.Visual, "Mostrar nomes", 108, "names", "onESPNames")
    toggle(pages.Visual, "Mostrar distância", 158, "distance", "onESPDistance")
    local legend = label(pages.Visual, "VERDE · Inocente     AZUL · Xerife\nVERMELHO · Assassino     AMARELO · Herói\nSem confirmação: Desconhecido.", UDim2.fromOffset(0, 222), UDim2.new(1, 0, 0, 74), 11, colors.muted)
    legend.TextWrapped, legend.TextYAlignment = true, Enum.TextYAlignment.Top
    local help = label(pages.Ajustes, "AUTO RESET BOLSA 50\nAo chegar a 50, reinicia somente se a função confirmada for Inocente.\n\nUNDER MAPA\nPercorre a rota deitado abaixo do mapa.\n\nCONTROLES\nArrasta o cabeçalho para mover. O botão − minimiza. Fechar encerra as automações e restaura o personagem.", UDim2.fromOffset(0, 59), UDim2.new(1, 0, 0, 240), 12, colors.muted)
    help.TextWrapped, help.TextYAlignment = true, Enum.TextYAlignment.Top

    function api.setSpeed(value)
        if not alive then return end
        local parsed = tonumber(value)
        if not parsed or parsed ~= parsed then parsed = speed end
        speed = math.clamp(math.floor(parsed + 0.5), 15, 29)
        speedBox.Text = tostring(speed)
        local ratio = (speed - 15) / 14
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.fromScale(ratio, 0.5)
    end
    function api.setOption(key, value)
        if not alive or values[key] == nil then return end
        values[key] = value == true
        paintToggle(key)
    end
    function api.setFarm(value) api.setOption("farm", value) end
    function api.setESP(value) api.setOption("esp", value) end
    function api.setMode(value)
        if not alive then return end
        mode = value == "Under mapa" and "Under mapa" or "Auto farm fast"
        fastButton.BackgroundColor3 = mode == "Auto farm fast" and colors.selected or colors.row
        underButton.BackgroundColor3 = mode == "Under mapa" and colors.selected or colors.row
        fastButton.TextColor3 = mode == "Auto farm fast" and colors.lime or colors.muted
        underButton.TextColor3 = mode == "Under mapa" and colors.lime or colors.muted
    end
    function api.setTelemetry(role, bag)
        if not alive then return end
        roleLabel.Text = tostring(role or "Desconhecido")
        bagLabel.Text = "Bolsa: " .. tostring(bag or "-- / 50")
    end
    function api.setStatus(text)
        if alive then status.Text = tostring(text or "") end
    end
    function api.destroy()
        if not alive then return end
        alive, sliding, dragging = false, false, false
        if cameraConnection then cameraConnection:Disconnect() end
        for _, connection in ipairs(connections) do connection:Disconnect() end
        connections = {}
        gui:Destroy()
    end
    api.gui, api.cleanup = gui, cleanup
    api.setSpeed(initialSpeed or 15)
    api.setMode(mode)

    local function fit()
        if not alive then return end
        local camera = Workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize or gui.AbsoluteSize
        scale.Scale = math.max(0.1, math.min(1, (viewport.X - 24) / 600, (viewport.Y - 24) / 430))
    end
    local function bindCamera()
        if cameraConnection then cameraConnection:Disconnect() end
        local camera = Workspace.CurrentCamera
        cameraConnection = camera and camera:GetPropertyChangedSignal("ViewportSize"):Connect(fit) or nil
        fit()
    end
    connect(Workspace:GetPropertyChangedSignal("CurrentCamera"), bindCamera)
    bindCamera()
    connect(fastButton.Activated, function() api.setMode("Auto farm fast"); emit("onMode", mode) end)
    connect(underButton.Activated, function() api.setMode("Under mapa"); emit("onMode", mode) end)
    connect(speedBox.FocusLost, function() api.setSpeed(speedBox.Text); emit("onSpeed", speed) end)
    local function updateSlider(x)
        if track.AbsoluteSize.X <= 0 then return end
        local previous = speed
        api.setSpeed(15 + math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1) * 14)
        if previous ~= speed then emit("onSpeed", speed) end
    end
    connect(slider.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding, sliderInput = true, input
            updateSlider(input.Position.X)
        end
    end)
    connect(dragHandle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragInput, dragStart, startPosition = true, input, input.Position, panel.Position
        end
    end)
    connect(UIS.InputChanged, function(input)
        local mouse = input.UserInputType == Enum.UserInputType.MouseMovement
        if sliding and (input == sliderInput or mouse and sliderInput.UserInputType == Enum.UserInputType.MouseButton1) then updateSlider(input.Position.X) end
        if dragging and (input == dragInput or mouse and dragInput.UserInputType == Enum.UserInputType.MouseButton1) then
            local delta, viewport = input.Position - dragStart, gui.AbsoluteSize
            local half = panel.AbsoluteSize / 2
            local x = startPosition.X.Scale * viewport.X + startPosition.X.Offset + delta.X
            local y = startPosition.Y.Scale * viewport.Y + startPosition.Y.Offset + delta.Y
            panel.Position = UDim2.fromOffset(math.clamp(x, half.X, math.max(half.X, viewport.X - half.X)),
                math.clamp(y, half.Y, math.max(half.Y, viewport.Y - half.Y)))
        end
    end)
    connect(UIS.InputEnded, function(input)
        if input == sliderInput then sliding, sliderInput = false, nil end
        if input == dragInput then dragging, dragInput = false, nil end
    end)
    connect(UIS.WindowFocusReleased, function() sliding, dragging = false, false end)
    connect(minimize.Activated, function()
        minimized = not minimized
        body.Visible, status.Visible = not minimized, not minimized
        panel.Size = UDim2.fromOffset(600, minimized and 60 or 430)
        minimize.Text = minimized and "+" or "−"
    end)
    connect(close.Activated, function()
        if type(callbacks.onClose) == "function" then emit("onClose") else api.destroy() end
    end)
    return api
end


-- Dados compartilhados: ações usam funções confirmadas; armas só ajudam o ESP.
local function createESP(config)
    config = config or {}
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")
    local localPlayer = Players.LocalPlayer
    local refreshSeconds = math.max(1, config.RoleRefreshSeconds or 1)
    local cacheSeconds = math.max(refreshSeconds, config.RoleCacheSeconds or 3)
    local remoteName = config.RoleRemoteName or "GetPlayerData"
    local bagLimit = config.BagLimit or 50
    local bagAttributes = config.BagAttributeNames or {
        "BagCount", "CandyBag", "CandiesCollected", "CollectedCandies", "CoinsCollected",
    }
    local enabled, names, distances, destroyed = false, true, false, false
    local inFlight, generation, nextQuery, queryStarted = false, 0, 0, 0
    local queryTask, pollTask
    local cache, visuals = {}, {}
    local bagRespawnDelay = config.BagRespawnDelaySeconds or 0.75
    local bagNextCheck, bagCharacter, bagCount, bagSource = 0, localPlayer.Character, nil, "contador indisponível"
    local bagCharacterSince = os.clock() - bagRespawnDelay
    local roles = {
        Innocent = {label = "Inocente", color = Color3.fromRGB(172, 255, 151)},
        Sheriff = {label = "Xerife", color = Color3.fromRGB(111, 184, 255)},
        GunHolder = {label = "Xerife / Herói", color = Color3.fromRGB(111, 184, 255)},
        Murderer = {label = "Assassino", color = Color3.fromRGB(255, 91, 134)},
        Hero = {label = "Herói", color = Color3.fromRGB(255, 219, 112)},
        Unknown = {label = "Desconhecido", color = Color3.fromRGB(190, 176, 210)},
    }
    local aliases = {
        innocent = "Innocent", inocente = "Innocent", innocente = "Innocent",
        sheriff = "Sheriff", sherif = "Sheriff", xerife = "Sheriff",
        murderer = "Murderer", murder = "Murderer", assassino = "Murderer",
        hero = "Hero", heroi = "Hero", ["herói"] = "Hero",
    }

    local function normalize(value)
        if type(value) ~= "string" then return nil end
        return aliases[string.lower(value)]
    end

    local function roleOn(instance)
        if not instance then return nil end
        local found
        local function accept(value)
            local role = normalize(value)
            if role and found and role ~= found then return false end
            if role then found = role end
            return true
        end
        for _, key in ipairs({"Role", "PlayerRole"}) do
            if not accept(instance:GetAttribute(key)) then return nil, true end
            local value = instance:FindFirstChild(key)
            if value and value:IsA("StringValue") then
                if not accept(value.Value) then return nil, true end
            end
        end
        return found, false
    end

    local function weaponRole(player, character)
        local gun = false
        local containers = {character}
        local backpack = player:FindFirstChildOfClass("Backpack")
        if backpack then table.insert(containers, backpack) end
        for _, container in ipairs(containers) do
            for _, item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") then
                    local name = string.lower(item.Name)
                    if name == "knife" then return "Murderer" end
                    if name == "gun" then gun = true end
                end
            end
        end
        return gun and "GunHolder" or nil
    end

    local function confirmedRole(player, now)
        if destroyed or not player or player.Parent ~= Players then return nil end
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 or not character:IsDescendantOf(Workspace) then
            cache[player] = nil
            return nil
        end
        local entry = cache[player]
        if entry and (entry.character ~= character or now - entry.timestamp > cacheSeconds) then
            cache[player], entry = nil, nil
        end
        if player:GetAttribute("Dead") == true or character:GetAttribute("Dead") == true
            or (entry and entry.dead) then return nil end
        local playerRole, playerConflict = roleOn(player)
        local characterRole, characterConflict = roleOn(character)
        if playerConflict or characterConflict then return nil end
        local role = playerRole or characterRole or (entry and entry.role)
        for _, candidate in ipairs({playerRole or false, characterRole or false, entry and entry.role or false}) do
            if candidate and role and candidate ~= role then return nil end
        end
        -- Uma arma recém-recolhida invalida o antigo Innocent antes da consulta seguinte.
        -- Assim o auto reset não confunde o novo herói com um inocente sem arma.
        if role == "Innocent" and weaponRole(player, character) then return nil end
        if not role then return nil end
        return role, {
            source = (playerRole or characterRole) and "replicated" or "remote",
            timestamp = (playerRole or characterRole) and now or entry.timestamp,
            queriedAt = (playerRole or characterRole) and now or entry.queriedAt,
            character = character,
        }
    end

    local function clearVisual(player)
        local visual = visuals[player]
        if visual then
            visual.highlight:Destroy()
            visual.billboard:Destroy()
            visuals[player] = nil
        end
    end

    local function clearAll()
        for player in pairs(visuals) do clearVisual(player) end
    end

    local function cancelQuery()
        generation = generation + 1
        local old = queryTask
        queryTask, inFlight = nil, false
        if old then pcall(task.cancel, old) end
    end

    local function queryRoles(now, force)
        if inFlight then
            if now - queryStarted <= cacheSeconds then return end
            cancelQuery()
        end
        if now < nextQuery then return end
        nextQuery = now + refreshSeconds
        local needsRemote = false
        for _, player in ipairs(Players:GetPlayers()) do
            local playerRole, playerConflict = roleOn(player)
            local characterRole, characterConflict = roleOn(player.Character)
            if (not playerRole and not characterRole) or playerConflict or characterConflict
                or (playerRole and characterRole and playerRole ~= characterRole) then
                needsRemote = true break
            end
        end
        if not needsRemote and not force then return end
        local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
        if not remote or not remote:IsA("RemoteFunction") then return end
        inFlight, queryStarted = true, now
        local token, characters = generation, {}
        for _, player in ipairs(Players:GetPlayers()) do characters[player] = player.Character end
        queryTask = task.spawn(function()
            local ok, data = pcall(function() return remote:InvokeServer() end)
            if token ~= generation then return end
            queryTask, inFlight = nil, false
            if destroyed or not ok or type(data) ~= "table" or os.clock() - now > cacheSeconds then return end
            local updated, receivedAt = {}, os.clock()
            for _, player in ipairs(Players:GetPlayers()) do
                local entry = data[player.Name] or data[tostring(player.UserId)] or data[player.UserId]
                if type(entry) == "table" and characters[player] == player.Character then
                    updated[player] = {
                        role = normalize(entry.Role), dead = entry.Dead == true or entry.Killed == true,
                        character = characters[player], timestamp = receivedAt, queriedAt = now,
                    }
                end
            end
            cache = updated
        end)
    end

    local function validCount(value)
        return type(value) == "number" and value == value and value >= 0
            and value <= bagLimit and value == math.floor(value)
    end

    local function parseCount(text)
        if type(text) ~= "string" then return nil end
        local current, capacity = text:match("^%s*(%d+)%s*/%s*(%d+)%s*$")
        if current then
            current, capacity = tonumber(current), tonumber(capacity)
            if capacity == bagLimit and validCount(current) then return current, true end
            return nil
        end
        local plain = text:match("^%s*(%d+)%s*$")
        local value = plain and tonumber(plain)
        if validCount(value) then return value, false end
        return nil
    end

    local function pathFromPlayer(path)
        local instance = localPlayer
        local pieces = path
        if type(path) == "string" then
            pieces = {}
            for name in path:gmatch("[^%.%/]+") do table.insert(pieces, name) end
        end
        if type(pieces) ~= "table" then return nil end
        for _, name in ipairs(pieces) do
            if type(name) ~= "string" or not instance then return nil end
            instance = instance:FindFirstChild(name)
        end
        return instance
    end

    local function visibleWithin(instance, root)
        local current = instance
        while current do
            if current:IsA("GuiObject") and not current.Visible then return false end
            if current:IsA("ScreenGui") and not current.Enabled then return false end
            if current == root then return true end
            current = current.Parent
        end
        return false
    end

    local function readBag()
        for _, path in ipairs(config.BagValuePaths or {}) do
            local value = pathFromPlayer(path)
            if value then
                if (value:IsA("IntValue") or value:IsA("NumberValue")) and validCount(value.Value) then
                    return value.Value, "caminho configurado: " .. value.Name
                end
                if value:IsA("TextLabel") or value:IsA("TextBox") then
                    local count = parseCount(value.Text)
                    if count and visibleWithin(value, localPlayer:FindFirstChild("PlayerGui")) then
                        return count, "contador configurado: " .. value.Name
                    end
                end
            end
        end
        for _, owner in ipairs({localPlayer, localPlayer.Character}) do
            for _, name in ipairs(bagAttributes) do
                local value = owner:GetAttribute(name)
                if validCount(value) then return value, "atributo: " .. name end
                local child = owner:FindFirstChild(name)
                if child and (child:IsA("IntValue") or child:IsA("NumberValue"))
                    and validCount(child.Value) then return child.Value, "valor: " .. name end
            end
        end
        local gui = localPlayer:FindFirstChild("PlayerGui")
        local main = gui and gui:FindFirstChild("MainGUI")
        local gameGui = main and main:FindFirstChild("Game")
        local bags = gameGui and gameGui:FindFirstChild("CoinBags")
        if not bags or not visibleWithin(bags, gui) then return nil, "contador indisponível" end
        local bestScore, bestCount, bestSource, ambiguous
        for _, label in ipairs(bags:GetDescendants()) do
            if label:IsA("TextLabel") or label:IsA("TextBox") then
                local name = string.lower(label.Name)
                if name == "amount" or name == "count" or name == "collected" then
                    local count, fraction = parseCount(label.Text)
                    if count and visibleWithin(label, bags) then
                        local candy, collected, reject = false, name == "collected", false
                        local ancestor = label.Parent
                        while ancestor and ancestor ~= bags do
                            local ancestorName = string.lower(ancestor.Name)
                            if ancestorName:find("candy", 1, true) or ancestorName:find("candies", 1, true)
                                or ancestorName:find("halloween", 1, true) then candy = true end
                            if ancestorName == "collected" then collected = true end
                            if ancestorName:find("capacity", 1, true) or ancestorName:match("^max")
                                or ancestorName:match("^total") or ancestorName:find("wallet", 1, true) then reject = true end
                            ancestor = ancestor.Parent
                        end
                        if not reject and (collected or fraction or name == "count") then
                            local score = (candy and 20 or 0) + (collected and 10 or 0)
                                + (fraction and 4 or 0) + (name == "count" and 2 or 0)
                            if not bestScore or score > bestScore then
                                bestScore, bestCount, bestSource, ambiguous = score, count,
                                    "GUI CoinBags" .. (candy and " (candies)" or ""), false
                            elseif score == bestScore and count ~= bestCount then
                                ambiguous = true
                            end
                        end
                    end
                end
            end
        end
        if ambiguous then return nil, "contadores ambíguos" end
        return bestCount, bestSource or "contador indisponível"
    end

    local function getBag()
        if destroyed then return nil, "encerrado" end
        local now = os.clock()
        if bagCharacter ~= localPlayer.Character then
            bagNextCheck, bagCharacter, bagCharacterSince, bagCount = 0, localPlayer.Character, now, nil
        end
        local humanoid = bagCharacter and bagCharacter:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then return nil, "aguardando personagem vivo" end
        if now - bagCharacterSince < bagRespawnDelay then return nil, "aguardando bolsa da nova vida" end
        if now >= bagNextCheck then
            bagNextCheck, bagCharacter = now + 0.2, localPlayer.Character
            bagCount, bagSource = readBag()
        end
        return bagCount, bagSource
    end

    local function updateVisual(player, character, adornee, role)
        local visual = visuals[player]
        if visual and (visual.character ~= character or not visual.highlight.Parent
            or not visual.billboard.Parent) then clearVisual(player) visual = nil end
        if not visual then
            local highlight = Instance.new("Highlight")
            highlight.Name, highlight.Adornee = "MMRoleHighlight", character
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillTransparency, highlight.OutlineTransparency = 0.76, 0
            highlight.Parent = character
            local billboard = Instance.new("BillboardGui")
            billboard.Name, billboard.AlwaysOnTop = "MMRoleLabel", true
            billboard.Size = UDim2.fromOffset(190, 62)
            billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.4, 0)
            billboard.MaxDistance, billboard.Parent = 5000, character
            local label = Instance.new("TextLabel")
            label.Size, label.BackgroundTransparency = UDim2.fromScale(1, 1), 1
            label.Font, label.TextSize = Enum.Font.GothamBold, 14
            label.TextStrokeTransparency, label.Parent = 0.3, billboard
            visual = {character = character, highlight = highlight, billboard = billboard, label = label}
            visuals[player] = visual
        end
        local style = roles[role] or roles.Unknown
        visual.highlight.FillColor, visual.highlight.OutlineColor = style.color, style.color
        visual.billboard.Adornee, visual.label.TextColor3 = adornee, style.color
        local lines = {}
        if names then table.insert(lines, player.DisplayName) end
        table.insert(lines, style.label)
        local ownRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if distances and ownRoot then
            table.insert(lines, tostring(math.floor((ownRoot.Position - adornee.Position).Magnitude + 0.5)) .. " studs")
        end
        visual.label.Text = table.concat(lines, "\n")
    end

    pollTask = task.spawn(function()
        while not destroyed do
            local now = os.clock()
            -- A telemetria e as ações continuam recebendo funções com o ESP desligado.
            queryRoles(now)
            for player in pairs(cache) do
                if player.Parent ~= Players then cache[player] = nil end
            end
            if enabled then
                for player in pairs(visuals) do
                    if player.Parent ~= Players then clearVisual(player) end
                end
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= localPlayer then
                        local character = player.Character
                        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                        local adornee = character and (character:FindFirstChild("HumanoidRootPart")
                            or character:FindFirstChild("Head"))
                        if humanoid and humanoid.Health > 0 and adornee and character:IsDescendantOf(Workspace)
                            and player:GetAttribute("Dead") ~= true and character:GetAttribute("Dead") ~= true then
                            local role = confirmedRole(player, now) or weaponRole(player, character) or "Unknown"
                            local entry = cache[player]
                            if entry and entry.dead then clearVisual(player)
                            else updateVisual(player, character, adornee, role) end
                        else
                            cache[player] = nil
                            clearVisual(player)
                        end
                    end
                end
            end
            task.wait(0.25)
        end
    end)

    return {
        getRole = function(player) return confirmedRole(player or localPlayer, os.clock()) end,
        getBag = getBag,
        refreshRoles = function()
            if destroyed then return end
            nextQuery = 0
            queryRoles(os.clock(), true)
        end,
        setEnabled = function(value)
            if destroyed then return end
            enabled = value == true
            if not enabled then clearAll() end
        end,
        setNames = function(value) names = value == true end,
        setDistance = function(value) distances = value == true end,
        destroy = function()
            if destroyed then return end
            destroyed, enabled = true, false
            cancelQuery()
            if pollTask then pcall(task.cancel, pollTask) end
            pollTask = nil
            cache = {}
            clearAll()
        end,
    }
end


-- Ações opcionais: só usam função e contagem de bolsa confirmadas pelo provedor.
local function createActions(config, data, hooks)
    config, hooks = config or {}, hooks or {}
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local player = Players.LocalPlayer
    local limit = config.BagLimit or 50
    local options = {reset = false, shoot = false, killall = false, pickup = false}
    local destroyed, resetLatched, inFlight = false, false, false
    local character, workThread, activeKind, startedAt
    local fullBagStarted, waitingNotice
    local seenCharacter, awaitBagClear = false, false
    local generation, nextAttack, nextGunScan = 0, 0, 0
    local cachedGun, cachedGunObject
    local pendingTouches = {}
    local touch = type(firetouchinterest) == "function" and firetouchinterest or nil
    local gunNames = config.GunDropNames or {GunDrop = true, DroppedGun = true}

    local function notify(message)
        if hooks.notify then pcall(hooks.notify, message) end
    end

    local function aliveParts(who)
        local model = who and who.Character
        local humanoid = model and model:FindFirstChildOfClass("Humanoid")
        local root = model and model:FindFirstChild("HumanoidRootPart")
        if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
            return model, humanoid, root
        end
    end

    local function bagFull()
        local count = data.getBag()
        return type(count) == "number" and count == count and count >= limit
    end

    local function confirmedActionRole(who)
        if not fullBagStarted then return nil end
        local role, metadata = data.getRole(who)
        if not role or type(metadata) ~= "table" or metadata.character ~= who.Character then return nil end
        if metadata.source == "remote" then
            -- O início da consulta precisa ser posterior à bolsa cheia: uma resposta
            -- antiga recebida tarde ainda pode descrever a rodada anterior.
            local queriedAt = metadata.queriedAt or metadata.timestamp
            if type(queriedAt) ~= "number" or queriedAt < fullBagStarted then return nil end
        elseif metadata.source ~= "replicated" then
            return nil
        end
        return role
    end

    local function beforeAction(kind)
        if destroyed then return false end
        if not hooks.beforeAction then return true end
        local ok, allowed = pcall(hooks.beforeAction, kind)
        if not ok then notify("Ação pausada: não foi possível encerrar o movimento.") end
        return ok and allowed ~= false and not destroyed
    end

    local function releaseTouches()
        for _, pair in ipairs(pendingTouches) do
            if pair.active then
                pair.active = false
                pcall(touch, pair.handle, pair.root, 1)
            end
        end
        pendingTouches = {}
    end

    local function cancelWork()
        generation = generation + 1
        if workThread then pcall(task.cancel, workThread) end
        workThread, activeKind, startedAt, inFlight = nil, nil, nil, false
        releaseTouches()
    end

    local function findTool(name)
        local model = player.Character
        local backpack = player:FindFirstChildOfClass("Backpack")
        local tool = model and model:FindFirstChild(name)
            or backpack and backpack:FindFirstChild(name)
        if tool and tool:IsA("Tool") then return tool end
    end

    local function equip(tool, humanoid, model)
        if tool.Parent ~= model then humanoid:EquipTool(tool) end
        return tool.Parent == model
    end

    local function runAsync(kind, expectedRole, now, callback)
        if not beforeAction(kind) then return end
        inFlight, activeKind, startedAt = true, kind, now
        local token, initialCharacter = generation, player.Character
        local thread = task.spawn(function()
            -- A função pode mudar entre a leitura da bolsa e o envio da ação.
            if destroyed or token ~= generation or player.Character ~= initialCharacter
                or not options[kind] or confirmedActionRole(player) ~= expectedRole or not bagFull() then
                if token == generation then inFlight, activeKind, startedAt = false, nil, nil end
                return
            end
            local ok, message = pcall(callback)
            if destroyed or token ~= generation then return end
            workThread, activeKind, startedAt, inFlight = nil, nil, nil, false
            if ok then
                if type(message) == "string" then notify(message) end
            else
                notify("Ação não confirmada pelo jogo: " .. tostring(message))
            end
        end)
        if inFlight and token == generation then workThread = thread end
    end

    local function shootMurderer()
        local target
        for _, other in ipairs(Players:GetPlayers()) do
            if other ~= player and confirmedActionRole(other) == "Murderer" and aliveParts(other) then
                target = other
                break
            end
        end
        if not target then return "Sem assassino vivo com função confirmada." end
        if type(config.ShootAdapter) == "function" then
            config.ShootAdapter(player, target)
            return "Tentativa de disparo enviada pelo adaptador configurado."
        end
        local model, humanoid = aliveParts(player)
        local _, _, targetRoot = aliveParts(target)
        local gun = findTool("Gun")
        if not model or not gun or not targetRoot then return "Disparo aguardando arma e alvo vivos." end
        local knifeLocal = gun:FindFirstChild("KnifeLocal")
        local beam = knifeLocal and knifeLocal:FindFirstChild("CreateBeam")
        local remote = beam and beam:FindFirstChild("RemoteFunction")
        if not remote or not remote:IsA("RemoteFunction") then
            return "Disparo indisponível: protocolo da arma não reconhecido."
        end
        if not equip(gun, humanoid, model) then return "Não foi possível equipar a arma." end
        -- Compatibilidade MM2 conhecida. A assinatura pode mudar; o servidor decide o acerto.
        remote:InvokeServer(1, targetRoot.Position, "AH2")
        return "Tentativa de disparo enviada; aguardando confirmação do jogo."
    end

    local function activeVictim(other)
        if other == player then return false end
        local role = confirmedActionRole(other)
        return role == "Innocent" or role == "Sheriff" or role == "Hero"
    end

    local function killAll()
        local targets = {}
        for _, other in ipairs(Players:GetPlayers()) do
            if activeVictim(other) and aliveParts(other) then targets[#targets + 1] = other end
        end
        if #targets == 0 then return "Sem alvos vivos com participação na rodada confirmada." end
        if type(config.KnifeAdapter) == "function" then
            config.KnifeAdapter(player, targets)
            return "Tentativa em todos os alvos enviada pelo adaptador configurado."
        end
        local model, humanoid = aliveParts(player)
        local knife = findTool("Knife")
        local stab = knife and knife:FindFirstChild("Stab")
        local handle = knife and knife:FindFirstChild("Handle")
        if not touch or not stab or not stab:IsA("RemoteEvent")
            or not handle or not handle:IsA("BasePart") then
            return "Ataque indisponível: faca/toque não compatível com este ambiente."
        end
        if not model or not equip(knife, humanoid, model) then return "Não foi possível equipar a faca." end
        -- Todos os contatos são tentados nesta passagem, sem mover o personagem.
        -- Alcance, recarga e eliminações continuam sujeitos à validação do servidor.
        stab:FireServer("Slash")
        local attempted = 0
        for _, other in ipairs(targets) do
            local _, _, root = aliveParts(other)
            if root and activeVictim(other) and pcall(touch, handle, root, 0) then
                pendingTouches[#pendingTouches + 1] = {handle = handle, root = root, active = true}
                attempted = attempted + 1
            end
        end
        task.defer(releaseTouches)
        return "Contato de faca tentado em " .. attempted .. " alvo(s); acertos dependem do servidor."
    end

    local function insideCharacter(instance)
        local ancestor = instance.Parent
        while ancestor and ancestor ~= Workspace do
            if ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid") then return true end
            ancestor = ancestor.Parent
        end
        return false
    end

    local function actionAvailable(kind)
        if kind == "shoot" then
            local hasTarget = false
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= player and confirmedActionRole(other) == "Murderer" and aliveParts(other) then
                    hasTarget = true
                    break
                end
            end
            if not hasTarget then return false, "Sem assassino vivo com função confirmada." end
            if type(config.ShootAdapter) == "function" then return true end
            local gun = findTool("Gun")
            local localScript = gun and gun:FindFirstChild("KnifeLocal")
            local beam = localScript and localScript:FindFirstChild("CreateBeam")
            local remote = beam and beam:FindFirstChild("RemoteFunction")
            if not remote or not remote:IsA("RemoteFunction") then
                return false, "Disparo indisponível: arma/protocolo não reconhecido."
            end
            return true
        end
        if type(config.KnifeAdapter) == "function" then return true end
        local knife = findTool("Knife")
        local stab = knife and knife:FindFirstChild("Stab")
        local handle = knife and knife:FindFirstChild("Handle")
        if not touch or not stab or not stab:IsA("RemoteEvent")
            or not handle or not handle:IsA("BasePart") then
            return false, "Ataque indisponível: faca/toque não compatível com este ambiente."
        end
        return true
    end

    local function gunPart(instance)
        if insideCharacter(instance) then return nil end
        local namedDrop = gunNames[instance.Name] == true
        if instance:IsA("BasePart") then return namedDrop and instance or nil end
        if namedDrop and instance:IsA("Model") then
            return instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart", true)
        end
        if instance:IsA("Tool") and (namedDrop or instance.Name == "Gun") then
            local handle = instance:FindFirstChild("Handle")
            if handle and handle:IsA("BasePart") then return handle end
        end
    end

    return {
        setOption = function(key, value)
            if destroyed or options[key] == nil then return end
            options[key] = value == true
            if not options[key] and activeKind == key then cancelWork() end
        end,
        step = function(now)
            if destroyed then return end
            now = now or os.clock()
            if player.Character ~= character then
                if seenCharacter then awaitBagClear = true end
                if player.Character then seenCharacter = true end
                character, resetLatched, nextAttack = player.Character, false, 0
                fullBagStarted, waitingNotice = nil, nil
                cancelWork()
            end
            local model, humanoid = aliveParts(player)
            if not model then
                if inFlight or #pendingTouches > 0 then cancelWork() end
                fullBagStarted = nil
                return
            end
            local count = data.getBag()
            if type(count) ~= "number" or count ~= count or count < 0 or count < limit then
                if inFlight or #pendingTouches > 0 then cancelWork() end
                if type(count) == "number" and count == count and count >= 0 and count < limit then
                    awaitBagClear = false
                end
                fullBagStarted, waitingNotice, resetLatched = nil, nil, false
                return
            end
            if awaitBagClear then
                if waitingNotice ~= "respawn" then
                    waitingNotice = "respawn"
                    notify("Após respawn: aguardando a bolsa mostrar menos de 50 antes de rearmar ações.")
                end
                return
            end
            if not fullBagStarted then
                fullBagStarted = now
                if type(data.refreshRoles) == "function" then pcall(data.refreshRoles) end
            end
            local role = confirmedActionRole(player)
            local activeRole = activeKind == "shoot" and "Sheriff" or activeKind == "killall" and "Murderer"
            if inFlight and role ~= activeRole then cancelWork() end
            if inFlight and startedAt and now - startedAt > (config.AttackTimeoutSeconds or 4) then
                cancelWork()
                nextAttack = now + 1
                notify("Ação sem resposta do servidor; tentativa encerrada.")
            end
            if not role then
                if waitingNotice ~= "role" and (options.reset or options.shoot or options.killall) then
                    waitingNotice = "role"
                    notify("Bolsa cheia: aguardando confirmação recente da tua função.")
                end
                return
            end
            waitingNotice = nil
            if options.reset and role == "Innocent" and not resetLatched then
                if beforeAction("reset") and confirmedActionRole(player) == "Innocent" and bagFull() then
                    resetLatched = true
                    humanoid.Health = 0
                    notify("Bolsa cheia: reset do inocente solicitado.")
                end
                return
            end
            if inFlight or now < nextAttack then return end
            if options.shoot and role == "Sheriff" then
                nextAttack = now + (config.AttackRetrySeconds or 1)
                local ready, reason = actionAvailable("shoot")
                if ready then runAsync("shoot", "Sheriff", now, shootMurderer) else notify(reason) end
            elseif options.killall and role == "Murderer" then
                nextAttack = now + (config.AttackRetrySeconds or 1)
                local ready, reason = actionAvailable("killall")
                if ready then runAsync("killall", "Murderer", now, killAll) else notify(reason) end
            end
        end,
        findDroppedGun = function(now)
            if destroyed then return nil end
            now = now or os.clock()
            if cachedGun and (not cachedGun.Parent or not cachedGun:IsDescendantOf(Workspace)
                or insideCharacter(cachedGun)) then cachedGun, cachedGunObject = nil, nil end
            if now < nextGunScan then return cachedGun, cachedGunObject end
            nextGunScan = now + 0.5
            local _, _, root = aliveParts(player)
            cachedGun, cachedGunObject = nil, nil
            local bestDistance
            for _, instance in ipairs(Workspace:GetDescendants()) do
                local part = gunPart(instance)
                if part then
                    local distance = root and (root.Position - part.Position).Magnitude or 0
                    if not bestDistance or distance < bestDistance then
                        cachedGun, cachedGunObject, bestDistance = part, instance, distance
                    end
                end
            end
            return cachedGun, cachedGunObject
        end,
        destroy = function()
            if destroyed then return end
            destroyed = true
            cancelWork()
            cachedGun, cachedGunObject = nil, nil
        end,
    }
end


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerDeadline = os.clock() + 30
while not player and os.clock() < playerDeadline do
    task.wait(0.1)
    player = Players.LocalPlayer
end
assert(player, "O cliente não disponibilizou LocalPlayer em 30 segundos. Execute novamente após entrar no jogo.")
local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("MMFarmPanelV1")
if previous then
    local cleanup = previous:FindFirstChild("Cleanup")
    if cleanup and cleanup:IsA("BindableEvent") then cleanup:Fire() end
    previous:Destroy()
end

local state = {farm = false, pickup = false, mode = "Auto farm fast",
    speed = CONFIG.DefaultSpeed, surfaceHeight = CONFIG.NormalHeightAboveCoin, destroyed = false}
local coins, connections = {}, {}
local cooldown = setmetatable({}, {__mode = "k"})
local movement, target, contact, ui, actions
local nextSearch, nextTelemetry, pauseUntil, statusUntil = 0, 0, 0, 0
local data = createESP(CONFIG)
local touchInterest = type(firetouchinterest) == "function" and firetouchinterest or nil

local function connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    return connection
end

local function notify(message, holdSeconds)
    if not ui or state.destroyed then return end
    statusUntil = os.clock() + (holdSeconds or 2)
    ui.setStatus(message)
end

local function farmStatus(message)
    if ui and os.clock() >= statusUntil then ui.setStatus(message) end
end

local function characterParts()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if humanoid and humanoid.Health > 0 and root and root:IsA("BasePart") then
        return character, humanoid, root
    end
end

local function isCoin(part)
    if not part:IsA("BasePart") then return false end
    local ancestor = part.Parent
    while ancestor and ancestor ~= Workspace do
        if ancestor:IsA("Model") and ancestor:FindFirstChildOfClass("Humanoid") then return false end
        ancestor = ancestor.Parent
    end
    if CONFIG.CoinNames[part.Name] or part:GetAttribute("FarmCoin") == true
        or CollectionService:HasTag(part, CONFIG.CoinTag) then return true end
    local model = part.Parent
    return model and model:IsA("Model") and CONFIG.CoinNames[model.Name] == true
        and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) == part
end

local function indexCoin(part)
    if isCoin(part) and part:IsDescendantOf(Workspace) then coins[part] = true end
end

local function clearTarget()
    target, contact, nextSearch = nil, nil, 0
end

local function floorAt(cframe, character)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    params.RespectCanCollide = true
    return Workspace:Raycast(cframe.Position + Vector3.new(0, 3, 0),
        Vector3.new(0, -(state.surfaceHeight + 22), 0), params)
end

local function stopMovement(returnToSurface)
    local old = movement
    movement = nil
    if not old then return end
    old.positionHold:Destroy()
    old.rotationHold:Destroy()
    old.attachment:Destroy()
    if old.root.Parent and old.humanoid.Parent then
        if old.humanoid.Health > 0 then
            local returnPose = CFrame.new(old.root.Position) * old.uprightRotation
            local returnOrigin = old.kind == "gun" and not state.farm
            if returnToSurface and (old.mode == "Under mapa" or old.inContact or returnOrigin) then
                local candidates = returnOrigin and {old.origin, old.surface} or {old.surface, old.origin}
                for _, candidate in ipairs(candidates) do
                    local floor = floorAt(candidate, old.character)
                    if floor then
                        returnPose = CFrame.new(floor.Position + Vector3.new(0, state.surfaceHeight, 0))
                            * old.uprightRotation
                        break
                    end
                end
            end
            old.root.CFrame = returnPose
            old.root.AssemblyLinearVelocity = Vector3.zero
            old.root.AssemblyAngularVelocity = Vector3.zero
        end
        old.humanoid.AutoRotate = old.autoRotate
        old.humanoid.PlatformStand = old.platformStand
        if old.mode == "Under mapa" and not old.platformStand and old.humanoid.Health > 0 then
            old.humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
    for part, value in pairs(old.collisions) do
        if part.Parent then part.CanCollide = value end
    end
end

local function disableCollisions(session)
    for _, part in ipairs(session.character:GetDescendants()) do
        if part:IsA("BasePart") then
            if session.collisions[part] == nil then session.collisions[part] = part.CanCollide end
            part.CanCollide = false
        end
    end
end

local function poseAt(position, session)
    return CFrame.new(position) * session.uprightRotation
        * (session.mode == "Under mapa" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.new())
end

local function applyPose(session, pose)
    session.expected = pose
    session.positionHold.Position = pose.Position
    session.rotationHold.CFrame = pose.Rotation
    session.root.CFrame = pose
    session.root.AssemblyLinearVelocity = Vector3.zero
    session.root.AssemblyAngularVelocity = Vector3.zero
end

local function startMovement(character, humanoid, root, kind)
    local mode = kind == "gun" and "Auto farm fast" or state.mode
    if movement and movement.character == character and movement.root == root
        and movement.mode == mode and movement.kind == kind then return end
    stopMovement(true)
    local attachment = Instance.new("Attachment")
    attachment.Name, attachment.Parent = "MMFarmAttachment", root
    local positionHold = Instance.new("AlignPosition")
    positionHold.Name = "MMFarmPosition"
    positionHold.Mode = Enum.PositionAlignmentMode.OneAttachment
    positionHold.Attachment0 = attachment
    positionHold.ApplyAtCenterOfMass = true
    positionHold.MaxForce, positionHold.MaxVelocity = math.huge, math.huge
    positionHold.Responsiveness, positionHold.RigidityEnabled = 200, true
    positionHold.Position = root.Position
    positionHold.Parent = root
    local rotationHold = Instance.new("AlignOrientation")
    rotationHold.Name = "MMFarmRotation"
    rotationHold.Mode = Enum.OrientationAlignmentMode.OneAttachment
    rotationHold.Attachment0 = attachment
    rotationHold.MaxTorque, rotationHold.MaxAngularVelocity = math.huge, math.huge
    rotationHold.Responsiveness, rotationHold.RigidityEnabled = 200, true
    rotationHold.CFrame = root.CFrame.Rotation
    rotationHold.Parent = root
    movement = {character = character, humanoid = humanoid, root = root, mode = mode, kind = kind,
        origin = root.CFrame, surface = root.CFrame, uprightRotation = root.CFrame.Rotation,
        autoRotate = humanoid.AutoRotate, platformStand = humanoid.PlatformStand,
        positionHold = positionHold, rotationHold = rotationHold, attachment = attachment,
        collisions = {}, corrections = 0, correctionStart = os.clock(), started = os.clock()}
    disableCollisions(movement)
    humanoid.AutoRotate = false
    humanoid:Move(Vector3.zero, false)
    if mode == "Under mapa" then
        humanoid.PlatformStand = true
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        local below = root.Position - Vector3.new(0, CONFIG.UnderMapDepth, 0)
        if below.Y > Workspace.FallenPartsDestroyHeight + 12 then
            applyPose(movement, poseAt(below, movement))
        else
            applyPose(movement, poseAt(root.Position, movement))
        end
    else
        applyPose(movement, poseAt(root.Position, movement))
    end
end

local function destination(part, kind)
    if kind ~= "gun" and state.mode == "Under mapa" then
        return part.Position - Vector3.new(0, CONFIG.UnderMapDepth, 0)
    end
    return part.Position + Vector3.new(0, state.surfaceHeight, 0)
end

local function available(part, kind, now)
    return part and part.Parent and part:IsDescendantOf(Workspace)
        and part:GetAttribute("Collected") ~= true and (cooldown[part] or 0) <= now
        and destination(part, kind).Y > Workspace.FallenPartsDestroyHeight + 12
end

local function nearestCoin(position, now)
    local best, bestDistance
    for part in pairs(coins) do
        if available(part, "coin", now) then
            local distance = (destination(part, "coin") - position).Magnitude
            if not bestDistance or distance < bestDistance then best, bestDistance = part, distance end
        end
    end
    return best, bestDistance
end

local function hasGun(character)
    for _, container in ipairs({character, player:FindFirstChildOfClass("Backpack")}) do
        for _, item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") and item.Name == "Gun" then return true end
        end
    end
    return false
end

local function tryTouch(root, part)
    if not touchInterest then return false end
    local beginOK = pcall(touchInterest, root, part, 0)
    local endOK = pcall(touchInterest, root, part, 1)
    return beginOK and endOK
end

local function destroy()
    if state.destroyed then return end
    state.destroyed, state.farm, state.pickup = true, false, false
    for _, connection in ipairs(connections) do connection:Disconnect() end
    clearTarget()
    stopMovement(true)
    actions.destroy()
    data.destroy()
    if ui then ui.destroy() end
end

local function setActionOption(key, enabled)
    actions.setOption(key, enabled)
    if key == "pickup" then
        state.pickup = enabled
        if not enabled and target and target.kind == "gun" then
            clearTarget()
            stopMovement(true)
        end
    end
end

actions = createActions(CONFIG, data, {
    notify = notify,
    beforeAction = function()
        if state.destroyed then return false end
        clearTarget()
        stopMovement(true)
        pauseUntil = os.clock() + 0.35
        return true
    end,
})

ui = createUI({
    onFarm = function(enabled)
        state.farm = enabled
        clearTarget()
        stopMovement(true)
        notify(enabled and "Procurando candies..." or "Farm desligado.", 0.3)
    end,
    onMode = function(mode)
        stopMovement(true)
        clearTarget()
        state.mode = mode == "Under mapa" and "Under mapa" or "Auto farm fast"
        notify("Modo: " .. state.mode, 0.5)
    end,
    onSpeed = function(value)
        local speed = tonumber(value)
        if speed and speed == speed then state.speed = math.clamp(speed, CONFIG.MinSpeed, CONFIG.MaxSpeed) end
    end,
    onESP = function(enabled) data.setEnabled(enabled) end,
    onESPNames = function(enabled) data.setNames(enabled) end,
    onESPDistance = function(enabled) data.setDistance(enabled) end,
    onResetBag50 = function(enabled) setActionOption("reset", enabled) end,
    onShootMurderBag50 = function(enabled) setActionOption("shoot", enabled) end,
    onKillAllBag50 = function(enabled) setActionOption("killall", enabled) end,
    onPickupGun = function(enabled) setActionOption("pickup", enabled) end,
    onClose = destroy,
}, CONFIG.DefaultSpeed)
connect(ui.cleanup.Event, destroy)
connect(ui.gui.Destroying, destroy)

connect(Workspace.DescendantAdded, function(part)
    task.defer(function() if not state.destroyed and part.Parent then indexCoin(part) end end)
end)
connect(Workspace.DescendantRemoving, function(part) coins[part], cooldown[part] = nil, nil end)
connect(CollectionService:GetInstanceAddedSignal(CONFIG.CoinTag), indexCoin)
connect(CollectionService:GetInstanceRemovedSignal(CONFIG.CoinTag), function(part)
    if not isCoin(part) then coins[part] = nil end
end)
for _, part in ipairs(Workspace:GetDescendants()) do indexCoin(part) end

connect(player.CharacterRemoving, function()
    clearTarget()
    stopMovement(false)
end)

local function pauseAfterCorrection()
    state.farm = false
    clearTarget()
    stopMovement(false)
    ui.setFarm(false)
    notify("Servidor reposicionou o personagem. Under mapa pausado.", 8)
end

connect(RunService.PreSimulation, function()
    local session = movement
    if not session or state.destroyed then return end
    if not session.root.Parent or session.humanoid.Health <= 0 then
        clearTarget()
        stopMovement(false)
        return
    end
    disableCollisions(session)
    if session.mode == "Under mapa" then
        session.humanoid.PlatformStand = true
        local now = os.clock()
        if session.expected and now - session.started > 0.25
            and (session.root.Position - session.expected.Position).Magnitude > CONFIG.CorrectionDistance then
            if now - session.correctionStart > CONFIG.CorrectionWindow then
                session.correctionStart, session.corrections = now, 0
            end
            session.corrections = session.corrections + 1
            if session.corrections >= CONFIG.MaxCorrections then pauseAfterCorrection() return end
        end
    end
    if session.expected then applyPose(session, session.expected) end
end)

local roleLabels = {Innocent = "Inocente", Sheriff = "Xerife", Murderer = "Assassino", Hero = "Herói"}
connect(RunService.Heartbeat, function(dt)
    if state.destroyed then return end
    local now = os.clock()
    actions.step(now)
    if now >= nextTelemetry then
        nextTelemetry = now + 0.1
        local bag = data.getBag()
        local role = data.getRole(player)
        ui.setTelemetry(roleLabels[role] or "Desconhecido", bag and (tostring(bag) .. "/50") or "não detectada")
    end
    local character, humanoid, root = characterParts()
    if not character then
        clearTarget()
        stopMovement(false)
        if state.farm or state.pickup then farmStatus("Aguardando personagem...") end
        return
    end
    state.surfaceHeight = math.max(CONFIG.NormalHeightAboveCoin, humanoid.HipHeight + root.Size.Y / 2)
    if now < pauseUntil then return end
    if movement and (movement.character ~= character or movement.root ~= root
        or movement.humanoid ~= humanoid) then clearTarget() stopMovement(false) end

    if contact then
        if now < contact.untilTime then applyPose(movement, contact.pose) return end
        movement.inContact = false
        applyPose(movement, contact.resume)
        clearTarget()
    end

    if target and (not available(target.part, target.kind, now) or now > target.deadline
        or target.kind == "gun" and (not state.pickup or hasGun(character))
        or target.kind == "coin" and not state.farm) then
        if target.part.Parent then cooldown[target.part] = now + CONFIG.RetrySeconds end
        local wasGun = target.kind == "gun"
        clearTarget()
        if wasGun then stopMovement(true) end
    end

    -- Arma caída tem prioridade. Todo deslocamento passa por este controlador.
    if state.pickup and not hasGun(character) and data.getRole(player) ~= "Murderer" then
        local gun = actions.findDroppedGun(now)
        if available(gun, "gun", now) and (not target or target.kind ~= "gun") then
            stopMovement(true)
            clearTarget()
            local distance = (destination(gun, "gun") - root.Position).Magnitude
            target = {part = gun, kind = "gun", deadline = now + distance / CONFIG.MinSpeed + 5}
        end
    end

    if not target then
        if now < nextSearch then return end
        if state.farm then
            local coin, distance = nearestCoin(root.Position, now)
            if coin then target = {part = coin, kind = "coin", deadline = now + distance / CONFIG.MinSpeed + 5} end
        end
        if not target then
            local waitingUnder = state.farm and movement and movement.mode == "Under mapa"
                and movement.kind == "coin"
            -- Continua deitado no ponto atual entre spawns/tentativas de candy.
            if not waitingUnder then stopMovement(true) end
            nextSearch = now + 0.15
            if state.farm then
                farmStatus(waitingUnder and "Under mapa · deitado, aguardando candies..."
                    or "Aguardando candies reconhecidos...")
            end
            return
        end
    end

    startMovement(character, humanoid, root, target.kind)
    local goal = destination(target.part, target.kind)
    local delta = goal - root.Position
    local distance = delta.Magnitude
    local step = math.clamp(state.speed, CONFIG.MinSpeed, CONFIG.MaxSpeed) * math.min(dt, 0.1)
    if distance <= math.max(step, 0.6) then
        local part, kind = target.part, target.kind
        movement.surface = CFrame.new(part.Position + Vector3.new(0, state.surfaceHeight, 0))
            * movement.uprightRotation
        local resume = poseAt(goal, movement)
        applyPose(movement, resume)
        cooldown[part] = now + (kind == "gun" and 0.6 or CONFIG.RetrySeconds)
        if tryTouch(root, part) then
            clearTarget()
            farmStatus(kind == "gun" and "Tentando recolher a arma..." or state.mode .. " · coleta por toque")
        else
            movement.inContact = true
            contact = {untilTime = now + CONFIG.ContactSeconds, resume = resume,
                pose = CFrame.new(part.Position + Vector3.new(0, 1, 0)) * movement.uprightRotation}
            applyPose(movement, contact.pose)
            farmStatus(kind == "gun" and "Contato com a arma..." or state.mode .. " · contato rápido")
        end
    else
        applyPose(movement, poseAt(root.Position + delta.Unit * step, movement))
        farmStatus(target.kind == "gun" and "Indo buscar a arma..." or state.mode .. " · procurando candies")
    end
end)

ui.setStatus("Pronto. Selecione uma categoria à esquerda.")
