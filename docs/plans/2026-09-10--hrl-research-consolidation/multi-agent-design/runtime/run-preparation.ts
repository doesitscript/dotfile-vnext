#!/usr/bin/env bun
/** Run only the middle preparation stage through the installed multiagents MCP.
 * Usage: bun run run-preparation.ts CONFIG.json
 * Fresh output root per attempt. --resume reuses matching completed artifacts.
 */
import {readFileSync,writeFileSync,appendFileSync,existsSync,mkdirSync,statSync,readdirSync} from 'node:fs';
import {dirname,join,resolve} from 'node:path';
import {spawn} from 'node:child_process';
import {paths,sha,verifyArtifact,verifyRelease,frontmatter,receiptMatches} from './artifacts.ts';
const cfg=JSON.parse(readFileSync(process.argv[2],'utf8'));
for(const k of ['source_plan_root','preparation_output_root','project_root','run_id','pipeline_id','task_id','codex_binary','operator_skill_root'])if(!cfg[k])throw Error(`Missing config ${k}`);
const out=resolve(cfg.preparation_output_root),packet=resolve(import.meta.dir,'..');
if(existsSync(out)&&!process.argv.includes('--resume'))throw Error('Output exists; use --resume or a fresh output root. Never silently reset.');
mkdirSync(out,{recursive:true});
const pkg=cfg.multiagents_package_root||join(process.env.HOME!,'.bun/install/global/node_modules/multiagents');
const owner=join(out,'runtime','processes-'+process.pid+'.json');mkdirSync(dirname(owner),{recursive:true});
const requestedSession=`${cfg.task_id}--preparation--ppid${process.pid}`;
const expectedSession=requestedSession.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'');
let session=expectedSession;
const input={...cfg,contract_version:1,stage_id:'preparation',mode:'orchestrated',session_id:session,owner_manifest_path:owner,runtime_observation_path:join(out,'runtime/dashboard-observation.json'),plan_path:join(packet,'agent-prompts/CURRENT-PHASE-PREPARATION-PLAN.md')};
const log=(event:string,data:any={})=>{const line=JSON.stringify({time:new Date().toISOString(),event,...data});appendFileSync(join(out,'runtime/events.jsonl'),line+'\n');if(event!=='driver')console.log(line)};
const save=(name:string,data:any)=>writeFileSync(join(out,'runtime',name),JSON.stringify(data,null,2)+'\n');
const receiptsPath=join(out,'runtime/artifact-receipts.json');
const receipts:any=existsSync(receiptsPath)?JSON.parse(readFileSync(receiptsPath,'utf8')):{};
const ownership=join(cfg.operator_skill_root,'scripts/owned_processes.py');
// Resume must not create a second writer while an earlier owner is still live.
if(process.argv.includes('--resume'))for(const name of readdirSync(join(out,'runtime')).filter(n=>/^processes-\d+\.json$/.test(n))){
 const manifest=join(out,'runtime',name),prior=JSON.parse(readFileSync(manifest,'utf8'));if(prior.run_id!==cfg.run_id)throw Error('Output directory contains another run ownership manifest');
 const p=Bun.spawnSync(['python3',ownership,'observe','--manifest',manifest,'--run-id',cfg.run_id],{stdout:'pipe',stderr:'pipe'});if(p.exitCode!==0)throw Error(p.stderr.toString());const state=JSON.parse(p.stdout.toString());
 if(state.status==='active'&&state.owner_alive)throw Error(`Previous owner still live; stop its exact manifest before resume: ${manifest}`);
 if(state.processes.some((r:any)=>r.identity_live))throw Error(`Owned processes remain; reconcile this manifest before resume: ${manifest}`);
}
// A completed-run check is read-only with respect to its original provenance.
if(process.argv.includes('--resume')&&existsSync(join(out,paths.release))&&receipts.release?.sha256===sha(join(out,paths.release))){
 const priorResult=JSON.parse(readFileSync(join(out,'runtime/result.json'),'utf8'));
 if(priorResult.status!=='passed')throw Error(`Plan released but prior lifecycle incomplete; recover ${priorResult.owner_manifest_path} and session ${priorResult.session_id} before completion`);
 const verified=verifyRelease(input);log('already_released',verified);process.exit(0);
}
const incoming=(key:keyof typeof paths)=>Object.fromEntries((key==='route'?[]:key==='research'?['route']:key==='compose'?['route','research']:key==='review'?['compose']:['compose','review']).map(k=>[k,sha(join(out,paths[k as keyof typeof paths]))]));
function owned(mode:string,args:string[]=[]){const p=Bun.spawnSync(['python3',ownership,mode,'--manifest',owner,'--run-id',cfg.run_id,...args],{stdout:'pipe',stderr:'pipe'});if(p.exitCode!==0)throw Error(p.stderr.toString()||p.stdout.toString());return JSON.parse(p.stdout.toString());}
const env={...process.env,PATH:dirname(cfg.codex_binary)+':'+join(process.env.HOME!,'.bun/bin')+':'+process.env.PATH,MULTIAGENTS_PACKAGE_ROOT:pkg,MULTIAGENTS_GUARD_PATH:join(cfg.operator_skill_root,'scripts/codex_driver_guard.ts'),MULTIAGENTS_NO_OPEN:'1',MULTIAGENTS_RUN_ID:cfg.run_id};
const post=async(route:string,data:any)=>{const r=await fetch('http://127.0.0.1:7899'+route,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data),signal:AbortSignal.timeout(5000)});if(!r.ok)throw Error(`${route}: HTTP ${r.status}`);const j=await r.json();if(j.error)throw Error(JSON.stringify(j));return j};
const {Client}=await import(join(dirname(pkg),'@modelcontextprotocol/sdk/dist/esm/client/index.js'));
const {StdioClientTransport}=await import(join(dirname(pkg),'@modelcontextprotocol/sdk/dist/esm/client/stdio.js'));
const transport=new StdioClientTransport({command:process.execPath,args:['--preload',join(import.meta.dir,'managed-preload.ts'),join(pkg,'cli.ts'),'orchestrator'],env,stderr:'pipe',cwd:out});
const client=new Client({name:'middle-stage-preparation',version:'1.0.0'});
let failure:string|undefined,finishing=false,created=false,completed=0,current='preflight';let buffer='';
const completedByThread=new Map<string,number>();
let watcher:ReturnType<typeof spawn>|undefined;const driverPids=new Set<number>();
transport.stderr?.on('data',(chunk:any)=>{
 const text=String(chunk);appendFileSync(join(out,'runtime/orchestrator.log'),text);buffer+=text;
 const lines=buffer.split('\n');buffer=lines.pop()!;
 for(const line of lines){const prefix='[runtime-guard] ';const at=line.indexOf(prefix);if(at<0)continue;
  try{const e=JSON.parse(line.slice(at+prefix.length));log('driver',e);
   if(e.event==='spawn'){driverPids.add(e.pid);owned('register',['--pid',String(e.pid),'--role','app-server','--descendants']);}
   if(e.event==='turn/completed'){if(e.status==='completed'){completed++;completedByThread.set(e.thread_id,(completedByThread.get(e.thread_id)||0)+1);}else if(!finishing)failure=JSON.stringify(e);}
   if(['spawn_failed','turn_rejected'].includes(e.event)&&!finishing)failure=JSON.stringify(e);
  }catch(e){failure=String(e);}
 }
});
const skills={Coordinator:join(packet,'multi-agent-onsite-expert/skill-drafts/phase-scoped-onsite-expert-coordinator-draft/SKILL.md'),Researcher:join(packet,'researchers/skill-drafts/phase-scoped-researcher-draft/SKILL.md')};
const task=(role:keyof typeof skills,pass:string)=>`Use the skill ${skills[role]}; read its shared execution contract. Inputs: ${JSON.stringify({...input,pass})}. Execute ONLY this pass; write the exact owned artifact with complete YAML frontmatter. Source/project/HRL are READ ONLY. Do not mutate hosts, install, commit, spawn more agents or start runtime services. Parent schedules all passes: do not poll or wait and do not send work to teammates yourself. Finish your turn after writing your artifact. Research scoped to this source plan, not a whole-project audit. A precise future read-only discovery step may handle unavailable live facts; do not guess targets or waive genuine blockers. Use actual file SHA256 for review/release. Keep prose concise but cover all obligations. Return event and artifact path.`;
async function until(predicate:()=>boolean,seconds:number){const deadline=Date.now()+seconds*1000;while(Date.now()<deadline){if(failure)throw Error(failure);if(predicate())return;await Bun.sleep(1000)}throw Error(`${current}: deadline exceeded (${seconds}s); evidence retained`)}
async function stage(role:keyof typeof skills,pass:string,key:keyof typeof paths){
 current=role+'/'+pass;const path=join(out,paths[key]);const before=existsSync(path)?statSync(path).mtimeMs:null;
 const slots=await post('/slots/list',{session_id:session}),slot=slots.find((s:any)=>s.display_name===role);if(!slot)throw Error(`No live ${role} slot`);
 const thread=JSON.parse(slot.context_snapshot||'{}').codex_thread_id;if(!thread)throw Error(`Missing thread identity for ${role}`);const prior=completedByThread.get(thread)||0;
 log('pass_started',{pass:current,slot_id:slot.id});save('checkpoint.json',{...input,current_pass:current,status:'running'});
 await post('/send-message',{from_id:'orchestrator',to_slot_id:slot.id,session_id:session,msg_type:'chat',text:task(role,pass)});
 await until(()=>existsSync(path)&&statSync(path).mtimeMs!==before&&(completedByThread.get(thread)||0)>prior,cfg.pass_timeout_seconds||300);
 const artifact=verifyArtifact(path,input);receipts[key]={sha256:sha(path),incoming:incoming(key),run_id:cfg.run_id,pass:current,terminal:'completed'};save('artifact-receipts.json',receipts);log('pass_completed',{pass:current,path,status:artifact.status,sha256:sha(path)});
 return artifact;
}
const heartbeat=setInterval(()=>{log('heartbeat',{pass:current,completed_turns:completed,driver_pids:[...driverPids]});if(transport.pid){try{owned('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);}catch(e){if(!finishing)failure=String(e)}}},20000);
const overall=setTimeout(()=>{failure='Overall campaign deadline reached'},(cfg.run_timeout_seconds||1500)*1000);
process.on('SIGTERM',()=>{failure='SIGTERM received'});process.on('SIGINT',()=>{failure='SIGINT received'});
try{
 if(existsSync(join(out,paths.release))&&receipts.release?.sha256===sha(join(out,paths.release))){log('already_released',verifyRelease(input));finishing=true;}
 else{
  const health=await fetch('http://127.0.0.1:7899/health',{signal:AbortSignal.timeout(3000)}).then(r=>r.json());if(health.status!=='ok')throw Error('Authorized broker must be healthy before launch');
  const version=Bun.spawnSync([cfg.codex_binary,'--version'],{stdout:'pipe'});if(version.exitCode!==0)throw Error('Codex binary preflight failed');
  log('preflight',{codex_binary:cfg.codex_binary,version:version.stdout.toString().trim(),requested_session:session,dashboard_url:'http://127.0.0.1:7900'});
  save('inputs.json',input);
  owned('init',['--session-id',session,'--owner-pid',String(process.pid)]);
  const watchLog=await import('node:fs');const fd=watchLog.openSync(join(out,'runtime/watchdog.log'),'a');
  watcher=spawn('python3',[ownership,'watch','--manifest',owner,'--run-id',cfg.run_id,'--interval','1'],{detached:true,stdio:['ignore',fd,fd]});watcher.unref();watchLog.closeSync(fd);
  await until(()=>Boolean(JSON.parse(readFileSync(owner,'utf8')).watcher_heartbeat),10);
  writeFileSync(join(out,'AGENTS.md'),'# Preparation work area\nWrite only your assigned preparation artifacts. Source/project/HRL paths are read-only. No infrastructure apply. One finite pass per invocation; the parent owns scheduling and lifecycle.\n');
  await client.connect(transport);owned('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);
  const result=await client.callTool({name:'create_team',arguments:{project_dir:out,session_name:requestedSession,agents:(['Coordinator','Researcher'] as const).map(role=>({agent_type:'codex',name:role,role,role_description:`You are ${role}. For later work passes follow ${skills[role]}. Single pass only, no waiting or polling. Parent orchestrator schedules all work.`,initial_task:'Reply READY only. No tools, messages or file writes. End this initialization turn.',file_ownership:role==='Coordinator'?['coordination/**','handoff/**']:['research/**']}))}},undefined,{timeout:180000});
  const resultText=result.content?.map((x:any)=>x.text||'').join('\n')||'';const returned=resultText.match(/Session "([^"]+)" created/);if(!returned)throw Error(`create_team failed: ${resultText}`);session=returned[1];input.session_id=session;created=true;log('team_created',{session,result:resultText});
  if(session!==expectedSession)throw Error('Unexpected session collision; retained actual ID for cleanup');
  await until(()=>completed>=4,120);
  const dash=Bun.spawnSync(['python3',join(cfg.operator_skill_root,'scripts/runtime_operator.py'),'ensure-dashboard','--session-id',session,'--run-dir',join(out,'runtime/dashboard'),'--manifest',owner,'--run-id',cfg.run_id,'--cli',join(process.env.HOME!,'.bun/bin/multiagents')],{env,stdout:'pipe',stderr:'pipe'});
  if(dash.exitCode!==0)throw Error(dash.stderr.toString());const dr=JSON.parse(dash.stdout.toString());if(dr.action==='started')owned('register',['--pid',String(dr.process.pid),'--role','dashboard','--descendants']);save('dashboard-observation.json',dr.observation);log('dashboard',{url:dr.observation.dashboard_url,healthy:dr.observation.healthy,action:dr.action});
  const have=(k:keyof typeof paths)=>{const p=join(out,paths[k]);return existsSync(p)&&receiptMatches(p,input,receipts[k],incoming(k));};
  if(!have('route'))await stage('Coordinator','route','route');
  if(!have('research'))await stage('Researcher','research','research');
  if(frontmatter(join(out,paths.research)).status!=='ready')throw Error('Research reports a substantive preparation blocker; inspect readiness brief');
  if(!have('compose'))await stage('Coordinator','compose','compose');
  let passed=false;
  for(let round=0;round<3;round++){
   const r=round===0&&have('review')?frontmatter(join(out,paths.review)):await stage('Researcher','review-plan','review');
   if(r.status==='plan_review_passed'&&r.reviewed_plan_sha256===sha(join(out,paths.compose))){passed=true;break;}
   if(round<2)await stage('Coordinator','revise','compose');
  }
  if(!passed)throw Error('Independent review still requests changes after two corrections');
  await stage('Coordinator','release','release');const handoff=verifyRelease(input);save('handoff.json',{...input,...handoff,status:'ready_for_implementation',downstream_activation:'authorized_separately'});log('preparation_passed',handoff);
 }
}catch(e){failure=String(e);log('run_failed',{error:failure});process.exitCode=1;}
finally{
 finishing=true;clearInterval(heartbeat);clearTimeout(overall);
 if(existsSync(owner)){
  try{if(transport.pid)owned('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);}catch(e){log('capture_before_stop',{error:String(e)});}
  if(created)try{const result=await client.callTool({name:'end_session',arguments:{session_id:session,create_pr:false}},undefined,{timeout:15000});if(result.isError)throw Error(JSON.stringify(result));const state=await post('/sessions/get',{id:session});if(state.status!=='archived')throw Error('Session was not archived');log('end_session',{result});}catch(e){failure=failure||String(e);process.exitCode=1;log('end_session_failed',{error:String(e)});}
  try{await client.close();}catch{}
  try{const stopped=owned('stop',['--grace','3']);save('cleanup.json',stopped);if(watcher)await Promise.race([new Promise(r=>watcher!.once('exit',r)),Bun.sleep(3000)]);save('final-process-observation.json',owned('observe'));log('owned_processes_stopped',stopped);}catch(e){failure=failure||String(e);process.exitCode=1;log('cleanup_failed',{error:String(e)});}
 }
 save('result.json',{...input,status:failure?'incomplete':'passed',error:failure||null,completed_turns:completed,source_implementation_run:false});
 log('finished',{status:failure?'incomplete':'passed',artifacts:out});
}
