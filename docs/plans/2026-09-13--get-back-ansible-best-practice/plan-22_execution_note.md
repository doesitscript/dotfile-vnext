# Plan 22 execution note

Implemented Plan 21 slices 1–8 in the sibling package
`/Users/joshc/develop/homelab-model-lane-pytest` and refreshed the project
`homelab-litellm-model-lane-pytest-draft` skill as a thin SHIM.

## Local verification

```text
just unit: 5 passed
just lint: All checks passed; 18 files already formatted
just sync-env: wrote .env (0600) and refreshed .env.example
targeted package live: qwen3-coder-30b-a3b ping-pong [PASS]
targeted selection: 1 passed, 11 deselected
```

The targeted selection and marker collection were verified with the smoke
profile and `qwen3-coder-30b-a3b` keyword. Vault hydration used the existing
`vault_k3s_litellm_gateway_master_key` mapping; its value was not read into
chat, logs, source, or tracked files.

## Evidence boundary

The package now owns the manifest, capability omission, journey cases, tool
invoke/execute/follow-up path, receipts, profiles, and SSOT subset invariant.
The package now has the required targeted live PASS receipt. Broader tools,
FIM, and embedding live receipts remain targeted follow-up coverage rather
than claims made by this smoke run.

## Human receipt (evaluator-captured 2026-09-15)

Command (package, no skill required once `.env` exists):

```bash
cd /Users/joshc/develop/homelab-model-lane-pytest
just live -m smoke -k qwen3-coder-30b-a3b
```

```text
── qwen3-coder-30b-a3b / smoke::ping-pong [PASS] ──
JOURNEY:  Can the model hear you and answer with one exact word?
WHY:      Ping to pong proves basic communication end-to-end.
USER:     Reply with exactly the word: pong
EXPECTED: HTTP 200 and declared expectation
ACTUAL:   HTTP 200; 'pong'

1 passed, 11 deselected in 0.44s
```

Operator note: you do **not** need to paste these by hand for normal runs. The
package / global `homelab-litellm-model-lane-pytest` skill pattern already
prints them; agents must capture command stdout into this plan folder.
Remaining open items are in `plan-22_next_pass_evaluator.md` and
`feedback_for_review_by_evaluator_20260915-233237.md`.

Beta marker: package `0.2.0b0` / README `Status: beta`; existing receipt files:
`plan-22_acceptance_gap_commissioned_six_receipts.txt` and
`plan-22_acceptance_gap_one_model_receipt.txt`.
