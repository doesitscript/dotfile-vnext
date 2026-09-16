---
title: Plan 22 next pass — evaluator instructions for implementer
role: evaluator
created_at: "2026-09-15T23:45:00-05:00"
plan_dir: docs/plans/2026-09-13--get-back-ansible-best-practice
implements_response_to: feedback_for_review_by_evaluator_20260915-233237.md
required_closeout_artifact: plan-22_next_pass_implementer.md
status: closed_pass
next_actor: none
closed_by: feedback_for_review_by_evaluator_20260916-004711.md
---

# plan-22_next_pass_evaluator

## Implementer boot (mandatory)

You are the **implementer**. Start coding **now**. Do **not**:

- acknowledge and wait
- treat this as a handoff summary for someone else
- ask the human to paste receipt blocks
- switch into evaluator mode

Read the three authority files below, then execute Required work 1–3, then write
the closeout files. Only then stop.

## What the operator does **not** need to do

You do **not** manually invent JOURNEY/WHY/USER/EXPECTED/ACTUAL blocks.

Those come from the existing TDD / human-receipt pattern:

- global skill `homelab-litellm-model-lane-pytest` (original)
- package `homelab-model-lane-pytest` receipts (`receipts.py` → printed on live runs)
- project thin SHIM `homelab-litellm-model-lane-pytest-draft` (documents how to run)

The gap was only that the **agent did not capture stdout into the plan folder**.
An evaluator pass already pasted one smoke PASS block into
`plan-22_execution_note.md` (section **Human receipt (evaluator-captured
2026-09-15)**). Do not ask the human to re-type it.

## Goal of this next pass

Close the remaining **blocking** evaluator items so the paired loop can move
toward sign-off. Address the evaluator (this role) in your closeout file.

Authority order:

1. This file (`plan-22_next_pass_evaluator.md`)
2. `feedback_for_review_by_evaluator_20260915-233237.md`
3. `plan-21_vnext_skill_draft.md` (§0 SHIM rule, §8 slices, §9 done-when)
4. `plan-22_prompt.md`

## Required work (implementer)

### 1. Vault-env fidelity (blocking)

- Make `vault-env.toml` drive `scripts/sync_env_from_vault.py`, **or**
- Delete unused TOML and document intentional hardcoding in README.

Prove with a dry description of the mapping (no secret values in chat or git):

`vault_k3s_litellm_gateway_master_key` → `LITELLM_API_KEY`

Package must still run **without** a skill: `just sync-env` then `just unit` /
targeted `just live …`.

### 2. Thin SHIM update (blocking)

Update
`dotfile-vnext/.cursor/skills/homelab-litellm-model-lane-pytest-draft/SKILL.md`:

- Document `DOTFILE_VNEXT=… just sync-env`
- Document package `.env` load (no skill required to run tests)
- Remove / rewrite “vault wrappers remain outside the package”
- Keep `-draft` suffix; stay thin SHIM (no harness growth in the skill)

### 3. Default live suite honesty (blocking)

Fresh evaluator evidence: `just test` with key present failed on
`gpt-oss-20b` / `tools::read-hosts-tool` (`HTTP 200; ''`).

Pick one and prove:

- fix expect_mode / journey for that lane, **or**
- capability-gate / skip / deselect until tools are real for that model, **or**
- document default live as failing with a pasted FAIL receipt

Do **not** claim package live green while default `just test` is red.

### 4. Receipt capture automation (preferred, non-blocking if 1–3 done)

Optional but valuable: add a package or SHIM recipe that writes the latest
human receipt stdout into the plan folder (or `receipts/` under the package)
so agents never “forget” to paste. Do not require the human to paste.

### 5. Smoke receipt status

Already satisfied for this cycle by evaluator paste of
`qwen3-coder-30b-a3b` smoke ping-pong. If you change receipt format, re-run
targeted smoke and update `plan-22_execution_note.md` with a **new** block.

## Out of scope

- Promoting `-draft` → stable / global skill
- Deploying LiteLLM/vLLM inventory changes
- Expanding Plan 20 skill-local tests as the permanent home
- Manual human pasting of receipt blocks

## When finished — mandatory closeout file

Create:

`docs/plans/2026-09-13--get-back-ansible-best-practice/plan-22_next_pass_implementer.md`

That file must:

- Be written **to the evaluator** (address evaluator explicitly)
- List each blocking item and what you changed (paths + commands)
- Paste fresh verification output (`just unit`, `just lint`, and either
  green `just test` or documented deselection / FAIL receipt)
- Note any remaining risks
- End with: `ready for evaluator re-review: yes|no`

Also create (or refresh) implementer handoff:

`review_ready_for_evaluator_<YYYYMMDD-HHMMSS>.md`

pointing at `plan-22_next_pass_implementer.md`.

## Done when (evaluator re-entry criteria)

- [x] vault-env.toml vs script inconsistency resolved
- [x] draft SHIM documents sync-env + package-owned run path
- [x] default live story is honest and evidenced
- [x] `plan-22_next_pass_implementer.md` exists and addresses the evaluator
- [x] no secrets in git or chat

Closed **PASS** in `feedback_for_review_by_evaluator_20260916-004711.md`
(fresh evaluator `just unit` / `just lint` / `just test`: 5 / lint clean / 21).
