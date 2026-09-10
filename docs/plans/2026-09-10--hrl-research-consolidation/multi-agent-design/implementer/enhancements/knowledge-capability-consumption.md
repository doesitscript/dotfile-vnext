# Enhancement — consume knowledge capabilities before implementation

## Intent

When a plan has a task-specific implementation-readiness brief, the Implementer
must treat it as a design input and evidence map, not as generic background.

## Additive implementer behavior

1. Read the relevant capability brief before selecting implementation details.
2. Map every selected role, playbook, inventory surface, and verification step
   to the brief or state why it differs.
3. Record deviations in the implementation receipt with new evidence; do not
   silently replace the researched approach.
4. Use the brief's preflight and acceptance checks as a minimum, then add
   execution evidence appropriate to the actual change.
5. If a blocking research question remains, stop at the safe boundary and hand
   it back to the Researcher/Coordinator. Do not paper over it with shell work.

## Boundary preserved

The Implementer still owns code, Ansible execution, receipts, and the
`review_ready_for_evaluator_*` handoff. It does not author evaluator feedback,
approve its own research, or decide that an MCP resource is authoritative
without recording availability and source evidence.
