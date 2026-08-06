# Per-model route diagrams

Each stem matches the Open WebUI / LiteLLM model (or Arena feature) name.

| Model | SVG |
| --- | --- |
| `sex_scene` | [sex_scene.svg](sex_scene.svg) |
| `arena` | [arena.svg](arena.svg) |
| `llama2-uncensored` | [llama2-uncensored.svg](llama2-uncensored.svg) |
| `gemma4-12b-uncensored-1.5m` | [gemma4-12b-uncensored-1.5m.svg](gemma4-12b-uncensored-1.5m.svg) |
| `qwen3.6-35b-a3b-uncensored` | [qwen3.6-35b-a3b-uncensored.svg](qwen3.6-35b-a3b-uncensored.svg) |
| `smart-router` | [smart-router.svg](smart-router.svg) |
| `experiment` | [experiment.svg](experiment.svg) |
| `default` | [default.svg](default.svg) |

Artifacts per stem: `.py` (Mingrammer model), `.svg`, `.png`, `.dot`.

## Re-render all

```bash
DIR=docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams
SKILL=~/.codex/skills/create-diagrams/scripts/render_with_docker.sh
for py in "$DIR"/*.py; do "$SKILL" "$py" "$DIR"; done
```

Parent plan: [../README.md](../README.md)
