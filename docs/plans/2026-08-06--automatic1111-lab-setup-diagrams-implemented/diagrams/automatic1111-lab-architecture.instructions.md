# Lab Automatic1111 — HVH-01 Phase A — instructions

## Artifacts
- script: `automatic1111-lab-architecture.py`
- image: `automatic1111-lab-architecture.svg` (also `.png`, `.dot`)
- stem: `automatic1111-lab-architecture`

## Modification notes
- Open WebUI Images → `AUTOMATIC1111_BASE_URL` (`a1111-hvh01.hom.lab:7860`).
- Direct A1111 UI path is intentional (denoise / OpenPose not fully exposed in WebUI Images).
- Model node is a compute icon stand-in for on-disk checkpoints + ControlNet weights.
- Optional follow-up: split “Images button” vs “A1111 UI knobs” into its own diagram.

## Re-render
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh automatic1111-lab-architecture.py .`
- mode: docker (no local `diagrams` / `dot`)
