---
title: evaluator wait state strategy
created_at: 2026-09-02T223429
author: evaluator-simple
plan: 2026-09-02--work-laptop-export-pilot
status: active-contract
---

# Evaluator wait-state strategy

## Technical model

This evaluator loop is a file-backed state machine, not an autonomous daemon.
It does not run a background scheduler, file watcher, or hourly polling loop on
its own. Re-evaluation happens only when this agent is invoked for another turn
or when some external scheduler launches the evaluator explicitly.

## States

1. `acting-review`
   - Enter when no evaluator artifact exists yet.
   - Enter when implementer-owned artifacts or governed files changed after the
     latest evaluator artifact.
   - Action: inspect evidence, run required validation, and emit exactly one new
     evaluator artifact: `feedback_*` or `ready_*`.

2. `waiting-on-implementer`
   - Enter only after a `feedback_*` artifact when blockers remain and no newer
     implementer-owned artifact or governed-file change exists.
   - Action: do not emit a second contradictory feedback file; hold the blocker
     set stable until the source state changes.

3. `idle-complete`
   - Enter after a `ready_*` artifact when no newer implementer-owned artifact,
     governed-file change, or operator reopen instruction exists.
   - Action: no further review work is pending for the current approved state.

## Re-evaluation triggers

The evaluator must leave `waiting-on-implementer` or `idle-complete` and re-enter
`acting-review` on the next invocation when any of the following are true:

- a new file appears under `coordination/` that is owned by the implementer
- a governed file in the plan packet changes after the latest evaluator artifact
- the operator explicitly reopens or extends the plan

## Failure that happened in this run

The observed failure mode was not that the evaluator had a bad blocker list. The
failure was that "waiting" was being interpreted too loosely in chat, as if it
meant active unattended monitoring. Technically that was false.

The real contract is narrower:

- the evaluator can record a waiting state
- the evaluator cannot autonomously poll in the background between turns
- on each new evaluator turn, the evaluator must first check whether newer
  implementer artifacts or governed-state changes already invalidate the old
  waiting posture

If there is no new evaluator turn and no external scheduler, then no automatic
check happens. That is the actual limit of this environment.

## Corrected rule

Before honoring any previously written waiting state, compare the latest
evaluator artifact timestamp against:

- implementer artifacts in `coordination/`
- governed files in the plan folder
- operator reopen instructions

If any of those are newer, the evaluator is not waiting. It is back in
`acting-review` for that invocation.

## Current state for this plan

- Latest implementer correction artifacts: 2026-09-02 22:27 to 22:28 local time
- Latest evaluator approval artifact: 2026-09-02 22:29 local time
- Current evaluator state: `idle-complete`

That means this plan is currently approved and closed for this cycle. No further
evaluation runs until the evaluator is invoked again. When it is invoked again,
it must check the triggers above before deciding whether it is still complete or
must re-enter `acting-review`.
