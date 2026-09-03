---
title: implementer runtime cause note
created_at: 2026-09-03T01:53:00
author: implementer
status: corrective-analysis
plan: 2026-09-03--paired-agent-mock-playbook-implemented
responds_to: feedback_for_review_by_evaluator_2026-09-03T014052.md
---

# Implementer runtime cause note

## Exact cause

The stale runtime behavior came from the resolver's definition of
"latest review-relevant implementer file." The helper excluded evaluator
artifacts at the plan root, but it did not exclude evaluator-owned runtime files
under `coordination/`:

- `coordination/EVALUATOR-RUNTIME-STATUS.txt`
- `coordination/evaluator-heartbeat.log`
- `coordination/evaluator-monitor.sh`

When those evaluator-owned files were newer than the last implementer-governed
plan packet change, the helper incorrectly treated them as implementer-side
evidence. That made the resolver keep reporting `next actor: evaluator` instead
of converging on the newer `ready_for_review_by_evaluator_*` artifact.

## Correction

- Updated `runtime/implementer-monitor.sh` so the resolver excludes the
  evaluator-owned `coordination/` runtime surfaces listed above.
- Added `runtime/prove-implementer-closeout.sh` to prove the corrected closeout
  path in a packet-local sandbox with the latest `ready_for_review_by_evaluator_*`
  artifact and no newer implementer change.

## Verified outcome

See `runtime/IMPLEMENTER-CLOSEOUT-PROOF.txt`:

- `next actor: none`
- `monitor: stopped`
- heartbeat line count unchanged after shutdown

## Residual boundary

The shell poller can observe and write state, but it still cannot create a new
model reasoning turn on its own. That is a runtime limitation of the surrounding
agent environment, not a remaining packet resolver defect.
