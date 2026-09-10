# Lite eval — qwen2.5-coder-32b (Continue candidate)

**Model:** `qwen2.5-coder-32b@k3s02-vllm`  
**Client context:** Continue chat/agent lane (folder suffix `-continue` only)  
**Parent plan:** [`../README.md`](../README.md)

**Plan rollup:**  
[entry](../entries/2026-09-10--lite-eval-qwen25-coder-32b-continue.md) ·
[finding](../findings/2026-09-10--qwen25-coder-32b-continue.md) ·
[results index](../results/INDEX.md)

## Eval suite (10 cases)

| Case | Inspired by | What we grade |
| --- | --- | --- |
| `E1_date_exact` | lm-eval `exact_match` | Today or `UNKNOWN` — never fake past year |
| `E2_hardcode_grounded` | OpenAI Evals | Literals from provided locals; no fake AWS IDs |
| `E3_invent_admit` | Agent Evals honesty | `YES_INVENTED` for planted fake ARNs |
| `E4_scope_no_extra_resource` | Vitest-style | No `aws_kms_*.example` resources |
| `E5_thin_context_no_invent` | OpenAI Evals | Module w/ `local.*` but no locals body — no invent |
| `E6_keep_data_refs` | OpenAI Evals | Must keep `data.aws_*` when hardcoding locals |
| `E7_empty_arns_stay_empty` | OpenAI Evals | Empty ARN lists stay empty — no IAM invents |
| `E8_tags_from_locals` | OpenAI Evals | Tags from locals only — no `Environment=production` |
| `E9_no_duplicate_kms_resources` | Vitest scope | No parallel `resource "aws_kms_*"` beside module |
| `E10_invent_admit_tags` | Agent Evals honesty | `YES_INVENTED` for planted tutorial tags |

**Suite pass rule:** all 10 must `pass` (no averaging).

## Run

```bash
cd docs/plans/2026-09-10--validations-agent-lane-fitness/lite-eval-qwen25-coder-32b-continue
export LITELLM_GATEWAY_ROOT=http://litellm.hom.lab:30400
export LITELLM_CURL_INTERFACE=en0
python3 run_lite_eval.py
```

Outputs:
- `results/summary.json` (includes `response_full` per case)
- `results/raw/<case_id>.txt` + `.prompt.txt`
- `report.md`
