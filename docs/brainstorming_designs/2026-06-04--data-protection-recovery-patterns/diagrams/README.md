# Data Protection Diagrams

Brainstorm diagrams for the
[2026-06-04 data-protection-recovery-patterns](../README.md) packet.

**Status:** design exploration only — not repo authority or NetBox truth.

## Naming

Diagram IDs follow `render-patterns.yml` → `diagram_canonical_id`:

```text
cst-hom-lab-ctl-dia-<topic>-<idx>
```

Resource names inside diagrams use active schema patterns from
`docs/reference/naming-standards/` unless labeled **candidate**.

## Index

| Canonical ID | File | Shows |
|--------------|------|--------|
| `cst-hom-lab-ctl-dia-data-protection-naming-01` | [cst-hom-lab-ctl-dia-data-protection-naming-01.md](./cst-hom-lab-ctl-dia-data-protection-naming-01.md) | L1–L6 layers, baseline vs scaled domain codes, Cloud Posse label map |
| `cst-hom-lab-ctl-dia-zerto-homelab-topology-01` | [cst-hom-lab-ctl-dia-zerto-homelab-topology-01.md](./cst-hom-lab-ctl-dia-zerto-homelab-topology-01.md) | T0 ZVM, VRAs, protection groups on live Hyper-V lanes |
| `cst-hom-lab-ctl-dia-data-protection-surfaces-01` | [cst-hom-lab-ctl-dia-data-protection-surfaces-01.md](./cst-hom-lab-ctl-dia-data-protection-surfaces-01.md) | T2 management plane vs on-prem / AWS / Azure surfaces |
| `cst-hom-lab-ctl-dia-terraform-stacks-01` | [cst-hom-lab-ctl-dia-terraform-stacks-01.md](./cst-hom-lab-ctl-dia-terraform-stacks-01.md) | Terraform `stacks/` roots and deploy order |
| `cst-hom-lab-ctl-dia-protection-flow-01` | [cst-hom-lab-ctl-dia-protection-flow-01.md](./cst-hom-lab-ctl-dia-protection-flow-01.md) | Backup and copy flows (Zerto journals, AWS wrk→dr) |

## Related plans

- [terraform-cloudposse-zerto-layout-plan.md](../terraform-cloudposse-zerto-layout-plan.md) — T0
- [terraform-multi-surface-data-protection-scaled-out-plan.md](../terraform-multi-surface-data-protection-scaled-out-plan.md) — T1–T2
