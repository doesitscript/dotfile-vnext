# Per-model route diagrams — instructions

## Artifacts
- directory: `diagrams/`
- stems: sex_scene, arena, llama2-uncensored, gemma4-12b-uncensored-1.5m,
  qwen3.6-35b-a3b-uncensored, smart-router, experiment, default

## Modification notes
- Stem must equal the client-facing model string (hyphens preserved).
- `arena` is an Open WebUI feature, not a LiteLLM model id.
- `experiment` / `default` match OI tags from operator screenshots.
- If LiteLLM backend for `experiment` is pinned differently in Helm, update
  `experiment.py` edge labels from `roles/k3s_litellm_gateway` live values.

## Re-render
- docker loop: see `diagrams/README.md`
- mode: docker
