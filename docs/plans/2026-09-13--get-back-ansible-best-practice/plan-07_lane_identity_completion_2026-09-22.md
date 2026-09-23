# Plan 07 slice — lane identity completion (2026-09-22)

## Intent

Close plan-07 P1 “duplicate or mixed-purpose lane identities” for the live
autocomplete / edit vocabulary by making **plain LiteLLM client model IDs** the
canonical catalog `lane`, and demoting purpose-style names to capability
metadata / retired archaeology.

Correctness over operational bridging: prefer fail-loud if old purpose labels
reappear.

## Done this pass

| Item | Evidence |
| --- | --- |
| Catalog rows `qwen2.5-coder-1.5b-base-q8_0` and `qwen2.5-coder-7b` use `lane == client_model_id` | `inventory/group_vars/model_catalog/manifest.yml` |
| Purpose names → `capability` / `client_roles` / `deprecated_purpose_labels` | same |
| Strict resolver (canonical `lane` only + equality assert) | `playbooks/tasks/resolve_model_catalog_reference_names.yml` |
| End-state contract | `inventory/group_vars/model_catalog/LANE-IDENTITY.md` |
| Bridge pattern archived (dated) | `docs/archive/2026-09-22--model-lane-identity-bridge-deprecating.md` |
| Inventory refs updated (HVH-01 secondary runtime, ai_infra_inventory) | host/group vars |
| live-object-registry purpose slugs marked `retired` | `docs/reference/naming-standards/live-object-registry.yml` |
| Validators pass | `validate_ai_agent_client_profiles`, `validate_ai_inference_stack_contracts` |
| Cursor/Codex profiles re-rendered | `--tags cursor_ai_profiles` |

## Still open from plan-07 (not claimed complete)

| Finding | Status |
| --- | --- |
| P1 gateway backend vars still encode placement (`desktop_*`, placement as data) | open — structured deployments registry |
| P1 Continue/Cline defaults duplicated vs commissioned SSOT | partially improved historically; re-audit if drift returns |
| P1 token policy consistency | open / policy |
| P2 embedding ownership invariant | open |
| P2 mutable chart/image pins | open |
| P2 master-key plaintext fallback | open |

## Retired labels (do not reintroduce as `lane`)

- `code-autocomplete-1.5b`
- `code-autocomplete-7b`
- `code-fast`

## Commands

```bash
bin/codex-env ansible-playbook playbooks/validate_ai_agent_client_profiles.yaml \
  -i inventory/inventory.yaml
bin/codex-env ansible-playbook playbooks/validate_ai_inference_stack_contracts.yaml \
  -i inventory/inventory.yaml
bin/codex-env ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml --limit mac-dev --tags cursor_ai_profiles
```
