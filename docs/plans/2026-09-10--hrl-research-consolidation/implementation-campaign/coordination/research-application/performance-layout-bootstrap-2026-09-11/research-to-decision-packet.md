# Research-to-decision packet — performance layout bootstrap

## Input boundary

**Source:** [On-site Expert performance evaluation](../../../../multi-agent-design/multi-agent-onsite-expert/examples/storage-performance-research-application.md)
**User contribution represented:** use available storage tiers according to
workload value, performance needs, and durable/reproducible data class.
**Current-state basis:** S1 storage discovery cited by the source.
**Decision consumer:** Planner / Coordinator, then Implementer and Evaluator.

## Classified guidance

| Class | Meaning for downstream roles | Bootstrap result |
| --- | --- | --- |
| Hard correction | Must be preserved wherever its triggering implementation surface is used. | Use the supported HF cache interface; do not use the deprecated CLI; a future K3s/containerd 2.x template must use the current v3 template contract. |
| Placement principle | A technical direction, not a literal path or unconditional migration. Implementer maps it to proven current owners. | Latency-sensitive/reproducible-expensive data favors the available fast tier; low-value/rebuildable or contention-isolation work can use a slower SSD. |
| Durability prohibition | A boundary that a later plan may not silently cross. | Durable cluster/database/credential/work-product data stays on its durable/redundant class; kubelet pod logs remain on its accounted filesystem. |
| Conditional option | Valid only after the stated live fact is proven. | Smaller SATA allocation requires its identity, capacity, health, and Kubelet compatibility evidence; otherwise its workloads remain safely placed/capped. |
| Discovery/validation requirement | Required evidence before a plan can create, migrate, or claim a benefit. | Bind devices and mount/filesystem support; prove workload health, capacity behavior, rollback, and relevant I/O/storage observability after a change. |

## Recommendation form

The Expert's output is intentionally a **guidance envelope**, not an immutable
playbook. It supplies preferred data classes, constraints, and expected
outcomes. The Planner selects an implementation route only after mapping the
guidance to current configuration and ownership. The Implementer may choose a
different concrete Ansible mechanism when live/source evidence requires it, but
must retain the governing correction/principle or write a source/runtime-backed
exception. The Evaluator checks that this interpretation did not lose a hard
constraint, invent a performance claim, or create unowned configuration.

## Return conditions for the Expert loop

Return a specific question to the Expert/Synthesizer when:

- a placement principle maps to more than one materially different owner;
- current hardware, device identity, filesystem support, or workload behavior
  does not satisfy a source assumption;
- an expected performance benefit lacks a measurable proof metric; or
- a proposed change conflicts with a durability prohibition.

Do not return merely because a concrete Ansible module or path must be selected;
that is normal Planner/Implementer translation work when the source constraints
are clear.
