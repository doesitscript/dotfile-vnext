/** One parent-owned, bounded Implementer/Evaluator campaign via multiagents MCP. */
import {appendFileSync,existsSync,mkdirSync,readFileSync,writeFileSync,openSync,closeSync,renameSync,unlinkSync} from 'node:fs';
import {dirname,join,resolve} from 'node:path';
import {homedir} from 'node:os';
import {spawn} from 'node:child_process';
import {checkCampaign} from './check-implementation-handoff.ts';
import {scanEvents,acceptEvent,resumeEvent} from './paired-events.ts';

const cfg=JSON.parse(readFileSync(process.argv[2],'utf8'));
for(const k of ['project_root','plan_dir','run_dir','run_id','codex_binary','operator_skill_root'])if(!cfg[k])throw Error(`Missing ${k}`);
const project=resolve(cfg.project_root),plan=resolve(cfg.plan_dir),out=resolve(cfg.run_dir),packet=resolve(import.meta.dir,'..');
const expertRecommendationPath=cfg.expert_recommendation_path?resolve(cfg.expert_recommendation_path):null;
const decisionAuthorityProfilePath=cfg.decision_authority_profile_path?resolve(cfg.decision_authority_profile_path):null;
if(Boolean(expertRecommendationPath)!==Boolean(decisionAuthorityProfilePath))throw Error('Expert recommendation and decision authority profile must be supplied together');
if(expertRecommendationPath&&(!existsSync(expertRecommendationPath)||!existsSync(decisionAuthorityProfilePath!)))throw Error('Missing Expert recommendation or decision authority profile');
if(!/^[a-z0-9][a-z0-9-]+$/.test(cfg.run_id))throw Error('Use a unique kebab-case run ID');
if(existsSync(out))throw Error('run_dir already exists; use a fresh run directory. Resume from campaign artifacts, not overwritten runtime logs.');
const fixture=cfg.fixture_mode===true;
if(fixture&&(!existsSync(join(project,'PAIRED-RUNTIME-FIXTURE'))||project!==plan||project.includes('/dotfile-vnext/')))throw Error('Fixture mode requires a marked isolated project=plan directory');
const intake=fixture?{campaign_id:'paired-runtime-fixture',upstream_run_id:'fixture-preparation',upstream_plan_sha256:'f'.repeat(64)}:checkCampaign(plan);
const upstream=fixture?{pipeline_id:'paired-runtime-fixture',task_id:'paired-runtime-fixture'}:JSON.parse(readFileSync(join(plan,'upstream-manifest.json'),'utf8'));
if(!fixture&&project!==upstream.upstream_identity.project_root)throw Error('Project root disagrees with reviewed intake');
const skills=fixture?cfg.fixture_skills:{implementer:join(packet,'implementer/skills/storage-plan-implementer-beta/SKILL.md'),evaluator:join(packet,'evaluator/skills/storage-plan-evaluator-beta/SKILL.md')};
for(const role of ['implementer','evaluator'])if(!skills?.[role]||!existsSync(skills[role]))throw Error(`Missing ${role} skill`);
for(const [key,value] of Object.entries({max_passes:cfg.max_passes??8,pass_timeout_seconds:cfg.pass_timeout_seconds??900,run_timeout_seconds:cfg.run_timeout_seconds??5400}))if(!Number.isInteger(value)||Number(value)<1)throw Error(`Invalid ${key}`);
mkdirSync(out,{recursive:true});
const owner=join(out,'owned-processes.json'),lock=join(plan,'.paired-run-lock.json');
const pkg=cfg.multiagents_package_root||join(homedir(),'.bun/install/global/node_modules/multiagents');
const ownership=join(cfg.operator_skill_root,'scripts/owned_processes.py');
const requestedSession=`${upstream.task_id}--implementation-${cfg.run_id}--ppid${process.pid}`;
let session=requestedSession.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'');
let finishing=false,failure:string|undefined,status='incomplete',lockOwned=false,created=false,completed=0;
let current='preflight',nextActor='implementer',responseTo:string|null=null;
let watcher:ReturnType<typeof spawn>|undefined;
const save=(name:string,data:any)=>writeFileSync(join(out,name),JSON.stringify(data,null,2)+'\n');
const log=(event:string,data:any={})=>{const line=JSON.stringify({time:new Date().toISOString(),event,...data});appendFileSync(join(out,'events.jsonl'),line+'\n');if(event!=='driver')console.log(line);};
const shellQuote=(value:string)=>`'${value.replace(/'/g,"'\\''")}'`;
const printMonitorCommand=()=>console.log(`\nMonitor this run in a second terminal (read-only; Ctrl-C stops only the monitor):\n${shellQuote(join(import.meta.dir,'watch-implementation-output.sh'))} --session-id ${shellQuote(session)} --run-dir ${shellQuote(out)} --endpoint ${shellQuote('http://127.0.0.1:7899')} --interval 5 --clear\n`);
function ledger(mode:string,args:string[]=[],manifest=owner,run=cfg.run_id){
 const p=Bun.spawnSync(['python3',ownership,mode,'--manifest',manifest,'--run-id',run,...args],{stdout:'pipe',stderr:'pipe',timeout:20000});
 if(p.exitCode!==0)throw Error(p.stderr.toString()||p.stdout.toString());return JSON.parse(p.stdout.toString());
}
const env={...process.env,PATH:dirname(cfg.codex_binary)+':'+join(homedir(),'.bun/bin')+':'+process.env.PATH,MULTIAGENTS_RUN_ID:cfg.run_id,MULTIAGENTS_NO_OPEN:'1',MULTIAGENTS_PACKAGE_ROOT:pkg,MULTIAGENTS_GUARD_PATH:join(cfg.operator_skill_root,'scripts/codex_driver_guard.ts'),MULTIAGENTS_WORK_ROOT:project,MULTIAGENTS_WRITABLE_ROOTS:JSON.stringify([...new Set([project,plan,out])]),MULTIAGENTS_TURN_TIMEOUT_MS:String((cfg.pass_timeout_seconds??900)*1000)};
const post=async(route:string,data:any)=>{const r=await fetch('http://127.0.0.1:7899'+route,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data),signal:AbortSignal.timeout(5000)});if(!r.ok)throw Error(`${route}: HTTP ${r.status}`);const j=await r.json();if(j.error)throw Error(JSON.stringify(j));return j;};
const {Client}=await import(join(dirname(pkg),'@modelcontextprotocol/sdk/dist/esm/client/index.js'));
const {StdioClientTransport}=await import(join(dirname(pkg),'@modelcontextprotocol/sdk/dist/esm/client/stdio.js'));
const transport=new StdioClientTransport({command:process.execPath,args:['--preload',join(import.meta.dir,'implementation-preload.ts'),join(pkg,'cli.ts'),'orchestrator'],cwd:out,env,stderr:'pipe'});
const client=new Client({name:'paired-implementation-parent',version:'1.0.0'});
const verified=new Map<string,number>();let buffer='';
transport.stderr?.on('data',(chunk:any)=>{
 const text=String(chunk);appendFileSync(join(out,'orchestrator.log'),text);buffer+=text;const lines=buffer.split('\n');buffer=lines.pop()!;
 for(const line of lines){const at=line.indexOf('[runtime-guard] ');if(at<0)continue;
  try{const e=JSON.parse(line.slice(at+16));log('driver',e);
   if(e.event==='spawn')ledger('register',['--pid',String(e.pid),'--role','app-server','--descendants']);
   if(e.event==='turn_verified'){completed++;verified.set(e.threadId,(verified.get(e.threadId)||0)+1);}
   if(['spawn_failed','turn_rejected','process_exit'].includes(e.event)&&!finishing)failure=JSON.stringify(e);
  }catch(e){if(!finishing)failure=String(e);}
 }
});
async function until(predicate:()=>boolean,seconds:number){const deadline=Date.now()+seconds*1000;while(Date.now()<deadline){if(failure)throw Error(failure);if(predicate())return;await Bun.sleep(1000);}throw Error(`${current}: deadline exceeded (${seconds}s)`);}
const heartbeat=setInterval(()=>{log('heartbeat',{pass:current,completed_turns:completed,next_actor:nextActor});if(transport.pid)try{ledger('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);}catch(e){if(!finishing)failure=String(e);}},20000);
const deadline=setTimeout(()=>{failure='Overall campaign deadline exceeded';},(cfg.run_timeout_seconds??5400)*1000);
process.on('SIGTERM',()=>{failure='SIGTERM received';});process.on('SIGINT',()=>{failure='SIGINT received';});
try{
 ledger('init',['--session-id',session,'--owner-pid',String(process.pid)]);
 if(existsSync(lock)){
  if(!process.argv.includes('--recover-lock'))throw Error(`Campaign already has a run lock: ${lock}. Inspect its owner; use --recover-lock only after exact owned processes stop.`);
  const prior=JSON.parse(readFileSync(lock,'utf8')),state=ledger('observe',[],prior.owner_manifest_path,prior.run_id);
  if(state.owner_alive||state.processes.some((p:any)=>p.identity_live))throw Error('Previous owner/children still live; refusing duplicate campaign writer');
  renameSync(lock,join(plan,`.paired-run-lock-recovered-${Date.now()}.json`));
 }
 writeFileSync(lock,JSON.stringify({run_id:cfg.run_id,owner_manifest_path:owner,session_id:session}),{flag:'wx'});lockOwned=true;
 const tip=resumeEvent(plan,{campaign_id:intake.campaign_id,upstream_plan_sha256:intake.upstream_plan_sha256});
 if(tip){responseTo=tip.path;nextActor=tip.nextActor;log('resume_from',{...tip});}
 if(nextActor==='none'&&cfg.reopen_review===true)nextActor='evaluator';
 if(nextActor==='operator'&&cfg.operator_resolution_path){
  if(!existsSync(resolve(cfg.operator_resolution_path)))throw Error('Missing recorded operator resolution');
  nextActor='implementer';log('operator_resolution',{path:resolve(cfg.operator_resolution_path)});
 }
 if(nextActor==='none'||nextActor==='operator'){
  status=nextActor==='none'?'prior_signoff_present':'waiting_for_operator';
  log('no_team_needed',{status,last_artifact:responseTo});
 }else{
 const health=await fetch('http://127.0.0.1:7899/health',{signal:AbortSignal.timeout(3000)}).then(r=>r.json());if(health.status!=='ok')throw Error('Broker must be healthy; parent runtime operator must recover it first');
 const version=Bun.spawnSync([cfg.codex_binary,'--version'],{stdout:'pipe',stderr:'pipe',timeout:10000});if(version.exitCode!==0)throw Error('Codex executable preflight failed');
 save('inputs.json',{...cfg,...intake,session_id:session,owner_manifest_path:owner});log('preflight',{version:version.stdout.toString().trim(),dashboard_url:'http://127.0.0.1:7900',campaign_id:intake.campaign_id});
 const fd=openSync(join(out,'watchdog.log'),'a');watcher=spawn('python3',[ownership,'watch','--manifest',owner,'--run-id',cfg.run_id,'--interval','1'],{detached:true,stdio:['ignore',fd,fd]});watcher.unref();closeSync(fd);
 await until(()=>Boolean(JSON.parse(readFileSync(owner,'utf8')).watcher_heartbeat),10);
 await client.connect(transport);ledger('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);
 writeFileSync(join(out,'AGENTS.md'),`# Parent-owned runtime work area\nOne finite assigned pass; parent owns scheduling. Use explicit project_root and plan_dir from the task, never ambient cwd. ${fixture?'Fixture only: no real project or host access.':'Read project_root/AGENTS.md before substantive project work; follow that project framework. Preserve unrelated work and specific Apply authority.'}\n`);
 const result=await client.callTool({name:'create_team',arguments:{project_dir:out,session_name:requestedSession,agents:['implementer','evaluator'].map(role=>({agent_type:'codex',name:role,role,role_description:`You are ${role}. Follow ${skills[role]} for task passes. Parent schedules finite passes. No independent polling, peer launches or runtime operation.`,initial_task:'Reply READY only. No tools or file writes. End this initialization turn.',file_ownership:role==='implementer'?['roles/**','playbooks/**','inventory/**','review_ready_for_evaluator_*']:['feedback_for_review_by_evaluator_*','waiting_for_review_by_evaluator_*','ready_for_review_by_evaluator_*']}))}},undefined,{timeout:180000});
 const text=result.content?.map((x:any)=>x.text||'').join('\n')||'',match=text.match(/Session "([^"]+)" created/);if(result.isError||!match)throw Error(`create_team failed: ${text}`);
 const expectedSession=session;session=match[1];created=true;log('team_created',{session_id:session});save('session.json',{session_id:session,run_id:cfg.run_id,owner_manifest_path:owner});printMonitorCommand();
 if(session!==expectedSession)throw Error('Unexpected session collision; actual ID retained for cleanup');
 await until(()=>completed>=4,180);
 for(const slot of await post('/slots/list',{session_id:session}))await post('/hold-messages',{session_id:session,slot_id:slot.id});
 const dashboard=Bun.spawnSync(['python3',join(cfg.operator_skill_root,'scripts/runtime_operator.py'),'ensure-dashboard','--session-id',session,'--run-dir',join(out,'dashboard'),'--manifest',owner,'--run-id',cfg.run_id,'--cli',join(homedir(),'.bun/bin/multiagents')],{env,stdout:'pipe',stderr:'pipe',timeout:45000});
 if(dashboard.exitCode!==0)throw Error(dashboard.stderr.toString()||dashboard.stdout.toString());const observation=JSON.parse(dashboard.stdout.toString());save('dashboard-observation.json',observation.observation);log('dashboard',{url:observation.observation.dashboard_url,healthy:observation.observation.healthy,action:observation.action});
 for(let pass=1;pass<=(cfg.max_passes??8);pass++){
  const role=nextActor;current=`${role}/${pass}`;
  const slots=await post('/slots/list',{session_id:session}),slot=slots.find((s:any)=>s.display_name===role);if(!slot)throw Error(`Missing ${role} slot`);
  const thread=JSON.parse(slot.context_snapshot||'{}').codex_thread_id;if(!thread)throw Error(`Missing thread for ${role}`);
  const prior=verified.get(thread)||0,before=scanEvents(plan),invocation=`${cfg.run_id}-${role}-${pass}`;
  const inputs={project_root:project,plan_dir:plan,mode:'orchestrated',pipeline_id:upstream.pipeline_id,task_id:upstream.task_id,campaign_id:intake.campaign_id,stage_id:'implementation',run_id:invocation,upstream_run_id:intake.upstream_run_id,upstream_plan_sha256:intake.upstream_plan_sha256,session_id:session,owner_manifest_path:owner,runtime_observation_path:join(out,'dashboard-observation.json'),responds_to:responseTo,...(expertRecommendationPath?{expert_recommendation_path:expertRecommendationPath,decision_authority_profile_path:decisionAuthorityProfilePath}:{}),...(cfg.operator_resolution_path?{operator_resolution_path:resolve(cfg.operator_resolution_path)}:{})};
  const authorityGuidance=expertRecommendationPath?'Read both supplied Expert/profile paths. Apply only the profile-authorized recommendation within campaign scope; exact target identity, validation, receipts and Evaluator review remain mandatory.':'Live mutation needs recorded specific authority and verified targets/backup; never guess. Missing user choices go in the durable handoff; continue independent safe work.';
  const prompt=`Read and use ${skills[role]} for ONE finite ${role} pass. Inputs: ${JSON.stringify(inputs)}. Parent orchestrator is active and owns all wakeups/observation: do not advertise manual-chat launch prompts, poll, spawn or send work to another role. ${fixture?'ISOLATED FIXTURE ONLY. No source repo or host access.':`Implement the real campaign, not an orchestration test. Repository implementation and relevant read-only discovery are authorized. ${authorityGuidance}`} Write exactly ONE NEW mature top-level timestamped role artifact with these identity fields, role=${role}, responds_to=${JSON.stringify(responseTo)}, status and next_actor. Do not edit old or opposing-role events. If genuinely waiting for user authority/target decisions, say so with a concrete question; never mark complete instead. Evaluator ready requires whole-campaign evidence, not partial success. If progress requires a new user decision and no independent work remains, Evaluator writes waiting rather than repeating feedback. ${role==='evaluator'?'After a ready artifact only, call the peer approve tool with target implementer only; do not approve yourself. No peer feedback messages: the parent routes your feedback artifact.':'Do not self-approve. Your outbox is not sign-off.'} Finish your model turn after the artifact and any final approval signal.`;
  log('pass_started',{pass:current,slot_id:slot.id,run_id:invocation});save('checkpoint.json',{...inputs,pass,status:'running'});
  await post('/release-held',{session_id:session,slot_id:slot.id});
  // Explicit driver target avoids resolving a stale/nonexistent peer_id in this installed broker.
  await post('/send-message',{from_id:'orchestrator',to_id:`__slot_${slot.id}__`,to_slot_id:slot.id,session_id:session,msg_type:'chat',text:prompt+(cfg.operator_resolution_path?' Read the supplied operator_resolution_path first; it records a specific user decision, not blanket Apply authority.':'')});
  await until(()=>(verified.get(thread)||0)>prior,cfg.pass_timeout_seconds??900);
  await post('/hold-messages',{session_id:session,slot_id:slot.id});
  const event=acceptEvent(plan,before,{campaign_id:intake.campaign_id,run_id:invocation,role,upstream_plan_sha256:intake.upstream_plan_sha256,responds_to:responseTo});
  save(`pass-${pass}.json`,{...inputs,...event,terminal:'completed'});log('pass_completed',{pass:current,...event});responseTo=event.path;nextActor=event.nextActor;
  if(nextActor==='operator'){status='waiting_for_operator';break;}
  if(nextActor==='none'){
   const finalSlots=await post('/slots/list',{session_id:session});save('approval-slots.json',finalSlots);
   if(finalSlots.find((s:any)=>s.display_name==='implementer')?.task_state!=='approved')throw Error('Evaluator ready artifact exists but no Implementer peer approve signal was recorded');
   status='approved';break;
  }
  if(pass===(cfg.max_passes??8))status='pass_limit_reached';
 }
 }
}catch(e){failure=String(e);process.exitCode=1;log('run_failed',{error:failure});}
finally{
 finishing=true;clearInterval(heartbeat);clearTimeout(deadline);
 if(existsSync(owner)){
  try{if(transport.pid)ledger('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);}catch(e){log('capture_before_stop_failed',{error:String(e)});}
  if(created)try{const r=await client.callTool({name:'end_session',arguments:{session_id:session,create_pr:false}},undefined,{timeout:15000});if(r.isError)throw Error(JSON.stringify(r));const archived=await post('/sessions/get',{id:session});save('archived-session.json',archived);if(archived.status!=='archived')throw Error('Session did not archive');}catch(e){failure=failure||String(e);process.exitCode=1;log('end_session_failed',{error:String(e)});}
  try{await client.close();}catch{}
  try{save('cleanup.json',ledger('stop',['--grace','3']));if(watcher)await Promise.race([new Promise(r=>watcher!.once('exit',r)),Bun.sleep(3000)]);const final=ledger('observe');save('final-process-observation.json',final);if(final.processes.some((p:any)=>p.identity_live))throw Error('Owned children remain after cleanup');}catch(e){failure=failure||String(e);process.exitCode=1;log('cleanup_failed',{error:String(e)});}
 }
 if(lockOwned&&!failure&&JSON.parse(readFileSync(lock,'utf8')).run_id===cfg.run_id)unlinkSync(lock);
 // Keep a failed run lock for explicit owner-checked recovery, never erase another owner.
 save('result.json',{run_id:cfg.run_id,campaign_id:intake.campaign_id,session_id:session,owner_manifest_path:owner,status:failure?'incomplete':status,error:failure||null,next_actor:nextActor,last_artifact:responseTo,completed_turns:completed,fixture_mode:fixture});
 log('finished',{status:failure?'incomplete':status,next_actor:nextActor,last_artifact:responseTo,run_dir:out});
}
