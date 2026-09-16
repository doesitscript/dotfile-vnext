---
title: Plan 22 acceptance gap — evaluator instructions for implementer
role: evaluator
created_at: "2026-09-16T00:52:00-05:00"
plan_dir: docs/plans/2026-09-13--get-back-ansible-best-practice
prior_pass: feedback_for_review_by_evaluator_20260916-004711.md
required_closeout_artifact: plan-22_acceptance_gap_implementer.md
status: open
next_actor: implementer
acceptance_estimate_pct: 72
target_pct: 90
---

# plan-22_acceptance_gap_evaluator

## Operator acceptance bar (source of truth for this pass)

The package must:

1. Cover the **top six commissioned models** the project has been implementing.
2. Run a **full suite against all of them** when asked.
3. **Target one model** when asked.
4. Deliver the **same TDD / human-receipt level** as global skill
   `homelab-litellm-model-lane-pytest` (JOURNEY/WHY/USER/EXPECTED/ACTUAL on every
   pass/fail; tools steps when tools are claimed; agent must not report only
   `N passed`).

Evaluator estimate vs that bar: **~72%**. Target for this pass: **~90%**
(not perfection). Prior Plan 22 “blocking items” PASS does **not** mean the
operator acceptance bar is met.

## What already works (do not rebuild)

- Package owns harness; draft skill is thin SHIM.
- Six enabled lanes in `manifests/default.yml`:
  `qwen3-coder-30b-a3b`, `qwen2.5-coder-14b`, `qwen2.5-coder-7b`,
  `qwen2.5-coder-1.5b-base-q8_0`, `nomic-embed-text`, `gpt-oss-20b`.
- `just unit` / `just live -k …` / `just test` work.
- `--lane-filter` and pytest `-k` can target one model.
- Receipt format exists and smoke prints full JOURNEY blocks.
- Vault `vault-env.toml` → `just sync-env` works.

## Gaps to close for ~90%

### 1. Make `commissioned-six` real (blocking for acceptance)

Today `--profile commissioned-six` is just `not infrastructure` (same as
`nightly`). It must pin the six commissioned IDs (enabled subset), not “all
live tests.”

Prove:

```bash
uv run homelab-model-lane-pytest --profile commissioned-six
# and
uv run homelab-model-lane-pytest --profile smoke --lane-filter qwen3-coder-30b-a3b
```

Document both in the `-draft` SHIM and package README as the operator paths
for “all six” vs “one model.”

### 2. Full-suite operator path must be obvious (blocking)

One documented primary command for “run everything applicable for the six”:

- Prefer: `just run --profile commissioned-six` **or** fix `just run` arg
  forwarding so `just run -- --profile commissioned-six` works.
- Today `just run -- --help` / `just run -- --profile …` is broken (pytest
  sees `--help` / `--profile` as files). Fix the CLI/`just run` contract.

### 3. Skill-parity TDD surface (blocking for “same level”)

Bring package behavior closer to global skill without copying the whole skill
`lib/` tree:

- Keep JOURNEY/WHY/USER/EXPECTED/ACTUAL on **every** pass and fail (already
  mostly true — preserve).
- For tools journeys: preserve separate invoke / execute / follow-up receipts
  when tools run (match skill intent).
- Add a short **end-of-run grouped summary** (lane × scenario × PASS/FAIL),
  matching the skill’s “grouped summary” expectation.
- Align journey prose / tool user prompt closer to
  `global-skills/.../references/homelab-default-lanes.yml` where the package
  scenarios are the same IDs (`ping-pong`, `explain-add-function`,
  `read-hosts-tool`, FIM).

Honest capability gating stays: do **not** fake tools green for `gpt-oss-20b`.
Do document which of the six get chat / tools / fim / embed in the SHIM.

### 4. Prove the matrix with fresh receipts (blocking)

After fixes, capture into the plan folder (agent paste — human does not type):

1. One-model smoke: `--lane-filter qwen3-coder-30b-a3b` (or `-k`)
2. Full commissioned-six run (or documented subset if a lane is still
   capability-gated — say so explicitly)

Paste full JOURNEY blocks for at least one PASS per capability class covered
(chat smoke, tools if run, fim, embed) into
`plan-22_execution_note.md` or a sibling receipt file.

## Out of scope

- Promoting `-draft` → stable global skill
- Inventing tools success for models that return empty tool calls
- Ansible inventory import at pytest import time (hardcoded SSOT subset OK
  if documented)
- Perfect parity with every Codex CLI suite path in the global skill

## When finished — mandatory closeout

Create:

`docs/plans/2026-09-13--get-back-ansible-best-practice/plan-22_acceptance_gap_implementer.md`

Address **to the evaluator**. Include commands, receipt paths, what % you
believe you reached, and `ready for evaluator re-review: yes|no`.

Also:

`review_ready_for_evaluator_<YYYYMMDD-HHMMSS>.md`

## Done when

- [ ] `commissioned-six` actually selects the six commissioned models
- [ ] `just run --profile …` (or fixed equivalent) works for all-six and one-model
- [ ] SHIM + README document those two operator paths
- [ ] Grouped end summary + skill-parity receipt behavior preserved/improved
- [ ] Fresh receipt evidence pasted in plan folder
- [ ] No secrets leaked
