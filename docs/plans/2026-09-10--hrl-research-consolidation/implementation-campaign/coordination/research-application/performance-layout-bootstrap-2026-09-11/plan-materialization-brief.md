# Planner materialization brief — performance layout bootstrap

## What entered the canonical plan

The bootstrap packet is materialized through:

- [performance layout adoption](../../performance-layout-adoption.md), which
  records the tiered allocation and discovery gates;
- [decisions and authorization](../../decisions-and-authorization.md), which
  binds the applicable decisions to campaign authority; and
- [**refined technical handoff**](refined-technical-handoff.md), which is the
  **required** Implementer/Evaluator input: hard corrections, placement,
  functional areas → owners, and Light vs Full boundaries.

Classification alone (`research-to-decision-packet.md`) is **not** sufficient
to start Implementer. An unmapped recommendation remains incomplete.

These are current design inputs. They are not a claim that an exact storage
target has already been attached or that an Apply occurred.

## Translation responsibilities

| Consumer | Required interpretation |
| --- | --- |
| Planner / Coordinator | Map each applicable guidance class to the smallest owning role/playbook/inventory/configuration surface. Emit or refresh `refined-technical-handoff.md` with functional areas the Implementer can chunk. Keep illustrative research shell out of the handoff as mandatory commands. |
| Implementer | Read the refined technical handoff first. Derive/update `implementation-work-queue.md` from its functional areas. Translate one area at a time into idempotent Ansible through proven owners. Do not consume the onsite transcript as primary input. |
| Evaluator | Confirm each frozen chunk’s target state against the refined handoff area ID: Ansible quality, ownership, naming, hard corrections. Reject unowned config sprawl and Light safety-fixture theater. |

## Known orchestration gap

The parent runtime still begins at Implementer/Evaluator and does not yet
auto-schedule the full Research-Synthesizer ↔ Expert ↔ Planner loop. That
scheduling remains next-iteration work. **The missing handoff artifact itself
is no longer deferred:** use `refined-technical-handoff.md` as if Planner had
just completed materialization.
