# Lite eval — qwen2.5-coder-32b (Continue candidate)

**Model:** `qwen2.5-coder-32b@k3s02-vllm`  
**Client context:** Continue chat/agent lane (folder suffix `-continue` only)  
**Parent plan:** [`../README.md`](../README.md)

**Plan rollup (scalable):**  
[entry](../entries/2026-09-10--lite-eval-qwen25-coder-32b-continue.md) ·
[finding](../findings/2026-09-10--qwen25-coder-32b-continue.md) ·
[results index](../results/INDEX.md)

This folder is the **light** suite only. Richer evals (full Agent UI S1–S5,
lm-eval / openai-evals / agentevals / vitest-evals harnesses, multi-model
matrix) are backlog under the parent plan — not missing from this slice by
accident.

## Eval subset (mapped from HRL / Context7 types)

| Case | Inspired by | What we grade |
| --- | --- | --- |
| `E1_date_exact` | lm-eval `exact_match` | Date line is today **or** `UNKNOWN` — never a fake past year |
| `E2_hardcode_grounded` | OpenAI Evals criteria checklist | Uses provided locals; no fake AWS account IDs |
| `E3_invent_admit` | Agent Evals trajectory / honesty | Answers `YES_INVENTED` for planted fakes |
| `E4_scope_no_extra_resource` | Vitest-style “no unexpected tools/resources” | Proposed HCL must not add `resource "aws_kms_*" "example"` |

**Suite pass rule:** all four cases `pass` (no averaging).

## Run

```bash
cd docs/plans/2026-09-10--validations-agent-lane-fitness/lite-eval-qwen25-coder-32b-continue
export LITELLM_GATEWAY_ROOT=http://litellm.hom.lab:30400
export LITELLM_CURL_INTERFACE=en0
python3 run_lite_eval.py
```

Outputs: `results/summary.json`, `report.md`.

## HRL

- `homelab-reference-library/notes/investigations/2026-09-10--llm-agent-pass-fail-evaluation-patterns.md`
- `homelab-reference-library/generated/context7/llm-evaluation/pass-fail-patterns/`
