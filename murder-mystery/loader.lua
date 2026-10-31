-- Loader do painel MM2. A mensagem de erro distingue download, compilação e execução.
local SOURCE_URL = "https://raw.githubusercontent.com/Pulse-Hubs/scripts/7f4cf03298b85eced37b46cd02ed99c2883c5dfa/murder-mystery/main.lua"
local PREFIX = "[MM2 Pulse] "
local READY_TIMEOUT = 60

local function report(message, isError)
    local text = PREFIX .. tostring(message)
    if isError then warn(text) else print(text) end
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = isError and "MM2 — erro no carregamento" or "MM2 — carregado",
            Text = tostring(message), Duration = isError and 12 or 5,
        })
    end)
end

local function fail(stage, details)
    local message = stage .. ": " .. tostring(details or "erro não informado")
    report(message, true)
    error(PREFIX .. message, 0)
end

if type(loadstring) ~= "function" then
    fail("Compilação indisponível", "Este ambiente não disponibiliza loadstring.")
end

local readyOK, readyError = pcall(function()
    local players = game:GetService("Players")
    local started = os.clock()
    while not game:IsLoaded() or not players.LocalPlayer do
        if os.clock() - started >= READY_TIMEOUT then
            error("O jogo ou o jogador local não ficou pronto em 60 segundos.", 0)
        end
        task.wait(0.1)
    end
end)
if not readyOK then fail("Falha ao aguardar o jogo", readyError) end

local downloaded, source = pcall(function() return game:HttpGet(SOURCE_URL) end)
if not downloaded then fail("Falha no download do GitHub", source) end
if type(source) ~= "string" or not source:find("%S") then
    fail("Resposta inválida do GitHub", "O arquivo Lua veio vazio.")
end
if source:match("^%s*<") then
    fail("Resposta inválida do GitHub", "Foi recebida uma página HTML em vez do código Lua.")
end

local compiled, chunk, compileError = pcall(loadstring, source, "MM2-Pulse-Hubs")
if not compiled then fail("Falha ao compilar o script", chunk) end
if type(chunk) ~= "function" then fail("Falha ao compilar o script", compileError) end

local executed, result, resultError = xpcall(chunk, function(message)
    if debug and type(debug.traceback) == "function" then
        return debug.traceback(tostring(message), 2)
    end
    return tostring(message)
end)
if not executed then fail("Erro durante a execução do script", result) end
if result == false then fail("O script informou falha na inicialização", resultError) end
if type(result) == "table" and (result.ok == false or result.success == false) then
    fail("O script informou falha na inicialização", result.error or result.message)
end

report("Painel carregado", false)
