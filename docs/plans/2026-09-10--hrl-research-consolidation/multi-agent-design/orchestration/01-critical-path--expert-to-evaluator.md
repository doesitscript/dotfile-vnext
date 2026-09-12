# 01 — Critical path: Expert work area → Evaluator

Concise extract of the primary multi-agent coordination path for this design
project. Source material lives in role folders; this file is the map.

## Scaffolding (must survive every handoff)

1. **Expert frames a work area** (problem, surfaces, decision questions).
2. **Researchers** (Context7 / library / probes) answer those questions.
3. **Expert challenges** findings and settles recommendations.
4. **Planner** maps decisions → project owners → **refined technical handoff**.
5. **Implementer** intakes the refined handoff as work instructions, chunks
   functional areas into Ansible owner edits, and hands each freeze to
   Evaluator.
6. **Evaluator** verifies each frozen chunk (adaptation + Ansible quality).
   Feedback loops only on that chunk; Implementer may advance the next
   non-overlapping area. Evaluator does not re-teach the handoff.

The Expert conversation → research-enhanced recommendation → refined handoff
is the critical deliverable. Downstream: Implementer **implements from that
package**; Evaluator **checks the implementation**—not the transcript.

Campaign example handoff:
[05-refined-technical-handoff--storage-layout.md](05-refined-technical-handoff--storage-layout.md)

Expert on-call after the heavy pass:
[06-expert-on-call--lab-consultation.md](06-expert-on-call--lab-consultation.md)
(On stuck forks or missing by-id: Expert finds facts read-only via project
inventory/SSH/Ansible—Implementer does not guess and does not ask the human.)

## Diagrams

- [Critical path](diagrams/01-critical-path.mmd)
- [Role handoffs](diagrams/02-role-handoffs.mmd)

## Related

- [02 Authority — who to call](02-authority--who-to-call.md)
- [03 Handoffs and loops](03-handoffs-and-loops.md)
- [04 Decision authority profiles](04-decision-authority-profiles.md)
- [Examples: research transforms](examples/storage-layout-research-transforms/README.md)
- [07 Runtime surfaces — broker vs peer MCP](07-runtime-surfaces--broker-vs-peer-mcp.md)
- Light default: [light-profile-rationale-2026-09-11.md](light-profile-rationale-2026-09-11.md)
- Chunk pipeline: [chunked-light-pipeline-workflow.md](chunked-light-pipeline-workflow.md)
