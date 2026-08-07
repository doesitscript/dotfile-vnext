# continue-apply route — instructions

## Artifacts
- script: `continue-apply.py`
- image: `continue-apply.png` (also `.svg`, `.dot`)
- stem: `continue-apply`

## Modification notes
- This alias currently targets the HVH-01 co-resident `phi4-mini` Ollama helper route used for apply flows.
- If apply work moves off HVH-01 or changes models, update the backend node label and edge note.

## Re-render
- local: run the script with a repo-managed Python that imports `diagrams` and has Graphviz `dot` on PATH
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams/continue-apply.py docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams`
