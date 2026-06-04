# Data Protection Recovery Patterns

> **Status: brainstorming / design exploration - NOT repo work**
>
> This packet is a low-context holding area for backup, replication, disaster
> recovery, restore testing, and product-specific ideas such as Zerto. It is not
> an approved capability, intake item, plan, inventory source, NetBox source of
> truth, or implementation commitment for `dotfile-vnext`.

## How Agents Should Treat This Packet

- Read this README and the local `.aiignore` first.
- Do not bulk-read the plan-like markdown files in this packet unless the user
  explicitly asks for them or the task directly depends on this packet.
- Treat product names, hostnames, service names, model names, storage names, and
  candidate architectures as examples until promoted through `docs/intake/` or
  `docs/plans/`.
- Preserve useful ideas, but do not infer active work from their presence here.

## Packet Artifacts

| File | Role |
|------|------|
| [`terraform-cloudposse-zerto-layout-plan.md`](./terraform-cloudposse-zerto-layout-plan.md) | T0 homelab layout — Terraform modules, stacks, Zerto on Hyper-V lanes |
| [`terraform-multi-surface-data-protection-scaled-out-plan.md`](./terraform-multi-surface-data-protection-scaled-out-plan.md) | T1–T2 scaled layout — management plane, AWS workload/DR accounts, Azure `aix`, protection matrix |
| [`diagrams/`](./diagrams/) | Schema-notation diagrams (`cst-hom-lab-ctl-dia-*-01`) — naming, topology, surfaces, stacks, flows |

## Intended Use

Use this packet for early thinking around:

- Zerto-style replication or recovery orchestration
- backup and restore strategy
- disaster recovery runbooks and drills
- storage snapshot, retention, and recovery patterns
- migration from loose ideas into shaped intake docs

## Promotion Path

Move only shaped, decision-worthy material to `docs/intake/`. Move approved
implementation work to a folder packet under `docs/plans/`.
