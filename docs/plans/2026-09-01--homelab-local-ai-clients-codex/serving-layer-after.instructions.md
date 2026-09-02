<!-- Concurrent-work note: Codex owns this diagram product; Cursor should preserve it. -->

# After serving layer diagram - instructions

## Artifacts

- Script: `serving_layer_before_after.py`
- Image: `serving-layer-after.png`
- Stem: `serving-layer-after`

## Scope

- Source model: the deployed deep-lane serving-format repair.
- Focus boundary: Codex CLI through LiteLLM and the vLLM serving pod.
- Explicit exclusions: model training, model weights, IDE extension UI, and
  current local Codex command-execution qualification.

## Modification notes

- The chat template and custom parser must remain a matched pair. Changing one
  without revalidating the other can turn a real action back into plain text.
- The `Codex exec runner` is intentionally shown as a logical service. It is
  Codex's local command executor, not another homelab server.
- The final node is a verification gate, not a pass marker: a current local
  profile must execute a command and receive its result before the diagram can
  be changed to show a completed tool loop.

## Re-render

```bash
/Users/joshc/.codex/skills/create-diagrams/scripts/render_with_docker.sh \
  docs/plans/2026-09-01--homelab-local-ai-clients-codex/serving_layer_before_after.py \
  docs/plans/2026-09-01--homelab-local-ai-clients-codex
```
