-- Artist page: https://www.palcomp3.com.br/brancoala/craudete/
-- The audio stays on the artist's public CDN and is cached only in the client.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Music = {}
Music.__index = Music

local AUDIO_URL = "https://palcocdn.akamaized.net/5/d/4/f/brancoala-craudete-ab35bc.mp3"
local CACHE_DIRECTORY = "NexusHub/audio"
local CACHE_FILE = CACHE_DIRECTORY .. "/craudete.mp3"
local MAX_BYTES = 10 * 1024 * 1024
local ACTIONS = { ["music.play"] = true, ["music.previous"] = true, ["music.next"] = true, ["music.songs"] = true }

local function capability(name)
    local environment = getfenv()
    local value = environment[name]
    if type(value) == "function" then return value end
    if name == "request" then
        value = environment.http_request or (type(environment.syn) == "table" and environment.syn.request)
            or (type(environment.http) == "table" and environment.http.request)
        if type(value) == "function" then return value end
    end
    return nil
end

function Music.validateAudio(body, contentType)
    if type(body) ~= "string" or #body < 128 or #body > MAX_BYTES then
        return false, "O arquivo de audio esta vazio ou excede 10 MiB."
    end
    if contentType ~= nil then
        local mime = tostring(contentType):lower():match("^%s*([^;%s]+)")
        if mime ~= "audio/mpeg" and mime ~= "audio/mp3" then return false, "O servidor nao retornou um arquivo MP3." end
    end
    local first, second = body:byte(1, 2)
    local id3 = body:sub(1, 3) == "ID3" and (body:byte(4) == 2 or body:byte(4) == 3 or body:byte(4) == 4)
    local frame = first == 255 and second and math.floor(second / 32) == 7
        and math.floor(second / 8) % 4 ~= 1 and math.floor(second / 2) % 4 ~= 0
    if not id3 and not frame then return false, "O conteudo recebido nao possui um cabecalho MP3 valido." end
    return true
end

function Music.new(context)
    assert(context.features and context.features.sound, "Music requer o Sound do modulo Features.")
    local self = setmetatable({ context = context, features = context.features, sound = context.features.sound,
        alive = true, generation = 0, loading = false, connections = {}, state = "idle", elapsed = 0 }, Music)
    self.features.playlist = { { name = "Craudete - Brancoala", id = "" } }
    self.features.playlistIndex, self.features.paused = 1, false
    self.context.settings["music.name"] = "Craudete - Brancoala"
    self.connections[1] = RunService.Heartbeat:Connect(function(delta)
        if not self.alive or not self.gui then return end
        self.elapsed += delta
        if self.elapsed < 0.2 then return end
        self.elapsed = 0
        self.playButton.Text = self.loading and "..." or self.sound.IsPlaying and "Pause" or "Play"
        local position, duration = self.sound.TimePosition, self.sound.TimeLength
        local function clock(value) return string.format("%d:%02d", math.floor(value / 60), math.floor(value % 60)) end
        self.progress.Text = clock(position) .. " / " .. clock(duration)
    end)
    self:_bindRound()
    table.insert(self.connections, ReplicatedStorage.DescendantAdded:Connect(function(object)
        if self.alive and object.Name == "RoundStart" then self:_bindRound() end
    end))
    if context.get and context.get("music.onScreen") then self:_showHud(true) end
    return self
end

function Music:_notify(message)
    if self.alive and self.context.notify then self.context.notify(message) end
end
function Music:_cachedAudio(force)
    if not force and self.cacheCheckAt and os.clock() < self.cacheCheckAt then return self.cacheValid end
    self.cacheCheckAt, self.cacheValid = os.clock() + 5, false
    local exists, read = capability("isfile"), capability("readfile")
    if not exists or not read then return false end
    local checked, present = pcall(exists, CACHE_FILE)
    if not checked or not present then return false end
    local loaded, body = pcall(read, CACHE_FILE)
    self.cacheValid = loaded and Music.validateAudio(body) == true
    return self.cacheValid
end
function Music:_roundEvent()
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local gameplay = remotes and remotes:FindFirstChild("Gameplay")
    local event = gameplay and gameplay:FindFirstChild("RoundStart")
    return event and event:IsA("RemoteEvent") and event or nil
end
function Music:_bindRound()
    local event = self:_roundEvent()
    if event == self.roundEvent then return end
    if self.roundConnection then self.roundConnection:Disconnect(); self.roundConnection = nil end
    self.roundEvent = event
    if event then
        self.roundConnection = event.OnClientEvent:Connect(function()
            if not self.alive or self.loading or not self.context.get or not self.context.get("music.autoPlay") then return end
            task.spawn(function()
                if not self.alive or not self.context.get("music.autoPlay") then return end
                local called, ok, message = pcall(self._play, self, true, true)
                if self.alive and (not called or not ok) then
                    self:_notify(called and message or "Falha ao iniciar Craudete nesta rodada.")
                end
            end)
        end)
    end
end
function Music:_canResolve()
    local localAsset = capability("getcustomasset") or capability("getsynasset")
    if not localAsset then return false, "Este cliente precisa de getcustomasset ou getsynasset para tocar o MP3 local." end
    if self:_cachedAudio() then return true end
    if not capability("request") or not capability("writefile") or not capability("makefolder") then
        return false, "Este cliente precisa de HTTP, writefile e makefolder para carregar Craudete."
    end
    return true
end
function Music:Supports(id)
    if id ~= "music.onScreen" and id ~= "music.autoPlay" and not ACTIONS[id] then return nil end
    if not self.alive then return false, "O player foi encerrado." end
    if id == "music.onScreen" then return true end
    if id == "music.autoPlay" and not self:_roundEvent() then return false, "O evento RoundStart do jogo ainda nao foi observado." end
    if self.sound.IsPlaying or self.resolved or self.loading then return true end
    return self:_canResolve()
end
function Music:_resolve(generation)
    local localAsset = capability("getcustomasset") or capability("getsynasset")
    if not self:_cachedAudio(true) then
        local request, write, folder = capability("request"), capability("writefile"), capability("makefolder")
        if not request or not write or not folder or not localAsset then return false, "As APIs de audio local nao estao disponiveis." end
        local ok, response = pcall(request, { Url = AUDIO_URL, Method = "GET", Timeout = 20 })
        if not self.alive or self.generation ~= generation then return false, "Carregamento cancelado." end
        if not ok or type(response) ~= "table" then return false, "Falha ao baixar Craudete da pagina do artista." end
        local status = tonumber(response.StatusCode or response.Status)
        if not status or status < 200 or status >= 300 then return false, "O servidor de audio retornou um erro HTTP." end
        local contentType
        local headers = response.Headers or response.headers
        if type(headers) ~= "table" then return false, "O cliente nao retornou os cabecalhos do audio." end
        for key, value in pairs(headers) do
            if tostring(key):lower() == "content-type" then contentType = value; break end
        end
        if not contentType then return false, "A resposta do servidor nao informa o tipo de audio." end
        local valid, problem = Music.validateAudio(response.Body, contentType)
        if not valid then return false, problem end
        for _, directory in ipairs({ "NexusHub", CACHE_DIRECTORY }) do
            local exists = capability("isfolder")
            local checked, present = false, false
            if exists then checked, present = pcall(exists, directory) end
            if not checked or not present then
                local made = pcall(folder, directory)
                if not made and exists then
                    local rechecked, available = pcall(exists, directory)
                    if not rechecked or not available then return false, "Falha ao criar a pasta de audio do Nexus Hub." end
                elseif not made then return false, "Falha ao criar a pasta de audio do Nexus Hub." end
            end
        end
        if not self.alive or self.generation ~= generation then return false, "Carregamento cancelado." end
        local saved = pcall(write, CACHE_FILE, response.Body)
        if not saved then return false, "Falha ao gravar o cache local de Craudete." end
        self.cacheValid, self.cacheCheckAt = true, os.clock() + 5
    end
    if not localAsset then return false, "A API de asset local nao esta disponivel." end
    local resolved, value = pcall(localAsset, CACHE_FILE)
    if not resolved or type(value) ~= "string" or value == "" then return false, "O cliente nao registrou o MP3 local." end
    if not self.alive or self.generation ~= generation then return false, "Carregamento cancelado." end
    self.resolved = value
    self.features.playlist = { { name = "Craudete - Brancoala", id = value } }
    self.features.playlistIndex = 1
    return true
end
function Music:_play(restart, automatic)
    if automatic and (not self.context.get or not self.context.get("music.autoPlay")) then return false, "Reproducao automatica desativada." end
    local available, reason = self:_canResolve()
    if not available and not self.resolved then return false, reason end
    self.generation += 1
    local generation = self.generation
    self.autoGeneration = automatic and generation or nil
    self.loading, self.state = true, "loading"
    if not self.resolved then
        local resolved, problem = self:_resolve(generation)
        if not resolved then
            if self.generation == generation then self.loading, self.state = false, "idle" end
            return false, problem
        end
    end
    if not self.alive or self.generation ~= generation then return false, "Carregamento cancelado." end
    if self.sound.SoundId ~= self.resolved then self.sound.SoundId = self.resolved end
    local deadline = os.clock() + 10
    while not self.sound.IsLoaded and os.clock() < deadline do
        if not self.alive or self.generation ~= generation then return false, "Carregamento cancelado." end
        task.wait(0.05)
    end
    if not self.alive or self.generation ~= generation then return false, "Carregamento cancelado." end
    self.loading = false
    if not self.sound.IsLoaded then self.state = "idle"; return false, "O cliente nao carregou o MP3 local." end
    if restart then self.sound.TimePosition = 0 end
    if self.features.paused and not restart then self.sound:Resume() else self.sound:Play() end
    self.features.paused, self.state = false, "playing"
    return true, "Craudete - Brancoala."
end
function Music:Action(id, payload)
    if not ACTIONS[id] then return false, "Acao de musica desconhecida." end
    if not self.alive then return false, "O player foi encerrado." end
    if self.loading then
        self.generation += 1
        self.loading, self.state = false, "idle"
        return true, "Carregamento cancelado."
    end
    if id == "music.play" and self.sound.IsPlaying then
        self.sound:Pause()
        self.features.paused, self.state = true, "paused"
        return true, "Craudete pausada."
    end
    if id == "music.songs" then
        local value = type(payload) == "table" and (payload.id or payload.value or payload.index) or payload
        value = tostring(value or ""):lower()
        if value ~= "1" and value ~= "craudete" and value ~= "craudete - brancoala" then
            return false, "O catalogo possui apenas Craudete, de Brancoala."
        end
    end
    return self:_play(id ~= "music.play")
end
function Music:Set(id, value)
    if id ~= "music.onScreen" and id ~= "music.autoPlay" then return false, "Controle nao gerenciado pelo player." end
    if not self.alive or type(value) ~= "boolean" then return false, "Estado do player invalido." end
    if id == "music.autoPlay" and value then
        local supported, problem = self:Supports(id)
        if not supported then return false, problem end
    end
    self.context.settings[id] = value
    if id == "music.onScreen" then self:_showHud(value)
    else
        if not value and self.loading and self.autoGeneration == self.generation then
            self.generation += 1
            self.loading, self.state = false, "idle"
        end
        self:_bindRound()
    end
    return true
end
function Music:_showHud(visible)
    if not visible then
        if self.gui then self.gui:Destroy(); self.gui = nil end
        for _, connection in ipairs(self.hudConnections or {}) do connection:Disconnect() end
        self.hudConnections = nil
        return
    end
    if self.gui then return end
    local gui = Instance.new("ScreenGui")
    gui.Name, gui.ResetOnSpawn, gui.DisplayOrder = "NexusMusicPlayer", false, 90
    local frame = Instance.new("Frame")
    frame.Size, frame.Position, frame.AnchorPoint = UDim2.fromOffset(320, 86), UDim2.new(0.5, 0, 1, -12), Vector2.new(0.5, 1)
    frame.BackgroundColor3, frame.BorderSizePixel, frame.Parent = Color3.fromRGB(25, 16, 20), 0, gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius, corner.Parent = UDim.new(0, 12), frame
    local title = Instance.new("TextLabel")
    title.Text, title.Size, title.Position = "Craudete - Brancoala", UDim2.new(1, -20, 0, 24), UDim2.fromOffset(10, 5)
    title.BackgroundTransparency, title.TextColor3, title.Font, title.TextSize = 1, Color3.fromRGB(245, 237, 240), Enum.Font.GothamBold, 14
    title.Parent = frame
    self.progress = title:Clone()
    self.progress.Text, self.progress.Position, self.progress.TextSize, self.progress.Parent = "0:00 / 0:00", UDim2.fromOffset(10, 27), 11, frame
    self.hudConnections = {}
    for index, action in ipairs({ { "<<", "music.previous" }, { "Play", "music.play" }, { ">>", "music.next" } }) do
        local button = Instance.new("TextButton")
        button.Text, button.Size, button.Position = action[1], UDim2.fromOffset(82, 27), UDim2.fromOffset(28 + (index - 1) * 92, 53)
        button.BackgroundColor3, button.TextColor3, button.Font, button.TextSize = Color3.fromRGB(190, 37, 52), Color3.new(1, 1, 1), Enum.Font.GothamBold, 12
        button.Parent = frame
        if action[2] == "music.play" then self.playButton = button end
        table.insert(self.hudConnections, button.Activated:Connect(function()
            local ok, result, message = pcall(self.Action, self, action[2])
            if not ok then self:_notify("Falha ao operar o player de musica.")
            elseif not result then self:_notify(message) end
        end))
    end
    gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.gui = gui
end
function Music:GetCatalog(id)
    if id ~= "music.songs" then return {} end
    return { { id = "craudete", index = 1, name = "Craudete - Brancoala", kind = "Musica local", artist = "Brancoala" } }
end
function Music:GetStats()
    return { music = { playing = self.sound.IsPlaying, loading = self.loading == true } }
end
function Music:Destroy()
    if not self.alive then return end
    self.alive, self.loading, self.generation, self.state = false, false, self.generation + 1, "closed"
    self:_showHud(false)
    for _, connection in ipairs(self.connections) do connection:Disconnect() end
    if self.roundConnection then self.roundConnection:Disconnect(); self.roundConnection = nil end
    table.clear(self.connections)
    pcall(self.sound.Stop, self.sound)
    self.features.paused = false
end

return Music
