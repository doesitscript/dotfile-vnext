# E2E 1 — Lab-doc still via Open WebUI Images — instructions

## Artifacts
- script: `automatic1111-e2e-lab-doc-still.py`
- image: `automatic1111-e2e-lab-doc-still.svg` (also `.png`, `.dot`)
- stem: `automatic1111-e2e-lab-doc-still`

## Modification notes
- End-to-end: lab notes → chat coaching → Open WebUI Images → A1111 sdapi → share → docs.
- Phase A happy path on HVH-01; pixels do not route through LiteLLM.
- Documentation stills only (topology vignette / badge / simple scene).

## Re-render
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh automatic1111-e2e-lab-doc-still.py .`
- mode: docker
