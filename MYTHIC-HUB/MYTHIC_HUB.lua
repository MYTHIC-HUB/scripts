local url = "https://raw.githubusercontent.com/MYTHIC-HUB/scripts/main/MYTHIC-HUB/main.lua"
local ok, body = pcall(function() return game:HttpGet(url) end)
if not ok or type(body) ~= "string" or body == "" then
    error("MYTHIC HUB: erro ao baixar o loader. Verifique a conexao e o GitHub.")
end
local run, err = loadstring(body)
if type(run) ~= "function" then
    error("MYTHIC HUB: erro ao compilar loader: " .. tostring(err))
end
return run()
