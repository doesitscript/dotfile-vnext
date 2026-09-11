import {describe,expect,test} from 'bun:test';
import {consultationArtifacts,consultationRoles} from './consultation-contract.ts';

describe('bounded Expert/Researcher consultation contract',()=>{
  test('ordinary Light work keeps the two-role fast path',()=>{
    expect(consultationRoles(null)).toEqual(['implementer','evaluator']);
    expect(consultationArtifacts('/plan',null,'run-1')).toBeNull();
  });
  test('a named request gets deterministic durable paths and only two sidecar roles',()=>{
    expect(consultationRoles('/plan/coordination/requests/s5.md')).toEqual(['implementer','evaluator','coordinator','researcher']);
    expect(consultationArtifacts('/plan','/plan/coordination/requests/s5.md','light-run-1')).toEqual({
      coordinator:'/plan/coordination/consultations/s5-light-run-1-expert.md',
      researcher:'/plan/coordination/consultations/s5-light-run-1-research.md',
    });
  });
});
