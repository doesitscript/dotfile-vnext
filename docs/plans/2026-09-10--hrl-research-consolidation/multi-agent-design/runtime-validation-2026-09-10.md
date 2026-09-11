---
title: Coordinator/researcher runtime validation
observed_at: 2026-09-11T02:12:00Z
dashboard_url: http://127.0.0.1:7900
status: component-validation-passed-end-to-end-not-run
---

# Runtime validation result

Historical receipt: the later request expanded the task to full execution and
testing. [Validation 2026-09-11](validation-2026-09-11.md) supersedes the readiness
claims below. Preserve this file for the original failure/recovery evidence.

## Current closeout — supersedes the historical blocker below

Delivery: two implemented phase-scoped skills, multiagent metadata, copy/paste
prompts, independent Researcher plan review, hash-bound Coordinator release,
shared artifact/wakeup contract, and developer flow. Names retain `draft` as
requested. Stable Implementer/Evaluator skills are unchanged. Start with
[START-HERE.md](START-HERE.md).

The user clarified that these authoring deliverables were the intended endpoint.
An unexecuted new campaign harness was removed; no background preparation
campaign continues the source plan. The two prompts are ready to use, but their
full end-to-end content workflow has not been exercised. Manual two-chat use
requires the explicit followups supplied in the prompts; metadata is not an
automatic scheduler. No actual storage implementation plan or host change is
claimed from this authoring task.

### Fresh checks

- Both role skills pass skill-creator `quick_validate.py` through global-skills
  `bin/gs-env`; system Python lacks PyYAML. Both companion YAML files parse and
  shared-contract links resolve.
- Runtime operator: 9 isolated Python lifecycle/error tests pass.
- Driver terminal guard: 7 Bun tests / 10 assertions pass (success, failed,
  interrupted, missing terminal, stale success, exceptions, repeated install).
- Global catalog passes; full metadata validation retains two pre-existing
  unrelated default-prompt errors in `multiagent-paired-review-designer` and
  `skill-to-paired-review-converter`. Runtime-contract metadata fixed in scope.
- Runtime bridge succeeds; Codex/Cursor operator symlinks resolve to source.
- Task-surface `git diff --check` passes.

### Exact diagnosis and recovery

Raw app-server `turn/completed` showed `status=failed`: HTTP 400 said the selected
gpt-5.6-terra model required a newer Codex. PATH selected NVM Codex 0.142.5.
The installed CodexDriver incorrectly returned empty success for this failure.
Zero broker token counters were not proof of a long-running reasoning stall.

Per-process PATH selection of the already-installed Cursor Codex 0.153.4
completed the same-model READY probe (23347 input / 5 output tokens). No global
configuration or model selection was changed. This proves driver execution,
not a full two-role orchestration. The reusable operator now supplies terminal
failure diagnostics and a Bun preload guard without editing node_modules;
future harnesses must explicitly activate it and drain stderr.

Dashboard http://127.0.0.1:7900 restored by reusable helper, PID 13744.
Broker `/health`, dashboard `/` and `/api/sessions` are healthy. `/api/state` is
unsupported (404); helper uses the documented fallback. No selected-session or
WebSocket proof is claimed. No active team remains; historical archived
`phase1-smoke-v3` remains untouched.

User-authorized stale sessions `codex-coordinator-researcher-smoke-20260910` and
`phase1-stdio-harness` were exported/deleted after process inspection confirmed
no surviving orchestrator/app-server. Workspaces and current chat broker/peers
were retained. Optional leftovers cleanup covers owned dashboard PID 13744
(revalidate identity) and the disposable smoke workspace below; preserve source
skills, plans, reviewed artifacts and evidence by default.

### Evidence and sources

Evidence root:
`/Users/joshc/develop/oneoffs/multiagents-coordinator-researcher-smoke-20260910`.
See `driver-diagnostic.jsonl`, `cleanup-stale-smoke/session-before-delete.json`,
`cleanup-stale-harness/session-before-delete.json`, their cleanup results, and
`dashboard-recovery-20260911/dashboard-process.json` plus startup log.

Sources checked: skill-creator; runtime-contract/operator; mature paired
implementer/evaluator skills; project evaluator-implementer-loop registry;
HRL multiagents guide/roadmap and librarian advisory/source map; installed
CodexDriver, orchestrator, monitor, broker and dashboard source. Official
[Codex app-server documentation](https://developers.openai.com/codex/app-server/)
was consulted; the specific failure/recovery evidence is local wire output.

The Researcher review is a preparation gate, not mature Evaluator approval.
Until these prompts produce a hash-matched release, no evaluated implementation
plan is claimed.

## Historical observation — superseded diagnosis

The reusable `multiagents-runtime-operator` skill makes lifecycle observation
a reusable capability rather than unrecorded coordinator logic.

## Observed working

- Broker: `http://127.0.0.1:7899` running.
- Dashboard: `http://127.0.0.1:7900` reachable after team creation.
- An isolated two-slot Coordinator/Researcher session was created.
- The Coordinator had `peer_id = null`, so an explicit `to_slot_id` message
  route was used and accepted by the broker.
- The named disposable session was deleted without touching the pre-existing
  active session or stopping the broker.

## Blocker

Both spawned Codex slots remained connected/working for more than three
minutes with zero model token counts. The initial task and an explicit routed
recovery message produced no `coordination.md`, `research.md`, or `handoff.md`.
The saved disposable evidence is:

`/Users/joshc/develop/oneoffs/multiagents-coordinator-researcher-smoke-20260910/runtime-blocker.md`

This is a CodexDriver/app-server execution blocker, not proof that the draft
roles are correct or that an implementation handoff exists. Do not start the
Implementer/Evaluator loop until a real Coordinator/Researcher pass creates
the required handoff artifact.

## Next diagnostic owner

Use `multiagents-runtime-operator` in observe mode and inspect the CodexDriver
app-server launch/turn path for a zero-token condition. Re-run a new uniquely
named disposable session only after that condition is resolved; preserve the
same ownership and cleanup boundary.
