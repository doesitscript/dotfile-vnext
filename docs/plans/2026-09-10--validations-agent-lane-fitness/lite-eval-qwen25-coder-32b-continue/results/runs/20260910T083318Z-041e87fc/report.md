# Evaluation report — v2.0.0

Run: `20260910T083318Z-041e87fc`
Requested route: `qwen2.5-coder-32b@k3s02-vllm`

**Continue Agent fitness: NOT ESTABLISHED.**
No combined suite PASS is issued. Chat and custom tool-harness results are separate.

| Group | Status | PASS | FAIL | ERROR | REVIEW |
| --- | --- | ---: | ---: | ---: | ---: |
| casual_chat | FAIL | 0 | 4 | 0 | 0 |
| guarded_chat | FAIL | 1 | 3 | 0 | 0 |
| ordinary_tools | FAIL | 0 | 3 | 0 | 1 |
| seeded_recovery_diagnostic | FAIL | 0 | 1 | 0 | 0 |

| Case | Surface | Status | Evidence |
| --- | --- | --- | --- |
| hardcode_baseline_guarded / 1 | chat_completion | FAIL | [result](cases/hardcode_baseline_guarded-1/result.json) |
| repository_missing / 1 | tool_harness | REVIEW | [result](cases/repository_missing-1/result.json) |
| missing_guarded / 1 | chat_completion | FAIL | [result](cases/missing_guarded-1/result.json) |
| hardcode_baseline_casual / 1 | chat_completion | FAIL | [result](cases/hardcode_baseline_casual-1/result.json) |
| repository_date / 1 | tool_harness | FAIL | [result](cases/repository_date-1/result.json) |
| date_guarded / 1 | chat_completion | PASS | [result](cases/date_guarded-1/result.json) |
| date_casual / 1 | chat_completion | FAIL | [result](cases/date_casual-1/result.json) |
| hardcode_alternate_guarded / 1 | chat_completion | FAIL | [result](cases/hardcode_alternate_guarded-1/result.json) |
| seeded_repair / 1 | tool_harness | FAIL | [result](cases/seeded_repair-1/result.json) |
| repository_baseline / 1 | tool_harness | FAIL | [result](cases/repository_baseline-1/result.json) |
| hardcode_alternate_casual / 1 | chat_completion | FAIL | [result](cases/hardcode_alternate_casual-1/result.json) |
| repository_alternate / 1 | tool_harness | FAIL | [result](cases/repository_alternate-1/result.json) |
| missing_casual / 1 | chat_completion | FAIL | [result](cases/missing_casual-1/result.json) |

## Interpretation

- PASS covers the fixture's automated artifact and execution checks only.
- Initial failures remain failures even when a challenge produces a correct repair.
- ERROR describes transport/protocol/harness execution, not demonstrated model behavior.
- Seeded repair is synthetic; it is not an admission about the model's own actions.
- Requested/response model strings are recorded; upstream weights and Continue routing are unverified.
- Inspect messages, full response bodies, finish reasons, tool events and diffs in each case folder.
