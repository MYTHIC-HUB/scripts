-- MYTHIC HUB: select the game's device choice when both Mobile and PC options are visible.
-- No changes to CoreGui / system prompts. If input injection is unavailable, leave choice to user.
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
if not player then return end
local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then return end

local function isMobile()
    local ok, platform = pcall(function() return UserInputService:GetPlatform() end)
    if ok and platform then
        local value = tostring(platform)
        if value:find("Android", 1, true) or value:find("IOS", 1, true) then return true end
        if value:find("Windows", 1, true) or value:find("OSX", 1, true) then return false end
    end
    local preferredOK, preferred = pcall(function() return UserInputService.PreferredInput end)
    if preferredOK and preferred == Enum.PreferredInput.Touch then return true end
    if preferredOK and preferred == Enum.PreferredInput.KeyboardAndMouse then return false end
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local mobile = isMobile()
local global = type(getgenv) == "function" and getgenv() or _G
global.__mythicDeviceChoice = mobile and "Mobile" or "Computer"

local function active(button, gui)
    if not gui.Enabled or not button.Visible then return false end
    if button.AbsoluteSize.X < 10 or button.AbsoluteSize.Y < 10 then return false end
    local ancestor = button.Parent
    while ancestor and ancestor ~= gui do
        if ancestor:IsA("GuiObject") and not ancestor.Visible then return false end
        ancestor = ancestor.Parent
    end
    return ancestor == gui
end

local function kindOf(button)
    local label = string.lower(button.Name)
    if button:IsA("TextButton") then label ..= " " .. string.lower(button.Text) end
    for _, child in button:GetDescendants() do
        if child:IsA("TextLabel") then label ..= " " .. string.lower(child.Text) end
    end
    if label:find("mobile", 1, true) or label:find("celular", 1, true)
        or label:find("touch", 1, true) or label:find("telefone", 1, true) then
        return "mobile"
    end
    if label:match("%f[%a]pc%f[%A]") or label:find("computer", 1, true)
        or label:find("computador", 1, true) or label:find("desktop", 1, true) then
        return "computer"
    end
end

local function clickButton(button)
    local pos = button.AbsolutePosition + (button.AbsoluteSize / 2)
    local okVirtual, virtual = pcall(function() return UserInputService:CreateVirtualInput() end)
    if okVirtual and virtual then
        local ok = pcall(function()
            virtual:SendMouseButton(pos, Enum.UserInputType.MouseButton1, true, 0)
            task.wait(0.05)
            virtual:SendMouseButton(pos, Enum.UserInputType.MouseButton1, false, 0)
        end)
        if ok then return true end
    end
    local okManager, manager = pcall(function() return game:GetService("VirtualInputManager") end)
    if okManager and manager then
        local ok = pcall(function()
            manager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
            task.wait(0.05)
            manager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
        end)
        if ok then return true end
    end
    local fire = rawget(global, "firesignal")
    if type(fire) == "function" then
        local ok = pcall(fire, button.MouseButton1Click)
        if ok then return true end
    end
    return false
end

local started = os.clock()
repeat
    local groups = {}
    for _, button in playerGui:GetDescendants() do
        if button:IsA("GuiButton") then
            local gui = button:FindFirstAncestorOfClass("ScreenGui")
            if gui and not gui.Name:upper():find("MYTHIC", 1, true)
                and not gui.Name:upper():find("PULSE", 1, true) and active(button, gui) then
                local kind = kindOf(button)
                if kind then
                    groups[gui] = groups[gui] or {}
                    groups[gui][kind] = groups[gui][kind] or button
                end
            end
        end
    end
    for _, options in pairs(groups) do
        if options.mobile and options.computer then
            if not clickButton(mobile and options.mobile or options.computer) then
                warn("MYTHIC HUB: clique automatico indisponivel; escolha o dispositivo manualmente.")
            end
            return
        end
    end
    task.wait(0.4)
until os.clock() - started >= 25
