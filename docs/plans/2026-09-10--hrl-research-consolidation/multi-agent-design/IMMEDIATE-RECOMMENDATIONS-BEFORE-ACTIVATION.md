# Immediate recommendations — before role activation

**Purpose:** This is the single actionable pre-plan for the next phase of the
storage/research-consolidation work. It captures recommended work that belongs
outside this design folder, while keeping the current mature Implementer and
Evaluator contracts intact.

**Activation rule:** Do not start the Implementer/Evaluator loop for the
storage implementation until the `Immediate` rows below have been incorporated
into the implementation plan or explicitly deferred by the operator.

## Immediate recommendations

| ID | Recommendation | Immediate action before activation | Intended production home | Evidence of readiness |
| --- | --- | --- | --- | --- |
| IR-1 | Make implementation research a named plan input. | Add an implementation-readiness brief to the storage plan, using the template in `knowledge-capabilities/examples/`. | The active storage plan's coordination/plan artifacts. | Decision, owners, module/pattern options, preflight, acceptance checks, undo boundary, and open questions are present. |
| IR-2 | Compose existing Ansible knowledge; do not create a parallel authority. | In the next project-skill change, extend `.cursor/skills/ansible-knowledge-gate/` with the readiness-brief output and the configured/listed/callable MCP distinction. | Project skill: `ansible-knowledge-gate`. | The skill routes a Researcher/Implementer/Evaluator to one output contract without duplicating module discovery. |
| IR-3 | Make the workflow select expertise diagnostically. | Add a capability-selection row to the storage plan: domain research, Ansible implementation knowledge, and any other selected knowledge capability. | Active plan plus future project skill metadata. | Every selected capability has a trigger, authority map, caller, output, and boundary. |
| IR-4 | Bind implementation to research without weakening ownership. | Add the readiness-brief consumption requirement to the next revision of the mature implementer workflow. | Project implementer integration surface and its role documentation; do not alter evaluator-owned artifacts. | Implementer receipt maps implementation choices and deviations to the brief. |
| IR-5 | Give the evaluator a research-use rubric, not a duplicate research job. | Add the evaluator rubric to the next evaluator-skill/workflow revision. | Evaluator workflow/skill integration surface. | Feedback, waiting, or ready artifacts assess availability, traceability, fidelity, safety proof, and escalation. |
| IR-6 | Keep the control plane honest. | Before activating a multi-agent run, choose the operator/orchestrator wakeup path and record how each handoff is delivered. | Active plan's coordination section; existing external-orchestration contract. | Real actor IDs or operator steps, durable handoff artifacts, and stop conditions are documented. |

## What happens now versus later

### Now — include in the next implementation plan

1. Create the storage implementation-readiness brief from the supplied
   template.
2. Add IR-1 through IR-6 as explicit obligations, with an owner and acceptance
   evidence.
3. Select the knowledge capabilities needed for the plan; do not assume every
   available MCP resource applies.
4. Set the role activation gate: the brief must be `ready`, or unresolved
   questions must be explicitly deferred outside the current scope.

### After the plan is accepted, before the first role run

1. Verify every knowledge source used by the brief: configured, visible in the
   client namespace, and successfully invoked where callable proof matters.
2. Confirm role boundaries and durable artifacts: Researcher brief,
   Implementer `review_ready_for_evaluator_*`, and Evaluator
   `feedback_*`/`waiting_*`/`ready_*`.
3. Run the plan's read-only target and storage preflights.
4. Start the Implementer only after the Coordinator/Onsite Expert records that
   the activation gate is met.

### Later — promotion after trials

- Promote the Ansible capability draft only after the storage effort and at
  least two more independent Ansible efforts prove its stable core.
- Keep project-specific inventory, role, plan, and wrapper details in
  dotfile-vnext.
- Consider a global capability only if the reusable portion remains truthful
  without those project details.

## Role notes

| Role | Pre-activation note |
| --- | --- |
| Onsite Expert / Coordinator | [`multi-agent-onsite-expert/enhancements/pre-activation-routing-note.md`](multi-agent-onsite-expert/enhancements/pre-activation-routing-note.md) |
| Researcher | [`researchers/enhancements/pre-activation-research-note.md`](researchers/enhancements/pre-activation-research-note.md) |
| Implementer | [`implementer/enhancements/pre-activation-implementer-note.md`](implementer/enhancements/pre-activation-implementer-note.md) |
| Evaluator | [`evaluator/enhancements/pre-activation-evaluator-note.md`](evaluator/enhancements/pre-activation-evaluator-note.md) |

## Non-negotiable boundaries

- Research informs implementation; it is not deployment authority.
- Implementers may not create evaluator approval artifacts.
- Evaluators may request or spot-check research, but may not become the
  Implementer.
- A configured MCP is not proof that a role can invoke its tools or resources.
- Repeated unresolved feedback triggers targeted research, not blind patches.
