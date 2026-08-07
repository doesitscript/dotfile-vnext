# E2E 2 — Agent-run storyboard pipeline — instructions

## Artifacts
- script: `comfyui-e2e-agent-storyboard.py`
- image: `comfyui-e2e-agent-storyboard.svg` (also `.png`, `.dot`)
- stem: `comfyui-e2e-agent-storyboard`

## Modification notes
- End-to-end: session/trace summary → N frame briefs → ComfyUI still sequence → share.
- Stills only (storyboard frames), not motion/video generation.
- Optional Langfuse edge is dashed — helpful when a trace exists, not required.

## Re-render
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh comfyui-e2e-agent-storyboard.py .`
- mode: docker
