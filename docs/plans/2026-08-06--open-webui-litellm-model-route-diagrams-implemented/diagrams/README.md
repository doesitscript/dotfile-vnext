# Per-model route diagrams

Each stem matches the Open WebUI / LiteLLM model (or Arena feature) name.

| Model | SVG |
| --- | --- |
| `positive-negative-prompt-assist` | [studio-coach.svg](studio-coach.svg) |
| `arena` | [arena.svg](arena.svg) |
| `code-review` | [code-review.svg](code-review.svg) |
| `code-fast` | [code-fast.svg](code-fast.svg) |
| `code-autocomplete-1.5b` | [code-autocomplete-1.5b.svg](code-autocomplete-1.5b.svg) |
| `continue-edit` | [continue-edit.svg](continue-edit.svg) |
| `continue-apply` | [continue-apply.svg](continue-apply.svg) |
| `gpt-oss-20b` | [gpt-oss-20b.svg](gpt-oss-20b.svg) |
| `gemma4-12b` | [gemma4-12b.svg](gemma4-12b.svg) |
| `qwen3.6-27b` | [qwen3.6-27b.svg](qwen3.6-27b.svg) |
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
