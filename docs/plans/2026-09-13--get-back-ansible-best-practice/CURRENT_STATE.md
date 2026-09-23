# Ansible best-practice refactor — current state

Status date: 2026-09-22  
Prior snapshot: 2026-09-15 (`v10.5.0-beta` / `2bd1e3e3`)

## Completeness (plan-07 identity slice)

| Slice | Status | Notes |
| --- | --- | --- |
| Mixed-purpose catalog lane IDs (P1) | **closed for live FIM/edit vocabulary** | `lane == client_model_id`; purpose → capability metadata |
| Dual-vocab validation bridge | **removed** | archived `docs/archive/2026-09-22--model-lane-identity-bridge-deprecating.md` |
| Agent profiles ↔ catalog | **pass** | client IDs only |
| LiteLLM lane_contract ⊆ catalog lanes | **pass** | strict lane match |
| Placement-encoded gateway vars (P1) | open | still needs structured deployments registry |
| Client catalog duplication (P1) | open / monitor | Continue/Cline historically rendered from `ai_cli_apps.yml` |
| Token policy (P1) | open | |
| Embedding ownership invariant (P2) | open | |
| Chart/image pins + vault fail-closed (P2) | open | |

Receipt: [plan-07_lane_identity_completion_2026-09-22.md](./plan-07_lane_identity_completion_2026-09-22.md)

## Current implementation

### Model identity (2026-09-22)

- Contract: `inventory/group_vars/model_catalog/LANE-IDENTITY.md`
- Catalog SSOT: `inventory/group_vars/model_catalog/manifest.yml`
- Agent roles: `inventory/group_vars/all/ai_agent_profiles.yml` (client model ids)
- CLI commissioned models: `inventory/group_vars/all/ai_cli_apps.yml` (already client ids)

Canonical examples:

| Lane (canonical) | Capability metadata |
| --- | --- |
| `qwen2.5-coder-1.5b-base-q8_0` | `capability: code_completion` / autocomplete |
| `qwen2.5-coder-7b` | `capability: code_edit` / edit+apply |
| `qwen3-coder-30b-a3b` | `capability: code_agent` |
| `ministral-3-8b` | `capability: fast_chat` |

### Client contracts (2026-09-15 baseline, still true)

`ai_cli_client_model_contracts` defines which model roles each client may
consume. Continue accepts chat, edit, apply, autocomplete, and embed. Cline,
OpenCode, and Kilo accept chat, edit, and apply. FIM-only and embed-only lanes
stay out of agent-client catalogs.

## Current evidence (2026-09-22)

```text
validate_ai_agent_client_profiles.yaml     → failed=0
validate_ai_inference_stack_contracts.yaml → failed=0
deploy_development_nodes --tags cursor_ai_profiles → profiles re-rendered
```

Prior 2026-09-15 client convergence (unchanged claim):

```text
Cline:    ok=23 changed=2 failed=0
OpenCode: ok=16 changed=0 failed=0
Kilo:     ok=62 changed=1 failed=0
Continue: ok=16 changed=0 failed=0
```

## Evidence boundaries

Identity slice does **not** claim: full structured deployment registry, token
policy convergence, embedding invariant automation, or chart pin / vault
fail-closed work.

## Document map

- [Plan 07 anti-pattern audit](plan-07_antipattern_audit.md)
- [Plan 07 lane identity completion 2026-09-22](plan-07_lane_identity_completion_2026-09-22.md)
- [Plan 06 validation history](plan-06_validating_final_step.md)
- [Plan 13 Cline review](plan-13_cline_client_compatibility_review_reviewed.md)
- [Plan 14 client evaluation receipt](plan-14_clien_and_other_cli_evaluation_reviewed.md)
- [Plan 15 historical evaluation](plan-15_clien_and_other_cli_evaluation_executed_reviewed.md)
- [Plan 15b review input](plan-15b_re-reviewed.md)
- [Plan 15b execution receipt](plan-15b_re-reviewed_executed.md)
- [Archived bridge 2026-09-22](../../archive/2026-09-22--model-lane-identity-bridge-deprecating.md)

## Documentation Provenance

- Origin: plan-07 P1 identity closure after LiteLLM recovery / agent-profile
  validation drift (2026-09-22).
- Root source of truth: `model_catalog/manifest.yml` + `LANE-IDENTITY.md` +
  `ai_agent_profiles.yml` + `ai_cli_apps.yml`.
- Skills used: `homelab-ansible-first-entry`, `verification-before-completion`.
