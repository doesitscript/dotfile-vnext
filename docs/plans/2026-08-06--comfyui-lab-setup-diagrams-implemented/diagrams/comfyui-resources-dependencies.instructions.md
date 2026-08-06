# ComfyUI resources and dependencies — instructions

## Artifacts
- script: `comfyui-resources-dependencies.py`
- image: `comfyui-resources-dependencies.svg` (also `.png`, `.dot`)
- stem: `comfyui-resources-dependencies`

## Modification notes
- Explains brainstorm studio asset *kinds* generically (profile, coaching,
  presets, negatives, examples, workflow graphs, adapter slots, lab share).
- Does not name content themes; maps kinds → ComfyUI runtime + model volume.

## Re-render
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh comfyui-resources-dependencies.py .`
- mode: docker
