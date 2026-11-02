-- MYTHIC HUB - loader oficial da copia publicada neste repositorio.
-- Recupera 35 blocos do codigo (12.468.912 bytes) do proprio GitHub.
local base = "https://raw.githubusercontent.com/Pulse-Hubs/scripts/main/MYTHIC-HUB/chunks/part-"
local segments = {}
for i = 1, 35 do
    local url = base .. string.format("%03d", i) .. ".txt"
    local ok, body = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok or type(body) ~= "string" or #body == 0 then
        error("MYTHIC HUB: falha ao carregar bloco " .. i .. "/35. Confirme internet e link do GitHub.")
    end
    segments[i] = body
end
local source = table.concat(segments)
if #source ~= 12468912 then
    error("MYTHIC HUB: arquivo incompleto (" .. #source .. " bytes, esperado 12468912).")
end
-- MYTHIC CUSTOM PATCH: substitui logo e remove a categoria Chat.
local function mythicReplaceOnce(needle, replacement, label)
    local first = string.find(source, needle, 1, true)
    if not first then error("MYTHIC HUB: nao foi possivel aplicar ajuste " .. label) end
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
local avatarBase64 = [==[/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAwADADASIAAhEBAxEB/8QAGgAAAgMBAQAAAAAAAAAAAAAABAYBAwUCB//EAC4QAAEDAgQGAQMEAwAAAAAAAAECAwQFEQASITEGEyJBUXFhQoGxIyQyUmORof/EABgBAAMBAQAAAAAAAAAAAAAAAAIEBQED/8QAKBEAAQMDAQgCAwAAAAAAAAAAAQIDEQAEMSESE0FRcbHB8GGBkaHR/9oADAMBAAIRAxEAPwDweHDfmyW48dpTjizZKUjU49GpnAC4RRz4zLr4UA67LcsyyfHLT1KPuw/OLeAo1PpbKnZT8mLLU0HFvst5lMpUejsbA7k27pwZxXxUukM0+G0VqmhkrdLpJKSVEAqO5VYC99cWUMItWS6sSrtNVGrdLTW2rU9q7rHCcNlLaHeKhAddR0oEdDLV/GVKrgfOuFOrKqnCzCILqmJDr4Ky4tIebW3oBlKgRfe9tRtjFnVeTKmqkvvKdd/iSfqHj84Li1SRUGBGmOcxmKOc0XR1ItYED4Omnxpha3vFuLKCc4NAlRJInWpLFMrkZDEeIIFVQkqVlX+g6Br31QrfuR6wtvMOMOqbdQUrSbEHDwmupER2XHgUxtoHq5URGa+ibgKJO/8A3XGVUnhXWpkwp/cskOKVlCQUHSwSNBlNvtfBuW5cTgBUTnI940C2SoCQAc9RW81UHKdKcqbKnI0sS1RxJUSUBsIAS2pP9SP9WxmVl5XEVZK5gTGmuKCVLQklFgLAADYetNb40p8tmS67HlrU5FqDSHo7zZylLmwC9NQLkebEa4x88uFFlU4XZmJskHL15e6Uq3CTft+DjH7jdPLaeEoJkadqqOoC0iBp55fY1B44oOFUnKRFqEBdJhOyXQpoyJCMy2biyspvb79sVw34jMRSJSXOapdw41lJCbWtqfODaDJcQ6YqaOZkhAWVtqQOnYgm4OoIUNR9Xm2O+Kk1h2JGkToUWLHZWphpLB2v1WtfCTbu7VtIqGFlCpFVSFU5UdEeJKUgaK/XZCSV/Kwo+r2GnjE8OpdZqrjbrGZpxpyO7mGgzJIv8WNj9sLvbuL/ABhzo0uYuHNdbbSIDcXmyHQ2FEECyRm+klVhpripavB5YLmkRjlTbC0uLBXpFB0SoIn0pmnLOSZEc5kVdh1pJ6mz9+oH2MCKnRyl5mWp+WqOstRiFWPLuSc3e3ceNcL6FqbUFJNiMMMSoUaegpq7TzMrQomRwDc/5EH+XsWPvCZWm4aDazBHPj/Kxm5MATBHPB8aVQZ8lDy323I7IdFlltsKNj9Wu53131PnA78l2U4VOvPyVDXO6sqt9thucFCkIfnBqNVISmVKslbjvLsL981rY3XhDpzyGYs+jssMJsXAC8txX9tjc+O2OrFiTJWQAOh/GsViWVOEqcMef3FDtsRYNNDyGWpsxRyuMrQSGyT0626jbe3rFNY4idRw6mgpbaaKni9J5SAnXsjTe1r+/WId4ych092FTUJzvXDsxxtPNVcWsnToHrX5wqElRuTc47Xl42E7pnER780VxcpCdhrER770r//Z]==]
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
		-- Em dispositivos touch, evita o interceptador nativo __namecall que pode encerrar o executor.
		-- Usa o método de posição quando suportado; não força o recurso incompatível.
		if context.inputService.TouchEnabled then
			local ready = installPointHook()
			if not notifiedLimited then
				notifiedLimited = true
				notify(ready and "Silent Aim: modo compativel mobile. Wallbang nao garantido." or "Silent Aim indisponivel neste executor mobile.")
			end
			return ready
		end
		if installNamecall() then return true end]==], "Safe Silent Aim on mobile")
mythicReplaceOnce([==[local canFling = context.configuration.autoFlingSheriff and active and humanoid and ownRoot and humanoid.Health > 0]==], [==[local canFling = context.configuration.autoFlingSheriff and active and humanoid and ownRoot and humanoid.Health > 0
				and not (own and own:FindFirstChild("Gun"))]==], "No new fling while gun is equipped")
mythicReplaceOnce([==[if not ok or method ~= "FireServer" or not current or not current.on or current.bypass or globals.__pulseAimGen ~= generation then]==], [==[if not ok or method ~= "FireServer" or not current or not current.on or current.bypass or globals.__pulseAimGen ~= generation or (settings.silentAim and settings.wallbang) then]==], "Skip intercepted shot if incompatible pair")
-- MYTHIC AUTO SHOOT STABILITY v1.6: desacelera tentativas automaticas e bloqueia combinacoes instaveis.
mythicReplaceOnce([==[local interval = rapid and (aim.dsGap or 0.04) or 0.2]==], [==[local interval = math.max(tonumber(aim.cooldown) or 3.2, 3.2)]==], "Auto Shoot estabilidade 1")
mythicReplaceOnce([==[if not settings.autoShoot or now - lastAuto <= interval or not SheriffRuntime.gun(context) then return end]==], [==[if not settings.autoShoot or settings.silentAim or settings.wallbang or now - lastAuto <= interval or not SheriffRuntime.gun(context) then return end]==], "Auto Shoot estabilidade 2")
local fn, parseError = loadstring(source)
if not fn then
    error("MYTHIC HUB: erro ao compilar Lua: " .. tostring(parseError))
end
return fn()
