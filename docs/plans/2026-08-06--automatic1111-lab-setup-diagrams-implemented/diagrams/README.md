# Automatic1111 diagrams

| Stem | What it shows |
| --- | --- |
| [automatic1111-lab-architecture](automatic1111-lab-architecture.svg) | Phase A host / Open WebUI Images / direct UI |
| [automatic1111-e2e-lab-doc-still](automatic1111-e2e-lab-doc-still.svg) | E2E 1 — lab-doc still via Open WebUI Images |
| [automatic1111-e2e-controlnet-mock](automatic1111-e2e-controlnet-mock.svg) | E2E 2 — ControlNet reference-locked mock |

Artifacts per stem: `.py` · `.svg` · `.png` · `.dot` · `.instructions.md`

**Removed:** `automatic1111-studio-setup`, `automatic1111-resources-dependencies`
(prior prior studio framing).

## Re-render all

```bash
DIR=docs/plans/2026-08-06--automatic1111-lab-setup-diagrams-implemented/diagrams
SKILL=~/.codex/skills/create-diagrams/scripts/render_with_docker.sh
for py in "$DIR"/*.py; do "$SKILL" "$py" "$DIR"; done
```

Parent plan: [../README.md](../README.md)
