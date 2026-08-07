# continue-edit route — instructions

## Artifacts
- script: `continue-edit.py`
- image: `continue-edit.png` (also `.svg`, `.dot`)
- stem: `continue-edit`

## Modification notes
- This diagram reflects the commissioned desktop Ollama `qwen3-coder:30b` route, not the blocked DiffuCoder fallback path.
- If `continue-edit` later switches to DiffuCoder or another vLLM wrapper, replace the desktop Ollama cluster and edge label.

## Re-render
- local: run the script with a repo-managed Python that imports `diagrams` and has Graphviz `dot` on PATH
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams/continue-edit.py docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams`
