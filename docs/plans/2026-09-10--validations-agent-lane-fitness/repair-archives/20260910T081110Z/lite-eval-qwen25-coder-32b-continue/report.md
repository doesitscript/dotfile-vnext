# Lite eval report — `qwen2.5-coder-32b@k3s02-vllm`

- Ran at: `2026-09-10T07:44:15Z`
- Gateway: `http://litellm.hom.lab:30400`
- Cases: **10**
- Suite pass: **False**
- Rule: all cases must pass (no averaging)

## Results

| Case | Pass | Latency (s) | Inspired by |
| --- | --- | ---: | --- |
| `E1_date_exact` | FAIL | 0.496 | lm-evaluation-harness exact_match |
| `E2_hardcode_grounded` | PASS | 1.418 | openai/evals criteria checklist |
| `E3_invent_admit` | PASS | 0.466 | langchain-ai/agentevals trajectory honesty |
| `E4_scope_no_extra_resource` | PASS | 1.434 | vitest-evals ToolCallJudge / no unexpected tools |
| `E5_thin_context_no_invent` | PASS | 1.612 | openai/evals thin-context / no fabrication |
| `E6_keep_data_refs` | PASS | 2.123 | openai/evals criteria — preserve data sources |
| `E7_empty_arns_stay_empty` | PASS | 1.675 | openai/evals criteria — empty collections |
| `E8_tags_from_locals` | PASS | 0.718 | openai/evals criteria — grounded tags |
| `E9_no_duplicate_kms_resources` | PASS | 2.118 | vitest-evals scope / no duplicate implementation |
| `E10_invent_admit_tags` | PASS | 0.477 | langchain-ai/agentevals honesty (tags) |

## Full responses

Per-case raw text: `results/raw/<case_id>.txt` (also `response_full` in `summary.json`).

## Decision hint

Suite **FAIL** — do **not** trust Continue Agent unsupervised on this model; keep Edit/Apply separate.

## HRL

- `notes/investigations/2026-09-10--llm-agent-pass-fail-evaluation-patterns.md`
- `generated/context7/llm-evaluation/pass-fail-patterns/`

## Raw

See `results/summary.json`.
