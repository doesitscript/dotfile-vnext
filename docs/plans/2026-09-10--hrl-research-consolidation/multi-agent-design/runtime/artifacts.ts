import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {join,resolve} from 'node:path';
export const paths={route:'coordination/current-phase-routing.md',research:'research/current-phase-readiness-brief.md',compose:'handoff/current-phase-implementation-plan.md',review:'research/current-phase-plan-review.md',release:'handoff/current-phase-release.md'};
export const sha=(path:string)=>createHash('sha256').update(readFileSync(path)).digest('hex');
export function frontmatter(path:string):any{
 const text=readFileSync(path,'utf8');const match=text.match(/^---\r?\n([\s\S]*?)\r?\n---(?:\r?\n|$)/);
 if(!match)throw Error(`Missing YAML frontmatter: ${path}`);
 return Bun.YAML.parse(match[1]);
}
export function verifyArtifact(path:string,input:any){
 const m=frontmatter(path);
 for(const k of ['contract_version','pipeline_id','stage_id','task_id','run_id','source_plan_root','preparation_output_root','project_root']){
  if(m[k]!==input[k])throw Error(`${path}: ${k} mismatch (${JSON.stringify(m[k])})`);
 }
 if(!m.status||!m.next_actor)throw Error(`Missing status/next_actor: ${path}`);
 const allowed:any={route:['research_requested'],research:['ready','needs_research','operator_decision_required'],compose:['awaiting_plan_review','needs_research','operator_decision_required'],review:['plan_review_passed','plan_changes_required'],release:['ready_for_implementation','needs_research','operator_decision_required']};
 const key=Object.entries(paths).find(([,p])=>path.endsWith('/'+p))?.[0];
 if(key&&!allowed[key].includes(m.status))throw Error(`Invalid ${key} status: ${m.status}`);
 return m;
}
export function verifyRelease(input:any){
 const root=input.preparation_output_root;const plan=join(root,paths.compose);
 const review=verifyArtifact(join(root,paths.review),input), release=verifyArtifact(join(root,paths.release),input);
 const digest=sha(plan);verifyArtifact(plan,input);
 if(input.require_plan_diagrams){const body=readFileSync(plan,'utf8');for(const title of ['Architecture/Structure Diagram','Capability Routing Diagram','Naming/Modeling Diagram','Diagram Inventory'])if(!body.includes(title))throw Error(`Missing plan section: ${title}`);}
 if(review.status!=='plan_review_passed'||release.status!=='ready_for_implementation')throw Error('Not independently reviewed/released');
 for(const m of [review,release])if(resolve(m.reviewed_plan_path)!==resolve(plan)||m.reviewed_plan_sha256!==digest)throw Error('Review/release plan hash or path mismatch');
 if(resolve(release.plan_review_path)!==resolve(join(root,paths.review))||release.next_actor!=='Implementer'||release.downstream_activation!=='authorized_separately')throw Error('Downstream handoff contract mismatch');
 return {plan,sha256:digest,review:join(root,paths.review),release:join(root,paths.release)};
}
export function receiptMatches(path:string,input:any,receipt:any,incoming:any){
 verifyArtifact(path,input);
 return Boolean(receipt?.run_id===input.run_id&&receipt?.terminal==='completed'&&receipt.sha256===sha(path)&&JSON.stringify(receipt.incoming)===JSON.stringify(incoming));
}
