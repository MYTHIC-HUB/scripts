-- MYTHIC HUB - entrada estavel para a distribuicao codificada.
-- Este arquivo permanece pequeno; o codigo principal fica no loader de distribuicao.
-- A versao anterior (MYTHIC-HUB/main.lua) continua disponivel para compatibilidade.
local loaderUrl = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/encoded-v1/loader.lua"

local ok, body = pcall(function()
    return game:HttpGet(loaderUrl)
end)
if not ok or type(body) ~= "string" or #body < 10000 then
    error("MYTHIC HUB: nao foi possivel carregar a distribuicao. Verifique sua conexao.", 0)
end

local execute, syntaxError = loadstring(body)
if type(execute) ~= "function" then
    error("MYTHIC HUB: loader invalido: " .. tostring(syntaxError), 0)
end

return execute()
