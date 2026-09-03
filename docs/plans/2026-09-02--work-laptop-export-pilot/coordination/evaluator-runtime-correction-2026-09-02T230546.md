---
title: evaluator runtime correction
created_at: 2026-09-02T230546
author: evaluator-simple
plan: 2026-09-02--work-laptop-export-pilot
status: active-correction
---

# Evaluator runtime correction

## Problem found

Both agents could say they were "waiting" while still producing an
operator-visible deadlock. The broken logic was that each side trusted its own
role-local prose state instead of deriving the next actor from the latest
artifact class and the newest governed-file change.

## Runtime correction

When evaluator and implementer status messages conflict, the workflow must use
this resolver instead of prose:

1. Find the latest evaluator artifact in the plan root:
   - `feedback_for_review_by_evaluator_*`
   - `waiting_for_review_by_evaluator_*`
   - `ready_for_review_by_evaluator_*`
2. Find the newest implementer-owned governed file:
   - `README.md`
   - `coordination/implementation-accounting.md`
   - `coordination/implementer-after-action-*.md`
   - `coordination/implementer-rereview-request-*.md`
   - `coordination/implementer-runtime-correction-*.md`
3. Resolve the next actor:
   - If the newest implementer-governed change is newer than the latest
     evaluator artifact, the next actor is `evaluator`.
   - Else if the latest evaluator artifact is `feedback_*` or `waiting_*`, the
     next actor is `implementer`.
   - Else if the latest evaluator artifact is `ready_*` and no newer
     implementer-governed change exists, the next actor is `none`; the campaign
     is closed for the current state.

## Current resolution

- Latest evaluator artifact class during this correction: `ready_*`
- Newer implementer-governed changes existed after that approval
- Therefore the evaluator correctly owned the next action for this turn

## Required runtime behavior going forward

- Evaluator and implementer should stop saying only "waiting on the other"
  without also naming the computed next actor.
- The monitor surface should publish the computed actor so the operator can see
  whether the loop is live and who owns the next move.
- Ephemeral monitor heartbeat files such as `implementer-monitor-status.md` must
  not count as new review work for actor resolution.
- A new evaluator approval must supersede the stale earlier `ready_*` artifact
  once the changed governed state has been reviewed.
