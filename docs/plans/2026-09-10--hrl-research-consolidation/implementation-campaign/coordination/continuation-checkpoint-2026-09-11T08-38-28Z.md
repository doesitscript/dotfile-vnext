# Continuation checkpoint — implementation beta 01

## Captured state

- Campaign: `hrl-storage-implementation-beta-01`
- Terminal run: `hrl-storage-implementation-beta-01-parent-20260911t074328z`
- Run result: `incomplete`; finite pass limit reached after 13 completed turns.
- Last governed artifact: [`feedback_for_review_by_evaluator_2026-09-11T083117Z.md`](../feedback_for_review_by_evaluator_2026-09-11T083117Z.md)
- Runtime: session archived; owner and all owned processes stopped as observed
  at this checkpoint.
- Apply authority: closed. No live storage Apply was authorized or recorded.
- Full transcript/runtime evidence: [`execution record`](../execution-records/2026-09-11T074328Z-implementation-beta-01/README.md).

## Resume from this exact boundary

The next actor is **Implementer**. Address only the three final Evaluator S4
corrections, then publish a new receipt and `review_ready_for_evaluator_*`
outbox. Do not re-run completed discovery merely to recreate evidence.

1. In `roles/linux_data_disk_mount/tasks/absent.yml`, use an exact mountpoint
   lookup rather than `findmnt --target`; add an already-unmounted rerun test.
2. In `roles/linux_data_disk_mount/tasks/{present,absent,derive_partition}.yml`,
   reject anything other than a stable whole-disk `/dev/disk/by-id/` input before
   partitioning; add a populated negative test for a raw/unstable device path.
3. In `roles/hyperv_vm_data_disk/tasks/present.yml`, recheck the selected host
   free-space reserve immediately inside the mutation-capable VHDX creation
   operation; extend the static/safety fixture to prove it.

## Required evidence for the next handoff

- Syntax, focused lint, controller-local safety checks, and target/task listing.
- A fresh correction receipt binding the changed owners and commands to their
  outputs.
- A new Implementer outbox with hashes and an explicit `next_actor: evaluator`.
- Evaluator review remains required; neither this checkpoint nor prior runtime
  success constitutes approval.

## Remaining campaign boundaries

- S3 stays blocked on persistent-backing target, backup, cutover, health,
  integrity, and reversal evidence.
- S4 stays closed to Apply until the three corrections above are independently
  accepted and a physical-selection decision is available.
- S5 stays blocked on monitoring owner and policy values.

This checkpoint is an operational restart index, not a replacement for the
Evaluator-owned feedback or authorization ledger.
