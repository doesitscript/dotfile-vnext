import {test,expect,afterEach} from 'bun:test';
import {mkdtempSync,mkdirSync,writeFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';import {join,dirname} from 'node:path';
import {paths,sha,verifyArtifact,verifyRelease,receiptMatches} from './artifacts.ts';
const roots:string[]=[];
afterEach(()=>{for(const root of roots.splice(0))rmSync(root,{recursive:true});});
function fixture(){const out=mkdtempSync(join(tmpdir(),'prep-artifact-test-'));roots.push(out);const input={contract_version:1,pipeline_id:'pipeline',stage_id:'preparation',task_id:'task',run_id:'run',source_plan_root:'/source',preparation_output_root:out,project_root:'/project'};return {input,out};}
function write(out:string,key:keyof typeof paths,m:any,body='Evidence'){const p=join(out,paths[key]);mkdirSync(dirname(p),{recursive:true});writeFileSync(p,'---\n'+Bun.YAML.stringify(m).trimEnd()+'\n---\n'+body+'\n');return p;}
function release(){const f=fixture();const plan=write(f.out,'compose',{...f.input,status:'awaiting_plan_review',next_actor:'Researcher'});const reviewed={...f.input,reviewed_plan_path:plan,reviewed_plan_sha256:sha(plan),next_actor:'Coordinator'};const review=write(f.out,'review',{...reviewed,status:'plan_review_passed'});write(f.out,'release',{...reviewed,status:'ready_for_implementation',next_actor:'Implementer',plan_review_path:review,downstream_activation:'authorized_separately'});return {...f,plan};}
test('matching independent review and release accepted',()=>{const f=release();expect(verifyRelease(f.input).sha256).toBe(sha(f.plan));});
test('changed reviewed bytes invalidate release',()=>{const f=release();writeFileSync(f.plan,read(f.plan)+'changed');expect(()=>verifyRelease(f.input)).toThrow('hash');});
test('another run artifact rejected',()=>{const f=fixture();const p=write(f.out,'route',{...f.input,run_id:'other',status:'ready',next_actor:'Researcher'});expect(()=>verifyArtifact(p,f.input)).toThrow('run_id');});
test('missing frontmatter rejected',()=>{const f=fixture();writeFileSync(join(f.out,'bad.md'),'status: ready');expect(()=>verifyArtifact(join(f.out,'bad.md'),f.input)).toThrow('frontmatter');});
test('review failed cannot release',()=>{const f=release();const p=join(f.out,paths.review);writeFileSync(p,read(p).replace('plan_review_passed','plan_changes_required'));expect(()=>verifyRelease(f.input)).toThrow('reviewed');});
test('release cannot auto-authorize downstream',()=>{const f=release();const p=join(f.out,paths.release);writeFileSync(p,read(p).replace('authorized_separately','automatic'));expect(()=>verifyRelease(f.input)).toThrow('Downstream');});
import {readFileSync} from 'node:fs';const read=(p:string)=>readFileSync(p,'utf8');
test('valid frontmatter alone is not a completed-pass receipt',()=>{const f=release();expect(receiptMatches(f.plan,f.input,null,{})).toBe(false);});
test('changed upstream invalidates an otherwise unchanged artifact',()=>{const f=release();const receipt={run_id:f.input.run_id,terminal:'completed',sha256:sha(f.plan),incoming:{research:'old'}};expect(receiptMatches(f.plan,f.input,receipt,{research:'new'})).toBe(false);});
test('unchanged completed artifact can be resumed idempotently',()=>{const f=release();const receipt={run_id:f.input.run_id,terminal:'completed',sha256:sha(f.plan),incoming:{research:'same'}};expect(receiptMatches(f.plan,f.input,receipt,{research:'same'})).toBe(true);});
test('project diagram gate cannot be waived by a passing review',()=>{const f=release();expect(()=>verifyRelease({...f.input,require_plan_diagrams:true})).toThrow('Missing plan section');});
