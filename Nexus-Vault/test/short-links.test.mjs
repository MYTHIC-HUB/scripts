import test from 'node:test';
import assert from 'node:assert/strict';
import {randomBytes,randomUUID,createHash} from 'node:crypto';
import {mkdtemp,rm,readFile} from 'node:fs/promises';
import path from 'node:path';
import {tmpdir} from 'node:os';
import {fileStorage} from '../storage.mjs';
import {createVault} from '../server.mjs';
test('compact links preserve old keys, shared counters, expiration and revocation',async()=>{
 const dir=await mkdtemp(path.join(tmpdir(),'vault-short-')),storage=await fileStorage(dir);
 const id=randomUUID(),old=randomBytes(32).toString('hex'),keyId=randomUUID(),hash=v=>createHash('sha256').update(v).digest('hex');
 await storage.transaction(s=>{s.scripts.push({id,name:'legacy',source:'return 7',enabled:true});s.keys.push({id:keyId,scriptId:id,hash:hash(old),uses:0,maxUses:2,revoked:false,expires:null});});
 const server=await createVault({password:'fixture-password-1234',storage});await new Promise(r=>server.listen(0,'127.0.0.1',r));const base='http://127.0.0.1:'+server.address().port;
 try{
  const login=await fetch(base+'/api/login',{method:'POST',body:JSON.stringify({password:'fixture-password-1234'})});const cookie=login.headers.get('set-cookie').split(';')[0],{csrf}=await login.json();
  const post=async(route,data)=>fetch(base+route,{method:'POST',headers:{Cookie:cookie,'X-CSRF-Token':csrf},body:JSON.stringify(data)});
  assert.equal((await fetch(base+'/api/keys/shorten',{method:'POST',body:JSON.stringify({scriptId:id,token:old})})).status,401);
  const response=await post('/api/keys/shorten',{scriptId:id,token:old});assert.equal(response.status,201);const result=await response.json();assert.match(result.path,/^\/r\/[A-Za-z0-9_-]{22}$/);assert.equal(result.id,keyId);
  const oldPath='/s/'+id+'?key='+old;assert.equal(await(await fetch(base+oldPath)).text(),'return 7');assert.equal(await(await fetch(base+result.path)).text(),'return 7');
  assert.equal((await fetch(base+oldPath)).status,403);assert.equal((await fetch(base+result.path)).status,403);
  let state=await storage.read();assert.equal(state.keys.length,1);assert.equal(state.keys[0].uses,2);
  assert.equal((await post('/api/keys/shorten',{scriptId:id,token:old})).status,403);
  const fresh=await(await post('/api/keys',{scriptId:id,hours:0,maxUses:0})).json();assert.equal(fresh.token.length,22);assert.equal(await(await fetch(base+fresh.path)).text(),'return 7');
  await fetch(base+'/api/keys/'+fresh.id,{method:'DELETE',headers:{Cookie:cookie,'X-CSRF-Token':csrf}});assert.equal((await fetch(base+fresh.path)).status,403);
  await storage.transaction(s=>{s.keys[0].maxUses=0;s.keys[0].expires=Date.now()-1;});assert.equal((await fetch(base+oldPath)).status,403);assert.equal((await fetch(base+result.path)).status,403);
  const raw=await readFile(path.join(dir,'vault.json'),'utf8');assert.ok(!raw.includes(result.path.slice(3))&&!raw.includes(fresh.token));
 }finally{await new Promise(r=>{server.close(r);server.closeAllConnections();});await rm(dir,{recursive:true,force:true});}
});
