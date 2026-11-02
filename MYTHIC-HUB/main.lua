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
local fn, parseError = loadstring(source)
if not fn then
    error("MYTHIC HUB: erro ao compilar Lua: " .. tostring(parseError))
end
return fn()
