<!-- Concurrent-work note: Codex owns this diagram product; Cursor should preserve it. -->

# Before serving layer diagram - instructions

## Artifacts

- Script: `serving_layer_before_after.py`
- Image: `serving-layer-before.png`
- Stem: `serving-layer-before`

## Scope

- Source model: the documented pre-repair local Codex deep tool path.
- Focus boundary: Codex CLI through LiteLLM and the vLLM serving pod.
- Explicit exclusions: model training, model weights, IDE extension UI, and
  interactive Codex qualification.

## Modification notes

- The old parser node represents a parser/template mismatch, not a model
  refusal or a shell-permission denial.
- Keep the diagram paired with `serving-layer-after.png`; neither image is a
  full homelab topology.

## Re-render

```bash
/Users/joshc/.codex/skills/create-diagrams/scripts/render_with_docker.sh \
  docs/plans/2026-09-01--homelab-local-ai-clients-codex/serving_layer_before_after.py \
  docs/plans/2026-09-01--homelab-local-ai-clients-codex
```
