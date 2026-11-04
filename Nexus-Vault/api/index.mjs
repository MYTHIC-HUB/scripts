import {createVault} from '../server.mjs';
import {blobStorage} from '../storage.mjs';
let serverPromise;
export default async function handler(req,res){
  try{
    serverPromise||=blobStorage().then(storage=>createVault({password:process.env.NEXUS_ADMIN_PASSWORD,storage,secureCookies:true}));
    const server=await serverPromise;
    return server.listeners('request')[0](req,res);
  }catch{serverPromise=undefined;res.writeHead(503,{'Content-Type':'application/json','Cache-Control':'no-store'});res.end(JSON.stringify({error:'Hospedagem em configuracao. Tente novamente.'}));}
}
