import {basename, join} from 'node:path';

export const consultationRoles=(requestPath:string|null)=>requestPath
  ? ['implementer','evaluator','coordinator','researcher']
  : ['implementer','evaluator'];

export const consultationArtifacts=(planDir:string,requestPath:string|null,runId:string)=>{
  if(!requestPath)return null;
  const stem=basename(requestPath).replace(/\.md$/,'');
  const root=join(planDir,'coordination','consultations');
  return {
    coordinator:join(root,`${stem}-${runId}-expert.md`),
    researcher:join(root,`${stem}-${runId}-research.md`),
  };
};
