# Terraform Stack Layout and Deploy Order

**Canonical ID:** `cst-hom-lab-ctl-dia-terraform-stacks-01`

Directory roots under `terraform/stacks/` for T0–T2. Path encodes placement;
rendered IDs use schema baseline (see naming diagram).

---

## Stack roots

```mermaid
flowchart TB
  subgraph stacks [terraform/stacks]
    G["_global/\nbackup-catalog\nzerto-org-pairing\naws-org-backup-policy"]
    M["management/\non-prem/hom/lab/ctl/shared\naws/hom/lab/mgmt"]
    OP["on-prem/hom/lab/ctl/\nlane-storage | lane-gpu | shared"]
    AWS["aws/hom/lab/\nwrk | dr | sbx"]
    AZ["azure/hom/lab/aix/"]
  end

  G --> M
  M --> OP
  M --> AWS
  M --> AZ
  OP --> AWS
  AWS --> AZ

  classDef phase fill:#dbeafe,stroke:#1d4ed8,color:#000;
  class G,M phase;
```

---

## Deploy order

```mermaid
flowchart LR
  P1["1 management/\nZVM + tfstate + org admin"]
  P2["2 _global/\ncatalog + pairing + org policy"]
  P3["3 on-prem/\nVRAs + PGs + journals"]
  P4["4 aws/wrk/\nVPC EC2 RDS + backup plans"]
  P5["5 aws/dr/\nvault replica + copy jobs"]
  P6["6 azure/aix/\nRG + recovery vault"]

  P1 --> P2 --> P3 --> P4 --> P5 --> P6
```

---

## Path ↔ schema quick reference

| Stack path segment | Schema domain / surface | Example unit | Rendered ID |
|--------------------|-------------------------|--------------|-------------|
| `on-prem/hom/lab/ctl/lane-storage/.../zvm-01` | `ctl` | ZVM | `hom-lab-ctl-zrt-01` |
| `on-prem/.../protection-group-k3s-02` | `ctl` | PG | protects `hom-lab-ctl-k3s-02` |
| `management/aws/hom/lab/mgmt/.../terraform-state` | `mgmt` | state bucket | `hom-lab-mgmt-bkp-tfstate-01` |
| `aws/hom/lab/wrk/.../ec2-01` | `wrk` | EC2 | `hom-lab-wrk-ec2-01` |
| `aws/hom/lab/dr/.../vault-replica-01` | `dr` | vault | `hom-lab-dr-bkp-01` |
| `azure/hom/lab/aix/.../recovery-vault-01` | `aix` | RSV | `rsv-hom-lab-aix-01` |

**Terragrunt unit dirs:** kebab-case, ordinal in dirname (`zvm-01`, `ec2-01`) —
not a second hostname vocabulary.

---

## Module families (reusable)

```text
terraform/modules/
├── data-protection/zerto/     # T0 on-prem
├── data-protection/aws-backup/
├── data-protection/aws-dr/
├── data-protection/azure-recovery/
├── aws/{organization,vpc,ec2,rds}/
└── azure/resource-group/
```

Components (optional Atmos): `terraform/components/terraform/zerto-*`,
`aws-backup-plan`, `aws-backup-copy`.
