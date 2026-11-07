-- Entry point: load the hub without inventory reporting or automated trades.
local hostGlobal = type(getgenv) == "function" and getgenv() or _G
local revision = hostGlobal.MYTHIC_HUB_REF or "main"
assert(type(revision) == "string" and revision:match("^[%w%._/-]+$"), "Invalid MYTHIC_HUB_REF")
local source = game:HttpGet("https://raw.githubusercontent.com/MYTHIC-HUB/scripts/" .. revision .. "/MYTHIC-HUB/main.lua")
local chunk, problem = loadstring(source)
source = nil
if not chunk then error("MYTHIC-HUB: " .. tostring(problem), 0) end
return chunk()
