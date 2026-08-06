# Automatic1111 diagrams

| Stem | What it shows |
| --- | --- |
| [automatic1111-lab-architecture](automatic1111-lab-architecture.svg) | Phase A host / Open WebUI Images / direct UI |
| [automatic1111-studio-setup](automatic1111-studio-setup.svg) | Whole studio surfaces; A1111 as still bootstrap |
| [automatic1111-resources-dependencies](automatic1111-resources-dependencies.svg) | Generic resource kinds → A1111 dependencies |

Artifacts per stem: `.py` · `.svg` · `.png` · `.dot` · `.instructions.md`

## Re-render all

```bash
DIR=docs/plans/2026-08-06--automatic1111-lab-setup-diagrams-implemented/diagrams
SKILL=~/.codex/skills/create-diagrams/scripts/render_with_docker.sh
for py in "$DIR"/*.py; do "$SKILL" "$py" "$DIR"; done
```

Parent plan: [../README.md](../README.md)
