# ComfyUI diagrams

| Stem | What it shows |
| --- | --- |
| [comfyui-lab-architecture](comfyui-lab-architecture.svg) | Phase B host / publish / GPU time-share |
| [comfyui-e2e-ops-change-card](comfyui-e2e-ops-change-card.svg) | E2E 1 — ops change-card illustrator |
| [comfyui-e2e-agent-storyboard](comfyui-e2e-agent-storyboard.svg) | E2E 2 — agent-run storyboard stills |

Artifacts per stem: `.py` · `.svg` · `.png` · `.dot` · `.instructions.md`

**Removed:** `comfyui-studio-setup`, `comfyui-resources-dependencies` (prior
prior studio image/video framing).

## Re-render all

```bash
DIR=docs/plans/2026-08-06--comfyui-lab-setup-diagrams-implemented/diagrams
SKILL=~/.codex/skills/create-diagrams/scripts/render_with_docker.sh
for py in "$DIR"/*.py; do "$SKILL" "$py" "$DIR"; done
```

Parent plan: [../README.md](../README.md)
