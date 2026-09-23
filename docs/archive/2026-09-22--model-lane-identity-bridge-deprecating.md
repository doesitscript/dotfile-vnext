---
title: Model lane identity bridge (deprecated)
archived_at: 2026-09-22
superseded_by: inventory/group_vars/model_catalog/LANE-IDENTITY.md
related_plan: docs/plans/2026-09-13--get-back-ansible-best-practice/plan-07_antipattern_audit.md
status: deprecated
---

# Archived — dual-vocabulary bridge (2026-09-22)

## Why this existed

On 2026-09-22 a short-lived bridge accepted:

```text
lane ∪ aliases ∪ client_model_id
```

so agent profiles using LiteLLM client IDs could pass validation while the
catalog still used purpose-style primary keys (`code-autocomplete-1.5b`) with
client IDs only as aliases.

That fixed a validation hole but **preserved** the plan-07 P1 anti-pattern
(mixed-purpose lane identities).

## Why it was removed

Correctness target:

- canonical `lane` **equals** LiteLLM client model id
- purpose / capability are metadata (`capability`, `client_roles`, `purpose`)
- purpose labels (`code-fast`, `code-autocomplete-*`) are **not** accepted
  references — fail loud instead of silent alias bridging

## Replacement

See current `inventory/group_vars/model_catalog/LANE-IDENTITY.md` and
`playbooks/tasks/resolve_model_catalog_reference_names.yml`.

Plan-folder receipt:
`docs/plans/2026-09-13--get-back-ansible-best-practice/plan-07_lane_identity_completion_2026-09-22.md`
