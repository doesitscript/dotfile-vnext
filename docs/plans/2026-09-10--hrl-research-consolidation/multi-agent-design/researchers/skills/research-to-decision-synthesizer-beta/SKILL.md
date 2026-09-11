---
name: research-to-decision-synthesizer-beta
description: Convert Expert research and verified current-state evidence into decision packets and a Planner-ready refined technical handoff for Implementer/Evaluator. Use during planning; do not implement infrastructure.
metadata:
  status: beta
  scope: research-application-planning
  workflow_id: guided-research-application
  role: research-synthesizer
  counterpart_roles: onsite-expert, planner-coordinator
---

# Research-to-decision Synthesizer — beta

Use when a supplied Expert document, research pack, or user/Expert collaboration
must become reusable planning input. Context7-style packs are the Researcher
lane; this skill organizes them for Expert challenge—not for Implementer.

## Inputs

Nominated source document(s), campaign location, Expert decision questions,
user constraints, current receipts/topology/config. Preserve sources as
provenance. A transcript is **not** a plan; extract findings into packets.

## Produce bounded packets

Classify findings: hard correction, placement/design principle,
durability/safety prohibition, conditional option, discovery/validation.

Write under a campaign research-application packet **or** directly into the
orchestration handoff when the design packet owns it:

1. `research-to-decision-packet.md` — classified evidence for Expert
2. After Expert acceptance, support Planner in emitting a
   **refined technical handoff** — owner-mapped functional areas, hard
   corrections, Light vs Full boundary (required before Implementer)

Keep general guidance general until Planner maps owners. Do not force device
paths or shell commands as the only mechanism.

Follow [the guided research-application loop](../../../orchestration/03-handoffs-and-loops.md).

## Iterate with the Expert

Return only named ambiguities. Stop when decision questions are answered or
exact missing facts are named. Post-challenge refinements (new traps, Ansible
practice defects, mechanism clarifications) must land in the next packet
revision—**not** only in chat.

## Boundaries

No Apply authority, no implementation source edits, no treating research as
Evaluator approval. Runtime may not auto-schedule this skill yet; the artifact
contract is mandatory whenever the loop is run manually or by a parent.

Example shape:
[storage-performance-research-application.md](../../../multi-agent-onsite-expert/examples/storage-performance-research-application.md)
→ [refined handoff](../../../orchestration/05-refined-technical-handoff--storage-layout.md)
plus historical campaign transforms under
[orchestration/examples/storage-layout-research-transforms/](../../../orchestration/examples/storage-layout-research-transforms/).
