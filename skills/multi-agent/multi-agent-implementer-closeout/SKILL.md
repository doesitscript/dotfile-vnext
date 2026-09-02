---
name: multi-agent-implementer-closeout
description: "Use when ready_for_review_by_evaluator_* exists with decision approved — update EVALUATOR-WAIT-STATE.md, stop folder watch, optional handoff to complete-plan-lifecycle. Do not re-open corrections unless a newer not-satisfactory evaluator file appears."
license: MIT
version: "1.0.0"
author: "dotfile-vnext"
title: Multi-Agent Implementer Closeout
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
depends_on_skills: "multi-agent-implementer, complete-plan-lifecycle"
applies_to:
  - docs/plans
tags:
  - skill
  - multi-agent
  - implementer
  - closeout
---

# Skill: Multi-Agent Implementer Closeout

Close the implementer loop after **evaluator-authored** sign-off.

## When to use / not use

Use when:

- `ready_for_review_by_evaluator_<timestamp>.md` exists
- frontmatter includes `decision: approved` or `status: satisfactory`
- no **newer** `feedback_for_review_*` with `decision: not satisfactory` supersedes it

Do **not** use when only implementer believes work is done — evaluator file required.

## Inputs

| Input | Required |
| --- | --- |
| `plan_dir` | yes |
| `sign_off_file` | yes — path to ready stamp |

## Workflow

1. Read sign-off file; capture check matrix / timestamp.
2. Fresh verification probe this turn (Superpowers `verification-before-completion`).
3. Update `EVALUATOR-WAIT-STATE.md`:
   - `status: evaluator-signed-off`
   - `sign_off_file`, `sign_off_at`
   - remove stale “awaiting evaluator” prose
4. Stop `watch_evaluator_folder.sh` if running (`pkill -f watch_evaluator_folder.sh` scoped to plan).
5. Resolve open rows in `AI-CORRECTION-EVALUATION.md` to `resolved` with pointer to sign-off (implementer documentation only).
6. Hand off to `complete-plan-lifecycle` when user wants `lifecycle: implemented` / GitHub issue.

## Outputs

- Closed wait state
- Watcher stopped
- Optional plan lifecycle promotion

## Validation

- [ ] Sign-off file is evaluator-authored (`author: evaluator-simple` or equivalent)
- [ ] Fresh verify output recorded this turn

## Prohibited behavior

- Creating `ready_for_review_*` as implementer
- Closing loop on local grep simulation without evaluator file

## Progressive disclosure

- `skills/multi-agent/references/evaluator-implementer-partition.md`
- `skills/documentation/complete-plan-lifecycle/SKILL.md`
