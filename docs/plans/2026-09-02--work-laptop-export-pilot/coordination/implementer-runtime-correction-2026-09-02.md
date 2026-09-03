---
title: implementer runtime correction
created_at: 2026-09-02
author: plan-implementer
plan: 2026-09-02--work-laptop-export-pilot
status: corrective-change
---

# Implementer runtime correction

## Broken logic identified

- The workflow had no shared runtime state model between implementer and
  evaluator monitors.
- The word `waiting` was overloaded and could mean:
  - blocked on the other role
  - approved and only monitoring for reopen events
  - no current work pending on this turn
- That made both terminals look like they were waiting on each other even after
  the evaluator had already approved the governed state.

## Runtime correction applied

- Added `coordination/implementer-monitor.sh` as an implementer-owned polling
  script with an explicit action-state model.
- Added `coordination/implementer-monitor-status.md` as the implementer runtime
  status surface.
- The implementer monitor now uses the same shared resolver shape as the
  evaluator correction:
  - latest review-relevant evaluator artifact class
  - newest review-relevant implementer-governed file
  - computed next actor
- The implementer monitor now distinguishes:
  - `implementer-action-required`
  - `waiting-for-evaluator-review`
  - `approved-no-implementer-work-pending`
- Transient monitor files such as `implementer-monitor-status.md` and
  `implementer-monitor-events.log` are explicitly excluded from actor
  resolution.
- When the evaluator state is approved and no newer review-relevant
  implementer-governed file exists, the implementer monitor reports
  `approved-no-implementer-work-pending` with computed next actor `none`
  instead of any form of “waiting on evaluator.”

## Follow-up correction from evaluator recheck

- The first noisy runtime came from an older running monitor process image that
  still treated `coordination/implementer-monitor-status.md` as part of its
  watch set.
- The governed script source is now narrowed to review-relevant implementer
  artifacts only:
  - `coordination/implementation-accounting.md`
  - `coordination/implementer-after-action-*.md`
  - `coordination/implementer-rereview-request-*.md`
  - `coordination/implementer-runtime-correction-*.md`
- Explicitly excluded from watch-driven actor resolution:
  - `coordination/implementer-monitor-status.md`
  - `coordination/implementer-monitor-events.log`
- Operational implication: after this source correction, the monitor must run
  from the current script image so the live runtime matches the governed file.

## Expected effect

- The implementer terminal can keep actively polling without misrepresenting the
  approved state as a live blocker.
- The implementer and evaluator runtime surfaces now use the same actor
  resolution concept, so the operator can compare both without relying on loose
  prose like “waiting on the other.”
