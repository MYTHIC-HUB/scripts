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
local avatarBase64 = [==[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]==]
mythicReplaceOnce("local EMBEDDED_FILES = {", 'local EMBEDDED_FILES = {\n    ["PulseHub/nova/mythic_avatar_logo.jpg"] = [=[' .. avatarBase64 .. ']=],', "foto")
local fn, parseError = loadstring(source)
if not fn then
    error("MYTHIC HUB: erro ao compilar Lua: " .. tostring(parseError))
end
return fn()
