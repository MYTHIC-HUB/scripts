import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtemp,rm,readFile} from 'node:fs/promises';
import {tmpdir} from 'node:os';
import path from 'node:path';
import {createVault} from '../server.mjs';

test('authentication, private source, key lifecycle, atomic limits and persistence',async()=>{
  const directory=await mkdtemp(path.join(tmpdir(),'nexus-vault-'));
  const password='fixture-password-1234';let server,base,cookie,csrf;
  async function start(){server=await createVault({password,dataDir:directory});await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));base='http://127.0.0.1:'+server.address().port;}
  async function stop(){await new Promise(resolve=>{server.close(resolve);server.closeAllConnections();});}
  async function request(route,method='GET',data,authenticated=true){return fetch(base+route,{method,headers:{'Content-Type':'application/json',...(authenticated?{Cookie:cookie||'','X-CSRF-Token':csrf||''}:{})},body:data===undefined?undefined:JSON.stringify(data)});}
  async function json(route,method,data){const response=await request(route,method,data);assert.ok(response.ok,await response.clone().text());return response.json();}
  async function login(){const response=await request('/api/login','POST',{password},false);assert.equal(response.status,200);cookie=response.headers.get('set-cookie').split(';')[0];assert.match(response.headers.get('set-cookie'),/HttpOnly; SameSite=Strict/);csrf=(await response.json()).csrf;}
  try{
    await start();assert.equal((await request('/api/scripts','GET',undefined,false)).status,401);
    assert.equal((await request('/api/login','POST',{password:'wrong'},false)).status,401);
    const page=await request('/','GET',undefined,false);assert.equal(page.status,200);assert.match(page.headers.get('content-security-policy'),/script-src 'self'/);assert.doesNotMatch(await page.text(),/SECRET_FIXTURE_SOURCE/);
    await login();const savedCsrf=csrf;csrf='wrong';assert.equal((await request('/api/scripts','POST',{name:'bad',source:'x'})).status,403);csrf=savedCsrf;
    const script=await json('/api/scripts','POST',{name:'<img src=x onerror=alert(1)>',source:'-- SECRET_FIXTURE_SOURCE\nreturn 42'});
    const other=await json('/api/scripts','POST',{name:'other',source:'return 5'});
    const listing=await json('/api/scripts');assert.equal(listing.scripts.length,2);assert.equal(listing.scripts[0].source,undefined);
    assert.equal((await request('/api/scripts/'+script.id,'GET',undefined,false)).status,401);
    assert.equal((await request('/s/'+script.id,'GET',undefined,false)).status,403);
    const key=await json('/api/keys','POST',{scriptId:script.id,label:'limited',hours:24,maxUses:3});
    const responses=await Promise.all(Array.from({length:15},()=>request(key.path,'GET',undefined,false)));
    assert.equal(responses.filter(r=>r.status===200).length,3);assert.equal(responses.filter(r=>r.status===403).length,12);
    assert.equal(await responses.find(r=>r.ok).text(),'-- SECRET_FIXTURE_SOURCE\nreturn 42');assert.equal(responses[0].headers.get('cache-control'),'no-store');
    let data=await json('/api/scripts');assert.equal(data.keys[0].uses,3);assert.equal(data.keys[0].hash,undefined);assert.equal(data.keys[0].token,undefined);
    assert.doesNotMatch(await readFile(path.join(directory,'vault.json'),'utf8'),new RegExp(key.token));
    const unlimited=await json('/api/keys','POST',{scriptId:script.id,hours:0,maxUses:0});
    await json('/api/scripts/'+script.id,'PATCH',{source:'return 99'});assert.equal(await(await request(unlimited.path,'GET',undefined,false)).text(),'return 99');
    await json('/api/scripts/'+script.id,'PATCH',{enabled:false});assert.equal((await request(unlimited.path,'GET',undefined,false)).status,403);
    await json('/api/scripts/'+script.id,'PATCH',{enabled:true});assert.equal((await request(unlimited.path,'GET',undefined,false)).status,200);
    const expired=await json('/api/keys','POST',{scriptId:script.id,hours:0.000001});await new Promise(resolve=>setTimeout(resolve,15));assert.equal((await request(expired.path,'GET',undefined,false)).status,403);
    await json('/api/keys/'+unlimited.id,'DELETE');assert.equal((await request(unlimited.path,'GET',undefined,false)).status,403);
    assert.equal((await request('/api/keys','POST',{scriptId:other.id,hours:-1})).status,400);
    await stop();await start();await login();data=await json('/api/scripts');assert.equal(data.scripts.length,2);assert.equal(data.keys.find(k=>k.id===unlimited.id).revoked,true);
    await json('/api/scripts/'+script.id,'DELETE');data=await json('/api/scripts');assert.equal(data.scripts.length,1);assert.equal(data.scripts[0].id,other.id);assert.equal(data.keys.length,0);
    await json('/api/logout','POST');assert.equal((await request('/api/session')).status,401);
  }finally{if(server?.listening)await stop();await rm(directory,{recursive:true,force:true});}
});
test('no fixed or empty admin password',async()=>{await assert.rejects(createVault({password:''}),/12 caracteres/);});
