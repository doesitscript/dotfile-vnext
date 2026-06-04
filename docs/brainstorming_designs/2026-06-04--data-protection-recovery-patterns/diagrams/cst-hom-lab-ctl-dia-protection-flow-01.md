# Protection and Copy Flows

**Canonical ID:** `cst-hom-lab-ctl-dia-protection-flow-01`

How protected objects relate to journals, vaults, and copy targets across
surfaces. All names use schema notation from
[cst-hom-lab-ctl-dia-data-protection-naming-01.md](./cst-hom-lab-ctl-dia-data-protection-naming-01.md).

---

## On-prem Zerto flow (T0)

```mermaid
flowchart LR
  subgraph protected [Protected VMs — ctl]
    K3S01["hom-lab-ctl-k3s-01"]
    K3S02["hom-lab-ctl-k3s-02"]
    DKR01["hom-lab-ctl-dkr-01"]
    DKR02["hom-lab-ctl-dkr-02"]
  end

  subgraph zerto [Zerto control]
    ZVM["hom-lab-ctl-zrt-01"]
    VRA1["VRA @ hvh-01"]
    VRA2["VRA @ hvh-02"]
    JRN["hom-lab-ctl-bkp-journal-01\ncandidate"]
  end

  ZVM --> VRA1
  ZVM --> VRA2
  VRA1 --> K3S01
  VRA1 --> DKR01
  VRA2 --> K3S02
  VRA2 --> DKR02
  K3S01 -->|continuous| JRN
  DKR01 -->|continuous| JRN
```

---

## AWS workload → DR copy (T2)

```mermaid
flowchart LR
  subgraph wrk [hom-lab-wrk surface]
    EC2["hom-lab-wrk-ec2-01"]
    RDS["hom-lab-wrk-rds-01"]
    PLAN["hom-lab-wrk-bkp-plan-01"]
    VAULT_W["wrk backup vault"]
  end

  subgraph mgmt [hom-lab-mgmt surface]
    ORG["org backup admin\ndelegated from mgmt"]
  end

  subgraph dr [hom-lab-dr surface]
    VAULT_D["hom-lab-dr-bkp-01"]
    COPY["copy-job-from-wrk"]
  end

  ORG -.-> PLAN
  PLAN --> EC2
  PLAN --> RDS
  PLAN --> VAULT_W
  VAULT_W -->|scheduled copy| COPY
  COPY --> VAULT_D
```

---

## Protection matrix (T2)

| Protected resource | Pattern | Surface | Mechanism | Copy / journal target |
|--------------------|---------|---------|-----------|------------------------|
| `hom-lab-ctl-k3s-02` | `hom-lab-ctl-k3s-02` | `ctl` / `lane-gpu` | Zerto PG | `hom-lab-ctl-bkp-journal-01` |
| `hom-lab-ctl-dkr-01` | `hom-lab-ctl-dkr-01` | `ctl` / `lane-storage` | Zerto PG | same journal candidate |
| `hom-lab-wrk-ec2-01` | `hom-lab-wrk-ec2-01` | `wrk` | AWS Backup plan | `hom-lab-dr-bkp-01` |
| `hom-lab-wrk-rds-01` | `hom-lab-wrk-rds-01` | `wrk` | AWS Backup + snapshots | `hom-lab-dr-bkp-01` |
| `oai-hom-lab-aix-api-01` | azure-ai.yml | `aix` | Recovery vault | geo-redundant / paired vault |
| Terraform state | `hom-lab-mgmt-bkp-tfstate-01` | `mgmt` | S3 versioning | DR bucket in `dr` |
| Catalog metadata | `cst-hom-lab-ctl-artifact-backup-catalog-01` | L6 canonical | git + `_global/backup-catalog` | repo clone |

---

## SSOT by concern

| Concern | Authority | Rendered anchor |
|---------|-----------|-----------------|
| On-prem hostnames | NetBox + `live-object-registry.yml` | `hom-lab-ctl-*` |
| Cloud resource tags | Terraform `label` module | `hom-lab-<surface>-<role>-<idx>` |
| Documentation IDs | L6 `canonical_id` | `cst-hom-lab-<surface>-artifact-*` |
| Backup membership | `_global/backup-catalog` stack | matrix rows above |
