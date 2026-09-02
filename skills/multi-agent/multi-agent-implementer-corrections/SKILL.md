---
name: multi-agent-implementer-corrections
description: "Use when evaluator feedback or AI-CORRECTION-EVALUATION directives require repo fixes on a plan packet. Apply findings in severity order, live-verify, update EXECUTION-RECEIPT.md — then wait for evaluator re-run. Do not run the evaluator or write evaluator sign-off files."
license: MIT
version: "1.0.0"
author: "dotfile-vnext"
title: Multi-Agent Implementer Corrections
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
depends_on_skills: "multi-agent-implementer, homelab-ansible-first-entry"
applies_to:
  - docs/plans
  - ansible
tags:
  - skill
  - multi-agent
  - implementer
  - corrections
---

# Skill: Multi-Agent Implementer Corrections

Apply evaluator findings as an **implementer** — code, docs, and live evidence only.

## When to use / not use

Use when a new or updated file exists:

- `feedback_for_review_by_evaluator_*` with open blockers
- `AI-CORRECTION-EVALUATION.md` or `AI-*-EVALUATION.md` with open findings
- `AI-CORRECTION-EVALUATION.md` P1–Pn table (apply **P1 first**)

Do **not** use when the newest authority is `ready_for_review_*` with `decision: approved` — use `multi-agent-implementer-closeout`.

## Inputs

| Input | Required |
| --- | --- |
| `plan_dir` | yes |
| `finding_order` | optional — default P1→Pn then check matrix rows |

## Workflow

1. Read newest evaluator feedback + any `AI-*-EVALUATION.md` directives.
2. Build an obligation list (finding ID → repo path → prove command).
3. Implement fixes (Ansible via `homelab-ansible-first-entry` when mutating hosts).
4. Update plan `README.md` contract rows if evaluator checks reference them.
5. Append **fresh** evidence to `EXECUTION-RECEIPT.md` (include evaluator grep literals when known).
6. Run `bin/codex-env python skills/scripts/validate_metadata.py` and `validate_skills_catalog.py` when skills changed.
7. Load Superpowers `verification-before-completion`; run prove commands **this turn**.
8. Update `EVALUATOR-WAIT-STATE.md` implementer section only — **not** evaluator decision.
9. Stop — wait for evaluator; do not author `ready_for_review_*`.

## Outputs

- Repo fixes with captured command output
- Updated receipt / plan checklist evidence
- Implementer status note in `EVALUATOR-WAIT-STATE.md`

## Validation

- [ ] Every open blocker addressed or explicitly blocked with probe evidence
- [ ] No evaluator loop invoked
- [ ] Fresh verification output attached this turn

## Failure boundaries

- Three informed fix attempts on same failing step → alternate path per `AGENTS.md` §9a
- Cannot satisfy evaluator grep literal → fix wording in receipt/plan, not evaluator script

## Prohibited behavior

- `evaluator_simple_loop.sh`, `ready_for_review_*`, `feedback_for_review_*` authorship
- Marking plan `implemented` without evaluator sign-off when loop is active
- Claiming satisfactory based on local grep simulation

## Progressive disclosure

- `skills/multi-agent/references/evaluator-implementer-partition.md`
- `skills/multi-agent/references/implementer-good-bad-examples.md`
- Parent: `multi-agent-implementer`
