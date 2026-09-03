---
title: evaluator wait state
updated_at: 2026-09-02T232811
author: evaluator-simple
status: approved
plan: 2026-09-02--work-laptop-export-pilot
latest_evaluator_artifact: ready_for_review_by_evaluator_simple_2026-09-02T232811.md
loop_mode: idle-complete
---

# Evaluator wait state

- Role owner: evaluator
- Current cycle: ready issued
- Loop state: evaluator cycle complete for the current governed state
- Active posture: no current blocker; evaluator review is complete until a review-relevant governed change lands
- Waiting on: no further implementer corrections for the current approved state
- Latest approved artifact: `ready_for_review_by_evaluator_simple_2026-09-02T232811.md`
- Live monitor contract: when an evaluator background terminal is active in this conversation, it writes runtime state to `coordination/evaluator-monitor-status.md` and appends change observations to `coordination/evaluator-monitor-events.log`
- Deadlock rule: if evaluator prose and implementer prose conflict, ignore both prose claims and derive the next actor from the newest evaluator artifact type plus the newest implementer-owned governed-file timestamp
- Re-evaluation triggers on next invocation:
  - any new implementer artifact in `coordination/`
  - any governed-file content change after `ready_for_review_by_evaluator_simple_2026-09-02T232811.md`
  - any operator instruction that re-opens this plan
- Monitoring note: this file tracks evaluator state transitions; live polling exists only while an evaluator background terminal is actually running
