---
name: chunked-light-pipeline-beta
description: "Turn a refined technical handoff into Implementer-owned Ansible intake chunks; Evaluator verifies each freeze against the handoff."
metadata:
  status: beta
  scope: light-source-first-pipeline
  workflow_id: chunked-evaluator-implementer-loop
  role: parent-orchestrator
---

# Chunked Light pipeline

Use only after the research ↔ On-site Expert ↔ Planner loop has produced a
**refined technical handoff** (work instructions + owner-mapped functional
areas). Do not launch workers on a raw transcript or classification-only packet.

1. Require the refined technical handoff as **Implementer primary input**
   (work instructions). Evaluator uses it as acceptance criteria only.
2. Let **Implementer** derive/refresh a dynamic work queue from the handoff’s
   functional areas, then **intake** each area into project Ansible owners.
3. Dispatch Implementer on one ready chunk (target state + owners first).
4. Require a snapshot-bound package: `chunk_id`, owners, hashes, diff,
   validation, `available_next_chunk`.
5. Dispatch Evaluator to **verify** that freeze: did they correctly adapt the
   handoff? Ansible quality only—do not re-teach handoff design details.
6. If the next area has non-overlapping owners and no dependency, dispatch
   Implementer to it while evaluation proceeds.
7. Feedback returns to its chunk only.

Never pipeline edits to the same role/playbook, queue file, inventory, live
target, storage identity, Apply, or final synthesis. A source/runtime conflict
pauses only dependent chunks and uses bounded Expert/Researcher consultation.
