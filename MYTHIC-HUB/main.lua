-- MYTHIC HUB | Link oficial estavel
-- Mantem o comando original enquanto carrega a distribuicao encoded-v2.
-- Fonte anterior preservada no historico Git e no repositorio privado.
local url = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/encoded-v2/loader.lua"

local ok, source = pcall(function()
    return game:HttpGet(url)
end)
if not ok or type(source) ~= "string" or #source < 10000 then
    error("MYTHIC HUB: falha ao baixar a versao atual. Confira a conexao com o GitHub.", 0)
end

local run, err = loadstring(source)
if type(run) ~= "function" then
    error("MYTHIC HUB: versao atual invalida: " .. tostring(err), 0)
end

return run()
