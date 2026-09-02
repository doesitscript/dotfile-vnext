---
status: trial
owner: codex-framework
applies_to:
  - plan-promotion
  - multi-agent-implementer
  - evaluator-simple-loop
reference_plan: docs/plans/2026-09-02--codex-multi-terminal-promotion/
skill_entrypoint: multi-agent-implementer
---

# Evaluator–implementer correction loop

## Purpose

Coordinate **plan packet corrections** when an independent evaluator (automated
loop and/or AI audit files) must sign off before the work is considered complete.
Typical use: one-off promotion, framework repair plans, skill-family audits tied
to a plan folder.

## Triggers

- User says continue until evaluator is satisfied / approved / done.
- Plan folder contains `EVALUATOR-WAIT-STATE.md` or evaluator feedback files.
- Promotion or correction work with `feedback_for_review_by_evaluator_*` present.
- User invokes skill `multi-agent-implementer`.

## Roles

### Implementer (correcting agent)

- **Responsibility:** Repo fixes, live Ansible, receipts, plan contract rows.
- **Read/write boundary:** All implementation artifacts; implementer sections of wait-state.
- **Allowed tools:** Ansible via `bin/codex-env`, folder watch script, skill validators.
- **Forbidden tools:** `evaluator_simple_loop.sh`; authoring `feedback_*` / `ready_*`.
- **Handoff artifact:** Updated `EXECUTION-RECEIPT.md`, corrected roles/docs.
- **Completion signal:** None alone — waits for evaluator sign-off.
- **Skill entry:** `multi-agent-implementer`

### Evaluator-simple (automated loop or operator)

- **Responsibility:** Run check matrix; emit timestamped feedback or sign-off.
- **Read/write boundary:** `feedback_*`, `waiting_*`, `ready_*`; evaluator logs.
- **Allowed tools:** `evaluator_simple_loop.sh`, project validators as coded in script.
- **Handoff artifact:** `ready_for_review_by_evaluator_*` when satisfactory.
- **Completion signal:** `decision: approved` in ready file.

### Evaluator-audit (AI markdown)

- **Responsibility:** Durable finding lists (`AI-CORRECTION-EVALUATION.md`, etc.).
- **Handoff artifact:** P1–Pn findings for implementer.
- **Completion signal:** Findings resolved in repo + confirmed by evaluator-simple.

### Folder watch (implementer aid)

- **Responsibility:** Wake implementer on evaluator file changes.
- **Allowed:** `watch_evaluator_folder.sh` only.

## Parallel work

- HRL / Context7 research while waiting for evaluator cadence.
- Skill validator runs after implementer edits.
- Read-only plan/inventory probes.

## Serialized work

- Implementer corrections before evaluator re-run.
- Live mutating Ansible after read-only preview.
- Closeout only after `ready_for_review_*`.

## Gates

| Gate | Input | Pass | Fail / send-back |
| --- | --- | --- | --- |
| Bootstrap | `plan_dir` resolved | Boot line emitted | Ambiguity listed; one question |
| Corrections | Newest `feedback_*` or AI audit | Blockers addressed + fresh verify | Open blockers remain |
| Evaluator boundary | Implementer session | No evaluator loop run | Stop; document interference |
| Sign-off | `ready_for_review_*` | `decision: approved`, newest authority | Continue loop |
| Closeout | Sign-off + fresh verify | Wait-state signed off, watch stopped | Do not claim complete |

**Fallback:** If evaluator loop unavailable, leave unsigned; implementer documents blocked state — does not self-sign-off.

## Artifacts

| Artifact | Owner |
| --- | --- |
| `EXECUTION-RECEIPT.md` | Implementer |
| `EVALUATOR-WAIT-STATE.md` | Implementer (status); evaluator (sign-off ref) |
| `feedback_*` / `ready_*` | Evaluator-simple |
| `AI-*-EVALUATION.md` | Evaluator-audit |
| `AFTER-ACTION-REPORT-*.md` | Implementer/steward |
| `documentation/*--implementer.md` | Implementer or durable pointer |
| `documentation/*--evaluator.md` | Evaluator |

## Completion rule

Coordinator/implementer may report the **loop** complete only when:

1. Evaluator-simple `ready_for_review_by_evaluator_*` with `decision: approved` exists.
2. Fresh verification probes ran in the closeout turn.
3. Folder watch stopped; wait-state shows `evaluator-signed-off`.

Plan `lifecycle: implemented` is a **separate** step (`complete-plan-lifecycle`).

## Failure rule

- Implementer runs evaluator → invalidates trust; stop and acknowledge per good/bad examples.
- Validator/tool failure → narrow scope, retry; do not self-sign-off.
- Repeated identical blockers → research before next code change.

## Documentation

- `docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/` — role docs + AAR
- `docs/codex_framework/multi-agent/agent-workflow-registry/patterns/evaluator-implementer-loop.md` — pattern contract
- `docs/plans/<slug>/documentation/` — plan-local paired documentation packet
- `skills/multi-agent/references/` — skill-pack meditation and examples
