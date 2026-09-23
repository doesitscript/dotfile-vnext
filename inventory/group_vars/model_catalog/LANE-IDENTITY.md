# Model lane identity contract

End-state (2026-09-22): **plain LiteLLM client model IDs are the canonical
lane identity**. Purpose-style names are capability metadata only.

Authority for this direction:
`docs/plans/2026-09-13--get-back-ansible-best-practice/plan-07_antipattern_audit.md`
(P1 mixed-purpose lane identities). Bridge-era union resolution is archived at
`docs/archive/2026-09-22--model-lane-identity-bridge-deprecating.md`.

## Layers

| Layer | Authority | Name |
| --- | --- | --- |
| Catalog row key | `manifest.yml` `entries[].lane` | **Must equal** LiteLLM `model_name` when published |
| Gateway publish | LiteLLM `model_name` | Same string clients send on `/v1/*` |
| Agent profiles | `ai_agent_profiles.yml` | Must reference `lane` (== client id) |
| Capability label | `capability` / `client_roles` / `purpose` | Human/role metadata — **not** a second ID |

## Required fields (published rows)

| Field | Rule |
| --- | --- |
| `lane` | Canonical identity; equals `client_model_id` |
| `client_model_id` | Exact LiteLLM `model_name`; must equal `lane` |
| `capability` | Optional capability class (`code_completion`, `fast_chat`, …) |
| `client_roles` | Optional list of consumer roles (`autocomplete`, `chat`, …) |
| `purpose` | Human description only |
| `deprecated_purpose_labels` | Retired labels for archaeology; **not** accepted by validators |

## Resolution rule (strict)

Valid reference names for agent profiles and LiteLLM lane contracts:

```text
entries[].lane
```

When `client_model_id` is set, validators also assert `lane == client_model_id`.

Do **not** accept purpose labels (`code-autocomplete-1.5b`, `code-fast`) as
live lane references. Prefer fail-loud over silent alias bridging.

Reusable Ansible task:

```text
playbooks/tasks/resolve_model_catalog_reference_names.yml
```

Sets `model_catalog_reference_names` (canonical `lane` values only).

## Agent profiles

`default_lane` / `alternate_lane` MUST be catalog `lane` values (client IDs).
Cursor/Codex JSON is rendered from inventory by `roles/cursor` — do not hand-edit
a fourth vocabulary.

## Adding a published lane

1. Catalog row with `lane` == `client_model_id` plus `capability` / `client_roles`.
2. Matching LiteLLM route / `k3s_litellm_gateway_lane_contract` entry (same string).
3. Point agent profiles / CLI defaults at that `lane`.
4. Run `validate_ai_agent_client_profiles` and `validate_ai_inference_stack_contracts`.

## Pytest eval membership (homelab-model-lane-pytest)

Gateway journey probes live in `/Users/joshc/develop/homelab-model-lane-pytest`.
Opt a published lane into the default matrix with:

```yaml
pytest_eval:
  profiles: [eval-core]
```

Rules:

- `pytest_eval` is membership only — journeys/capabilities stay in the package
  `manifests/default.yml`.
- Package unit tests fail loud when enabled package IDs drift from catalog
  `pytest_eval` for profile `eval-core`.
- Do not put `retired` / `deprecated` / `pending_research` rows in `pytest_eval`.
- Operator profile: `just run --profile eval-core` (alias `commissioned-six`
  is deprecated).

When adding a model you intend to test: set `pytest_eval`, add a package lane
row with journeys, then run `just unit` in the pytest package.
