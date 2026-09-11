/** One parent-owned, bounded Implementer/Evaluator campaign via multiagents MCP. */
import {appendFileSync,existsSync,mkdirSync,readFileSync,writeFileSync,openSync,closeSync,renameSync,unlinkSync} from 'node:fs';
import {dirname,join,resolve} from 'node:path';
import {homedir} from 'node:os';
import {spawn} from 'node:child_process';
import {checkCampaign} from './check-implementation-handoff.ts';
import {scanEvents,acceptEvent,resumeEvent} from './paired-events.ts';
import {consultationArtifacts as consultationArtifactPaths,consultationRoles} from './consultation-contract.ts';

const cfg=JSON.parse(readFileSync(process.argv[2],'utf8'));
for(const k of ['project_root','plan_dir','run_dir','run_id','codex_binary','operator_skill_root'])if(!cfg[k])throw Error(`Missing ${k}`);
const project=resolve(cfg.project_root),plan=resolve(cfg.plan_dir),out=resolve(cfg.run_dir),packet=resolve(import.meta.dir,'..');
const expertRecommendationPath=cfg.expert_recommendation_path?resolve(cfg.expert_recommendation_path):null;
const decisionAuthorityProfilePath=cfg.decision_authority_profile_path?resolve(cfg.decision_authority_profile_path):null;
const consultationRequestPath=cfg.consultation_request_path?resolve(cfg.consultation_request_path):null;
const implementationWorkQueuePath=cfg.implementation_work_queue_path?resolve(cfg.implementation_work_queue_path):null;
const defaultRefinedHandoff=join(packet,'orchestration/05-refined-technical-handoff--storage-layout.md');
const refinedTechnicalHandoffPath=cfg.refined_technical_handoff_path?resolve(cfg.refined_technical_handoff_path):(existsSync(defaultRefinedHandoff)?defaultRefinedHandoff:null);
const parallelPreflightJobs=Array.isArray(cfg.parallel_preflight_jobs)?cfg.parallel_preflight_jobs:[];
const orchestrationProfile=cfg.orchestration_profile==='full'?'full':'light';
const workerAgentType='codex' as const;
const allowFullTipResume=cfg.allow_full_tip_resume===true;
const defaultLightOwnerBatch=['roles/k3s_vllm_runtime/**','roles/k3s_storage_offload/**','playbooks/deploy_k3s_storage_expansion.yaml'];
const lightOwnerBatch=(Array.isArray(cfg.owner_batch)?cfg.owner_batch:defaultLightOwnerBatch).filter((item:any)=>typeof item==='string'&&item.length>0);
// A completed artifact wakes the next role immediately. These are leak/stall
// ceilings, not planned wait times; source work can legitimately need longer.
const limits={max_passes:cfg.max_passes??(orchestrationProfile==='full'?8:4),pass_timeout_seconds:cfg.pass_timeout_seconds??900,run_timeout_seconds:cfg.run_timeout_seconds??(orchestrationProfile==='full'?5400:3600)};
if(Boolean(expertRecommendationPath)!==Boolean(decisionAuthorityProfilePath))throw Error('Expert recommendation and decision authority profile must be supplied together');
if(expertRecommendationPath&&(!existsSync(expertRecommendationPath)||!existsSync(decisionAuthorityProfilePath!)))throw Error('Missing Expert recommendation or decision authority profile');
if(consultationRequestPath&&!existsSync(consultationRequestPath))throw Error('Missing bounded consultation request');
if(implementationWorkQueuePath&&!existsSync(implementationWorkQueuePath))throw Error('Missing implementation work queue');
if(orchestrationProfile==='light'&&cfg.fixture_mode!==true&&!refinedTechnicalHandoffPath)throw Error('Light profile requires refined_technical_handoff_path (or the default orchestration/05-refined-technical-handoff--storage-layout.md)');
if(refinedTechnicalHandoffPath&&!existsSync(refinedTechnicalHandoffPath))throw Error('Missing refined technical handoff');
if(!/^[a-z0-9][a-z0-9-]+$/.test(cfg.run_id))throw Error('Use a unique kebab-case run ID');
if(existsSync(out))throw Error('run_dir already exists; use a fresh run directory. Resume from campaign artifacts, not overwritten runtime logs.');
const fixture=cfg.fixture_mode===true;
if(fixture&&(!existsSync(join(project,'PAIRED-RUNTIME-FIXTURE'))||project!==plan||project.includes('/dotfile-vnext/')))throw Error('Fixture mode requires a marked isolated project=plan directory');
const intake=fixture?{campaign_id:'paired-runtime-fixture',upstream_run_id:'fixture-preparation',upstream_plan_sha256:'f'.repeat(64)}:checkCampaign(plan);
const upstream=fixture?{pipeline_id:'paired-runtime-fixture',task_id:'paired-runtime-fixture'}:JSON.parse(readFileSync(join(plan,'upstream-manifest.json'),'utf8'));
if(!fixture&&project!==upstream.upstream_identity.project_root)throw Error('Project root disagrees with reviewed intake');
const skills:any=fixture?cfg.fixture_skills:orchestrationProfile==='full'?{implementer:join(packet,'implementer/skills/storage-plan-implementer-beta/SKILL.md'),evaluator:join(packet,'evaluator/skills/storage-plan-evaluator-beta/SKILL.md'),coordinator:join(packet,'multi-agent-onsite-expert/skills/onsite-expert-consultation-light-beta/SKILL.md'),researcher:join(packet,'researchers/skills/researcher-consultation-light-beta/SKILL.md')}:{implementer:join(packet,'implementer/skills/storage-plan-implementer-light-beta/SKILL.md'),evaluator:join(packet,'evaluator/skills/storage-plan-evaluator-light-beta/SKILL.md'),coordinator:join(packet,'multi-agent-onsite-expert/skills/onsite-expert-consultation-light-beta/SKILL.md'),researcher:join(packet,'researchers/skills/researcher-consultation-light-beta/SKILL.md')};
for(const role of ['implementer','evaluator'])if(!skills?.[role]||!existsSync(skills[role]))throw Error(`Missing ${role} skill`);
if(consultationRequestPath)for(const role of ['coordinator','researcher'])if(!skills?.[role]||!existsSync(skills[role]))throw Error(`Missing ${role} consultation skill`);
for(const [key,value] of Object.entries(limits))if(!Number.isInteger(value)||Number(value)<1)throw Error(`Invalid ${key}`);
mkdirSync(out,{recursive:true});
const owner=join(out,'owned-processes.json');
const lockDir=join(packet,'orchestration/temp');
mkdirSync(lockDir,{recursive:true});
const lock=join(lockDir,'.paired-run-lock.json');
const pkg=cfg.multiagents_package_root||join(homedir(),'.bun/install/global/node_modules/multiagents');
const ownership=join(cfg.operator_skill_root,'scripts/owned_processes.py');
const requestedSession=`${upstream.task_id}--implementation-${cfg.run_id}--ppid${process.pid}`;
let session=requestedSession.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/^-|-$/g,'');
let finishing=false,failure:string|undefined,status='incomplete',lockOwned=false,created=false,completed=0;
let current='preflight',nextActor='implementer',responseTo:string|null=null;
let watcher:ReturnType<typeof spawn>|undefined;
let parallelPreflightManifest:string|null=null;
const consultationArtifacts=consultationArtifactPaths(plan,consultationRequestPath,cfg.run_id);
const save=(name:string,data:any)=>writeFileSync(join(out,name),JSON.stringify(data,null,2)+'\n');
const log=(event:string,data:any={})=>{const line=JSON.stringify({time:new Date().toISOString(),event,...data});appendFileSync(join(out,'events.jsonl'),line+'\n');if(event!=='driver')console.log(line);};
const shellQuote=(value:string)=>`'${value.replace(/'/g,"'\\''")}'`;
const printMonitorCommand=()=>console.log(`\nMonitor this run in a second terminal (read-only; Ctrl-C stops only the monitor):\n${shellQuote(join(import.meta.dir,'watch-implementation-output.sh'))} --session-id ${shellQuote(session)} --run-dir ${shellQuote(out)} --endpoint ${shellQuote('http://127.0.0.1:7899')} --interval 5 --clear\n`);
function ledger(mode:string,args:string[]=[],manifest=owner,run=cfg.run_id){
 const p=Bun.spawnSync(['python3',ownership,mode,'--manifest',manifest,'--run-id',run,...args],{stdout:'pipe',stderr:'pipe',timeout:20000});
 if(p.exitCode!==0)throw Error(p.stderr.toString()||p.stdout.toString());return JSON.parse(p.stdout.toString());
}
const env={...process.env,PATH:dirname(cfg.codex_binary)+':'+join(homedir(),'.bun/bin')+':'+process.env.PATH,MULTIAGENTS_RUN_ID:cfg.run_id,MULTIAGENTS_NO_OPEN:'1',MULTIAGENTS_PACKAGE_ROOT:pkg,MULTIAGENTS_GUARD_PATH:join(cfg.operator_skill_root,'scripts/codex_driver_guard.ts'),MULTIAGENTS_WORK_ROOT:project,MULTIAGENTS_WRITABLE_ROOTS:JSON.stringify([...new Set([project,plan,out])]),MULTIAGENTS_TURN_TIMEOUT_MS:String(limits.pass_timeout_seconds*1000)};
const post=async(route:string,data:any)=>{const r=await fetch('http://127.0.0.1:7899'+route,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data),signal:AbortSignal.timeout(5000)});if(!r.ok)throw Error(`${route}: HTTP ${r.status}`);const j=await r.json();if(j.error)throw Error(JSON.stringify(j));return j;};
async function brokerHealthy(){try{return (await fetch('http://127.0.0.1:7899/health',{signal:AbortSignal.timeout(3000)}).then(r=>r.json())).status==='ok';}catch{return false;}}
async function useOrRecoverBroker(){
 if(await brokerHealthy()){log('broker_reused',{url:'http://127.0.0.1:7899'});return;}
 // Setup is a failure-only recovery path. It does not run when the MCP-managed
 // broker is already available.
 const cli=cfg.multiagents_cli||join(homedir(),'.bun/bin/multiagents');
 log('broker_recovery_started',{cli});
 const started=Bun.spawnSync([cli,'broker','start'],{stdout:'pipe',stderr:'pipe',timeout:15000});
 if(started.exitCode!==0)throw Error(`Broker recovery failed: ${started.stderr.toString()||started.stdout.toString()}`);
 for(let attempt=0;attempt<10;attempt++){if(await brokerHealthy()){log('broker_recovered',{url:'http://127.0.0.1:7899'});return;}await Bun.sleep(500);}
 throw Error('Broker recovery returned without a healthy broker');
}
async function dashboardHealthy(){try{return (await fetch('http://127.0.0.1:7900',{signal:AbortSignal.timeout(3000)})).ok;}catch{return false;}}
async function publishSlotSummary(slot:any,summary:string){
 if(!slot.peer_id){log('dashboard_summary_unavailable',{slot_id:slot.id,role:slot.display_name,reason:'peer_id_not_registered'});return;}
 try{await post('/set-summary',{id:slot.peer_id,summary});log('dashboard_summary',{slot_id:slot.id,role:slot.display_name,summary});}
 catch(error){log('dashboard_summary_unavailable',{slot_id:slot.id,role:slot.display_name,reason:String(error)});}
}
const dashboardSummaryText=(value:any)=>String(value||'').replace(/\s+/g,' ').trim().slice(0,280);
/**
 * The installed driver writes its concise agent update to context_snapshot.
 * The dashboard itself renders peer.summary first, so promote that one safe,
 * human-facing field while the role is active. This is a fallback for agents
 * that miss their direct set_summary call; it never streams commands or logs.
 */
async function mirrorWorkerSummary(slotId:number,role:string,last:string){
 try{
  const live=(await post('/slots/list',{session_id:session})).find((candidate:any)=>candidate.id===slotId);
  const summary=dashboardSummaryText(JSON.parse(live?.context_snapshot||'{}').last_summary);
  // Driver placeholders such as "File: unknown file" are not progress. Keep
  // the last useful status instead of letting a UI implementation detail erase it.
  if(!summary||summary.length<30||/^file:\s*unknown\s*file$/i.test(summary)||summary==='READY'||summary==='(driver-mode MCP adapter)'||summary===last)return last;
  await publishSlotSummary(live,summary);
  log('dashboard_summary_mirrored',{slot_id:slotId,role,summary});
  return summary;
 }catch(error){log('dashboard_summary_mirror_unavailable',{slot_id:slotId,role,reason:String(error)});return last;}
}
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
const deadline=setTimeout(()=>{failure='Overall campaign deadline exceeded';},limits.run_timeout_seconds*1000);
process.on('SIGTERM',()=>{failure='SIGTERM received';});process.on('SIGINT',()=>{failure='SIGINT received';});
try{
 ledger('init',['--session-id',session,'--owner-pid',String(process.pid)]);
 if(existsSync(lock)){
  if(!process.argv.includes('--recover-lock'))throw Error(`Campaign already has a run lock: ${lock}. Inspect its owner; use --recover-lock only after exact owned processes stop.`);
  const prior=JSON.parse(readFileSync(lock,'utf8')),state=ledger('observe',[],prior.owner_manifest_path,prior.run_id);
  if(state.owner_alive||state.processes.some((p:any)=>p.identity_live))throw Error('Previous owner/children still live; refusing duplicate campaign writer');
  renameSync(lock,join(lockDir,`.paired-run-lock-recovered-${Date.now()}.json`));
 }
 writeFileSync(lock,JSON.stringify({run_id:cfg.run_id,owner_manifest_path:owner,session_id:session}),{flag:'wx'});lockOwned=true;
 const tip=resumeEvent(plan,{campaign_id:intake.campaign_id,upstream_plan_sha256:intake.upstream_plan_sha256});
 if(tip){
  const fullEraTip=tip.kind==='feedback'||tip.kind==='waiting';
  if(orchestrationProfile==='light'&&fullEraTip&&!allowFullTipResume){
   throw Error(
    `Light profile refuses to resume Full-era tip ${tip.path} (kind=${tip.kind}). `+
    'Quarantine/supersede that tip and start from the implementation work queue, '+
    'or pass allow_full_tip_resume: true for an explicit override.',
   );
  }
  responseTo=tip.path;nextActor=tip.nextActor;log('resume_from',{...tip});
 }
 if(nextActor==='none'&&cfg.reopen_review===true)nextActor='evaluator';
 if(nextActor==='operator'&&cfg.operator_resolution_path){
  if(!existsSync(resolve(cfg.operator_resolution_path)))throw Error('Missing recorded operator resolution');
  nextActor='implementer';log('operator_resolution',{path:resolve(cfg.operator_resolution_path)});
 }
 if(nextActor==='none'||nextActor==='operator'){
  status=nextActor==='none'?'prior_signoff_present':'waiting_for_operator';
  log('no_team_needed',{status,last_artifact:responseTo});
 }else{
 await useOrRecoverBroker();
 const version=Bun.spawnSync([cfg.codex_binary,'--version'],{stdout:'pipe',stderr:'pipe',timeout:10000});if(version.exitCode!==0)throw Error('Codex executable preflight failed');
 if(parallelPreflightJobs.length>0){
  const preflightConfig=join(out,'parallel-preflight-config.json');
  writeFileSync(preflightConfig,JSON.stringify({project_root:project,plan_dir:plan,output_dir:join(out,'parallel-preflight'),run_id:cfg.run_id,jobs:parallelPreflightJobs},null,2)+'\n');
  const preflight=Bun.spawnSync(['bun',join(import.meta.dir,'experimental/run-parallel-preflight.ts'),preflightConfig],{cwd:out,stdout:'pipe',stderr:'pipe',timeout:550000});
  if(preflight.exitCode!==0)throw Error(`Parallel preflight failed: ${preflight.stderr.toString()||preflight.stdout.toString()}`);
  parallelPreflightManifest=join(out,'parallel-preflight','manifest.json');log('parallel_preflight_admission_completed',{manifest:parallelPreflightManifest,summary:preflight.stdout.toString().trim()});
 }
 save('inputs.json',{...cfg,...intake,session_id:session,owner_manifest_path:owner});log('preflight',{version:version.stdout.toString().trim(),dashboard_url:'http://127.0.0.1:7900',campaign_id:intake.campaign_id});
 const fd=openSync(join(out,'watchdog.log'),'a');watcher=spawn('python3',[ownership,'watch','--manifest',owner,'--run-id',cfg.run_id,'--interval','1'],{detached:true,stdio:['ignore',fd,fd]});watcher.unref();closeSync(fd);
 await until(()=>Boolean(JSON.parse(readFileSync(owner,'utf8')).watcher_heartbeat),10);
 await client.connect(transport);ledger('register',['--pid',String(transport.pid),'--role','orchestrator','--descendants']);
 writeFileSync(join(out,'AGENTS.md'),`# Parent-owned runtime work area\nOne finite assigned pass; parent owns scheduling. Use explicit project_root and plan_dir from the task, never ambient cwd. ${fixture?'Fixture only: no real project or host access.':'Read project_root/AGENTS.md before substantive project work; follow that project framework. Preserve unrelated work and specific Apply authority.'}\n`);
 const runtimeRoles=consultationRoles(consultationRequestPath);
 const result=await client.callTool({name:'create_team',arguments:{project_dir:out,session_name:requestedSession,agents:runtimeRoles.map(role=>({agent_type:workerAgentType,name:role,role,role_description:`You are ${role}. Follow ${skills[role]} for task passes. Parent schedules finite passes. No independent polling, peer launches or runtime operation.`,initial_task:'Reply READY only. No tools or file writes. End this initialization turn.',file_ownership:role==='implementer'?['roles/**','playbooks/**','inventory/**','review_ready_for_evaluator_*','coordination/implementation-work-queue.md']:role==='evaluator'?['feedback_for_review_by_evaluator_*','waiting_for_review_by_evaluator_*','ready_for_review_by_evaluator_*']:['coordination/consultations/**']}))}},undefined,{timeout:180000});
 if(workerAgentType!=='codex')throw Error(`Worker agent_type must be codex; refused ${workerAgentType}`);
 const text=result.content?.map((x:any)=>x.text||'').join('\n')||'',match=text.match(/Session "([^"]+)" created/);if(result.isError||!match)throw Error(`create_team failed: ${text}`);
 const expectedSession=session;session=match[1];created=true;log('team_created',{session_id:session});save('session.json',{session_id:session,run_id:cfg.run_id,owner_manifest_path:owner});printMonitorCommand();
 if(session!==expectedSession)throw Error('Unexpected session collision; actual ID retained for cleanup');
 await until(()=>completed>=runtimeRoles.length*2,180);
 for(const slot of await post('/slots/list',{session_id:session})){
  await post('/hold-messages',{session_id:session,slot_id:slot.id});
  const role=slot.display_name;
  const label=role==='implementer'?'Implementer':role==='evaluator'?'Evaluator':role==='coordinator'?'On-site Expert':'Researcher';
  const held=role===nextActor?`${label} queued — awaiting parent dispatch.`:role==='evaluator'?'Evaluator held — awaiting a validated Implementer handoff.':`${label} held — awaiting a bounded consultation request.`;
  await publishSlotSummary(slot,held);
 }
 if(await dashboardHealthy()){
  const observation={dashboard_url:'http://127.0.0.1:7900',healthy:true,action:'reused-existing'};
  save('dashboard-observation.json',observation);log('dashboard',observation);
 }else{
  const dashboard=Bun.spawnSync(['python3',join(cfg.operator_skill_root,'scripts/runtime_operator.py'),'ensure-dashboard','--session-id',session,'--run-dir',join(out,'dashboard'),'--manifest',owner,'--run-id',cfg.run_id,'--cli',cfg.multiagents_cli||join(homedir(),'.bun/bin/multiagents')],{env,stdout:'pipe',stderr:'pipe',timeout:45000});
  if(dashboard.exitCode!==0)throw Error(dashboard.stderr.toString()||dashboard.stdout.toString());const observation=JSON.parse(dashboard.stdout.toString());save('dashboard-observation.json',observation.observation);log('dashboard',{url:observation.observation.dashboard_url,healthy:observation.observation.healthy,action:observation.action});
 }
 if(consultationRequestPath&&consultationArtifacts){
  mkdirSync(dirname(consultationArtifacts.coordinator),{recursive:true});
  for(const role of ['coordinator','researcher']){
   current=`consultation/${role}`;
   const slots=await post('/slots/list',{session_id:session}),slot=slots.find((s:any)=>s.display_name===role);if(!slot)throw Error(`Missing ${role} consultation slot`);
   const thread=JSON.parse(slot.context_snapshot||'{}').codex_thread_id;if(!thread)throw Error(`Missing ${role} consultation thread`);
   const prior=verified.get(thread)||0,output=consultationArtifacts[role as 'coordinator'|'researcher'];
   const counterpart=role==='coordinator'?'None; frame the technical fork and evidence needed.':'Read the Coordinator consultation output before synthesizing the evidence-backed answer.';
   const prompt=`Read and use ${skills[role]} for ONE bounded Light consultation pass. Inputs: ${JSON.stringify({project_root:project,plan_dir:plan,consultation_request_path:consultationRequestPath,coordinator_output_path:consultationArtifacts.coordinator,researcher_output_path:consultationArtifacts.researcher,run_id:`${cfg.run_id}-${role}-consultation`,session_id:session})}. ${counterpart} Read only the named request and cited evidence; do not reopen broad preparation, edit implementation-owned sources, run SSH/live discovery, Apply changes, or request human authority. Write the concise evidence-backed consultation response to exactly ${output}, including the request path, recommendation, assumptions, cited evidence, affected owners, and return_to. Finish the model turn after that one artifact.`;
   log('consultation_started',{role,request:consultationRequestPath,output});
   await publishSlotSummary(slot,`${role === 'coordinator' ? 'On-site Expert' : 'Researcher'} consultation — resolving the named technical fork.`);
   await post('/release-held',{session_id:session,slot_id:slot.id});
   await post('/send-message',{from_id:'orchestrator',to_id:`__slot_${slot.id}__`,to_slot_id:slot.id,session_id:session,msg_type:'chat',text:prompt});
   await until(()=>(verified.get(thread)||0)>prior,limits.pass_timeout_seconds);
   await post('/hold-messages',{session_id:session,slot_id:slot.id});
   if(!existsSync(output))throw Error(`${role} consultation did not write ${output}`);
   await publishSlotSummary(slot,`${role === 'coordinator' ? 'On-site Expert' : 'Researcher'} consultation complete — response saved for the implementation pair.`);
   log('consultation_completed',{role,request:consultationRequestPath,output});
  }
 }
 for(let pass=1;pass<=limits.max_passes;pass++){
  const role=nextActor;current=`${role}/${pass}`;
  const slots=await post('/slots/list',{session_id:session}),slot=slots.find((s:any)=>s.display_name===role);if(!slot)throw Error(`Missing ${role} slot`);
  const thread=JSON.parse(slot.context_snapshot||'{}').codex_thread_id;if(!thread)throw Error(`Missing thread for ${role}`);
  const prior=verified.get(thread)||0,before=scanEvents(plan),invocation=`${cfg.run_id}-${role}-${pass}`;
  const inputs={project_root:project,plan_dir:plan,mode:'orchestrated',pipeline_id:upstream.pipeline_id,task_id:upstream.task_id,campaign_id:intake.campaign_id,stage_id:'implementation',run_id:invocation,upstream_run_id:intake.upstream_run_id,upstream_plan_sha256:intake.upstream_plan_sha256,session_id:session,owner_manifest_path:owner,runtime_observation_path:join(out,'dashboard-observation.json'),responds_to:responseTo,...(refinedTechnicalHandoffPath?{refined_technical_handoff_path:refinedTechnicalHandoffPath}:{}),...(implementationWorkQueuePath?{implementation_work_queue_path:implementationWorkQueuePath}:{}),...(parallelPreflightManifest?{parallel_preflight_manifest_path:parallelPreflightManifest}:{}),...(expertRecommendationPath?{expert_recommendation_path:expertRecommendationPath,decision_authority_profile_path:decisionAuthorityProfilePath}:{}),...(consultationArtifacts?{consultation_request_path:consultationRequestPath,consultation_expert_path:consultationArtifacts.coordinator,consultation_research_path:consultationArtifacts.researcher}:{}),...(cfg.operator_resolution_path?{operator_resolution_path:resolve(cfg.operator_resolution_path)}:{})};
  const authorityGuidance=expertRecommendationPath?'Read both supplied Expert/profile paths. Apply only the profile-authorized recommendation within campaign scope; exact target identity, validation, receipts and Evaluator review remain mandatory.':'Live mutation needs recorded specific authority and verified targets/backup; never guess. Missing user choices go in the durable handoff; continue independent safe work.';
  const batch=orchestrationProfile==='light'?lightOwnerBatch:[];
  const lightScope=`Read the refined technical handoff FIRST as work instructions (primary input, not optional): ${refinedTechnicalHandoffPath}. Do not use the onsite transcript or raw research dumps as the work specification. ${role==='implementer'?`Your job is Ansible intake: derive or refresh the dynamic work queue from that handoff's functional areas${implementationWorkQueuePath?` at ${implementationWorkQueuePath}`:''}, then select exactly one ready non-overlapping chunk and adapt its settled settings into existing project owners. Hand the freeze to Evaluator. While a prior chunk is under evaluation, you may start the next independent area only when owners do not overlap. Do not wait for Evaluator to restate handoff design details. `:`Your job is verification only: check whether the frozen Implementer chunk correctly adapted its handoff functional-area target into the declared owners with mature Ansible quality. Do not re-teach the handoff's placement matrix or correction catalog. `}${implementationWorkQueuePath?`Queue path: ${implementationWorkQueuePath}. `:`Light owner batch fallback (do not expand it): ${JSON.stringify(batch)}. `}`;
  const prompt=`Read and use ${skills[role]} for ONE finite ${role} pass. Inputs: ${JSON.stringify(inputs)}. ${orchestrationProfile==='light'?`${lightScope}The primary work is to implement the target from the refined handoff (Implementer) or verify that adaptation (Evaluator). Treat diffs, file reads, git status, task/argument inspection, and source checks only as evidence directly tied to that target—not as separate work streams. This recreatable lab treats workloads and storage state as cattle. Check/implement desired-state convergence and source quality; do not spend this pass on bespoke rollback, backup, approval, failure-forensics, or unrelated hygiene. For Light, ignore superseded Full-era feedback that demands retired safety-contract fixtures unless orchestration_profile is full. Read only the latest governed artifact at ${responseTo||'the campaign intake'} when it is chunk-local feedback, the refined handoff, and these owners. Controller-local source work only: do not run SSH, inventory-targeted ansible/ansible-playbook commands, remote probes, live discovery, Apply, or runtime diagnostics. Allowed validation is one bundled source-local whitespace, syntax, lint, template, argument-contract or static module check; do not run S3/S4 safety-contract playbooks. `:''}${parallelPreflightManifest?'The preflight manifest is informational only; do not reopen it or treat it as authorization. ':''}${consultationArtifacts?'The supplied consultation outputs answer one named fork only; apply them without reopening research. ':''}Parent orchestrator owns routing and monitoring. Publish at most a start summary naming the chunk and a final handoff/verdict summary; never report individual commands or checks. ${fixture?'ISOLATED FIXTURE ONLY. No source repo or host access.':`Implement the real campaign source package. ${authorityGuidance}`} First produce the bounded owner change, then run one targeted controller-local validation bundle, then write exactly ONE NEW mature top-level timestamped role artifact with role=${role}, responds_to=${JSON.stringify(responseTo)}, status and next_actor. Do not edit old or opposing-role events. ${role==='evaluator'?'Verify adaptation with short actionable owner/file feedback or ready—do not rewrite the refined handoff. After a ready artifact only, call peer approve for Implementer. Filename must be ready_for_review_by_evaluator_* (never *_by_coordinator_*).':'Write review_ready_for_evaluator after the one batch validates; do not self-approve.'} Finish the model turn immediately after that artifact.`;
  log('pass_started',{pass:current,slot_id:slot.id,run_id:invocation});save('checkpoint.json',{...inputs,pass,status:'running'});
  await publishSlotSummary(slot,`${role === 'implementer' ? 'Implementer' : 'Evaluator'} pass ${pass} — preparing the next bounded source package.`);
  await post('/release-held',{session_id:session,slot_id:slot.id});
  // Explicit driver target avoids resolving a stale/nonexistent peer_id in this installed broker.
  await post('/send-message',{from_id:'orchestrator',to_id:`__slot_${slot.id}__`,to_slot_id:slot.id,session_id:session,msg_type:'chat',text:prompt+(cfg.operator_resolution_path?' Read the supplied operator_resolution_path first; it records a specific user decision, not blanket Apply authority.':'')});
  log('pass_dispatched',{pass:current,slot_id:slot.id,deadline_seconds:limits.pass_timeout_seconds});
  let lastMirroredSummary='';
  const dashboardMirror=setInterval(()=>{void mirrorWorkerSummary(slot.id,role,lastMirroredSummary).then(summary=>{lastMirroredSummary=summary;});},3000);
  try{await until(()=>(verified.get(thread)||0)>prior,limits.pass_timeout_seconds);}
  finally{clearInterval(dashboardMirror);}
  await post('/hold-messages',{session_id:session,slot_id:slot.id});
  const event=acceptEvent(plan,before,{campaign_id:intake.campaign_id,run_id:invocation,role,upstream_plan_sha256:intake.upstream_plan_sha256,responds_to:responseTo});
  save(`pass-${pass}.json`,{...inputs,...event,terminal:'completed'});log('pass_completed',{pass:current,...event});await publishSlotSummary(slot,`${role === 'implementer' ? 'Implementer' : 'Evaluator'} pass ${pass} complete — ${event.kind}; next: ${event.nextActor}.`);responseTo=event.path;nextActor=event.nextActor;
  if(nextActor==='operator'){status='waiting_for_operator';break;}
  if(nextActor==='none'){
   const finalSlots=await post('/slots/list',{session_id:session});save('approval-slots.json',finalSlots);
   if(finalSlots.find((s:any)=>s.display_name==='implementer')?.task_state!=='approved')throw Error('Evaluator ready artifact exists but no Implementer peer approve signal was recorded');
   status='approved';break;
  }
  if(pass===limits.max_passes)status='pass_limit_reached';
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
