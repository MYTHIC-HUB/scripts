-- Luau / MYTHIC-HUB/mythic-badges.lua / Arceus X Neo / Roblox MM2
-- Etiquetas locais e voluntarias, sem busca entre servidores. IDs declarados, nao autenticados.
return function(context)
    local section = context.section
    local hub = context.hub
    local window = context.window
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local localPlayer = Players.LocalPlayer
    local task = task
    local live = true
    local optedIn = false
    local session = nil
    local known = {}
    local connections = {}
    local lastHeartbeat = 0
    local endpoint = "https://bpgovdwdigwrrzokqvlh.supabase.co/functions/v1/mythic-badges"
    local allowed = game.PlaceId == 142823291 and type(game.JobId) == "string" and #game.JobId >= 20

    local requestApi = type(context.request) == "function" and context.request or
        type(request) == "function" and request or
        type(http_request) == "function" and http_request or nil
    if not requestApi then
        pcall(function() if syn and type(syn.request) == "function" then requestApi = syn.request end end)
    end
    if not requestApi then
        pcall(function() if http and type(http.request) == "function" then requestApi = http.request end end)
    end

    section:Group({Title="USER MYTHIC | Mesmo servidor", Side="Right"})
    section:Note({Text="Para ver USER MYTHIC sobre Samuelzinho, ative esta opcao no celular dele. Para os dois verem a tag um do outro, ative nos dois celulares."})
    local status = section:Note({Text="Identificacao desativada. Ative somente se quiser aparecer para outros usuarios MYTHIC no mesmo servidor."})
    local countStatus = section:Note({Text="Tags neste servidor: carregando..."})
    local function updateStatus(value)
        pcall(function() status.Text = tostring(value) end)
    end
    local function call(data)
        if not requestApi then return nil end
        local encodedOk, body = pcall(function() return HttpService:JSONEncode(data) end)
        if not encodedOk then return nil end
        local ok, reply = pcall(requestApi, {
            Url=endpoint, Method="POST",
            Headers={["Content-Type"]="application/json",["Accept"]="application/json"},
            Body=body
        })
        if not ok or type(reply)~="table" then return nil end
        local code=tonumber(reply.StatusCode or reply.Status or 0)
        if not code or code < 200 or code >= 300 then
            warn("MYTHIC TAG: pedido recusado (HTTP " .. tostring(code or "?") .. ")")
            return nil
        end
        local decoded,payload=pcall(function() return HttpService:JSONDecode(tostring(reply.Body or reply.body or "")) end)
        return decoded and type(payload)=="table" and payload.ok==true and payload or nil
    end

    local logo="rbxassetid://102076719808486"
    pcall(function()
        local resolver=type(getcustomasset)=="function" and getcustomasset or
            (type(getsynasset)=="function" and getsynasset or nil)
        if resolver then
            local asset=resolver("PulseHub/nova/mythic_avatar_logo.jpg")
            if type(asset)=="string" and #asset>0 then logo=asset end
        end
    end)

    local function removeTag(player)
        if not player.Character then return end
        local head=player.Character:FindFirstChild("Head")
        if head then
            local old=head:FindFirstChild("MYTHIC_USER_TAG")
            if old then old:Destroy() end
        end
    end
    local function drawTag(player)
        if not live or player==localPlayer or not known[player.UserId] then
            removeTag(player)
            return
        end
        local character=player.Character
        local head=character and character:FindFirstChild("Head")
        if not head or head:FindFirstChild("MYTHIC_USER_TAG") then return end

        local gui=Instance.new("BillboardGui")
        gui.Name="MYTHIC_USER_TAG"
        gui.Size=UDim2.fromOffset(188,42)
        gui.StudsOffsetWorldSpace=Vector3.new(0,2.65,0)
        gui.AlwaysOnTop=true
        gui.LightInfluence=0
        gui.MaxDistance=85
        gui.Adornee=head
        gui.Parent=head
        local base=Instance.new("Frame")
        base.Size=UDim2.fromScale(1,1)
        base.BackgroundColor3=Color3.fromRGB(20,9,38)
        base.BackgroundTransparency=.08
        base.BorderSizePixel=0
        base.Parent=gui
        local corner=Instance.new("UICorner")
        corner.CornerRadius=UDim.new(0,11)
        corner.Parent=base
        local border=Instance.new("UIStroke")
        border.Thickness=1.7
        border.Color=Color3.fromRGB(169,65,247)
        border.Parent=base
        local icon=Instance.new("ImageLabel")
        icon.Name="MYTHIC_LOGO"
        icon.BackgroundTransparency=1
        icon.Size=UDim2.fromOffset(32,32)
        icon.Position=UDim2.fromOffset(5,5)
        icon.Image=logo
        icon.ScaleType=Enum.ScaleType.Fit
        icon.Parent=base
        local text=Instance.new("TextLabel")
        text.Name="MYTHIC_TEXT"
        text.Position=UDim2.fromOffset(42,5)
        text.Size=UDim2.new(1,-48,1,-10)
        text.BackgroundTransparency=1
        text.Font=Enum.Font.GothamBold
        text.Text="USER MYTHIC"
        text.TextColor3=Color3.fromRGB(245,221,255)
        text.TextScaled=true
        text.Parent=base
    end

    local function unregister()
        local old=session
        session=nil
        if old then
            task.spawn(function()
                call({action="leave",session_id=old.session_id,token=old.token})
            end)
        end
    end
    local function sendHeartbeat()
        if not live or not allowed or not optedIn or not requestApi then return end
        if session then
            local result=call({action="ping",session_id=session.session_id,token=session.token})
            if not result then session=nil end
        end
        if not session and live and optedIn then
            local result=call({action="join",user_id=localPlayer.UserId,
                place_id=game.PlaceId,job_id=game.JobId})
            if not live or not optedIn then
                if result and result.session_id and result.token then
                    call({action="leave",session_id=result.session_id,token=result.token})
                end
                return
            end
            if result and result.session_id and result.token then
                session={session_id=result.session_id,token=result.token}
                updateStatus("Sua tag esta visivel para outros usuarios MYTHIC deste servidor.")
            else
                updateStatus("Servidor de tags indisponivel. Tente mais tarde.")
            end
        end
    end
    local function updateVisible()
        if not live or not allowed or not requestApi then return end
        local result=call({action="list",place_id=game.PlaceId,job_id=game.JobId})
        if not live then return end
        if not result or type(result.user_ids)~="table" then
            pcall(function() countStatus.Text="Falha ao consultar tags. Verifique a conexao." end)
            return
        end
        local nextKnown={}
        for _,id in ipairs(result.user_ids) do
            local n=tonumber(id)
            if n then nextKnown[n]=true end
        end
        known=nextKnown
        local recognized = 0
        for _,player in ipairs(Players:GetPlayers()) do
            if player~=localPlayer and known[player.UserId] then recognized+=1 end
            drawTag(player)
        end
        pcall(function()
            countStatus.Text="Tags detectadas neste servidor: "..tostring(recognized)
        end)
    end
    local function stop()
        if not live then return end
        live=false
        optedIn=false
        unregister()
        for _,connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        for _,player in ipairs(Players:GetPlayers()) do removeTag(player) end
    end

    local globalEnv=type(getgenv)=="function" and getgenv() or _G
    if type(globalEnv.__mythicBadgeStop)=="function" then
        pcall(globalEnv.__mythicBadgeStop)
    end
    globalEnv.__mythicBadgeStop=stop

    section:Toggle({Text="Exibir minha tag USER MYTHIC",Default=false,NoSave=true,
        Callback=function(value)
            optedIn=(value==true)
            if optedIn then
                updateStatus("Ativando sua tag MYTHIC...")
                task.spawn(function()
                    sendHeartbeat()
                    updateVisible()
                end)
            else
                updateStatus("Sua tag esta desativada.")
                unregister()
            end
        end
    })
    section:Button({Text="Atualizar tags agora",Callback=function()
        task.spawn(updateVisible)
    end})
    if not allowed then
        updateStatus("Tags disponiveis apenas dentro dos servidores MM2.")
    elseif not requestApi then
        updateStatus("O executor nao suporta consulta HTTP de tags.")
    else
        local function watch(player)
            table.insert(connections,player.CharacterAdded:Connect(function()
                task.delay(.3,function() if live then drawTag(player) end end)
            end))
        end
        for _,player in ipairs(Players:GetPlayers()) do watch(player) end
        table.insert(connections,Players.PlayerAdded:Connect(watch))
        table.insert(connections,Players.PlayerRemoving:Connect(function(player)
            known[player.UserId]=nil
            removeTag(player)
        end))
        task.spawn(function()
            while live and not hub.dead and not window.Destroyed do
                local now=os.clock()
                if now-lastHeartbeat >= 23 then
                    lastHeartbeat=now
                    sendHeartbeat()
                end
                updateVisible()
                task.wait(6)
            end
            stop()
        end)
    end
    return stop
end
