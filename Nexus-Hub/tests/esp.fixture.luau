-- Executes the real marker/projection flow with a deterministic camera, without Roblox rendering.
local vectorMeta = {}
local function vector(x, y, z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},vectorMeta) end
function vectorMeta.__sub(a,b) return vector(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
function vectorMeta.__add(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
function vectorMeta.__index(a,key)
    if key=="Magnitude" then return math.sqrt(a.X*a.X+a.Y*a.Y+a.Z*a.Z) end
end
local Vector3={new=vector,zero=vector()}
local Vector2={new=function(x,y)return {X=x,Y=y}end}
local UDim2={fromOffset=function(x,y)return {X={Offset=x},Y={Offset=y}}end,
    fromScale=function(x,y)return {X={Scale=x},Y={Scale=y}}end}
local Color3={fromRGB=function(r,g,b)return {r=r,g=g,b=b}end}
local Enum={Font={GothamBold="GothamBold"},HighlightDepthMode={AlwaysOnTop="AlwaysOnTop"}}
local registry={}
local methods={}
local Instance={new=function(class)
    local object=setmetatable({ClassName=class,Parent=nil},{__index=methods})
    table.insert(registry,object)
    return object
end}
function methods:IsA(class) return self.ClassName==class or (class=="BasePart" and self.ClassName=="Part") end
function methods:GetChildren()
    local children={}
    for _,object in ipairs(registry)do if object.Parent==self then table.insert(children,object)end end
    return children
end
function methods:FindFirstChild(name)
    for _,object in ipairs(self:GetChildren())do if object.Name==name then return object end end
end
function methods:FindFirstChildOfClass(class)
    for _,object in ipairs(self:GetChildren())do if object:IsA(class)then return object end end
end
function methods:IsDescendantOf(ancestor)
    local parent=self.Parent
    while parent do if parent==ancestor then return true end;parent=parent.Parent end
    return false
end
function methods:Destroy()
    for _,child in ipairs(self:GetChildren())do child:Destroy()end
    self.Destroyed=true;self.Parent=nil
end
local Workspace=Instance.new("Workspace")
local camera={ViewportSize={X=800,Y=600},CFrame={Position=vector()}}
function camera:WorldToViewportPoint(position)
    local projected=vector(400+position.X*10,300-position.Y*10,position.Z)
    return projected,projected.Z>0 and projected.X>=0 and projected.X<=800 and projected.Y>=0 and projected.Y<=600
end
Workspace.CurrentCamera=camera
local players={}
local Players={GetPlayers=function()return players end}
local unbound=0
local RunService={UnbindFromRenderStep=function()unbound+=1 end}
local services={Workspace=Workspace,Players=Players,RunService=RunService}
local game={GetService=function(_,name)services[name]=services[name]or{};return services[name]end}

-- INSERT_GAME_MODULE

local function bodyPart(character,name,x,y,z)
    local part=Instance.new("Part");part.Name=name;part.Position=vector(x,y,z);part.Parent=character
    return part
end
local function character(r15)
    local model=Instance.new("Model");model.Parent=Workspace
    local root=bodyPart(model,"HumanoidRootPart",0,0,10)
    local humanoid=Instance.new("Humanoid");humanoid.Health=100;humanoid.Parent=model
    bodyPart(model,"Head",0,3,10)
    if r15 then
        bodyPart(model,"UpperTorso",0,1,10);bodyPart(model,"LowerTorso",0,0,10)
        for _,side in ipairs({{"Left",-1},{"Right",1}})do
            local prefix,sign=side[1],side[2]
            bodyPart(model,prefix.."UpperArm",sign,1,10);bodyPart(model,prefix.."LowerArm",sign,0,10)
            bodyPart(model,prefix.."Hand",sign,-1,10);bodyPart(model,prefix.."UpperLeg",sign/2,-1,10)
            bodyPart(model,prefix.."LowerLeg",sign/2,-2,10);bodyPart(model,prefix.."Foot",sign/2,-3,10)
        end
    else
        bodyPart(model,"Torso",0,1,10);bodyPart(model,"Left Arm",-2,1,10);bodyPart(model,"Right Arm",2,1,10)
        bodyPart(model,"Left Leg",-1,-2,10);bodyPart(model,"Right Leg",1,-2,10)
    end
    return model,root,humanoid
end
local localCharacter,localRoot=character(false)
local targetCharacter,targetRoot,targetHumanoid=character(false)
local localPlayer={Character=localCharacter,UserId=1,Name="Local",DisplayName="Local"}
local target={Character=targetCharacter,UserId=2,Name="Target",DisplayName="Target"}
players={localPlayer,target}
localRoot.Position=vector(-5,0,10)
local settings={["visuals.esp"]=true,["visuals.maxDistance"]=2000}
local role="innocent"
local unobstructed=true
local instance=setmetatable({alive=true,context={},settings=settings,adapters={},player=localPlayer,
    markers={},gunMarkers={},guns={},roles={},connections={},webhookGeneration=0,roleEpoch=0,
    folder=Instance.new("Folder"),visualGui=Instance.new("ScreenGui"),aimRenderName="testEsp"},Game)
function instance:_role() return role,true end
function instance:_visible()return unobstructed end
function instance:_cancelFarm()end
local function visibleBones(marker)
    local count=0
    for _,pair in ipairs(marker.boneLines)do
        if pair[2].Visible then
            count+=1
            assert(pair[1].Visible,"The visible bone must have a contrasting outline")
            assert(pair[2].Size.X.Offset>0 and pair[2].Size.X.Offset<3200,"Invalid bone geometry")
        end
    end
    return count
end
instance:_updateMarkers();instance:_updateEspProjection()
local marker=instance.markers[target]
assert(marker and marker.overlay and marker.overlay.Visible)
local r6Bones=visibleBones(marker)
assert(r6Bones>=5 and not marker.arrow.Visible,"R6 body must draw lines without an offscreen arrow")
assert(instance:Supports("esp.skeleton") and instance:Supports("esp.arrows"))
local head=targetCharacter:FindFirstChild("Head");head.Parent=nil
instance:_updateEspProjection();assert(visibleBones(marker)<r6Bones,"Streaming-out parts must hide stale bones")
head.Parent=targetCharacter
targetRoot.Position=vector(100,0,10)
instance:_updateEspProjection()
assert(marker.arrow.Visible and visibleBones(marker)==0,"Offscreen targets need an arrow rather than stale body lines")
assert(marker.arrow.Position.X.Offset<=762 and marker.arrow.Position.Y.Offset==300)
assert(marker.triangle.Rotation==90 and marker.triangle.TextColor3.g==198)
assert(marker.arrowDistance.Text=="105 st","Arrow distance must use the observed target position")
targetRoot.Position=vector(0,0,-10)
instance:_updateEspProjection()
assert(marker.arrow.Visible and marker.triangle.Rotation==180,"Target directly behind must have a finite downward direction")
assert(marker.arrow.Position.Y.Offset==562)
settings["esp.arrows"]=false;instance:_updateEspProjection();assert(not marker.arrow.Visible)
targetRoot.Position=vector(0,0,10);settings["esp.skeleton"]=false
instance:_updateEspProjection();assert(visibleBones(marker)==0)
settings["esp.skeleton"]=true;settings["esp.arrows"]=true
targetRoot.Position=vector(100,0,10);settings["visuals.maxDistance"]=10
instance:_updateEspProjection()
assert(not marker.overlay.Visible and marker.highlight.Enabled==false and marker.billboard.Enabled==false,
    "All ESP elements must share the distance filter")
instance:_updateMarkers();assert(not instance.markers[target] and marker.overlay.Destroyed)
settings["visuals.maxDistance"]=2000;settings["esp.innocent"]=false
instance:_updateMarkers();assert(not instance.markers[target],"Role filtering must also apply to overlays")
settings["esp.innocent"]=true;settings["visuals.visibilityCheck"]=true;unobstructed=false
instance:_updateMarkers();assert(not instance.markers[target],"Occluded targets must not leak an overlay")
unobstructed=true;targetRoot.Position=vector(0,0,10)
instance:_updateMarkers();instance:_updateEspProjection();marker=instance.markers[target]
local oldOverlay=marker.overlay
target.Character,targetRoot,targetHumanoid=character(true)
instance:_updateEspProjection()
assert(not instance.markers[target] and oldOverlay.Destroyed,"A respawn must discard old body references immediately")
instance:_updateMarkers();instance:_updateEspProjection();marker=instance.markers[target]
assert(visibleBones(marker)>r6Bones,"R15 must draw its articulated arm/leg links")
targetHumanoid.Health=0;instance:_updateEspProjection()
assert(not instance.markers[target] and marker.overlay.Destroyed,"Dead characters must not retain arrows or body lines")
targetHumanoid.Health=100;instance:_updateMarkers();instance:_updateEspProjection();marker=instance.markers[target]
settings["visuals.esp"]=false;instance:_updateEspProjection()
assert(not instance.markers[target] and marker.overlay.Destroyed and marker.billboard.Destroyed and marker.highlight.Destroyed)
settings["visuals.esp"]=true;instance:_updateMarkers();instance:_updateEspProjection();marker=instance.markers[target]
instance:Destroy();instance:_updateEspProjection()
assert(not instance.alive and marker.overlay.Destroyed and marker.billboard.Destroyed and marker.highlight.Destroyed and unbound==1,
    "Unload must destroy every overlay and stop the shared render callback")
print("PASS: R6/R15 ESP geometry, offscreen/behind arrows, filters, streaming, OFF, respawn, death and unload")
