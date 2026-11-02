import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

test('MP3 checks and single-song lifecycle without network or copyrighted audio', () => {
  const source = fs.readFileSync(path.join(path.dirname(fileURLToPath(import.meta.url)), '..', 'src', 'Music.luau'), 'utf8');
  const prefix = `local signal={Connect=function() return {Disconnect=function() end} end}
local services = {RunService={Heartbeat=signal},Players={LocalPlayer={}},ReplicatedStorage={DescendantAdded=signal,FindFirstChild=function() return nil end}}
local game={GetService=function(_,name) return services[name] end}
local runtimeEnvironment={}
local getfenv=function() return runtimeEnvironment end
local task={spawn=function(callback) callback() end}
local Music=(function()\n`;
  const checks = `\nend)()
local tagged="ID3"..string.char(4)..string.rep("x",124)
assert(Music.validateAudio(tagged,"audio/mpeg"))
assert(Music.validateAudio(string.char(255,251)..string.rep("x",126),"audio/mp3"))
assert(not Music.validateAudio("<html>"..string.rep("x",150),"audio/mpeg"))
assert(not Music.validateAudio(tagged,"text/html"))
assert(not Music.validateAudio("ID3", "audio/mpeg"))
assert(not Music.validateAudio("ID3"..string.char(4)..string.rep("x",10*1024*1024),"audio/mpeg"))
local stops=0
local sound={IsPlaying=false,Stop=function() stops+=1 end}
local features={sound=sound}
local music=Music.new({features=features,settings={},get=function() return false end})
assert(#features.playlist==1 and features.playlist[1].name=="Craudete - Brancoala")
assert(features.playlist[1].id=="" and stops==0)
assert(music:Supports("music.play")==false)
assert(music:Supports("music.onScreen")==true)
assert(music:Supports("music.volume")==nil)
assert(music:Supports("music.autoPlay")==false)
assert(#music:GetCatalog("music.songs")==1)
assert(music:GetCatalog("music.songs")[1].id=="craudete")
assert(not music:Action("music.songs", "other-song"))
music:Destroy();music:Destroy()
assert(stops==1 and not music.alive)
local calls=0
runtimeEnvironment.request=function() calls+=1; error("Simulated HTTP failure; no real network") end
runtimeEnvironment.writefile=function() error("A failed response must not be saved") end
runtimeEnvironment.makefolder=function() end
runtimeEnvironment.getcustomasset=function() return "rbxasset://fixture.mp3" end
local callback
local round={IsA=function(_,name) return name=="RemoteEvent" end,OnClientEvent={Connect=function(_,fn) callback=fn;return {Disconnect=function() end} end}}
local gameplay={FindFirstChild=function(_,name) if name=="RoundStart" then return round end end}
local remotes={FindFirstChild=function(_,name) if name=="Gameplay" then return gameplay end end}
services.ReplicatedStorage.FindFirstChild=function(_,name) if name=="Remotes" then return remotes end end
local settings={}
local automatic=Music.new({features=features,settings=settings,get=function(id) return settings[id] end})
assert(automatic:Supports("music.autoPlay"))
callback();assert(calls==0,"RoundStart must not autoplay by default")
assert(automatic:Set("music.autoPlay",true))
callback();assert(calls==1,"An enabled RoundStart must attempt the fixed song")
assert(automatic:Set("music.autoPlay",false))
callback();assert(calls==1,"Disabled autoplay must not fetch audio")
automatic:Destroy();callback();assert(calls==1,"Unloaded callbacks must not fetch audio")
print("PASS: MP3 validation, no autoplay, only Craudete, capability detection and cleanup")
`;
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'nexus-music-'));
  try {
    const target = path.join(directory, 'music.luau');
    fs.writeFileSync(target, prefix + source + checks);
    const result = spawnSync(process.env.LUAU_BINARY || 'luau', [target], { encoding: 'utf8' });
    assert.ifError(result.error);
    assert.equal(result.status, 0, result.stderr + result.stdout);
  } finally { fs.rmSync(directory, { recursive: true, force: true }); }
});
