import readline from 'node:readline';
import assert from 'node:assert/strict';
console.log('Ready for private verification JSON on stdin.');
const input=readline.createInterface({input:process.stdin,terminal:false});
const config=JSON.parse(await new Promise(resolve=>input.once('line',resolve)));input.close();
const origin=new URL(config.origin);assert.equal(origin.protocol,'https:');assert.ok(origin.hostname.endsWith('.vercel.app'));
let cookie='',csrf='',script;
async function request(route,method='GET',data,authenticated=true){return fetch(new URL(route,origin),{method,headers:{'Content-Type':'application/json',...(authenticated?{Cookie:cookie,'X-CSRF-Token':csrf}:{})},body:data===undefined?undefined:JSON.stringify(data)});}
async function json(route,method,data){const response=await request(route,method,data);assert.ok(response.ok,`HTTP ${response.status} at ${route.split('?')[0]}: ${await response.clone().text()}`);return response.json();}
try{
 const home=await request('/', 'GET',undefined,false);assert.equal(home.status,200);assert.match(await home.text(),/Nexus Vault/);
 assert.equal((await request('/api/scripts','GET',undefined,false)).status,401);
 const login=await request('/api/login','POST',{password:config.password},false);assert.equal(login.status,200,await login.clone().text());cookie=login.headers.get('set-cookie').split(';')[0];csrf=(await login.json()).csrf;
 await json('/api/session');
 script=await json('/api/scripts','POST',{name:'Verificacao automatica temporaria',source:'return "nexus-qa-ok"'});
 const key=await json('/api/keys','POST',{scriptId:script.id,hours:1,maxUses:2});
 const delivery=await request(key.path,'GET',undefined,false);assert.equal(delivery.status,200,await delivery.clone().text());assert.equal(await delivery.text(),'return "nexus-qa-ok"');
 await json('/api/keys/'+key.id,'DELETE');assert.equal((await request(key.path,'GET',undefined,false)).status,403);
 await json('/api/scripts/'+script.id,'DELETE');script=null;
 await json('/api/logout','POST');assert.equal((await request('/api/session')).status,401);
 console.log('PASS: production page, private API, login, persistent session, script upload, key delivery, revocation, cleanup and logout.');
}catch(error){if(script)await request('/api/scripts/'+script.id,'DELETE').catch(()=>{});console.error(error.message);process.exitCode=1;}
