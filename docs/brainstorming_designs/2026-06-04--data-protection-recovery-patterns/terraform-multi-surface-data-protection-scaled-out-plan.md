# Multi-Surface Data Protection — Scaled-Out Plan

> Plan-like brainstorm — not an approved `docs/plans/` packet or repo authority.
> Extends the homelab-first layout in
> [`terraform-cloudposse-zerto-layout-plan.md`](./terraform-cloudposse-zerto-layout-plan.md)
> to a mature **management plane + workload surfaces** model (on-prem lanes, AWS
> accounts, Azure workload domain).
> Parent packet: [README.md](./README.md)

---

## What this document adds

The base plan places Zerto on Hyper-V lanes inside `hom/lab/ctl`. That is the
**first slice**. A scaled-out setup separates:

1. **Where control runs** — management location (ZVM, backup catalog, Terraform
   state, org policies, NetBox-adjacent metadata)
2. **What gets protected** — workload surfaces (on-prem VMs, AWS accounts,
   Azure resource groups, future SaaS/API endpoints)
3. **How paths are named** — same compact schema; **surface code** replaces
   `domain` in the third segment for cloud accounts (`mgmt`, `wrk`, `dr`, `aix`)

**Diagrams:** [diagrams/](./diagrams/) — naming layers, surfaces, stack layout,
and protection flows. Start with
[`cst-hom-lab-ctl-dia-data-protection-naming-01.md`](./diagrams/cst-hom-lab-ctl-dia-data-protection-naming-01.md).

This mirrors the AWS pattern you described: a primary VM or control stack lives
in one account; protected resources scale into **other accounts** (workload,
DR, sandbox) while **management stays centralized**.

---

## Maturity model (three tiers)

| Tier | Scope | Management location | Protected surfaces |
|------|--------|---------------------|-------------------|
| **T0 — homelab only** | Base plan | `hom-lab-ctl-zrt-01` on storage lane | `lane-storage`, `lane-gpu` Hyper-V guests |
| **T1 — hybrid control** | On-prem mgmt + cloud workloads | On-prem ZVM + AWS mgmt account for state/IAM | On-prem lanes + one AWS workload account |
| **T2 — multi-surface** | Full Cloud Posse / Geodesic shape | Dedicated **management stack** (on-prem and/or AWS org root) | On-prem lanes + multiple AWS accounts + Azure `aix` domain + DR copy account |

Everything below assumes **T2 as the target shape**; T0/T1 are valid partial
deployments of the same tree.

---

## Concept: management plane vs protected surfaces

See
[`cst-hom-lab-ctl-dia-data-protection-surfaces-01.md`](./diagrams/cst-hom-lab-ctl-dia-data-protection-surfaces-01.md).

**Rules:**

- **Management location** hosts orchestration, not primary app data (except
  journals/catalog paths explicitly designed for backup).
- **Protected resources** keep schema-rendered names:
  - on-prem L4: `hom-lab-ctl-k3s-02`, `hom-lab-ctl-dkr-01`
  - AWS L4 (candidate): `hom-lab-wrk-ec2-01`, `hom-lab-dr-bkp-01`
  - Azure (integrated): `oai-hom-lab-aix-api-01` in `rg-hom-lab-aix-01`
- **Cross-surface pairing** (Zerto sites, AWS Backup copy jobs, Azure Recovery
  Vault replication) is declared in `_global/` or `management/` stacks — not
  duplicated per workload folder.

---

## Schema mapping: Cloud Posse × homelab × AWS × Azure

Full notation tables:
[`cst-hom-lab-ctl-dia-data-protection-naming-01.md`](./diagrams/cst-hom-lab-ctl-dia-data-protection-naming-01.md).

### Label context (scaled baseline)

Pattern for cloud surfaces — **third segment = surface code** (replaces `ctl`
only for non-on-prem resources):

```text
<tenant>-<environment>-<surface>-<role>-<idx>
→ hom-lab-wrk-ec2-01
→ hom-lab-dr-bkp-01
→ hom-lab-ctl-zrt-01          # on-prem keeps ctl
```

| Cloud Posse label | Hom schema field | On-prem example | AWS example | Azure example |
|-------------------|------------------|-----------------|-------------|---------------|
| `namespace` | namespace | `cst` | `cst` | `cst` |
| `tenant` | tenant | `hom` | `hom` | `hom` |
| `environment` | environment / site | `lab` | `lab` | `lab` |
| `stage` | surface (domain slot) | `ctl` | `wrk`, `dr`, `mgmt` | `aix` |
| `name` | role code | `zrt`, `hvh`, `k3s` | `ec2`, `rds`, `bkp` | `oai`, `fdy` |
| `attributes` | idx + modifiers | `["01"]` | `["01"]`, `["vault"]` | `["api"]` |
| **L6 canonical** | `canonical_id` | `cst-hom-lab-ctl-service-zerto-01` | `cst-hom-lab-wrk-artifact-ec2-01` | `cst-hom-lab-aix-artifact-oai-api-01` |

**Important:** For AWS, **`stage` carries account role** (`mgmt`, `wrk`, `dr`)
while **`environment` stays `lab`** until you introduce a non-lab site. Region
goes in **directory path** (`us-east-1/`) and optionally in `attributes`
(`ue1`), not in the hostname baseline.

### Surface registry (candidate — not in live-object-registry yet)

| Surface code | Meaning | Stack path | L4 example | L6 canonical example |
|--------------|---------|------------|------------|----------------------|
| `ctl` | On-prem control plane | `stacks/on-prem/hom/lab/ctl/` | `hom-lab-ctl-hvh-01` | `cst-hom-lab-ctl-device-hvh-01` |
| `mgmt` | Management / org / state | `stacks/management/aws/hom/lab/mgmt/` | `hom-lab-mgmt-bkp-tfstate-01` | `cst-hom-lab-mgmt-artifact-tfstate-01` |
| `wrk` | AWS primary workload | `stacks/aws/hom/lab/wrk/` | `hom-lab-wrk-ec2-01` | `cst-hom-lab-wrk-artifact-ec2-01` |
| `dr` | AWS DR / vault copy | `stacks/aws/hom/lab/dr/` | `hom-lab-dr-bkp-01` | `cst-hom-lab-dr-artifact-bkp-01` |
| `sbx` | Sandbox (optional) | `stacks/aws/hom/lab/sbx/` | `hom-lab-sbx-ec2-01` | `cst-hom-lab-sbx-artifact-ec2-01` |
| `aix` | Azure AI domain | `stacks/azure/hom/lab/aix/` | `oai-hom-lab-aix-api-01` | per `azure-ai.yml` |

On-prem **lanes** remain `lane-storage` and `lane-gpu` under `ctl` — they are
not AWS accounts; they are **parallel workload surfaces** in the same taxonomy.

---

## Scaled Terraform directory tree

Extends the base plan. Stack layout and deploy order:
[`cst-hom-lab-ctl-dia-terraform-stacks-01.md`](./diagrams/cst-hom-lab-ctl-dia-terraform-stacks-01.md).

New top-level split under `stacks/`:

```text
terraform/
├── context/                          # unchanged — global label defaults
├── modules/
│   ├── data-protection/
│   │   ├── zerto/                    # on-prem (base plan)
│   │   ├── aws-backup/               # AWS Backup vault, plan, selection
│   │   ├── aws-dr/                   # cross-account copy, DRG
│   │   └── azure-recovery/           # Recovery Services vault (future)
│   ├── aws/
│   │   ├── organization/             # SCPs, delegated admin
│   │   ├── account/                  # account vending metadata
│   │   ├── vpc/
│   │   ├── ec2/
│   │   └── rds/
│   └── azure/
│       └── resource-group/
│
├── components/terraform/             # Atmos components (optional)
│   ├── zerto-*
│   ├── aws-backup-plan/
│   └── aws-backup-copy/
│
└── stacks/
    ├── _global/
    │   ├── backup-catalog/           # cross-surface retention catalog
    │   ├── zerto-org-pairing/        # all site pairs (on-prem ↔ on-prem, optional cloud)
    │   └── aws-org-backup-policy/    # org-level AWS Backup policy
    │
    ├── management/                   # MANAGEMENT PLANE — deploy first
    │   ├── on-prem/
    │   │   └── hom/lab/ctl/shared/
    │   │       └── data-protection/zerto/zvm-01/    # hom-lab-ctl-zrt-01
    │   └── aws/
    │       └── hom/lab/mgmt/                      # AWS mgmt account role
    │           ├── account.hcl
    │           ├── us-east-1/
    │           │   ├── terraform-state/           # S3 + DynamoDB for all surfaces
    │           │   ├── iam/delegated-backup/      # AWS Backup org admin
    │           │   └── data-protection/
    │           │       └── central-vault-01/
    │           └── global/                        # IAM Identity Center, org roots
    │
    ├── on-prem/                      # PROTECTED — existing homelab (base plan)
    │   └── hom/lab/ctl/
    │       ├── lane-storage/         # hvh-01, dkr-01, k3s-01, VRAs, PGs
    │       ├── lane-gpu/             # hvh-02, dkr-02, k3s-02, VRAs, PGs
    │       └── shared/               # cross-lane journals if not in mgmt only
    │
    ├── aws/                          # PROTECTED — workload + DR accounts
    │   └── hom/lab/
    │       ├── wrk/                  # primary workload account
    │       │   ├── account.hcl
    │       │   └── us-east-1/
    │       │       ├── networking/vpc-main/
│       │       ├── compute/
│       │       │   └── ec2-01/                  # L4: hom-lab-wrk-ec2-01
│       │       └── data-protection/
│       │           ├── backup-plan-ec2/
│       │           ├── backup-plan-rds/
│       │           └── selection-tags-hom-lab/
    │       ├── dr/                   # DR / copy target account
    │       │   ├── account.hcl
    │       │   └── us-east-1/
    │       │       └── data-protection/
    │       │           ├── vault-replica-01/
    │       │           └── copy-job-from-wrk/
    │       └── sbx/                  # optional sandbox account
    │           └── us-east-1/
    │               └── ...
    │
    └── azure/                        # PROTECTED — Azure AI domain
        └── hom/lab/aix/
            ├── subscription.hcl      # or resource-group scope if no multi-sub yet
            └── eastus/
                ├── rg-hom-lab-aix-01/
                └── data-protection/
                    └── recovery-vault-01/
```

**Deploy order (dependency chain):**

1. `management/` — ZVM, Terraform state backend, org backup admin
2. `_global/` — catalog, pairing, org policies
3. `on-prem/` workload lanes — VRAs and protection groups (base plan)
4. `aws/wrk` — app infra, then backup plans in same account
5. `aws/dr` — vault replica and copy jobs referencing `wrk`
6. `azure/.../aix` — parallel pattern when Azure workloads exist

---

## AWS example: main VM in workload account, management elsewhere

### Scenario

- **EC2 app VM** — L4 `hom-lab-wrk-ec2-01` in **`hom/lab/wrk/us-east-1/compute/ec2-01`**
- **AWS Backup vault + plan** can live in **same account** (default) or be
  **org-managed from `mgmt`** with selections targeting `wrk`
- **Copy / DR** lands in **`hom/lab/dr`** — separate account, no app compute
- **ZVM** stays on-prem at **`hom-lab-ctl-zrt-01`** for Hyper-V; AWS uses
  **AWS Backup + optional Zerto for AWS** only if you add that product lane

### Protection matrix (T2 example)

Full flow diagram:
[`cst-hom-lab-ctl-dia-protection-flow-01.md`](./diagrams/cst-hom-lab-ctl-dia-protection-flow-01.md).

| Protected resource | Pattern / L4 | Surface | Lane or account | Backup mechanism | Copy target |
|-------------------|--------------|---------|-----------------|------------------|-------------|
| `hom-lab-ctl-k3s-02` | baseline | `ctl` | `hyperv_lane_gpu` | Zerto PG | `hom-lab-ctl-bkp-journal-01` |
| `hom-lab-ctl-dkr-01` | baseline | `ctl` | `hyperv_lane_storage` | Zerto PG | same journal candidate |
| `hom-lab-wrk-ec2-01` | `hom-lab-wrk-ec2-01` | `wrk` | AWS wrk account | AWS Backup plan | `hom-lab-dr-bkp-01` |
| `hom-lab-wrk-rds-01` | `hom-lab-wrk-rds-01` | `wrk` | AWS wrk account | AWS Backup + snapshots | `hom-lab-dr-bkp-01` |
| `oai-hom-lab-aix-api-01` | `azure-ai.yml` | `aix` | `rg-hom-lab-aix-01` | Recovery Services vault | paired / geo vault |
| `hom-lab-mgmt-bkp-tfstate-01` | candidate | `mgmt` | AWS mgmt account | S3 versioning | DR bucket in `dr` |
| Backup catalog | L6 `cst-hom-lab-ctl-artifact-backup-catalog-01` | `ctl` + `_global` | git + TF stack | git + NetBox tags | repo clone |

### Example Terragrunt: workload EC2 with backup selection

```hcl
# stacks/aws/hom/lab/wrk/us-east-1/compute/ec2-01/terragrunt.hcl

include "root" { path = find_in_parent_folders("root.hcl") }
include "account" { path = find_in_parent_folders("account.hcl") }

terraform {
  source = "${get_repo_root()}/terraform/modules/aws/ec2"
}

dependency "vpc" {
  config_path = "../../networking/vpc-main"
}

dependency "backup_plan" {
  config_path = "../../data-protection/backup-plan-ec2"
}

inputs = {
  namespace   = "cst"
  tenant      = "hom"
  environment = "lab"
  stage       = "wrk"          # surface code → hom-lab-wrk-*
  name        = "ec2"
  attributes  = ["01"]

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = dependency.vpc.outputs.private_subnet_ids

  backup_plan_id = dependency.backup_plan.outputs.plan_id

  tags = {
    homelab           = "true"
    protected_surface = "wrk"
    inventory_anchor  = "hom-lab-wrk-ec2-01"
    canonical_id      = "cst-hom-lab-wrk-artifact-ec2-01"
  }
}
```

### Example: cross-account copy (wrk → dr)

```hcl
# stacks/aws/hom/lab/dr/us-east-1/data-protection/copy-job-from-wrk/terragrunt.hcl

dependency "wrk_vault" {
  config_path = "../../../wrk/us-east-1/data-protection/backup-plan-ec2"
}

dependency "dr_vault" {
  config_path = "../vault-replica-01"
}

inputs = {
  source_vault_arn = dependency.wrk_vault.outputs.vault_arn
  destination_vault_arn = dependency.dr_vault.outputs.vault_arn
  stage = "dr"
  copy_action_cron = "cron(0 5 * * ? *)"   # example — research before pin
}
```

---

## On-prem ↔ AWS: one management story

Do not run **two unrelated** backup namespaces.

| Concern | SSOT location | Notes |
|---------|---------------|-------|
| **Naming** | `docs/reference/naming-standards/` | Add `terraform.yml` + surface codes when promoted |
| **Live hostnames** | NetBox + `live-object-registry.yml` | On-prem only today |
| **AWS resource tags** | Terraform `context/` + `label` module | `stage=wrk|dr|mgmt`, not free-form |
| **Backup catalog** | `_global/backup-catalog` stack + git | Lists every protected object by surface |
| **Zerto** | `management/on-prem/.../zvm-01` | Hyper-V and VMware-shaped guests |
| **AWS Backup** | `aws/.../data-protection/` | EC2, EBS, RDS in wrk/dr |
| **Azure recovery** | `azure/.../aix/data-protection/` | Follow `azure-ai.yml` patterns |
| **Runbooks** | Future intake — not this packet | Failover order: mgmt → verify catalog → surface-specific restore |

**Geodesic profile switch (operator model):**

```text
# geodesic/rootfs/etc/geodesic/geodesic.env — examples only
ATMOS_STACK=hom-lab-ctl              # on-prem Zerto work
ATMOS_STACK=hom-lab-wrk-ue1          # AWS workload apply
AWS_PROFILE=hom-lab-mgmt             # state and org admin
```

---

## Scaling to other infra (same pattern)

| Future surface | Stack root | Domain / stage code | Module family |
|----------------|------------|---------------------|---------------|
| GCP (optional) | `stacks/gcp/hom/lab/wrk/...` | `wrk` + region path | `modules/gcp/...` |
| K3s etcd / PV | `on-prem/.../lane-*/data-protection/` | `ctl` | Velero module (candidate) |
| NAS snapshots | `on-prem/.../lane-storage/data-protection/` | `ctl` + `nas` | vendor or REST module |
| SaaS (GitHub, DNS) | `_global/saas-backup/` | `mgmt` | provider-specific |
| Edge GPU workstation | `on-prem/hom/lab/dev/` when promoted | `dev` / `gpu` candidates | Ansible-first; TF for cloud backup of configs only |

Each new surface adds **one row** to the protection matrix and **one subtree**
under `stacks/` — not a new naming vocabulary.

---

## What stays in Ansible vs Terraform at scale

| Tier | Ansible (steady-state) | Terraform (declarative intent) |
|------|------------------------|--------------------------------|
| T0 | Hyper-V guests, OS, K3s, NetBox seed | Zerto PG/VRAs, optional ZVM |
| T1 | Same + mac controller | Above + AWS mgmt state backend |
| T2 | Same | Above + AWS accounts (VPC, EC2, Backup, DR copy), Azure RG backup, org policies |

**Rule:** If a resource is already `ansible-managed` in NetBox, Terraform
references it by `inventory_hostname` or tag anchor — it does not reprovision
the host unless you explicitly migrate ownership.

---

## Schema gaps before promotion (scaled)

In addition to the base plan gaps (`zrt`, `terraform.yml`):

1. **`surface` or account-role codes** in `context.yml` — `mgmt`, `wrk`, `dr`, `sbx`
2. **`terraform.yml`** — stack path convention:
   `stacks/<provider>/hom/lab/<stage>/<region>/...`
3. **AWS tag contract** — align with Cloud Posse `tags` output + `homelab`, `protected_surface`
4. **NetBox** — decide whether AWS accounts are modeled as tenants, sites, or tags only
5. **Protection matrix** as generated artifact from `_global/backup-catalog` (future)

---

## Relationship to base plan

| Topic | Base plan | This document |
|-------|-----------|---------------|
| Zerto on Hyper-V | Full tree | Unchanged — lives under `on-prem/` and `management/on-prem/` |
| Cloud Posse labels | `hom/lab/ctl` | Adds `stage` = account role for AWS/Azure |
| Directory depth | Single `hom/lab/ctl` | Adds `management/`, `aws/`, `azure/` roots |
| Maturity | T0 | T1–T2 target |

---

## Apply / Verify / Undo (scaled)

| | |
|--|--|
| **Apply** | Ordered `terragrunt run --all apply` from `management/` → `_global/` → surfaces; or Atmos stack per surface |
| **Verify** | Protection matrix row per resource; AWS Backup job history; Zerto replication; catalog drift check vs NetBox |
| **Undo** | Destroy DR copy jobs before vaults; PGs before VRAs; workload before mgmt state (never destroy state bucket first) |
| **Class** | Idempotent for cloud backup objects; bootstrap for org/account vending if accounts do not exist yet |

---

## Sources checked

- [`terraform-cloudposse-zerto-layout-plan.md`](./terraform-cloudposse-zerto-layout-plan.md): base homelab layout
- `docs/reference/naming-standards/context.yml`: tenant, environment, domain fields
- `docs/reference/naming-standards/azure-ai.yml`: Azure `aix` domain patterns
- `docs/reference/naming-standards/live-object-registry.yml`: on-prem lanes and hosts
- `docs/reference/naming-standards/archive/cloud-posse-context-integrated.md`: label/context chaining
- `docs/reference/naming-standards/archive/terragrunt-structure-not-yet-integrated.md`: accounts and live layout
- `docs/reference/naming-standards/archive/cross-ecosystem-patterns-not-yet-integrated.md`: hierarchy in structure, not names
