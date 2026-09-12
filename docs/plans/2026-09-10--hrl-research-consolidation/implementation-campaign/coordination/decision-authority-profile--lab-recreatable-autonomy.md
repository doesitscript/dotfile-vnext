---
title: Decision authority profile — lab_recreatable_autonomy
campaign_id: hrl-storage-implementation-beta-01
decision_authority_profile: lab_recreatable_autonomy
status: active
---

# Decision authority profile (campaign pin)

Canonical prose:
`multi-agent-design/orchestration/04-decision-authority-profiles.md`

```yaml
decision_authority_profile: lab_recreatable_autonomy
environment_class: homelab_recreatable_nonproduction
availability_commitment: none
expert_defaults: auto_adopt_when_evidence_backed
apply_authority: campaign_scoped
target_identity: must_be_verified_before_apply
evaluator_review: required
```

## Hands-free rule

When an evidence-backed Expert **Best** (or Preference whose assumptions hold)
exists in `expert_recommendation_path` / refined handoff / operator resolution,
**auto-adopt it**. Do not create `waiting_for_operator` merely to choose among
already-researched options.

Human wait remains only for: missing Apply authority for live mutation,
unproven target identity that cannot be bound without inventing facts, or an
explicit product_governed consequential choice (not this campaign).
