# Plan 22 beta-prep implementer report

To: The Plan 22 evaluator

## Changes

- Added `test_enabled_commissioned_ids_are_exactly_the_six_profile_ids` in
  `/Users/joshc/develop/homelab-model-lane-pytest/tests/unit/test_ssot.py`.
  It asserts the enabled manifest IDs equal exactly the six commissioned IDs,
  while the separate subset assertion still permits the documented disabled
  pending lane.
- Marked the package beta as `0.2.0b0` in `pyproject.toml` and
  `src/homelab_model_lane_pytest/__init__.py`.
- Added `Status: beta (0.2.0b0)` to the package README and synchronized the
  installed package metadata with `uv sync --dev`.
- Updated the `-draft` SHIM frontmatter to `version: "0.2.0b0"` and
  `status: beta`; its body states that the package is beta-stable to consume,
  while the skill remains `-draft` pending a later promote decision.
- Refreshed `plan-22_execution_note.md` with the beta marker and existing
  commissioned-six / one-model receipt file pointers.

## Fresh verification

Command required by the operator:

```text
just unit && just lint && just test
```

Results:

```text
just unit
6 passed in 0.12s

just lint
All checks passed!
19 files already formatted

just test
22 passed in 51.23s
```

The full suite included live grouped summaries for smoke, chat, tools, FIM,
and embed. Existing full receipts remain in:

- `plan-22_acceptance_gap_commissioned_six_receipts.txt`
- `plan-22_acceptance_gap_one_model_receipt.txt`

## Safety checks

```text
.env gitignored: pass
nothing staged: pass
secret scan: pass for real secret values
```

The scan’s only match was the intentional placeholder
`sk-REPLACE_VIA_VAULT` in commit-safe configuration; no real secret was
printed, staged, or written to plan artifacts. No commit was made.

ready for evaluator re-review: yes
