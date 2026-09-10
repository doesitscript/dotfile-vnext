# Continue edit/apply validations

Probe LiteLLM (`LITELLM_GATEWAY_ROOT`, default `http://litellm.hom.lab:30400`)
for Continue **edit** and **apply** model fitness. Transport uses
`/usr/bin/curl --interface en0` via `lib_gateway.py` (errno 49 bind workaround).

## Run

```bash
cd docs/plans/2026-03-09--continue-edit-apply-presetup/validations
export LITELLM_GATEWAY_ROOT=http://litellm.hom.lab:30400
python3 run_all.py
```

Or individually:

```bash
python3 test_models_present.py
python3 test_edit_role.py
python3 test_apply_role.py
python3 compare_candidates.py
```

## Outputs

Written under `results/`:

| File | Purpose |
| --- | --- |
| `models_present.json` | Required `@desktop` ids published on `/v1/models` |
| `edit_role.json` | Edit-prompt latency + score for selected + candidates |
| `apply_role.json` | Apply-prompt latency + score for selected + candidates |
| `candidate_comparison.json` | Dual-pass ranking; fastest desktop that passes both |
| `summary.json` | Exit codes from `run_all.py` |

Selected model: `qwen2.5-coder-7b@desktop` (see `../model_recommendations.md`).
