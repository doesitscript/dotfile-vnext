---
name: multiagent-plan-observer-beta
description: "Observe this project's storage implementation campaign and optional multiagents session read-only, with brief dashboard and artifact status. On an explicit or automatic orchestration stop, record one concise timestamped observation report; do not evaluate, schedule, or mutate runtime."
metadata:
  status: beta
  scope: storage-implementation-campaign
  workflow_id: evaluator-implementer-loop
  contract_version: 1
  evaluation_role: observer
  paired_agent_model: evaluator-implementer
  counterpart_role: none
  depends_on_skills: "multiagents-runtime-operator, paired-agent-feedback-artifacts"
---

# Multiagent plan Observer — beta

Lightweight, read-only observation. You are not the Implementer, Evaluator,
scheduler or runtime owner. Read
[the integration contract](../../../orchestration/implementation-beta-contract.md).
Use the supplied `plan_dir` and optional **explicit** implementation
`session_id`; do not guess from preparation history, peer IDs or another team.

## Default: one snapshot

1. Read the campaign manifest and run the intake checker. Report consistency or
   the specific error, without turning it into an implementation verdict.
2. Read the accounting summary and newest governed Implementer/Evaluator
   artifacts for this campaign. Apply the existing
   `paired-agent-feedback-artifacts` ownership/freshness contract. Report the
   apparent next actor and remaining slice, clearly distinguishing an agent's
   claim from evidence you inspected. If source freshness is unverified, say so.
3. Load `/Users/joshc/develop/global-skills/skills/implementation/multiagents-runtime-operator/SKILL.md`
   and its runtime-contract dependency; use **observe mode only**:
   `python3 /Users/joshc/develop/global-skills/skills/implementation/multiagents-runtime-operator/scripts/runtime_operator.py observe`.
   Add `--session-id <exact-id>` only when the parent/operator supplies the
   campaign's mapping. This is a read-only command; do not redirect raw output
   into the plan. Inspect it and summarize minimally.
4. Report `Dashboard: http://127.0.0.1:7900 — <observed status>`, observation
   timestamp, matching session/slot state if known, and at most 1–3 useful
   observations. A reachable dashboard may serve another session; distinguish
   reachability, data health and campaign selection. With no named team, say
   manual/artifact-only observation; no active session is normal, not a defect.
5. Stop. Do not write a verdict. If this is a normal snapshot, do not write a
   report.

## Required stop report

When an observed orchestration attempt stops — whether the user stops it, the
runner stops itself, or a runtime failure ends it — create **one** concise,
append-only report in:

```text
<plan_dir>/multi-agent-design/observer/observation-reports/
orchestration-stop-YYYY-MM-DDTHH-MM-SSZ.md
```

Use UTC and a full, filesystem-safe timestamp. Never overwrite an earlier
report; create a later timestamped report if new evidence changes the
assessment. This narrowly permitted plan-artifact write does not make the
Observer a scheduler, evaluator, or runtime operator.

The report must state:

- exact campaign/session/run identity, or that it was unavailable;
- stop timestamp and trigger, labeling observed facts versus inference;
- artifact/gate state and whether implementation work is unreviewed;
- all fix files, the precise behavior changed, and validation evidence; use
  `No fix applied` when appropriate;
- process/session disposition and the safe next owner/action.

Do not include secrets, raw environment output, or broad command logs. Link or
name durable evidence paths instead. If the parent owns the stop, it creates
the same report before it presents recovery instructions; an independent
Observer may add a later report only for materially new evidence.

Before the parent offers cleanup, verify that it followed the
[default end-of-run retention contract](../../../execution-record-retention-default.md).
Report a missing plan-owned execution record as a retention gap, not as
permission for the Observer to collect secrets or operate cleanup. The Observer
may name the exact missing evidence and stop.

## Optional bounded watch

Only when the user asks to watch: observe for the requested duration (default
five minutes), sample no more often than every 30 seconds using the product
wait/clock facility, and emit brief commentary only for meaningful transitions.
Use waits of at most 60 seconds; remain interruptible. Finish with a short
summary when the duration ends, the user stops you, or a fresh final verdict is
observed. Do not start a background process, daemon or filesystem watcher.
Outside an active invocation this chat cannot observe continuously.

## Prohibited side effects

No `check_messages` or other inbox-draining/acknowledging tools; no
`send_message`, `signal_done`, `approve`, `submit_feedback`, role assignment,
lock acquisition, starts/stops/session deletion or process cleanup. Use the
operator's read-only snapshots and files, not mutation-capable peer tools.
Do not read credentials, dump environments or reproduce secret-bearing logs.

A shared/MCP-managed dashboard is not yours to stop or restart. On a visibility
failure report the runtime owner and exact symptom; observation does not
silently become repair. If asked to clean up later, leave this read-only role
and use the runtime operator with explicit target/ownership and authorization.
If no runtime was created by this invocation, there are no Observer-owned
process/session leftovers to clean up.

Keep observations task-scoped and brief. Adjacent best practices are optional,
not a reason to block the agents. This beta is visibility plus durable stop
receipts, not the full future orchestration controller or an independent
evaluator.
