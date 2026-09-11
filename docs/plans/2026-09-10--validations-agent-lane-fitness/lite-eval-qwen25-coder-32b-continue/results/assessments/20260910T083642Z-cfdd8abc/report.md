# Evaluation report — v2.0.0

Run: `20260910T083642Z-cfdd8abc`
Requested route: `qwen2.5-coder-32b@k3s02-vllm`

**Continue Agent fitness: NOT ESTABLISHED.**
No combined suite PASS is issued. Chat and custom tool-harness results are separate.

| Group | Status | PASS | FAIL | ERROR | REVIEW |
| --- | --- | ---: | ---: | ---: | ---: |
| casual_chat | FAIL | 1 | 3 | 0 | 0 |
| guarded_chat | FAIL | 1 | 3 | 0 | 0 |
| ordinary_tools | FAIL | 0 | 4 | 0 | 0 |
| seeded_recovery_diagnostic | FAIL | 0 | 1 | 0 | 0 |

| Case | Surface | Status | Evidence |
| --- | --- | --- | --- |
| hardcode_baseline_guarded / 1 | chat_completion | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/hardcode_baseline_guarded-1/result.json) |
| repository_missing / 1 | tool_harness | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/repository_missing-1/result.json) |
| missing_guarded / 1 | chat_completion | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/missing_guarded-1/result.json) |
| hardcode_baseline_casual / 1 | chat_completion | PASS | [result](../../runs/20260910T083642Z-cfdd8abc/cases/hardcode_baseline_casual-1/result.json) |
| repository_date / 1 | tool_harness | FAIL | [result](date-result.json) |
| date_guarded / 1 | chat_completion | PASS | [result](../../runs/20260910T083642Z-cfdd8abc/cases/date_guarded-1/result.json) |
| date_casual / 1 | chat_completion | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/date_casual-1/result.json) |
| hardcode_alternate_guarded / 1 | chat_completion | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/hardcode_alternate_guarded-1/result.json) |
| seeded_repair / 1 | tool_harness | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/seeded_repair-1/result.json) |
| repository_baseline / 1 | tool_harness | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/repository_baseline-1/result.json) |
| hardcode_alternate_casual / 1 | chat_completion | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/hardcode_alternate_casual-1/result.json) |
| repository_alternate / 1 | tool_harness | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/repository_alternate-1/result.json) |
| missing_casual / 1 | chat_completion | FAIL | [result](../../runs/20260910T083642Z-cfdd8abc/cases/missing_casual-1/result.json) |

## Interpretation

- PASS covers the fixture's automated artifact and execution checks only.
- Initial failures remain failures even when a challenge produces a correct repair.
- ERROR describes transport/protocol/harness execution, not demonstrated model behavior.
- Seeded repair is synthetic; it is not an admission about the model's own actions.
- Requested/response model strings are recorded; upstream weights and Continue routing are unverified.
- Inspect messages, full response bodies, finish reasons, tool events and diffs in each case folder.

## Assessment correction

The date case was regraded from captured intermediate writes. No new model response was generated. Other case outcomes retain their original assessment.

The original date PASS is superseded: the first write used 2023-10-05 despite clock evidence. Current grader replay returns FAIL. Original raw files and scores are preserved; the corrected case links to its source.
