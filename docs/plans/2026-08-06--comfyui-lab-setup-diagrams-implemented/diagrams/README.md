# ComfyUI diagrams

| Stem | What it shows |
| --- | --- |
| [comfyui-lab-architecture](comfyui-lab-architecture.svg) | Phase B host / publish / GPU time-share |
| [comfyui-studio-setup](comfyui-studio-setup.svg) | Whole studio surfaces; ComfyUI as advanced pixel engine |
| [comfyui-resources-dependencies](comfyui-resources-dependencies.svg) | Generic resource kinds → ComfyUI dependencies |

Artifacts per stem: `.py` · `.svg` · `.png` · `.dot` · `.instructions.md`

## Re-render all

```bash
DIR=docs/plans/2026-08-06--comfyui-lab-setup-diagrams-implemented/diagrams
SKILL=~/.codex/skills/create-diagrams/scripts/render_with_docker.sh
for py in "$DIR"/*.py; do "$SKILL" "$py" "$DIR"; done
```

Parent plan: [../README.md](../README.md)
