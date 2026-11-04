-- Luau / MYTHIC_HUB_RESTAURADO.lua / Arceus X Neo e Delta / Roblox MM2
local SUPABASE_URL = "https://bpgovdwdigwrrzokqvlh.supabase.co/rest/v1/"
local SUPABASE_KEY = "sb_publishable_xHCkWnnXecpiJQuVSHjgDA_KR3vRScD"
local OWNER_USER_ID = 0 -- Coloque seu UserId numerico para exibir [DONO].
local SCRIPT_URL = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/main.lua"

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CHANNELS = {"Geral", "Trading", "Off-topic"}

local sharedEnv = _G
pcall(function()
    if type(getgenv) == "function" then
        local value = getgenv()
        if type(value) == "table" then sharedEnv = value end
    end
end)

if type(sharedEnv.__MYTHIC_CHAT_TAGS_STOP) == "function" then
    pcall(sharedEnv.__MYTHIC_CHAT_TAGS_STOP)
end

local active = true
local gui
local playerTags = {}
local uiConnections = {}

local function cleanup()
    if not active then return end
    active = false
    for _, connection in ipairs(uiConnections) do
        pcall(function() connection:Disconnect() end)
    end
    for id, item in pairs(playerTags) do
        pcall(function() item.tween:Cancel() end)
        pcall(function() item.gui:Destroy() end)
        playerTags[id] = nil
    end
    if gui then
        local old = gui
        gui = nil
        pcall(function() old:Destroy() end)
    end
end
sharedEnv.__MYTHIC_CHAT_TAGS_STOP = cleanup

local function logError(message)
    warn("MYTHIC: " .. tostring(message))
end

local function getRequest()
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    local ok, result = pcall(function() return syn.request end)
    if ok and type(result) == "function" then return result end
    return nil
end

local function startFeatures()
    local player = Players.LocalPlayer
    local attempts = 0
    while not player and active and attempts < 40 do
        task.wait(0.25)
        attempts = attempts + 1
        player = Players.LocalPlayer
    end
    if not player or not active then return end

    local playerGui = player:WaitForChild("PlayerGui", 10)
    if not playerGui or not active then return end

    local httpRequest = getRequest()
    if not httpRequest then
        logError("Executor sem request/syn.request/http_request.")
        return
    end
    if SUPABASE_KEY == "COLE_SUA_CHAVE_PUBLICA_AQUI" or SUPABASE_KEY == "" then
        logError("Coloque a chave publica do Supabase em SUPABASE_KEY.")
        return
    end

    local function rest(method, resource, payload, prefer)
        if not active then return nil, "Servico encerrado." end
        local headers = {
            ["apikey"] = SUPABASE_KEY,
            ["Content-Type"] = "application/json",
            ["Accept"] = "application/json"
        }
        -- Chave anon JWT legada aceita Authorization; chave sb_publishable_ usa apikey.
        if SUPABASE_KEY:sub(1, 3) == "eyJ" then
            headers["Authorization"] = "Bearer " .. SUPABASE_KEY
        end
        if prefer then headers["Prefer"] = prefer end

        local encoded
        if payload ~= nil then
            local ok, result = pcall(function() return HttpService:JSONEncode(payload) end)
            if not ok then return nil, "Nao foi possivel preparar os dados." end
            encoded = result
        end

        local ok, response = pcall(httpRequest, {
            Url = SUPABASE_URL .. resource,
            Method = method,
            Headers = headers,
            Body = encoded,
            Timeout = 12
        })
        if not ok or type(response) ~= "table" then
            return nil, "Sem conexao com o chat."
        end

        local code = tonumber(response.StatusCode or response.Status or 0) or 0
        local body = tostring(response.Body or response.body or "")
        if code < 200 or code >= 300 then
            if body:find("limite_3_segundos", 1, true) then
                return nil, "Espere 3 segundos para enviar novamente."
            end
            if body:find("links_nao_permitidos", 1, true) then
                return nil, "Links nao sao permitidos no chat."
            end
            if code == 401 or code == 403 then
                return nil, "Chave ou permissao do Supabase invalida."
            end
            return nil, "Erro no Supabase (HTTP " .. tostring(code) .. ")."
        end
        if body == "" then return true end
        local decoded, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not decoded then return nil, "Resposta invalida do Supabase." end
        return data
    end

    local function badgeFor(userId)
        if OWNER_USER_ID > 0 and tonumber(userId) == OWNER_USER_ID then
            return "DONO"
        end
        return "USER"
    end

    local function corner(parent, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = parent
    end

    local function textLabel(parent, text, size)
        local item = Instance.new("TextLabel")
        item.BackgroundTransparency = 1
        item.Text = text
        item.Font = Enum.Font.Gotham
        item.TextSize = size
        item.TextColor3 = Color3.fromRGB(240, 222, 255)
        item.Parent = parent
        return item
    end

    gui = Instance.new("ScreenGui")
    gui.Name = "MYTHIC_GLOBAL_CHAT_AND_TAGS"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 970
    gui.Parent = playerGui
    table.insert(uiConnections, gui.Destroying:Connect(cleanup))

    local opener = Instance.new("TextButton")
    opener.Name = "OpenChat"
    opener.AnchorPoint = Vector2.new(1, 0)
    opener.Position = UDim2.new(1, -12, 0, 182)
    opener.Size = UDim2.fromOffset(133, 38)
    opener.BackgroundColor3 = Color3.fromRGB(41, 17, 70)
    opener.TextColor3 = Color3.fromRGB(250, 237, 255)
    opener.Font = Enum.Font.GothamBold
    opener.TextSize = 13
    opener.Text = "MYTHIC CHAT"
    opener.Parent = gui
    corner(opener, 12)

    local panel = Instance.new("Frame")
    panel.Name = "ChatPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.fromScale(0.5, 0.5)
    panel.Size = UDim2.new(0.80, 0, 0.74, 0)
    panel.BackgroundColor3 = Color3.fromRGB(21, 11, 34)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.Parent = gui
    corner(panel, 14)
    local sizeLimit = Instance.new("UISizeConstraint")
    sizeLimit.MaxSize = Vector2.new(460, 430)
    sizeLimit.MinSize = Vector2.new(280, 230)
    sizeLimit.Parent = panel

    local border = Instance.new("UIStroke")
    border.Color = Color3.fromRGB(156, 62, 241)
    border.Thickness = 1.4
    border.Parent = panel

    local title = textLabel(panel, "✦ MYTHIC CHAT GLOBAL", 15)
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Position = UDim2.fromOffset(12, 6)
    title.Size = UDim2.new(1, -60, 0, 27)

    local close = Instance.new("TextButton")
    close.Position = UDim2.new(1, -43, 0, 7)
    close.Size = UDim2.fromOffset(32, 27)
    close.BackgroundColor3 = Color3.fromRGB(71, 33, 101)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 14
    close.Parent = panel
    corner(close, 8)

    local selectedChannel = "Geral"
    local channelButtons = {}
    local chatStatus = textLabel(panel, "Conectando...", 11)
    chatStatus.Position = UDim2.fromOffset(13, 77)
    chatStatus.Size = UDim2.new(1, -26, 0, 17)
    chatStatus.TextXAlignment = Enum.TextXAlignment.Left
    chatStatus.TextColor3 = Color3.fromRGB(194, 160, 221)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Mensagens"
    scroll.Position = UDim2.fromOffset(10, 100)
    scroll.Size = UDim2.new(1, -20, 1, -157)
    scroll.BackgroundColor3 = Color3.fromRGB(28, 17, 45)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = Color3.fromRGB(164, 77, 239)
    scroll.CanvasSize = UDim2.fromOffset(0, 0)
    scroll.Parent = panel
    corner(scroll, 10)

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 7)
    listPadding.PaddingBottom = UDim.new(0, 7)
    listPadding.PaddingLeft = UDim.new(0, 7)
    listPadding.PaddingRight = UDim.new(0, 7)
    listPadding.Parent = scroll

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = scroll
    table.insert(uiConnections,
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            scroll.CanvasSize = UDim2.fromOffset(0, listLayout.AbsoluteContentSize.Y + 17)
        end)
    )

    local input = Instance.new("TextBox")
    input.Name = "Escrever"
    input.Position = UDim2.new(0, 10, 1, -48)
    input.Size = UDim2.new(1, -112, 0, 38)
    input.BackgroundColor3 = Color3.fromRGB(49, 30, 73)
    input.TextColor3 = Color3.new(1, 1, 1)
    input.PlaceholderText = "Escreva uma mensagem..."
    input.PlaceholderColor3 = Color3.fromRGB(184, 156, 204)
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.Text = ""
    input.ClearTextOnFocus = false
    input.Parent = panel
    corner(input, 9)

    local send = Instance.new("TextButton")
    send.Name = "Enviar"
    send.Position = UDim2.new(1, -94, 1, -48)
    send.Size = UDim2.fromOffset(84, 38)
    send.BackgroundColor3 = Color3.fromRGB(115, 44, 191)
    send.TextColor3 = Color3.new(1, 1, 1)
    send.Text = "ENVIAR"
    send.TextSize = 12
    send.Font = Enum.Font.GothamBold
    send.Parent = panel
    corner(send, 9)

    local function setStatus(message)
        if active then chatStatus.Text = tostring(message) end
    end

    local fetchId = 0
    local lastSignature = ""
    local fetchBusy = false
    local function renderMessages(rows)
        local signature = selectedChannel .. ":" .. tostring(#rows)
        for _, message in ipairs(rows) do
            signature = signature .. ":" .. tostring(message.id or "")
        end
        if signature == lastSignature then return end
        lastSignature = signature

        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("TextLabel") then child:Destroy() end
        end
        for n = #rows, 1, -1 do
            local message = rows[n]
            local label = textLabel(scroll, "", 12)
            label.Name = "Mensagem"
            label.LayoutOrder = #rows - n + 1
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.Size = UDim2.new(1, -6, 0, 0)
            label.BackgroundTransparency = 0
            label.BackgroundColor3 = Color3.fromRGB(41, 25, 61)
            label.TextWrapped = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.RichText = false
            label.Text = "[" .. badgeFor(message.user_id) .. "] "
                .. tostring(message.username or "Usuario") .. ": "
                .. tostring(message.content or "")
            corner(label, 7)
            local pad = Instance.new("UIPadding")
            pad.PaddingTop = UDim.new(0, 7)
            pad.PaddingBottom = UDim.new(0, 7)
            pad.PaddingLeft = UDim.new(0, 7)
            pad.PaddingRight = UDim.new(0, 7)
            pad.Parent = label
        end
        task.defer(function()
            if active and scroll.Parent then
                scroll.CanvasPosition = Vector2.new(
                    0, math.max(0, scroll.AbsoluteCanvasSize.Y - scroll.AbsoluteSize.Y))
            end
        end)
    end

    local function fetchChat()
        if not active or fetchBusy then return end
        fetchBusy = true
        fetchId = fetchId + 1
        local currentFetch = fetchId
        local channel = selectedChannel
        local path = "chat_messages?select=id,user_id,username,badge,content,created_at"
            .. "&channel=eq." .. HttpService:UrlEncode(channel)
            .. "&order=created_at.desc,id.desc&limit=30"
        local rows, err = rest("GET", path)
        fetchBusy = false
        if not active or currentFetch ~= fetchId or channel ~= selectedChannel then return end
        if type(rows) == "table" then
            renderMessages(rows)
            setStatus("Conectado | " .. channel)
        else
            setStatus(err or "Erro ao atualizar mensagens.")
        end
    end

    for i, channel in ipairs(CHANNELS) do
        local button = Instance.new("TextButton")
        button.Name = channel
        button.Position = UDim2.new((i - 1) / 3, 10, 0, 41)
        button.Size = UDim2.new(1/3, -13, 0, 30)
        button.BackgroundColor3 = channel == selectedChannel
            and Color3.fromRGB(112, 48, 181) or Color3.fromRGB(49, 29, 70)
        button.Text = channel
        button.TextColor3 = Color3.fromRGB(242, 225, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 11
        button.Parent = panel
        corner(button, 8)
        channelButtons[channel] = button
        table.insert(uiConnections, button.Activated:Connect(function()
            selectedChannel = channel
            lastSignature = ""
            for name, btn in pairs(channelButtons) do
                btn.BackgroundColor3 = name == channel
                    and Color3.fromRGB(112, 48, 181) or Color3.fromRGB(49, 29, 70)
            end
            task.spawn(function() pcall(fetchChat) end)
        end))
    end

    table.insert(uiConnections, opener.Activated:Connect(function()
        panel.Visible = not panel.Visible
    end))
    table.insert(uiConnections, close.Activated:Connect(function()
        panel.Visible = false
    end))

    local lastSent = -100
    local sending = false
    table.insert(uiConnections, send.Activated:Connect(function()
        if sending or not active then return end
        local content = input.Text:gsub("[%c]", " "):gsub("^%s+", ""):gsub("%s+$", "")
        local length = utf8.len(content)
        if content == "" then setStatus("Digite uma mensagem."); return end
        if not length or length > 240 then
            setStatus("Limite de 240 caracteres.")
            return
        end
        if os.clock() - lastSent < 3 then
            setStatus("Espere 3 segundos entre mensagens.")
            return
        end
        sending = true
        task.spawn(function()
            local ok, response, err = pcall(rest, "POST", "chat_messages", {
                channel = selectedChannel,
                user_id = player.UserId,
                username = player.Name,
                badge = "USER",
                content = content
            }, "return=minimal")
            if ok and response then
                lastSent = os.clock()
                input.Text = ""
                setStatus("Mensagem enviada!")
                pcall(fetchChat)
            else
                setStatus(ok and (err or "Falha ao enviar.") or "Erro ao enviar mensagem.")
            end
            sending = false
        end)
    end))

    local function clearTag(userId)
        local old = playerTags[userId]
        if old then
            playerTags[userId] = nil
            pcall(function() old.tween:Cancel() end)
            pcall(function() old.gui:Destroy() end)
        end
    end

    local function attachTag(otherPlayer)
        local head = otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head")
        if not head then return end
        local old = playerTags[otherPlayer.UserId]
        if old and old.head == head and old.gui.Parent == head then return end
        clearTag(otherPlayer.UserId)

        local tag = Instance.new("BillboardGui")
        tag.Name = "MYTHIC_USER_BADGE"
        tag.Adornee = head
        tag.Size = UDim2.fromOffset(188, 51)
        tag.StudsOffsetWorldSpace = Vector3.new(0, 2.65, 0)
        tag.AlwaysOnTop = true
        tag.MaxDistance = 110
        tag.LightInfluence = 0
        tag.Parent = head

        local background = Instance.new("Frame")
        background.Size = UDim2.fromScale(1, 1)
        background.BackgroundColor3 = Color3.fromRGB(30, 12, 49)
        background.BackgroundTransparency = 0.12
        background.BorderSizePixel = 0
        background.Parent = tag
        corner(background, 12)

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(119, 50, 186)
        stroke.Thickness = 1.6
        stroke.Parent = background

        local header = textLabel(background, "✦ MYTHIC [" .. badgeFor(otherPlayer.UserId) .. "]", 13)
        header.Font = Enum.Font.GothamBold
        header.Size = UDim2.new(1, -8, 0, 25)
        header.Position = UDim2.fromOffset(4, 2)
        header.TextColor3 = Color3.fromRGB(227, 189, 255)

        local username = textLabel(background, otherPlayer.Name, 11)
        username.Position = UDim2.fromOffset(5, 26)
        username.Size = UDim2.new(1, -10, 0, 20)
        username.TextColor3 = Color3.fromRGB(243, 228, 255)

        local tween = TweenService:Create(stroke, TweenInfo.new(
            1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true
        ), {Color = Color3.fromRGB(207, 116, 255), Transparency = 0.22})
        tween:Play()
        playerTags[otherPlayer.UserId] = {head = head, gui = tag, tween = tween}
    end

    local function updatePresence()
        local stamp = DateTime.now():ToIsoDate()
        local _, err = rest("POST", "chat_users?on_conflict=user_id", {
            user_id = player.UserId,
            username = player.Name,
            last_seen = stamp
        }, "resolution=merge-duplicates,return=minimal")
        if err then logError("Presenca: " .. err) end
    end

    local function refreshTags()
        local since = DateTime.fromUnixTimestamp(os.time() - 65):ToIsoDate()
        local rows, err = rest("GET", "chat_users?select=user_id,username,badge"
            .. "&last_seen=gte." .. HttpService:UrlEncode(since) .. "&limit=500")
        if not active then return end
        if type(rows) ~= "table" then
            if err then logError("Tags: " .. err) end
            return
        end
        local online = {}
        for _, row in ipairs(rows) do
            local id = tonumber(row.user_id)
            if id then online[id] = true end
        end
        local inServer = {}
        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            inServer[otherPlayer.UserId] = true
            if online[otherPlayer.UserId] then
                attachTag(otherPlayer)
            else
                clearTag(otherPlayer.UserId)
            end
        end
        for id in pairs(playerTags) do
            if not inServer[id] then clearTag(id) end
        end
    end

    local function loop(interval, callback)
        task.spawn(function()
            while active do
                local ok, err = pcall(callback)
                if not ok then logError(err) end
                task.wait(interval)
            end
        end)
    end

    loop(30, updatePresence)
    loop(8, refreshTags)
    loop(3, fetchChat)
end

task.spawn(function()
    local ok, err = pcall(startFeatures)
    if not ok then logError("Falha ao iniciar tag/chat: " .. tostring(err)) end
end)

-- Loader original, preservado: chat e tags iniciam em paralelo.
local ok, source = pcall(function()
    return game:HttpGet(SCRIPT_URL)
end)
if not ok or type(source) ~= "string" or source == "" then
    error("MYTHIC HUB: nao foi possivel baixar o script. Verifique a conexao.")
end
local run, compilationError = loadstring(source)
if type(run) ~= "function" then
    error("MYTHIC HUB: erro ao carregar Lua: " .. tostring(compilationError))
end
return run()