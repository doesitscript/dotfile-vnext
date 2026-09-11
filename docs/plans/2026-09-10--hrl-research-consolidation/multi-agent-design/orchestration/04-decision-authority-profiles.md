# Decision authority profiles

Portable approval routing for this design. Full detail lives here so campaign
configs can point at one stable path under `orchestration/`.

## `product_governed`

Expert Best becomes a **proposed** plan decision. Parent waits for human on
new consequential cost, outage, retention, destructive-target, or data-risk
choices. Implementer never silently Apply.

## `lab_recreatable_autonomy` (this campaign)

Non-production, recreatable, no availability commitment:

- Auto-adopt evidence-backed Expert **Best** as the selected technical default
- Treat Expert **Preference** as default when assumptions hold
- Continue sizing/placement/cutover/monitoring without human wait
- Keep exact target identity, fail-closed checks, validation, receipts, Evaluator

Does **not** allow guessing host/disk/path, bypassing Evaluator, or treating a
recommendation as Apply proof.

```yaml
decision_authority_profile: lab_recreatable_autonomy
environment_class: homelab_recreatable_nonproduction
availability_commitment: none
expert_defaults: auto_adopt_when_evidence_backed
apply_authority: campaign_scoped
target_identity: must_be_verified_before_apply
evaluator_review: required
```

See also [02-authority--who-to-call.md](02-authority--who-to-call.md).
