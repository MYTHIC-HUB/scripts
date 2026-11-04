import http from 'node:http';
import {readFile} from 'node:fs/promises';
import {randomBytes,randomUUID,scryptSync,timingSafeEqual,createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import {fileStorage} from './storage.mjs';

const root=path.dirname(fileURLToPath(import.meta.url));
const digest=value=>createHash('sha256').update(value).digest('hex');
const equal=(a,b)=>Buffer.byteLength(a)===Buffer.byteLength(b)&&timingSafeEqual(Buffer.from(a),Buffer.from(b));
export async function createVault({password,dataDir=path.join(root,'data'),secureCookies=false,storage}={}) {
  if(typeof password!=='string'||password.length<12)throw Error('Defina NEXUS_ADMIN_PASSWORD com pelo menos 12 caracteres.');
  const salt=randomBytes(16),passwordHash=scryptSync(password,salt,32);
  storage=storage||await fileStorage(dataDir);
  const transaction=storage.transaction;
  const generation=digest('nexus-vault-session:'+password);
  const safeScript=s=>({id:s.id,name:s.name,enabled:s.enabled,created:s.created,updated:s.updated,bytes:Buffer.byteLength(s.source),requests:s.requests||0});
  const safeKey=k=>({id:k.id,scriptId:k.scriptId,label:k.label,expires:k.expires,maxUses:k.maxUses,uses:k.uses,revoked:k.revoked,created:k.created});
  function send(res,status,value,type='application/json; charset=utf-8'){
    res.writeHead(status,{'Content-Type':type,'Cache-Control':'no-store','X-Content-Type-Options':'nosniff','Referrer-Policy':'no-referrer'});
    res.end(type.startsWith('application/json')?JSON.stringify(value):value);
  }
  async function body(req){
    const chunks=[];let size=0;
    for await(const chunk of req){size+=chunk.length;if(size>1024*1024)throw Object.assign(Error('Limite de 1 MB por envio.'),{status:413});chunks.push(chunk);}
    try{return JSON.parse(Buffer.concat(chunks).toString('utf8'));}catch{throw Object.assign(Error('JSON invalido.'),{status:400});}
  }
  function session(req,state){
    const token=(req.headers.cookie||'').split(';').map(x=>x.trim()).find(x=>x.startsWith('nexus_session='))?.slice(14);
    const key=token&&digest(token),record=key&&state.sessions?.[key];
    if(!record||record.expires<Date.now()||record.generation!==generation)return null;return {key,...record};
  }
  const server=http.createServer(async(req,res)=>{
    try{
      const url=new URL(req.url,'http://localhost'),method=req.method;
      const match=url.pathname.match(/^\/s\/([a-f0-9-]{36})$/);
      const short=url.pathname.match(/^\/r\/([A-Za-z0-9_-]{22})$/);
      if((match||short)&&method==='GET'){
        const token=short?short[1]:url.searchParams.get('key')||'';
        if(!short&&!/^[a-f0-9]{64}$/.test(token))return send(res,403,'Acesso negado.','text/plain; charset=utf-8');
        const source=await transaction(next=>{
          const hash=digest(token);
          const key=next.keys.find(k=>short?(equal(k.hash,hash)||(k.aliasHashes||[]).some(h=>equal(h,hash))):k.scriptId===match[1]&&equal(k.hash,hash));
          const script=key&&next.scripts.find(s=>s.id===key.scriptId);
          if(!script?.enabled||!key||key.revoked||(key.expires&&Date.now()>=key.expires)||(key.maxUses&&key.uses>=key.maxUses))return null;
          key.uses++;script.requests=(script.requests||0)+1;return script.source;
        });
        return source===null?send(res,403,'Acesso negado.','text/plain; charset=utf-8'):send(res,200,source,'text/plain; charset=utf-8');
      }
      if(url.pathname==='/api/login'&&method==='POST'){
        const ip=digest(req.socket.remoteAddress||'unknown');
        const permitted=await transaction(next=>{next.attempts||={};for(const [k,v]of Object.entries(next.attempts))if(v.until<Date.now())delete next.attempts[k];const limit=next.attempts[ip]||{count:0,until:Date.now()+15*60*1000};if(limit.count>=8)return false;limit.count++;next.attempts[ip]=limit;return true;});
        if(!permitted)return send(res,429,{error:'Muitas tentativas. Aguarde 15 minutos.'});
        const input=await body(req);
        if(typeof input.password!=='string'||input.password.length>1024||!timingSafeEqual(scryptSync(input.password,salt,32),passwordHash))return send(res,401,{error:'Senha incorreta.'});
        const token=randomBytes(32).toString('hex'),csrf=randomBytes(24).toString('hex');
        await transaction(next=>{delete next.attempts[ip];next.sessions||={};for(const [k,v]of Object.entries(next.sessions))if(v.expires<Date.now())delete next.sessions[k];next.sessions[digest(token)]={expires:Date.now()+8*60*60*1000,csrf,generation};});
        res.setHeader('Set-Cookie',`nexus_session=${token}; HttpOnly; SameSite=Strict; Path=/; Max-Age=28800${secureCookies?'; Secure':''}`);
        return send(res,200,{csrf});
      }
      if(url.pathname.startsWith('/api/')){
        const state=await storage.read(),user=session(req,state);if(!user)return send(res,401,{error:'Entre para continuar.'});
        if(method!=='GET'&&!equal(String(req.headers['x-csrf-token']||''),user.csrf))return send(res,403,{error:'Sessao invalida. Entre novamente.'});
        if(url.pathname==='/api/session'&&method==='GET')return send(res,200,{csrf:user.csrf});
        if(url.pathname==='/api/logout'&&method==='POST'){
          await transaction(next=>{delete next.sessions[user.key];});res.setHeader('Set-Cookie','nexus_session=; HttpOnly; SameSite=Strict; Path=/; Max-Age=0');return send(res,200,{ok:true});
        }
        if(url.pathname==='/api/scripts'&&method==='GET')return send(res,200,{scripts:state.scripts.map(safeScript),keys:state.keys.map(safeKey)});
        if(url.pathname==='/api/scripts'&&method==='POST'){
          const input=await body(req);const name=String(input.name||'').trim();
          if(!name||name.length>80||typeof input.source!=='string'||!input.source.trim()||Buffer.byteLength(input.source)>768*1024)return send(res,400,{error:'Informe um nome e um script de ate 768 KB.'});
          const script={id:randomUUID(),name,source:input.source,enabled:true,created:Date.now(),updated:Date.now(),requests:0};
          await transaction(next=>next.scripts.push(script));return send(res,201,safeScript(script));
        }
        const scriptRoute=url.pathname.match(/^\/api\/scripts\/([a-f0-9-]{36})$/);
        if(scriptRoute&&method==='GET'){
          const item=state.scripts.find(s=>s.id===scriptRoute[1]);return item?send(res,200,{...safeScript(item),source:item.source}):send(res,404,{error:'Script nao encontrado.'});
        }
        if(scriptRoute&&['PATCH','DELETE'].includes(method)){
          const input=method==='PATCH'?await body(req):{};
          if(input.source!==undefined&&(typeof input.source!=='string'||!input.source.trim()||Buffer.byteLength(input.source)>768*1024))return send(res,400,{error:'Script invalido.'});
          if(input.name!==undefined&&(!String(input.name).trim()||String(input.name).trim().length>80))return send(res,400,{error:'Nome invalido.'});
          const result=await transaction(next=>{
            const s=next.scripts.find(s=>s.id===scriptRoute[1]);if(!s)return null;
            if(method==='DELETE'){next.scripts=next.scripts.filter(item=>item.id!==s.id);next.keys=next.keys.filter(k=>k.scriptId!==s.id);return {ok:true};}
            if(input.name!==undefined)s.name=String(input.name).trim();if(input.source!==undefined)s.source=input.source;
            if(typeof input.enabled==='boolean')s.enabled=input.enabled;s.updated=Date.now();return safeScript(s);
          });return send(res,result?200:404,result||{error:'Script nao encontrado.'});
        }
        if(url.pathname==='/api/keys/shorten'&&method==='POST'){
          const input=await body(req);
          if(typeof input.token!=='string'||!/^[a-f0-9]{64}$/.test(input.token))return send(res,400,{error:'Informe um carregador antigo valido.'});
          const token=randomBytes(16).toString('base64url');
          const result=await transaction(next=>{
            const key=next.keys.find(k=>k.scriptId===input.scriptId&&equal(k.hash,digest(input.token)));
            if(!key||key.revoked||(key.expires&&Date.now()>=key.expires)||(key.maxUses&&key.uses>=key.maxUses))return null;
            key.aliasHashes||=[];if(key.aliasHashes.length>=10)return {full:true};key.aliasHashes.push(digest(token));return safeKey(key);
          });
          if(result?.full)return send(res,409,{error:'Esta chave ja tem 10 links curtos. Gere uma nova chave.'});
          return result?send(res,201,{...result,path:'/r/'+token}):send(res,403,{error:'Chave invalida ou encerrada.'});
        }
        if(url.pathname==='/api/keys'&&method==='POST'){
          const input=await body(req),hours=Number(input.hours||0),maxUses=Number(input.maxUses||0);
          if(!Number.isFinite(hours)||hours<0||hours>8760||!Number.isSafeInteger(maxUses)||maxUses<0||maxUses>1000000)return send(res,400,{error:'Validade ou limite invalido.'});
          const token=randomBytes(16).toString('base64url');const key={id:randomUUID(),scriptId:String(input.scriptId),label:String(input.label||'Chave de acesso').slice(0,80),hash:digest(token),expires:hours?Date.now()+hours*3600000:null,maxUses,uses:0,revoked:false,created:Date.now()};
          const added=await transaction(next=>{if(!next.scripts.some(s=>s.id===key.scriptId))return false;next.keys.push(key);return true;});
          return added?send(res,201,{...safeKey(key),token,path:'/r/'+token}):send(res,404,{error:'Script nao encontrado.'});
        }
        const keyRoute=url.pathname.match(/^\/api\/keys\/([a-f0-9-]{36})$/);
        if(keyRoute&&method==='DELETE'){
          const found=await transaction(next=>{const key=next.keys.find(k=>k.id===keyRoute[1]);if(!key)return false;key.revoked=true;return true;});return send(res,found?200:404,found?{ok:true}:{error:'Chave nao encontrada.'});
        }
        return send(res,404,{error:'Rota nao encontrada.'});
      }
      const files={'/':'index.html','/app.js':'app.js','/style.css':'style.css'};const file=files[url.pathname];
      if(method!=='GET'||!file)return send(res,404,'Nao encontrado.','text/plain; charset=utf-8');
      res.setHeader('Content-Security-Policy',"default-src 'self'; script-src 'self'; style-src 'self'; object-src 'none'; frame-ancestors 'none'; base-uri 'none'");
      send(res,200,await readFile(path.join(root,'public',file),'utf8'),file.endsWith('.js')?'text/javascript; charset=utf-8':file.endsWith('.css')?'text/css; charset=utf-8':'text/html; charset=utf-8');
    }catch(error){send(res,error.status||500,{error:error.status?error.message:'Erro ao processar a solicitacao.'});}
  });
  return server;
}
if(process.argv[1]&&path.resolve(process.argv[1])===fileURLToPath(import.meta.url)){
  const server=await createVault({password:process.env.NEXUS_ADMIN_PASSWORD,dataDir:process.env.NEXUS_DATA_DIR,secureCookies:process.env.NEXUS_HTTPS==='1'});
  server.listen(Number(process.env.PORT||3000),process.env.HOST||'127.0.0.1',()=>console.log('Nexus Vault iniciado.'));
}
