# Decision authority profiles

This design keeps approval/governance logic portable while allowing this
homelab to operate autonomously within a declared, recreatable scope. A profile
is an input to plan creation and role invocation; it is not agent memory or an
implicit permission grant.

## Product baseline: `product_governed`

Use for a future commercial/customer deployment. An evidence-backed Expert
default becomes a proposed plan decision, but the parent enters a human waiting
state for a new consequential cost, outage, retention, destructive-target, or
data-risk decision. Implementer never silently converts that proposal into an
Apply action.

## This lab override: `lab_recreatable_autonomy`

Use only when the campaign explicitly states that the target is non-production,
recreatable, and has no availability commitment. This profile:

- automatically adopts an evidence-backed Expert **Best recommendation** as
  the selected technical plan decision;
- treats Expert **Preference** as the default when its stated assumptions hold;
- permits the parent to continue through sizing, placement, cutover, and
  monitoring choices without a human waiting state; and
- preserves all technical safety controls: exact target identity, fail-closed
  checks, validation, reversal where meaningful, receipts, and independent
  Evaluator review.

It does **not** permit guessing an unknown host/disk/path, bypassing an
Evaluator finding, treating a recommendation as evidence of successful Apply,
or operating outside the campaign's declared lab scope. If identity/evidence is
missing, the workflow performs the narrow read-only discovery needed to bind
the target; that is an evidence gate, not a human-approval gate.

## Required profile fields

The future plan/authority record should carry these fields so roles can act
deterministically:

```yaml
decision_authority_profile: lab_recreatable_autonomy
environment_class: homelab_recreatable_nonproduction
availability_commitment: none
expert_defaults: auto_adopt_when_evidence_backed
apply_authority: campaign_scoped
target_identity: must_be_verified_before_apply
evaluator_review: required
```

When the system is adapted for a product, select `product_governed` or remove
the lab profile. The human-decision paths remain present and activate without a
workflow rewrite.

## Planning-stage behavior

Research and current-state evidence are first organized into the canonical plan
packet. The On-site Expert consumes those artifacts, resolves bounded forks,
and emits a recommendation with evidence, confidence, assumptions, validation,
and rollback. The Planner/Coordinator applies the selected authority profile:

- In this lab, it materializes the recommendation as the plan's technical
  default and sends that decision package to Implementer and Evaluator.
- In a governed product profile, it materializes a proposed decision and asks
  the smallest relevant human question only when the profile requires it.

The Implementer therefore receives a largely materialized plan, not an open
research problem. Expert consultation is used to resolve an identified doubt;
it does not restart planning or sidetrack the implementation loop.
