---
status: active
owner: codex-framework
applies_to:
  - plan-promotion
  - paired-agent-plan-implementer
  - paired-agent-plan-evaluator
reference_plan: docs/plans/2026-09-03--multi-agent-orchestration-plan/
skill_entrypoint: paired-agent-plan-implementer
orchestration: external
---

# Evaluator–implementer loop (external orchestration)

## Purpose

Coordinate **plan packet work** when an independent evaluator must sign off
before the scoped campaign is complete. Typical use: plan promotion, framework
repair, skill-family audits tied to a plan folder.

**Framing:** role skills own cooperation and quality; an external orchestrator
(for example `multiagents` + Codex app-server) owns wakeups and turn
advancement. Plan-folder artifacts remain the durable audit trail, not the
scheduler. See
`docs/plans/2026-09-03--multi-agent-orchestration-plan/discussion/orchestration-agnostic-framing.md`.

## Triggers

- User starts a paired-agent campaign on a plan folder.
- Operator or orchestrator invokes `paired-agent-plan-implementer` or
  `paired-agent-plan-evaluator` for a single pass.
- Plan folder contains evaluator artifacts or implementer
  `review_ready_for_evaluator_*` files.

## Roles

### Implementer

- **Responsibility:** Repo fixes, live verification when required, receipts,
  accounting when the packet uses it.
- **Skill entry:** `paired-agent-plan-implementer` (global-skills)
- **Read/write boundary:** Implementation artifacts;
  `review_ready_for_evaluator_*`; never evaluator `feedback_*` / `waiting_*` /
  `ready_*`.
- **Handoff artifact:** `review_ready_for_evaluator_<timestamp>.md`
- **Completion signal:** None alone — waits for evaluator sign-off across
  *later* invocations.
- **Must not:** Poll, folder-watch, or self-schedule the next evaluator turn.

### Evaluator

- **Responsibility:** Evidence-backed review; emit one of `feedback` /
  `waiting` / `ready` per invocation.
- **Skill entry:** `paired-agent-plan-evaluator` (global-skills)
- **Read/write boundary:** Evaluator-owned artifacts only.
- **Handoff artifact:** `feedback_*` or `waiting_*` (continue) or `ready_*`
  (terminate).
- **Completion signal:** `ready_for_review_by_evaluator_*` with evidence.
- **Must not:** Implementer work, self-schedule hidden rechecks, or own
  orchestration transport.

### Orchestrator (external)

- **Responsibility:** Session continuity; route implementer ↔ evaluator after
  durable handoff events; Codex `thread/start`, `turn/start`, `turn/steer` (or
  equivalent) when Codex-first.
- **Must not:** Redefine evaluator quality rules or replace plan-folder audit
  artifacts.

## Deprecated / non-primary paths

The following may still exist as historical helpers but are **not** the
preferred steady-state orchestration model:

- Implementer-owned folder watch scripts as the required wake mechanism
- Role-managed polling loops that keep a skill "alive" as its own scheduler
- Treating chat `continue` as the designed control plane

Document those as fallback/manual operator aids only.

## Parallel work

- Research while waiting for the next orchestrated pass.
- Skill validators after implementer edits.
- Read-only plan/inventory probes.

## Serialized work

- Implementer corrections before evaluator re-review.
- Live mutating apply after read-only preview when applicable.
- Closeout only after evaluator `ready_*`.

## Gates

| Gate | Input | Pass | Fail / send-back |
| --- | --- | --- | --- |
| Bootstrap | `plan_dir` resolved | Boot line emitted | Ambiguity listed; one question |
| Implementer pass | Scope / feedback | `review_ready_for_evaluator_*` written; stop | Open work without handoff |
| Evaluator pass | Newest review-ready + packet | One evaluator artifact | Wrong ownership / no evidence |
| Sign-off | `ready_for_review_*` | Evidence closes whole scoped scenario | Write feedback/waiting instead |
| Closeout | Sign-off + fresh verify | Orchestrator releases session | Do not claim complete |

**Fallback:** If orchestrator unavailable, operator may manually invoke each
skill pass. Implementer must not self-sign-off.

## Artifacts

| Artifact | Owner |
| --- | --- |
| `review_ready_for_evaluator_*` | Implementer |
| `coordination/implementation-accounting.md` | Implementer (when used) |
| `EXECUTION-RECEIPT.md` / verification receipts | Implementer sections |
| `EVALUATOR-WAIT-STATE.md` | Evaluator |
| `feedback_*` / `waiting_*` / `ready_*` | Evaluator |
| Plan packet README / diagrams | Shared packet; ownership per plan rules |

## Completion rule

The **loop** is complete only when:

1. Evaluator `ready_for_review_by_evaluator_*` exists with evidence-backed
   approval for the **whole** scoped scenario.
2. Fresh verification ran in the closeout context when the work type requires it.
3. Orchestrator (or operator) has released / stopped the paired session.

Plan `lifecycle: implemented` remains a separate step (`complete-plan-lifecycle`).

## Failure rule

- Implementer authors evaluator sign-off → invalid; stop and correct.
- Validator/tool failure → narrow scope, retry; do not self-sign-off.
- Repeated identical blockers → research before next code change.
- Ambiguous ownership or missing handoff artifacts → fail the validation stage.

## Documentation

- Global skills: `paired-agent-plan-implementer`, `paired-agent-plan-evaluator`,
  `paired-agent-feedback-artifacts`
- Plan packet:
  `docs/plans/2026-09-03--multi-agent-orchestration-plan/`
- Workflow package:
  `docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/`
