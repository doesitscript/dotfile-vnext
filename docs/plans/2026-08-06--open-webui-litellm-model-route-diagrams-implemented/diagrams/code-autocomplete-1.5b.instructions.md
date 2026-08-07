# code-autocomplete-1.5b route — instructions

## Artifacts
- script: `code-autocomplete-1.5b.py`
- image: `code-autocomplete-1.5b.png` (also `.svg`, `.dot`)
- stem: `code-autocomplete-1.5b`

## Modification notes
- This explicit autocomplete alias shares the HVH-01 GTX 1060 Ollama backend with `code-fast`.
- Keep the Pascal/llama.cpp note unless the route migrates to a different runtime class.

## Re-render
- local: run the script with a repo-managed Python that imports `diagrams` and has Graphviz `dot` on PATH
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams/code-autocomplete-1.5b.py docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams`
