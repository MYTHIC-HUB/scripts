import {readFile,writeFile,mkdir,rename} from 'node:fs/promises';
import path from 'node:path';
export const empty=()=>({scripts:[],keys:[],sessions:{},attempts:{}});
export async function fileStorage(directory){
  await mkdir(directory,{recursive:true,mode:0o700});const file=path.join(directory,'vault.json');let queue=Promise.resolve();
  async function read(){try{return JSON.parse(await readFile(file,'utf8'));}catch(e){if(e.code!=='ENOENT')throw e;return empty();}}
  function transaction(action){const result=queue.then(async()=>{const state=await read(),value=await action(state);await writeFile(file+'.tmp',JSON.stringify(state),{mode:0o600});await rename(file+'.tmp',file);return value;});queue=result.catch(()=>{});return result;}
  return {read,transaction};
}
export async function blobStorage(client){
  const {get,put,BlobPreconditionFailedError}=client||await import('@vercel/blob');
  const name='nexus-vault/state.json';
  async function snapshot(){const blob=await get(name,{access:'private',useCache:false});if(!blob)return {state:empty(),etag:null};return {state:await new Response(blob.stream).json(),etag:blob.blob.etag};}
  async function transaction(action){
    for(let attempt=0;attempt<25;attempt++){
      const {state,etag}=await snapshot(),value=await action(state);
      try{await put(name,JSON.stringify(state),{access:'private',addRandomSuffix:false,contentType:'application/json',cacheControlMaxAge:60,...(etag?{ifMatch:etag,allowOverwrite:true}:{allowOverwrite:false})});return value;}
      catch(e){if(!(e instanceof BlobPreconditionFailedError)&&!String(e.message).includes('already exists'))throw e;await new Promise(r=>setTimeout(r,Math.min(250,10*(attempt+1))+Math.random()*25));}
    }
    throw Object.assign(Error('Solicitacoes simultaneas. Tente novamente.'),{status:503});
  }
  return {read:async()=>(await snapshot()).state,transaction};
}
