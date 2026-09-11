# Planner / Coordinator — research application and plan composition

**Date:** September 10, 2026  
**Purpose:** Turn organized research and Expert recommendations into a
materialized implementation plan without asking Implementer or Evaluator to
reconstruct the planning work.

---

## Role boundary

The Planner/Coordinator is the second middle role after research synthesis. It
does not merely summarize research or generate a generic `plan.md`. It consumes
the Expert-approved decision packet and maps it to actual project surfaces:
roles, playbooks, inventory, configuration owners, target binding, safe order,
tests, validation, rollback, and Evaluator obligations.

It works iteratively with the On-site Expert and Research Synthesizer. When a
recommendation cannot be mapped to an owner or acceptance test, it returns the
specific gap instead of giving the open problem to Implementer.

## Guided plan-composition cycle

1. Read the User/Expert problem frame and authority profile.
2. Consume research-to-decision packets, rather than raw broad research alone.
3. Challenge missing project mappings, unsupported performance claims, or
   unclear rollback with the Expert/Synthesizer.
4. Materialize only accepted decisions into plan slices.
5. Produce a canonical plan whose inputs are bounded for Implementer and whose
   acceptance obligations are independently checkable by Evaluator.
6. Emit `refined-technical-handoff.md` under the campaign research-application
   packet: hard corrections, placement, functional areas → owners, Light vs
   Full boundary. Implementer derives the dynamic work queue from that file;
   Evaluator reviews chunks against it. Classification-only packets are not
   enough to activate the pair.

The complete interaction and packet schema are in
[the guided research-application loop](multi-agent-design/orchestration/03-handoffs-and-loops.md).
The current [refined technical handoff](multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md)
and [historical research transforms](multi-agent-design/orchestration/examples/storage-layout-research-transforms/)
demonstrate the required Implementer/Evaluator package.

## Future Workflow Vision

### Planned Enhancement:
In future iterations, the planner agent should:

1. **Consume synthesis packets** created from HRL research, receipts, current
   configuration, and topology—not a raw directory scan as the sole input.
2. **Map each accepted decision** to the smallest relevant owner and current
   configuration surface.
3. **Generate implementation guides** only where the owner/contract is missing.
4. **Create a consolidated plan** with:
   - Architecture diagrams
   - Apply/Verify/Undo steps
   - Ansible role integration points
   - Verification receipts

### Workflow Steps:
```
Research collection (Context7)
    ↓
Research Synthesizer ↔ On-site Expert
    ↓
Planner / Coordinator ↔ On-site Expert
    ↓
Plan Generation (plan.md)
    ↓
Implementation (Ansible roles/playbooks)
    ↓
Validation (receipts)
```

## Current State

- **Research complete:** Storage, disk management, cache offload topics
- **Research in progress:** Ansible execution scaling, quality gates (not yet finished)
- **Consolidation needed:** Transform scattered Context7 entries into cohesive plans

## Non-negotiable completion criteria

- Every plan decision links to a research-to-decision packet and a selected
  Expert recommendation.
- Every mutation identifies its owning project surface, exact target-binding
  requirement, validation and rollback path.
- The user’s outcome/constraint input is preserved as a plan constraint, not
  left only in a conversation.
- Unanswered questions return to the Expert/Synthesizer loop before activation.

---

**Status:** Planning phase - awaiting Ansible research completion
