---
title: Evaluator role documentation
role: evaluator
status: active
owner: codex-framework
last_reviewed_at: 2026-09-02
note: Evaluator-reviewed and extended after the reference run; keep plan-local paired docs aligned with this durable package.
---

# Evaluator role documentation

This documents the **evaluator side** of the evaluator–implementer loop: what
owns review, what files mean, and what the implementer must never impersonate.

Written after the codex multi-terminal promotion reference run. Extend when the
evaluator agent or operator process changes.

The durable package lives here; each reference plan packet should also keep a
plan-local `documentation/` folder with paired `*--implementer.md` and
`*--evaluator.md` files.

## Role definition

The **evaluator**:

- Judges whether the plan packet + repo state satisfy automated and prose gates.
- Emits timestamped markdown under the plan folder.
- Writes **sign-off** only when checks pass.

The evaluator does **not**:

- Replace implementer live Ansible runs with “should pass” reasoning.
- Mutate roles/playbooks as a shortcut without implementer evidence (audit docs may list findings; implementer applies fixes).

## Evaluator modes in this repo

| Mode | Mechanism | Output files |
| --- | --- | --- |
| **Evaluator-simple loop** | `scripts/evaluator_simple_loop.sh` | `feedback_*`, `waiting_*`, `ready_*` |
| **AI audit evaluations** | Human or agent-authored | `AI-CORRECTION-EVALUATION.md`, `AI-*-EVALUATION.md` |

Both can be active on one plan packet. Implementer applies **P1-first** from AI audits; **sign-off authority** for the simple loop is `ready_for_review_by_evaluator_*`.

## Evaluator-simple loop

### Operator entry

```bash
cd docs/plans/<slug>/
./scripts/evaluator_simple_loop.sh
# Optional: EVALUATOR_SIMPLE_INTERVAL_SEC=3600
```

Writes:

- `.evaluator-simple-loop.pid`
- `.evaluator-simple-loop.state`
- `.evaluator-simple-loop.log`

Stops when it writes a satisfactory `ready_for_review_by_evaluator_<timestamp>.md`.

### Check categories (codex multi-terminal reference)

| Check | Example |
| --- | --- |
| `skills-metadata` / `skills-catalog` | Project skill validators |
| `plan-update-behavior` | Self-contained Apply tags in README |
| `plan-undo-contract` | `real removal path` + `bashrc.d` in README |
| `shell-config-static-bash-ownership` | No generic bashrc.d sweep in shell_config |
| `fzf-absent-static-bash` | Literal `shell-completion.bash` in absent.yml |
| `codex-absent-static-bash` | `codex-multi-terminal.bash` near `state: absent` |
| `receipt-undo-verification` | `absent converge` or `Undo verification` in receipt |
| `plan-undo-closeout` | Checklist row `Truthful undo … done` |

Implementer must match **grep literals** in receipts/contracts — not paraphrase.

## Filename conventions

```text
feedback_for_review_by_evaluator_simple_<YYYY-MM-DDTHHMM>.md
  decision: not satisfactory
  Open blockers + check matrix

waiting_for_review_by_evaluator_simple_<YYYY-MM-DDTHHMM>.md
  decision: not yet satisfactory
  No source change since last cycle

ready_for_review_by_evaluator_simple_<YYYY-MM-DDTHHMM>.md
  decision: approved
  status: satisfactory
  Passing checks table — LOOP MAY CLOSE
```

**Newest timestamp wins** unless a newer `feedback_*` supersedes an older `ready_*`.

## AI audit files

| File | Typical content |
| --- | --- |
| `AI-CORRECTION-EVALUATION.md` | P1–Pn findings, disposition, plan contract gaps |
| `AI-DRAFT-SKILL-FAMILY-EVALUATION.md` | Skill pack audit (may lag implementer fixes) |

Implementer may mark finding rows `resolved` with evidence pointers after fixes.
Evaluator-simple sign-off remains the closeout gate for the promotion loop unless
the user defines otherwise.

## Implementer boundary (evaluator perspective)

Implementer **may**:

- Run `watch_evaluator_folder.sh` to detect new evaluator files
- Update `EXECUTION-RECEIPT.md`, plan README, Ansible, wait-state implementer sections

Implementer **must not**:

- Run `evaluator_simple_loop.sh`
- Author `feedback_*`, `waiting_*`, or `ready_*`
- Kill evaluator PIDs to re-run for a pass

Violation invalidates trust in sign-off. See implementer-good-bad-examples.md.

## Folder watch (implementer tool)

`scripts/watch_evaluator_folder.sh`:

- Polls plan folder (default 60s)
- Filters evaluator-relevant markdown (not implementer-only edits to README/receipt)
- Emits `AGENT_LOOP_WAKE_evaluator-folder-watch` for agent resume

Evaluator operators do not need this script; it exists for implementer sessions.

## Completion signal (evaluator)

The loop is **satisfactory** when:

1. `ready_for_review_by_evaluator_*` exists with `decision: approved`
2. Check matrix shows all in-scope rows pass
3. No newer contradictory `feedback_*`

## Future maturation

- [ ] Durable launchd plist operator doc (registration was blocked in reference session)
- [ ] Evaluator agent skill pack (separate from implementer family)
- [ ] Noise control for high-volume `waiting_*` files
- [ ] Second plan packet trial → promote workflow `trial` → `active`
