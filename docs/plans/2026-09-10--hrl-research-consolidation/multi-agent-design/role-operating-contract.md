# Role operating contract — planning through implementation

## Purpose and current boundary

This is the next definition pass for the roles used by the storage campaign.
It turns the observed consultation and blocker-resolution work into a reusable,
artifact-driven contract. It does **not** claim that the current beta runner
automatically launches every role: it currently schedules only Implementer and
Evaluator. Earlier roles are invoked through bounded artifacts until that
larger orchestration is implemented.

The canonical plan and evidence packet are the shared memory of the workflow.
No role may depend on another agent's private conversation as the sole source
of a decision, recommendation, target identity, or approval.

## Common invariants

1. Every role reads the current canonical plan, authority profile, relevant
   receipts, and its direct input artifact before acting.
2. Evidence has a bounded lifetime and an owning path. A recommendation cites
   its evidence, assumptions, validation, rollback, and affected plan slice.
3. `lab_recreatable_autonomy` changes approval routing only. It does not waive
   exact-target verification, fail-closed checks, receipts, tests, or Evaluator
   review. `product_governed` retains the human wait for consequential choices.
4. Consultation resolves a named fork; it is not permission to restart broad
   research, redesign the campaign, or replace the planned implementation.
5. A deviation exists only when authoritative source or live evidence conflicts
   with the materialized plan. Record the conflict and proposed alternative;
   never call an ordinary Expert clarification a deviation.
6. A role writes only its owned artifact class. The Evaluator owns verdicts;
   the Implementer owns source changes, receipts, and review-ready handoffs.

## Operating sequence

| Stage | Owner | Consumes | Produces / exit condition |
| --- | --- | --- | --- |
| Frame and plan | Coordinator / Planner | intake, research index, constraints, authority profile | canonical plan with decisions, acceptance criteria, rollback and known assumptions |
| Apply research to the problem | Research Synthesizer ↔ Resident Expert | decision questions, user constraints, research, current receipts, topology and configuration surfaces | challenged research-to-decision packet and selected recommendation |
| Resolve a fork | Resident Expert | canonical plan and matching current evidence | scoped recommendation: `best_recommendation` or `preference`, confidence, assumptions, validation, rollback |
| Fill an evidence gap | Researcher | exact question, evidence inventory, return target | evidence delta that changes a named decision or confirms its current basis |
| Implement | Implementer | materialized plan, Expert packet/profile, current Evaluator feedback | bounded source changes, tests/receipts, `review_ready_for_evaluator_*` |
| Independently assess | Evaluator | exact changed state, receipt, profile and recommendation | `feedback_*`, `waiting_*`, or `ready_*`; no implementation edits |
| Schedule and retain | Parent Orchestrator | durable role events and ownership manifest | one next-role dispatch, progress/stop receipt, execution record/checkpoint before cleanup |

## Consultation classifier

| Signal | Route | Result |
| --- | --- | --- |
| Plan already contains a safe, evidenced decision | Implementer | Continue; do not consult merely to re-confirm it. |
| Bounded technical sizing, placement, sequencing, or tool question | Resident Expert | Recommendation binds the plan under the selected profile when assumptions hold. |
| Missing, stale, or conflicting fact | Researcher, then Resident Expert | Targeted evidence delta; no broad rediscovery. |
| Exact target identity absent | Read-only discovery | Bind identity before Apply; this is an evidence gate, not a lab human wait. |
| Source/runtime contradiction | Implementer → Evaluator | Documented exception/deviation and independent review. |
| Consequential choice outside declared lab scope or under product profile | Human operator | Smallest explicit decision, then materialize it in the canonical plan. |

## Roles in more complete form

### Coordinator / Planner

Materializes research and Expert recommendations into a plan before
implementation. It selects a declared authority profile, resolves conflicts in
the evidence packet, records acceptance criteria, and gives Implementer a
closed-enough technical route. It never substitutes an unrecorded preference
for a plan decision or grants Apply authority by implication.

### Resident / On-site Expert

Consumes the plan's organized research and live receipts before making a
recommendation. It gives the best evidence-backed answer to a narrow fork,
not a parallel implementation. In this campaign it may provide the S3/S4/S5
technical defaults; the Coordinator records them and the profile decides
whether they are adopted or wait for human authority.

### Researchers and knowledge capabilities

Refresh only the exact missing knowledge. Their output is a reusable evidence
delta linked to a question and a returning role, including source status and
how the result affects a decision. They are not a general audit lane launched
because an Implementer starts.

For multi-technology work, the Research Synthesizer specialization owns the
intermediate application pass: cross-reference research with current state and
project surfaces; produce decision packets; accept Expert challenges; and make
focused follow-up passes. It does not choose the plan or apply changes.

### User / project sponsor

The user can collaboratively frame desired outcomes, tradeoffs, constraints,
and corrections to the problem model alongside the Expert. The Coordinator
records these as durable inputs to the packet so they can be reused by future
agents. This is design guidance, not a requirement that the user approve each
ordinary evidence-backed technical decision in a lab autonomy profile.

### Implementer

Treats the canonical plan as the design baseline. It makes the smallest
scoped implementation, proves it with tests and receipts, and applies an
in-scope Expert default when the profile says so. It asks for consultation only
when a named doubt or evidence gap prevents safe continuation. It does not
turn consultation into a re-plan, make evaluator verdicts, or silently choose
an alternative after a source/runtime conflict.

### Evaluator

Independently checks changed state, receipts, acceptance criteria, the selected
authority profile, and recommendation/exception fit. It rejects unsupported
claims or incomplete safety proof, but does not write fixes. Its review
establishes whether the materialized plan was faithfully and safely executed;
an Expert recommendation alone is never implementation approval.

### Parent Orchestrator and Observer

The parent schedules only durable next-role events, owns runtime lifecycle,
and captures a timestamped stop receipt plus execution record/checkpoint before
any cleanup discussion. The Observer reports facts and emerging risks but does
not route, approve, or mutate work. Both distinguish dashboard/runtime health
from plan or infrastructure correctness.

## Demonstrated storage application

The S4 decision demonstrates the intended flow: prior research and discovery
identified a bounded capacity fork; the Resident Expert recommended a 200 GiB
fixed VHDX, reserve, slot, mount, validation and reversal; the lab profile
materialized it as the default; the Implementer still must correct the three
Evaluator findings and prove target identity before any Apply. This is not a
human wait, and it is not an Implementer deviation unless current source or
runtime evidence contradicts the recommendation.

## Implementation readiness for the next playbook pass

The next pass should consume the canonical campaign decisions, the On-site
Expert recommendation, and the current Evaluator feedback together. It is
ready to implement the named S4 corrections and then submit a fresh review
handoff. A live storage Apply remains gated on those corrected tests, exact
identity checks, and a new Evaluator verdict.

## Next-major-iteration extension: performance and placement pass

Before plan materialization, Researchers/Organizers should turn relevant
technology research into a compact workload-to-storage matrix: I/O pattern,
durability class, current location, available hardware tier, compatibility
constraints, expected gain, and proof metric. A hardware collector supplies
current paths, device identity, capacity, and attachment facts. The Resident
Expert then chooses a bounded allocation; the Planner maps each accepted row to
an existing configuration surface and a verification/rollback path. This is the
automation target demonstrated by the current user-led performance pass, not an
invitation to re-run broad research on every implementation loop.

The [guided research-application loop](research-application-loop.md) now
defines the multi-pass ownership that this extension requires.

## Related material

- [Decision authority profiles](decision-authority-profiles.md)
- [Role interaction expansion](role-interaction-expansion.md)
- [Suggested overall workflow](SUGGESTED-OVERALL-WORKFLOW.md)
- [Implementation integration contract](orchestration/implementation-beta-contract.md)
