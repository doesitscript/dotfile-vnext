# On-site Expert correction blockers — test the export

## Purpose

This is the actionable question set for an on-site expert. It separates
source-safety corrections that can be completed without new infrastructure
authority from later capacity, backup, and monitoring decisions. The expert
should recommend the safest practical path, not grant Apply authority.

## Verified current state

- The managed campaign ended `incomplete` after Evaluator pass 8 with
  `changes-requested`; no live storage Apply was authorized or performed.
- Syntax, focused lint, controller-local safety checks, and target/task listing
  had passing evidence, but that evidence does not cover the three remaining
  safety boundaries below.
- The governed source is [the final Evaluator feedback](../feedback_for_review_by_evaluator_2026-09-11T083117Z.md);
  [the continuation checkpoint](../coordination/continuation-checkpoint-2026-09-11T08-38-28Z.md)
  is the restart index.

## Required S4 corrections

### 1. Exact mountpoint identity on the absent path

**Owner:** `roles/linux_data_disk_mount/tasks/absent.yml`

`findmnt --target <path>` identifies the filesystem containing an arbitrary
path, not necessarily a mount at that path. Read-only evidence on
`hom-lab-ctl-k3s-02` showed `--target /tmp` returning `/dev/sda1`, while an
exact mountpoint lookup returned no match. On a second absent run, the role
could therefore treat the root filesystem as the selected data mount.

**Required correction:** use exact mountpoint semantics; test an
already-unmounted rerun and prove it does not select or assert against the root
filesystem.

**Decision space for the expert:** recommend the exact `findmnt` contract and
the smallest idempotence test that proves a preserved-but-unmounted directory
is safe. Explain why the selected test fails closed.

### 2. Stable whole-disk identity before partitioning

**Owners:** `roles/linux_data_disk_mount/tasks/present.yml`,
`absent.yml`, and `derive_partition.yml`

The current input gate can accept a raw device such as `/dev/sdb`. The role
could partition it before later failing while attempting to derive a
`-part1` path. That is too late for a destructive-capable operation.

**Required correction:** accept only a stable whole-disk path under
`/dev/disk/by-id/`; reject partition paths and raw `/dev/sd*` paths before
`community.general.parted` runs. Add a populated negative fixture proving that
rejection.

**Decision space for the expert:** recommend the validation shape and fixture
inputs that cover symlink resolution, whole-disk versus partition identity, and
early failure without overfitting to the current device name.

### 3. Recheck host free-space reserve immediately before VHDX creation

**Owner:** `roles/hyperv_vm_data_disk/tasks/present.yml`

Preview checks reserve, VHDX type/size, and attachment state, but the
mutation-capable PowerShell path does not currently receive or re-evaluate the
selected host reserve. Free space can change between preview and creation.

**Required correction:** pass the reserve into the mutation-capable operation,
measure current free space immediately before creating a new VHDX, and fail
closed when the reserve would be crossed. Extend the static/safety fixture to
prove both parameter passage and enforcement.

**Decision space for the expert:** recommend whether the check should use free
space before fixed-size allocation, how to express the reserve error, and what
fixture demonstrates the check without creating a VHDX.

## Still-unactioned campaign decisions

These are not source-code defects, but they prevent a live implementation plan
from becoming safe:

| Slice | Decision needed | Expert recommendation needed |
| --- | --- | --- |
| S3 | Persistent backing target, backup/data-safety approach, cutover, health/integrity checks, reversal | Rank the best storage target/design using current capacity and workload evidence; state backup, validation, and rollback implications. |
| S4 | Physical capacity/second-VHDX-or-mount design, host reserve, backup, outage authority | Select a preferred design and explicitly state the assumptions that would invalidate it. |
| S5 | Monitoring owner, retention, cadence, thresholds, and current-stack-first versus metrics/Alertmanager implementation | Recommend a minimum viable policy and ownership model with motivation, operational cost, and escalation signals. |

## Required response

Write the recommendation in `response_on-site_expert/` using
[`instruction.MD`](instruction.MD). Cite the exact evidence/artifacts used and
label recommendations separately from verified facts.
