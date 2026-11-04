import test from 'node:test';
import assert from 'node:assert/strict';
import {blobStorage} from '../storage.mjs';
import {createVault} from '../server.mjs';
test('private Blob CAS and sessions survive different function instances',async()=>{
  let content=null,version=0;
  class BlobPreconditionFailedError extends Error{}
  const client={BlobPreconditionFailedError,
    async get(name,options){assert.equal(options.access,'private');assert.equal(options.useCache,false);assert.equal(options.headers['Accept-Encoding'],'identity');if(content===null)return null;const saved=content,etag=String(version);return {blob:{etag},stream:new Blob([saved]).stream(),statusCode:200};},
    async put(name,next,options){assert.equal(options.access,'private');await new Promise(r=>setTimeout(r,1));if(content!==null&&(!options.allowOverwrite||options.ifMatch!==String(version)))throw new BlobPreconditionFailedError();content=next;version++;return {etag:String(version)};}
  };
  const first=await createVault({password:'fixture-password-1234',storage:await blobStorage(client)});
  const second=await createVault({password:'fixture-password-1234',storage:await blobStorage(client)});
  for(const s of [first,second])await new Promise(r=>s.listen(0,'127.0.0.1',r));
  const a='http://127.0.0.1:'+first.address().port,b='http://127.0.0.1:'+second.address().port;
  try{
    const login=await fetch(a+'/api/login',{method:'POST',body:JSON.stringify({password:'fixture-password-1234'})});const {csrf}=await login.json();const cookie=login.headers.get('set-cookie').split(';')[0];const headers={cookie,'x-csrf-token':csrf};
    const scriptResponse=await fetch(b+'/api/scripts',{method:'POST',headers,body:JSON.stringify({name:'cross instance',source:'return 123'})});assert.equal(scriptResponse.status,201);const script=await scriptResponse.json();
    const keyResponse=await fetch(a+'/api/keys',{method:'POST',headers,body:JSON.stringify({scriptId:script.id,maxUses:3})});const key=await keyResponse.json();
    const outcomes=await Promise.all(Array.from({length:12},(_,i)=>fetch((i%2?a:b)+key.path)));
    assert.equal(outcomes.filter(r=>r.status===200).length,3);assert.equal(outcomes.filter(r=>r.status===403).length,9);
    const state=await(await fetch(b+'/api/scripts',{headers})).json();assert.equal(state.keys[0].uses,3);
    await fetch(a+'/api/logout',{method:'POST',headers});assert.equal((await fetch(b+'/api/session',{headers})).status,401);
  }finally{await Promise.all([first,second].map(s=>new Promise(r=>{s.close(r);s.closeAllConnections();})));}
});
