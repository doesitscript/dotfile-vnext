---
name: multi-agent-implementer-lifecycle
description: "Use when an implementer agent works alongside a separate evaluator (human or AI) on a plan packet — routes to corrections, folder watch, or closeout. Prefer parent skill multi-agent-implementer for conversation bootstrap. Do not use when no evaluator surface exists or when you are the evaluator."
license: MIT
version: "1.0.0"
author: "dotfile-vnext"
title: Multi-Agent Implementer Lifecycle
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
applies_to:
  - docs/plans
  - multi-agent
related:
  - skills/multi-agent/references/evaluator-implementer-partition.md
  - docs/plans/2026-09-02--codex-multi-terminal-promotion/EVALUATOR-WAIT-STATE.md
tags:
  - skill
  - multi-agent
  - implementer
  - evaluator
---

# Skill: Multi-Agent Implementer Lifecycle

Phase router for the **implementer** role. For conversation bootstrap (resolve
plan folder + continuous loop), use parent skill **`multi-agent-implementer`**
first.

## When to use / not use

Use when:

- a plan folder has or will have evaluator feedback files
- the user wants work to continue until evaluator sign-off
- you are the **implementing** agent, not the evaluator

Do **not** use when:

- no evaluator artifacts exist and none are planned
- you are asked to **run** or **drive** `evaluator_simple_loop.sh`

## Family members

| Phase | Skill |
| --- | --- |
| New evaluator file landed | `multi-agent-implementer-corrections` |
| Start/maintain watch only | `multi-agent-implementer-folder-watch` |
| `ready_for_review_*` approved | `multi-agent-implementer-closeout` |

## Inputs

| Input | Required |
| --- | --- |
| `plan_dir` | yes — `docs/plans/<slug>/` |
| `evaluator_mode` | optional — `simple-loop` \| `ai-audit` \| `both` |

## Workflow

1. Read `skills/multi-agent/references/evaluator-implementer-partition.md`.
2. List evaluator files in `plan_dir` (exclude implementer-only docs unless cited by evaluator).
3. If `ready_for_review_by_evaluator_*` with `decision: approved` exists and is newest authority → `multi-agent-implementer-closeout`.
4. Else if new `feedback_*` or `AI-*-EVALUATION` → `multi-agent-implementer-corrections`.
5. Else if user asked to monitor → `multi-agent-implementer-folder-watch`.

## Handoffs

- Corrections complete → wait for evaluator; optionally keep folder watch running
- Closeout → `one-off-promotion-verify` or `complete-plan-lifecycle` when promotion scope

## Outputs

- Correct phase skill executed
- No evaluator files authored by implementer

## Validation

- [ ] Implementer did not run evaluator loop
- [ ] Newest evaluator authority identified before claiming done

## Failure boundaries

- Ambiguous evaluator messages → state blockers; do not self-sign-off
- Repeated identical blockers → research before next code change (see partition doc)

## Prohibited behavior

- Running `evaluator_simple_loop.sh` or writing `feedback_for_review_*` / `ready_for_review_*`
- Killing evaluator processes to re-run them for a pass
- Treating `EVALUATOR-WAIT-STATE.md` edits as evaluator approval

## Progressive disclosure

- `skills/multi-agent/references/evaluator-implementer-partition.md`
- `skills/multi-agent/README.md`
