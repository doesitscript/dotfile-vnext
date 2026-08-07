# code-fast route — instructions

## Artifacts
- script: `code-fast.py`
- image: `code-fast.png` (also `.svg`, `.dot`)
- stem: `code-fast`

## Modification notes
- `code-fast` is the default Continue autocomplete alias over the same HVH-01 Ollama 1.5B backend as `code-autocomplete-1.5b`.
- If the default autocomplete alias moves to a 7B or vLLM-backed route, update both the backend label and the modification note here.

## Re-render
- local: run the script with a repo-managed Python that imports `diagrams` and has Graphviz `dot` on PATH
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams/code-fast.py docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams`
