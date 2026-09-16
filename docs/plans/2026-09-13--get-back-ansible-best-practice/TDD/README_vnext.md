# Model-lane TDD vNext draft

This is the first scalable project implementation of the global
`homelab-litellm-model-lane-pytest` skill. The suite is data-driven over six
evaluation models and keeps the embedding owner as a separate capability
check.

Run it with:

```bash
LITELLM_API_KEY="$LITELLM_API_KEY" python3 -m pytest -q -s \\
  TDD/test_model_lanes_vnext.py
```

Without `LITELLM_API_KEY`, live tests skip safely and the manifest invariant
test still runs. A live receipt requires the key to be supplied externally;
the key must never be written to this directory or included in a plan report.

The checks cover normal chat, FIM, embedding ownership, non-empty responses,
response identity, and context/output budget invariants. They do not claim
tool execution, IDE round-trip behavior, or role-specific behavioral quality.

## Documentation Provenance

- Origin: Plan 20 vNext request.
- Root source of truth: global LiteLLM pytest skill and project model SSOT.
- Direct inputs: existing `TDD/test_model_lanes.py` and Plan 20.
- Outputs: `test_model_lanes_vnext.py` and the draft project skill.
- Skills used: `skill-creator`, `documentation-provenance-chain`.
