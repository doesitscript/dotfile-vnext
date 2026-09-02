---
title: Implementer role documentation
role: implementer
status: active
owner: codex-framework
last_reviewed_at: 2026-09-02
skill_entrypoint: multi-agent-implementer
---

# Implementer role documentation

This is the **implementer-side** contract: what you do, what you own, which
skills to load, and how the 2026-09-02 codex multi-terminal session matured this
pattern.

## Role definition

You are the **correcting implementer**:

- Fix repo code, Ansible, plan README contracts, and receipts.
- Apply live on managed hosts when promotion scope requires it.
- Wait for **evaluator-authored** sign-off before claiming the loop is done.

You are **not** the evaluator. You do not grade your own homework.

## Skill entry point (conversation bootstrap)

**Skill:** `multi-agent-implementer`  
**Path:** `skills/multi-agent/multi-agent-implementer/SKILL.md`

### Minimum inputs

| Input | Required |
| --- | --- |
| User invokes the skill | yes |
| `plan_dir` | no — auto-detect if omitted |

### Boot sequence

1. Run plan resolution:

   ```bash
   bin/codex-env python skills/multi-agent/multi-agent-implementer/scripts/resolve_plan_dir.py --json
   ```

2. Read (mandatory, same session):
   - `skills/multi-agent/references/evaluator-implementer-partition.md`
   - `skills/multi-agent/references/implementer-good-bad-examples.md`
   - `skills/multi-agent/references/hrl-influences.md`

3. Emit boot line (`plan_dir`, `resolution`, `agent_role`, `stop_condition`).

4. Scan newest evaluator authority in `plan_dir` (see evaluator-role-documentation.md for filename patterns).

5. Route to child skills as needed.

## Child skills

| Skill | When |
| --- | --- |
| `multi-agent-implementer-lifecycle` | Phase unclear |
| `multi-agent-implementer-corrections` | New `feedback_*` or `AI-*-EVALUATION` findings |
| `multi-agent-implementer-folder-watch` | User wants background monitor |
| `multi-agent-implementer-closeout` | `ready_for_review_*` + `decision: approved` |
| `one-off-promotion-verify` | Promotion Ansible execute-complete |
| `complete-plan-lifecycle` | After sign-off, mark plan implemented |

## Continuous loop

```text
watch (optional) → evaluator file or user wake
  → read newest evaluator markdown
  → corrections (P1 first)
  → live verify + EXECUTION-RECEIPT update
  → EVALUATOR-WAIT-STATE (implementer section only)
  → WAIT — evaluator re-runs on its cadence
repeat until ready_for_review_* approved
  → closeout → stop watch
```

**Stop condition:** evaluator file `ready_for_review_by_evaluator_<timestamp>.md` with `decision: approved`, fresh verify this turn, no newer `feedback_*` with `not satisfactory`.

## Artifacts you may write

| Artifact | Purpose |
| --- | --- |
| `EXECUTION-RECEIPT.md` | Apply, verify, absent converge evidence |
| `EVALUATOR-WAIT-STATE.md` | Implementer status, sign-off pointer |
| Plan `README.md` | Contract rows, checklist, disposition ledger |
| Roles, playbooks, host_vars | Promotion implementation |
| `AI-CORRECTION-EVALUATION.md` finding rows | Mark **resolved** with evidence (not evaluator authorship) |

## Artifacts you must not write

| Artifact | Owner |
| --- | --- |
| `feedback_for_review_by_evaluator_*` | Evaluator |
| `waiting_for_review_by_evaluator_*` | Evaluator |
| `ready_for_review_by_evaluator_*` | Evaluator |

## Scripts you may run

| Script | Role |
| --- | --- |
| `scripts/watch_evaluator_folder.sh` | Implementer watch |
| `bin/codex-env ansible-playbook …` | Live apply/verify |
| `resolve_plan_dir.py` | Boot |

## Scripts you must not run

| Script | Why |
| --- | --- |
| `scripts/evaluator_simple_loop.sh` | Evaluator namespace — running it as implementer contaminates sign-off |

## Paired one-off skills (promotion context)

When the plan packet is a **one-off promotion**, also use:

- `one-off-promotion` — archive, roles, plan packet
- `one-off-promotion-verify` — execute-complete verification gate

These were promoted from `draft-one-off-*` to **`one-off-*`** (`status: reviewed`) during this maturation pass.

## Good work (calibration)

From codex multi-terminal promotion (2026-09-02):

- Removed `shell_config` bashrc.d sweep; role-owned absent paths
- Live absent converge via `-e …_state=absent` with file probes
- Fixed receipt section title to match evaluator grep (`absent converge`)
- Folder watch only; waited for `ready_for_review_by_evaluator_simple_2026-09-02T112907.md`
- Acknowledged evaluator interference when corrected; stopped driving evaluator

Full list: `skills/multi-agent/references/implementer-good-bad-examples.md`.

## Bad work (forbidden)

- Running `evaluator_simple_loop.sh` to escape the loop
- Self-sign-off without evaluator `ready_for_review_*`
- Skipping fresh verification on brief/handoff turns
- Killing evaluator processes to force a pass

## Verification gates (project + HRL)

- Superpowers `verification-before-completion` — every pass/complete claim this turn
- `docs/codex_framework/plan-verification-receipt.md` — obligation inventory
- HRL: `implementation-guides/agentskills/skill-scripting-quality-evaluation.md` — separate evaluator output from implementer fixes

## Maturation notes

- Parent skill `multi-agent-implementer` v1.1 includes **anti-escape gate**
- Workflow pattern registered as `trial` under `multi-agent/agent-workflow-registry`
- Second real plan run recommended before promoting skills to global-skills
