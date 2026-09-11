# Planner materialization brief — performance layout bootstrap

## What entered the canonical plan

The bootstrap packet is materialized through:

- [performance layout adoption](../../performance-layout-adoption.md), which
  records the tiered allocation and discovery gates; and
- [decisions and authorization](../../decisions-and-authorization.md), which
  binds the applicable S3–S5 decisions to campaign authority.

These are current design inputs. They are not a claim that an exact storage
target has already been attached or that an Apply occurred.

## Translation responsibilities

| Consumer | Required interpretation |
| --- | --- |
| Planner / Coordinator | Map each applicable guidance class to the smallest owning role/playbook/inventory/configuration surface, plus exact target binding, Apply/Verify/Undo, and acceptance metric. Keep general principles general until a live owner makes them concrete. |
| Implementer | Treat hard corrections and prohibitions as non-negotiable where applicable. Translate placement principles into idempotent Ansible through proven owners; do not copy illustrative shell commands or create new global configuration without ownership evidence. Record an exception only for genuine live/source conflict. |
| Evaluator | Confirm technical guidance was neither ignored nor over-literalized: each mutation has an owner, constraint/rationale, target proof, validation, rollback, and no unjustified change to durable data or kubelet accounting. Reject unsupported performance claims and configuration sprawl. |

## Known orchestration gap

The current beta implementation runtime begins at Implementer/Evaluator. It
does not automatically invoke the prior Research Synthesizer ↔ Expert ↔ Planner
cycle or decide the best moment to run it. That timing, packet routing, and
automated repeat-pass policy remain next-major-iteration work, documented in
[the accepted gap](../../../../ACCEPTED_GAP_NEXT_IMPROVEMENT.md) and
[the guided research-application loop](../../../../multi-agent-design/research-application-loop.md).
