# Runtime experimental (not core Light orchestration)

Parked surfaces that are **not** part of the default Expert → handoff →
Implementer ↔ Evaluator path.

| Script | Purpose |
| --- | --- |
| `run-parallel-preflight.ts` | Optional read-only parallel inspection jobs |
| `stage-batch-worktree.ts` | Optional isolated batch worktree staging |

Core runner (`../run-implementation.ts`) only invokes parallel preflight when
`parallel_preflight_jobs` is a non-empty array. Empty/default = skip.

Do not treat these as required gates for Light source adaptation.
