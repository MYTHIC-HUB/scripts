-- Real appearance handlers with live-rig mutation tripwires; no Roblox networking/rendering.
local vectorMeta = {}
local function vector(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vectorMeta) end
function vectorMeta.__add(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function vectorMeta.__sub(a,b) return vector(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function vectorMeta.__mul(a,b) return vector(a.X*b.X,a.Y*b.Y,a.Z*b.Z) end
local Vector3 = {new=vector,zero=vector()}
local frameMeta={}
local function frame(x,y,z) return setmetatable({Position=type(x)=="table" and x or vector(x,y,z)},frameMeta) end
function frameMeta.__mul(a,b) return frame(a.Position+b.Position) end
function frameMeta.__index(a,key)
    if key=="Inverse" then return function() return frame(vector(-a.Position.X,-a.Position.Y,-a.Position.Z)) end end
end
local CFrame={new=frame}
local Enum={HumanoidRigType={R6="R6",R15="R15"},BodyPart={RightLeg="RightLeg"},AccessoryType={RightShoe="RightShoe"}}
local queue={}
local task={defer=function(callback)table.insert(queue,callback)end}
local objects,methods={},{}
local destroyedLive=0
local blockedWrites={Health=true,RequiresNeck=true,RigType=true,BreakJointsOnDeath=true,Part0=true,Part1=true}
local Instance={}
function Instance.new(className)
    local properties={Name=className,Parent=nil,LocalTransparencyModifier=0,Transparency=0,Size=vector(1,1,1),CFrame=frame(),Position=vector()}
    local object={_class=className,_properties=properties,_children={},live=false}
    setmetatable(object,{
        __index=function(self,key)
            if key=="CFrame" and self._class=="Attachment" then return frame(properties.Position) end
            return methods[key] or properties[key]
        end,
        __newindex=function(self,key,value)
            if self.live and (blockedWrites[key] or key=="Parent" or key=="Size") then error("Destructive live rig write: "..key) end
            local previous=properties[key]
            if key=="Parent" and previous~=value then
                if previous then local i=table.find(previous._children,self);if i then table.remove(previous._children,i)end end
                if value then table.insert(value._children,self)end
            end
            properties[key]=value
        end,
    })
    table.insert(objects,object)
    return object
end
function methods:IsA(class)
    return class==self._class or (class=="BasePart" and (self._class=="Part" or self._class=="MeshPart"))
        or (class=="LuaSourceContainer" and self._class=="Script") or (class=="JointInstance" and self._class=="Motor6D")
end
function methods:GetChildren()return table.clone(self._children)end
function methods:GetDescendants()
    local result={}
    for _,child in ipairs(self._children)do table.insert(result,child);for _,nested in ipairs(child:GetDescendants())do table.insert(result,nested)end end
    return result
end
function methods:FindFirstChild(name,recursive)
    for _,child in ipairs(self._children)do if child.Name==name then return child end end
    if recursive then for _,child in ipairs(self._children)do local found=child:FindFirstChild(name,true);if found then return found end end end
end
function methods:FindFirstChildOfClass(class)
    for _,child in ipairs(self._children)do if child:IsA(class)then return child end end
end
function methods:IsDescendantOf(ancestor)
    local p=self.Parent
    while p do if p==ancestor then return true end;p=p.Parent end
    return false
end
function methods:FindFirstAncestorOfClass(class)
    local p=self.Parent
    while p do if p:IsA(class)then return p end;p=p.Parent end
end
function methods:Clone()
    local copy=Instance.new(self._class)
    for key,value in pairs(self._properties)do if key~="Parent" then copy[key]=value end end
    for _,child in ipairs(self:GetChildren())do child:Clone().Parent=copy end
    return copy
end
function methods:Destroy()
    if self.live then destroyedLive+=1;error("Attempted live rig destruction")end
    for _,child in ipairs(self:GetChildren())do child:Destroy()end
    self.Parent=nil;rawset(self,"Destroyed",true)
end
function methods:ApplyDescription()error("A live humanoid description must not be applied by appearance toggles")end
function methods:GetAppliedDescription()error("Headless/Korblox must not read a live description")end
function methods:BreakJoints()error("Appearance must not break joints")end
local Workspace=Instance.new("Workspace")
local Players={}
local AssetService={LoadAssetAsync=function()error("Native asset insertion unavailable in test")end}
local services={Workspace=Workspace,Players=Players,AssetService=AssetService}
local game={GetService=function(_,name)services[name]=services[name]or{};return services[name]end}

-- INSERT_FEATURES_MODULE

local function object(class,name,parent)
    local value=Instance.new(class);value.Name,value.Parent=name,parent;return value
end
local function character(rig)
    local body=object("Model","Character",Workspace)
    local humanoid=object("Humanoid","Humanoid",body);humanoid.RigType,humanoid.Health=rig,100
    local head=object("Part","Head",body)
    local face=object("Decal","face",head)
    local root=object("Part","HumanoidRootPart",body)
    local torso=object("Part","Torso",body)
    local neck=object("Motor6D","Neck",torso);neck.Part0,neck.Part1=torso,head
    if rig=="R6" then object("Part","Right Leg",body)
    else
        for i,name in ipairs({"RightUpperLeg","RightLowerLeg","RightFoot"})do
            local leg=object("MeshPart",name,body);leg.CFrame=frame(100,10-i,0)
            local attachment=object("Attachment",({"RightHipRigAttachment","RightKneeRigAttachment","RightAnkleRigAttachment"})[i],leg)
            attachment.Position=vector(0,0.5,0)
        end
    end
    for _,live in ipairs(body:GetDescendants())do rawset(live,"live",true)end
    return body,humanoid,head,face,torso,neck
end
local settings={}
local body,humanoid,head,face,torso,neck=character("R6")
local player={Character=body,LoadCharacter=function()error("Appearance must not respawn the player")end}
local notices={}
local features=setmetatable({alive=true,player=player,settings=settings,context={adapters={},notify=function(message)table.insert(notices,message)end},
    overrides={},activeSources={},serial=0,korbloxGeneration=0},Features)
-- Head and neck remain the same objects through repeated headless/invisibility transitions.
assert(features:Set("troll.fakeHeadless",true))
assert(head.LocalTransparencyModifier==1 and face.Transparency==1 and torso.LocalTransparencyModifier==0)
assert(humanoid.Health==100 and neck.Part1==head and body:FindFirstChild("Head")==head)
settings["player.invisible"]=true;features:_refreshCharacterVisuals()
assert(torso.LocalTransparencyModifier==1)
assert(features:Set("troll.fakeHeadless",false))
assert(head.LocalTransparencyModifier==1,"Turning headless off must preserve the independent invisibility owner")
settings["player.invisible"]=false;features:_refreshCharacterVisuals()
assert(head.LocalTransparencyModifier==0 and face.Transparency==0 and torso.LocalTransparencyModifier==0)
for _=1,8 do assert(features:Set("troll.fakeHeadless",true));assert(features:Set("troll.fakeHeadless",false))end
local lateFace=object("Decal","LateFace",head);rawset(lateFace,"live",true)
assert(features:Set("troll.fakeHeadless",true));features:_applyCharacterVisualObject(lateFace,body)
assert(lateFace.Transparency==1);assert(features:Set("troll.fakeHeadless",false));assert(lateFace.Transparency==0)
-- Classic R6 uses the actual official CharacterMesh rather than rejecting the rig or hiding a complete leg.
local existing=object("CharacterMesh","OriginalRightLegMesh",body)
existing.BodyPart,existing.MeshId,existing.BaseTextureId,existing.OverlayTextureId=Enum.BodyPart.RightLeg,12,13,14
assert(features:Set("troll.fakeKorblox",true))
local ownMesh=features.korblox.mesh
assert(ownMesh and ownMesh.Parent==body and ownMesh.MeshId==101851696 and ownMesh.OverlayTextureId==101851254)
assert(body:FindFirstChild("Right Leg").LocalTransparencyModifier==0 and existing.MeshId==101851696)
assert(features:Set("troll.fakeKorblox",false))
assert(ownMesh.Destroyed and existing.MeshId==12 and existing.BaseTextureId==13 and existing.OverlayTextureId==14)
-- Package folders must be resolved and the short R15 upper stump aligns at the hip, not the old thigh center.
body,humanoid,head,face,torso,neck=character("R15");player.Character=body
local function donor(missing)
    local package=object("Model","DetachedPackage")
    local rig=object("Folder","R15ArtistIntent",package)
    for i,name in ipairs({"RightUpperLeg","RightLowerLeg","RightFoot"})do
        if name~=missing then
            local leg=object("MeshPart",name,rig);leg.Transparency=i==1 and 0 or 1
            local att=object("Attachment",({"RightHipRigAttachment","RightKneeRigAttachment","RightAnkleRigAttachment"})[i],leg)
            att.Position=vector(0,0.24,0)
            object("Script","MustNotRun",leg)
            object("Motor6D","MustNotAttach",leg)
        end
    end
    return package
end
local lastDonor
features.context.adapters.KorbloxAsset=function()lastDonor=donor();return lastDonor end
assert(features:Set("troll.fakeKorblox",true))
local state=features.korblox
assert(lastDonor.Destroyed and #state.visuals==3 and state.folder.Parent==body)
local upper=body:FindFirstChild("RightUpperLeg")
local visual=state.visuals[1]
assert(math.abs(visual.CFrame.Position.Y-(upper.CFrame.Position.Y+0.26))<0.000001,"Visual hip attachment must align with the live hip")
assert(upper.LocalTransparencyModifier==1 and visual.LocalTransparencyModifier==0 and visual.Transparency==0)
assert(not visual:FindFirstChild("MustNotRun") and not visual:FindFirstChild("MustNotAttach"))
assert(visual:FindFirstChild("NexusKorbloxWeld").Part0==upper)
assert(humanoid.Health==100 and neck.Part1==head)
assert(features:Set("troll.fakeKorblox",false));assert(upper.LocalTransparencyModifier==0 and state.folder.Destroyed)
features.context.adapters.KorbloxAsset=function()lastDonor=donor("RightFoot");return lastDonor end
assert(not features:Set("troll.fakeKorblox",true))
assert(not features.korblox and lastDonor.Destroyed and upper.LocalTransparencyModifier==0,"A partial load cannot hide the original leg")
-- An OFF/unload or character replacement while a loader yields cancels the old generation.
features.context.adapters.KorbloxAsset=function()
    local package=donor();features:_clearKorblox();return package
end
assert(not features:Set("troll.fakeKorblox",true));assert(not features.korblox and upper.LocalTransparencyModifier==0)
features.context.adapters.KorbloxAsset=function()
    local package=donor();features.alive=false;return package
end
assert(not features:Set("troll.fakeKorblox",true));assert(not features.korblox and upper.LocalTransparencyModifier==0)
features.alive=true
features.context.adapters.KorbloxAsset=nil
Players.CreateHumanoidModelFromDescriptionAsync=function(_,description,rig)
    assert(description.RightLeg==139607718 and rig==Enum.HumanoidRigType.R15)
    return donor():FindFirstChild("R15ArtistIntent")
end
assert(features:Set("troll.fakeKorblox",true),"Detached model fallback must work without accessing the live description")
assert(features:Set("troll.fakeKorblox",false))
assert(destroyedLive==0 and humanoid.Health==100 and #notices==0,"Effects must not destroy the live rig, change health or emit activation notices")
print("PASS: Headless render-only ownership; official R6/R15 Korblox, hip alignment, atomic load, cancellation and unchanged live rigs")
