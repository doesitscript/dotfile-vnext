---
name: multi-agent-implementer-folder-watch
description: "Use when an implementer must monitor a plan folder for new evaluator markdown and wake on changes — runs watch_evaluator_folder.sh only. Do not run evaluator_simple_loop.sh or write evaluator feedback files."
license: MIT
version: "1.0.0"
author: "dotfile-vnext"
title: Multi-Agent Implementer Folder Watch
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
depends_on_skills: "multi-agent-implementer, multi-agent-implementer-corrections"
applies_to:
  - docs/plans
tags:
  - skill
  - multi-agent
  - implementer
  - watch
---

# Skill: Multi-Agent Implementer Folder Watch

Background **watch only** — detect evaluator file changes; hand off to corrections.

## When to use / not use

Use when:

- the user wants the implementer to keep working until evaluator sign-off
- `EVALUATOR-WAIT-STATE.md` says monitor until `ready_for_review_*`

Do **not** use to run or restart `evaluator_simple_loop.sh`.

## Inputs

| Input | Required |
| --- | --- |
| `plan_dir` | yes — contains `scripts/watch_evaluator_folder.sh` |
| `interval_sec` | optional — default 60 |

## Workflow

1. Confirm `ready_for_review_by_evaluator_*` with `decision: approved` does **not** already exist.
2. Start (or confirm running):

   ```bash
   docs/plans/<slug>/scripts/watch_evaluator_folder.sh
   ```

3. On `AGENT_LOOP_WAKE_evaluator-folder-watch`:
   - Re-list evaluator files (`AI-*`, `feedback_*`, `ready_*`)
   - If satisfactory sign-off → `multi-agent-implementer-closeout`
   - Else → `multi-agent-implementer-corrections`
4. Stop watcher after closeout.

## Outputs

- Watcher running with log at `.evaluator-watch.log`
- Implementer wakes only on evaluator-relevant file changes

## Validation

- [ ] `watch_evaluator_folder.sh` running; `evaluator_simple_loop.sh` not started by implementer

## Prohibited behavior

- Running, killing, or restarting evaluator loop to force pass
- Treating implementer edits to `README.md` / `EXECUTION-RECEIPT.md` as wake-worthy approval (watcher filters these)

## Progressive disclosure

- `skills/multi-agent/references/evaluator-implementer-partition.md`
