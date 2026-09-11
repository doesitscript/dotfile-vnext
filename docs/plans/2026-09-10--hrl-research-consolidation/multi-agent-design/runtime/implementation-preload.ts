/** Session-local project write scope; never modifies installed Codex/multiagents. */
import './managed-preload.ts';
import {join,isAbsolute} from 'node:path';
import {homedir} from 'node:os';
import {scopedThreadParams} from './implementation-policy.ts';
import {installParentManagedInterruptGuard,installParentManagedTurnTimeout} from './implementation-interrupt-guard.ts';
// Upstream ensureMcpConfigs writes global client config during launch. This
// controller supplies its peer explicitly; suppress those exact writes only.
const globalConfigs=new Set([join(homedir(),'.codex/config.toml'),join(homedir(),'.gemini/settings.json')]);
const write=Bun.write.bind(Bun);
Bun.write=((target:any,data:any,...rest:any[])=>{
 if(typeof target==='string'&&globalConfigs.has(target)){
  process.stderr.write('[managed-runtime] suppressed global client config write\n');return Promise.resolve(0);
 }
 return write(target,data,...rest);
}) as typeof Bun.write;
const root=process.env.MULTIAGENTS_WORK_ROOT;
const roots=JSON.parse(process.env.MULTIAGENTS_WRITABLE_ROOTS||'[]');
if(!root||!isAbsolute(root)||!roots.length||roots.some((p:any)=>typeof p!=='string'||!isAbsolute(p)))throw Error('Explicit implementation workspace roots required');
const {CodexDriver}=await import(join(process.env.MULTIAGENTS_PACKAGE_ROOT!,'orchestrator/codex-driver.ts'));
installParentManagedInterruptGuard(CodexDriver, event => process.stderr.write(`[managed-runtime] ${JSON.stringify(event)}\n`));
const turnTimeoutMs=Number(process.env.MULTIAGENTS_TURN_TIMEOUT_MS);
installParentManagedTurnTimeout(CodexDriver,turnTimeoutMs,event => process.stderr.write(`[managed-runtime] ${JSON.stringify(event)}\n`));
// Thread-scoped permission for each role's terminal workflow signal only.
// Keep the configured approval policy and all other tool permissions unchanged.
const identities=new WeakMap<object,any>();
const spawn=CodexDriver.spawn;
CodexDriver.spawn=async function(cwd:string,env:any,...rest:any[]){
 const driver=await spawn.call(this,cwd,env,...rest);
 identities.set(driver,env);return driver;
};
const original=CodexDriver.prototype.sendRequest;
CodexDriver.prototype.sendRequest=function(method:string,params:any,...rest:any[]){
 if(method==='thread/start'){
  const env=identities.get(this);
  if(!env?.MULTIAGENTS_SESSION||!env.MULTIAGENTS_SLOT||!env.MULTIAGENTS_ROLE)throw Error('Explicit worker session/slot/role required');
  params=scopedThreadParams(env.MULTIAGENTS_ROLE,{...params,config:{...params?.config,
   'mcp_servers.multiagents-peer.command':process.execPath,
   'mcp_servers.multiagents-peer.args':[join(process.env.MULTIAGENTS_PACKAGE_ROOT!,'cli.ts'),'mcp-server','--agent-type','codex','--session',env.MULTIAGENTS_SESSION,'--slot',env.MULTIAGENTS_SLOT,'--role',env.MULTIAGENTS_ROLE,'--name',env.MULTIAGENTS_NAME],
   'mcp_servers.multiagents-peer.env.MULTIAGENTS_DRIVER_MODE':'1'
  }});
 }
 if(method==='turn/start')params={...params,cwd:root,sandboxPolicy:{type:'workspaceWrite',writableRoots:roots,readOnlyAccess:{type:'fullAccess'},networkAccess:true,excludeTmpdirEnvVar:false,excludeSlashTmp:false}};
 return original.call(this,method,params,...rest);
};
