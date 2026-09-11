# Guided research-application loop

## Purpose

Broad research is useful only when it becomes a better answer to the current
problem. This contract defines the missing middle loop between collection and
implementation. It prepares a later pass to consume a supplied research or
Expert document; it does not itself evaluate or adopt any technology guidance.

## Participants

| Participant | Responsibility in the loop | Does not do |
| --- | --- | --- |
| User / project sponsor | Supplies desired outcomes, constraints, tradeoffs, and correction of assumptions. Those inputs become durable plan constraints. | Need not manually make ordinary in-scope technical choices under the selected autonomy profile. |
| On-site / Resident Expert | Frames the problem, selects the decision questions, interrogates synthesis results, and issues the final evidence-backed recommendation. | Organize a broad library alone or write the implementation plan. |
| Research Synthesizer (a Researcher specialization) | Cross-references findings, verified current state, hardware/topology, and current configuration surfaces into decision packets. Iterates with the Expert. | Choose authority, make Apply changes, or treat a finding as a plan decision. |
| Planner / Coordinator | Turns accepted recommendations into a materialized, scoped execution plan mapped to concrete project owners, tests, validation, and rollback. Returns missing mappings to the loop. | Re-research already resolved questions or replace Evaluator approval. |
| Implementer / Evaluator | Consume the materialized plan and independently prove its execution/review. | Recreate the planning loop unless a named evidence conflict requires it. |

## Iterative contract

1. **Frame.** The User and Expert define outcome, constraints, decision scope,
   risk/authority profile, and success metrics. The Expert writes decision
   questions—not generic research topics.
2. **Synthesize.** The Research Synthesizer inventories applicable research,
   current-state receipts, topology/hardware facts, and repository configuration
   surfaces. For each question it creates a concise decision packet: evidence,
   alternatives, compatibility constraints, assumptions, expected benefit,
   proof metric, and unresolved facts.
3. **Expert challenge.** The Expert reviews the packet, asks focused follow-up
   questions, rejects unsupported conclusions, and requests another bounded
   synthesis or research refresh when needed. This is the intended back-and-
   forth, not a single terminal handoff.
4. **Materialize.** Once the Expert has a recommendation, the Planner maps it to
   the smallest relevant roles, playbooks, inventory/configuration surfaces,
   sequence, validation, rollback, and acceptance criteria. An unmapped
   recommendation is incomplete, not an Implementer task.
5. **Plan-quality review.** Before implementation activation, the Planner checks
   that every planned change has a source path, evidence/rationale, exact target
   binding requirement, and measurable success condition. Gaps return to the
   appropriate previous participant.
6. **Handoff.** The canonical plan records both the selected decision and its
   evidence lineage. Implementer and Evaluator get that packet, not a raw
   transcript or an unfiltered research dump.

## Required packet shapes

### Research-to-decision packet — owned by Research Synthesizer

```yaml
decision_id: stable-scope-local-id
problem_question: exact question the Expert is resolving
user_constraints: durable outcome, limits, and preferences
current_state: paths to verified receipts and configuration surfaces
evidence: source-backed findings and confidence
alternatives: considered approaches with fit/rejection reason
compatibility_constraints: hard technical or ownership limits
assumptions_and_unknowns: targeted facts still required
expected_benefit: observable outcome, not a generic best-practice claim
proof_metrics: measurements that would confirm or reject the benefit
return_to: onsite_expert
```

### Materialized plan decision — owned by Planner / Coordinator

```yaml
decision_id: same stable id
expert_recommendation: selected option and rationale
authority_profile: selected decision routing
project_surfaces: roles, playbooks, inventory, configuration, ownership
execution_sequence: dependencies and safe order
target_binding: required exact live identity before Apply
validation: before/after and workload acceptance checks
rollback: retained source, reversal action, and boundary
implementer_input: bounded work item
evaluator_input: independent acceptance obligations
```

## Stop and return conditions

- The Synthesizer stops when the packet answers the Expert's question or names
  the exact missing fact; it does not expand research because adjacent topics are
  interesting.
- The Expert stops when it can choose a recommendation under the authority
  profile or has framed the smallest external decision required by a product
  profile.
- The Planner stops before activation when an accepted recommendation cannot be
  mapped to an owning project surface, target binding, validation, or rollback.
- During framing, synthesis, and plan materialization, a named ambiguity about
  evidence, applicability, owner mapping, measurable benefit, or a safety
  boundary returns to the Expert/Synthesizer loop. Once a materialized plan is
  in the Implementer/Evaluator stage, only a real source/runtime conflict or
  newly discovered safety contradiction reopens the design loop; ordinary
  implementation findings remain in the normal repair cycle.

## Current runtime boundary

The beta parent runtime does not yet launch this loop automatically. It remains
a durable artifact contract and a role definition for the next orchestration
iteration. A future run can use this contract to process a nominated research
document without changing the role boundaries again.

The current [performance-layout bootstrap packet](../implementation-campaign/coordination/research-application/performance-layout-bootstrap-2026-09-11/README.md)
is the first retrospective example of this contract: it retains a user/Expert
source, gives the Research Synthesizer classification ownership, and gives the
Planner, Implementer, and Evaluator their distinct downstream interpretation
responsibilities.
Its retained source example is [storage performance research application](multi-agent-onsite-expert/examples/storage-performance-research-application.md).
