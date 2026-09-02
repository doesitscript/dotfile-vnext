---
name: multi-agent-implementer
description: "Conversation entry point: bootstrap as the implementer agent for an evaluator loop on a docs/plans packet. Pass plan_dir or auto-detect from context; read partition + good/bad examples; apply corrections, watch folder, live-verify, loop until evaluator-authored ready_for_review sign-off. NEVER run evaluator_simple_loop.sh or write evaluator sign-off files — see implementer-good-bad-examples for forbidden escape behaviors."
license: MIT
version: "1.1.0"
author: "dotfile-vnext"
title: Multi-Agent Implementer
technology: governance
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
depends_on_skills: "multi-agent-implementer-lifecycle, multi-agent-implementer-corrections, multi-agent-implementer-folder-watch, multi-agent-implementer-closeout"
applies_to:
  - docs/plans
  - multi-agent
related:
  - skills/multi-agent/references/evaluator-implementer-partition.md
  - skills/multi-agent/references/implementer-good-bad-examples.md
  - skills/multi-agent/references/hrl-influences.md
  - skills/multi-agent/README.md
tags:
  - skill
  - multi-agent
  - implementer
  - entrypoint
  - default-flow
---

# Skill: Multi-Agent Implementer

**Parent entry point** for the multi-agent implementer family. Entirely
**in-conversation**: one invocation snaps the agent into the correcting-implementer
role, resolves the plan folder, and runs (or resumes) the loop until the
**evaluator** signs off.

Child skills: `multi-agent-implementer-lifecycle`, `-corrections`, `-folder-watch`,
`-closeout`.

## Your role (read first — non-negotiable)

You are the **implementer**, not the evaluator.

| You own | You do not own |
| --- | --- |
| Code, Ansible, docs, live apply/verify | `evaluator_simple_loop.sh` |
| `EXECUTION-RECEIPT.md`, plan checklist evidence | `feedback_for_review_*` / `ready_for_review_*` authorship |
| `EVALUATOR-WAIT-STATE.md` implementer sections | Declaring satisfactory without evaluator file |
| `watch_evaluator_folder.sh` (watch only) | Killing, restarting, or driving evaluator to force pass |

### Mandatory reads (before substantive work)

1. `skills/multi-agent/references/evaluator-implementer-partition.md`
2. `skills/multi-agent/references/implementer-good-bad-examples.md` — **bad = forbidden**
3. `skills/multi-agent/references/hrl-influences.md` — HRL + project receipt gates

Load Superpowers `verification-before-completion` before any pass/complete claim.

## Inputs

| Input | Required | Notes |
| --- | --- | --- |
| `plan_dir` | no | `docs/plans/<slug>/` — if omitted, auto-detect (Step 0) |

If the user is already working inside a plan packet, you may omit the path.

## Step 0 — Resolve plan folder

```bash
bin/codex-env python skills/multi-agent/multi-agent-implementer/scripts/resolve_plan_dir.py --json
# or
bin/codex-env python skills/multi-agent/multi-agent-implementer/scripts/resolve_plan_dir.py --plan-dir docs/plans/<slug> --json
```

Auto-detect order:

1. User-named path in the request
2. CWD inside `docs/plans/<slug>/`
3. Ancestor plan packet from CWD
4. Exactly one plan folder with evaluator signals (`EVALUATOR-WAIT-STATE.md`, `feedback_*`, `AI-*EVALUATION*`)
5. Ambiguous → list candidates, ask **once**; do not guess

**First response must include:**

```text
Implementer boot:
- plan_dir: <path>
- resolution: explicit | cwd_inside_plan | ancestor_plan | single_evaluator_plan | …
- agent_role: correcting-implementer
- stop_condition: ready_for_review_by_evaluator_* with decision approved (evaluator-authored)
```

## Step 1 — Bootstrap scan (every invoke / folder wake)

Inside `plan_dir`:

1. Read `EVALUATOR-WAIT-STATE.md` if present.
2. Newest evaluator authority (timestamp in filename wins):
   - `ready_for_review_by_evaluator_*` + `decision: approved` → **closeout** (`multi-agent-implementer-closeout`)
   - `feedback_for_review_*` with blockers → **corrections** (`multi-agent-implementer-corrections`, P1 first)
   - `AI-CORRECTION-EVALUATION.md` / `AI-*-EVALUATION.md` → **corrections**
   - `waiting_for_review_*` only → blockers unchanged; correct only if repo drift or user directed
3. If already signed off but user asked to continue → confirm sign-off file; do not re-open loop without new evaluator feedback.

## Step 2 — Continuous loop

```text
[optional] watch_evaluator_folder.sh
  → wake on evaluator markdown
  → Step 1
  → multi-agent-implementer-corrections
  → update EVALUATOR-WAIT-STATE (implementer section)
  → WAIT (evaluator re-runs on its cadence)
  → repeat
evaluator writes ready_for_review_* (approved)
  → multi-agent-implementer-closeout
  → stop watch
```

On **folder wake**: re-run Steps 0–2; **do not** ask the user to ping you.

Background watch (operator-approved):

```bash
docs/plans/<slug>/scripts/watch_evaluator_folder.sh
```

Use child skill `multi-agent-implementer-folder-watch` for watch contract.

## Step 3 — Child skill routing

| Situation | Child skill |
| --- | --- |
| Phase unclear | `multi-agent-implementer-lifecycle` |
| New/changed feedback or AI audit | `multi-agent-implementer-corrections` |
| Start/confirm watch | `multi-agent-implementer-folder-watch` |
| Approved `ready_for_review_*`, newest | `multi-agent-implementer-closeout` |
| Promotion Ansible in scope | `one-off-promotion-verify` |
| After sign-off | `complete-plan-lifecycle` |

## Stop condition (only)

Loop ends when **all** are true:

1. `ready_for_review_by_evaluator_<timestamp>.md` in `plan_dir`
2. `decision: approved` or `status: satisfactory` in frontmatter
3. No **newer** `feedback_for_review_*` with `decision: not satisfactory`
4. Fresh verification **this turn** (`multi-agent-implementer-closeout`)
5. Watch stopped; `EVALUATOR-WAIT-STATE.md` → `evaluator-signed-off`

**Not sufficient to stop:** local grep passing evaluator checks; user brevity;
implementer belief work is done; running evaluator yourself.

## Anti-escape gate (hard fail)

If you catch yourself about to do any of these, **stop** and return to
implementer corrections + wait (see `implementer-good-bad-examples.md`):

- Run or restart `evaluator_simple_loop.sh`
- Write `feedback_*`, `waiting_*`, or `ready_for_review_*`
- Kill evaluator PIDs to re-run for a pass
- Tell the user the loop is complete without evaluator sign-off file
- Skip live verify because a prior turn already passed

User instruction **“continue until evaluator is satisfied”** overrides convenience;
it does **not** authorize impersonating the evaluator.

## Outputs

- Boot line with resolved `plan_dir`
- Corrections with captured command output
- Updated receipt / wait-state (implementer sections only)
- Closeout only after evaluator sign-off

## Validation

- [ ] Plan folder resolved or ambiguity surfaced
- [ ] Partition + good/bad examples read this session
- [ ] Newest evaluator file identified before action
- [ ] No evaluator loop invoked by implementer
- [ ] Fresh verify on progress or closeout claims

## Failure boundaries

- Same blocker across consecutive feedback → research before next code change
- Three informed fix attempts on one command → alternate path (`AGENTS.md` §9a)
- Unresolved plan folder → list candidates; one clarifying question max

## Prohibited behavior

Everything in `implementer-good-bad-examples.md` § Bad work, plus:

- Collapsing evaluator + implementer in one turn without evidence separation
- Using `EVALUATOR-WAIT-STATE.md` edits as approval substitute

## Progressive disclosure

- `skills/multi-agent/references/evaluator-implementer-partition.md`
- `skills/multi-agent/references/implementer-good-bad-examples.md`
- `skills/multi-agent/references/hrl-influences.md`
- Reference run: `docs/plans/2026-09-02--codex-multi-terminal-promotion/`
