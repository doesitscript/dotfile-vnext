---
name: chunked-light-pipeline-beta
description: "Turn a refined technical handoff into Implementer-owned, snapshot-bound Ansible owner chunks for pipelined Implementer/Evaluator review."
metadata:
  status: beta
  scope: light-source-first-pipeline
  workflow_id: chunked-evaluator-implementer-loop
  role: parent-orchestrator
---

# Chunked Light pipeline

Use only after the research ↔ On-site Expert ↔ Planner loop has produced a
**refined technical handoff** (owner-mapped functional areas). Do not launch
workers on a raw transcript or classification-only packet.

1. Require `refined-technical-handoff.md` (or equivalent path) as the primary
   Implementer/Evaluator input.
2. Let **Implementer** derive/refresh `implementation-work-queue.md` from the
   handoff’s functional areas. The queue is dynamic, not a frozen human script.
3. Dispatch Implementer on one ready chunk (target state + owners first).
4. Require a snapshot-bound handoff: `chunk_id`, owners, hashes, diff,
   validation, `available_next_chunk`.
5. Dispatch Evaluator against that frozen snapshot only; first question is
   whether the handoff target state is implemented.
6. If the next area has non-overlapping owners and no dependency, dispatch
   Implementer to it while evaluation proceeds.
7. Feedback returns to its chunk only.

Never pipeline edits to the same role/playbook, queue file, inventory, live
target, storage identity, Apply, or final synthesis. A source/runtime conflict
pauses only dependent chunks and uses bounded Expert/Researcher consultation.
