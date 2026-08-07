# code-review route — instructions

## Artifacts
- script: `code-review.py`
- image: `code-review.png` (also `.svg`, `.dot`)
- stem: `code-review`

## Modification notes
- This route is the review alias over the same Ornith-backed vLLM primary used by `default` and `experiment`.
- If review traffic moves to a dedicated secondary runtime later, update the vLLM cluster label and edge note.

## Re-render
- local: run the script with a repo-managed Python that imports `diagrams` and has Graphviz `dot` on PATH
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams/code-review.py docs/plans/2026-08-06--open-webui-litellm-model-route-diagrams-implemented/diagrams`
