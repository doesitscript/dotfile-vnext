# Multi-Surface Data Protection (T2)

**Canonical ID:** `cst-hom-lab-ctl-dia-data-protection-surfaces-01`

Management plane vs protected workload surfaces. Companion:
[terraform-multi-surface-data-protection-scaled-out-plan.md](../terraform-multi-surface-data-protection-scaled-out-plan.md).

---

## Maturity tiers

| Tier | Management (domain) | Protected surfaces |
|------|---------------------|-------------------|
| **T0** | `hom-lab-ctl-zrt-01` on-prem | `hyperv_lane_storage`, `hyperv_lane_gpu` |
| **T1** | On-prem ZVM + `hom-lab-mgmt-*` AWS state | T0 + `hom-lab-wrk-*` |
| **T2** | `management/` stack (on-prem + AWS org) | T1 + `hom-lab-dr-*`, `rg-hom-lab-aix-01` |

---

## Diagram

```mermaid
flowchart TB
  subgraph mgmt [Management plane]
    ZVM["hom-lab-ctl-zrt-01\non-prem ctl"]
    CAT["backup-catalog\n_global stack"]
    TF["hom-lab-mgmt-bkp-tfstate-01\ncandidate S3 state"]
    NBX["NetBox SSOT\nAnsible ipam_netbox"]
    GEO["Geodesic / Atmos"]
  end

  subgraph onprem [Surface: ctl — on-prem lanes]
    LS["hyperv_lane_storage\nhvh-01 dkr-01 k3s-01"]
    LG["hyperv_lane_gpu\nhvh-02 dkr-02 k3s-02"]
  end

  subgraph aws_wrk [Surface: wrk — AWS workload]
    EC2["hom-lab-wrk-ec2-01\ncandidate"]
    RDS["hom-lab-wrk-rds-01\ncandidate"]
    BKP_W["hom-lab-wrk-bkp-plan-01\ncandidate vault/plan"]
  end

  subgraph aws_dr [Surface: dr — AWS copy target]
    VAULT["hom-lab-dr-bkp-01\ncandidate replica vault"]
    COPY["copy-job wrk to dr"]
  end

  subgraph azure [Surface: aix — Azure]
    RG["rg-hom-lab-aix-01"]
    OAI["oai-hom-lab-aix-api-01"]
    RSV["rsv-hom-lab-aix-01\ncandidate recovery vault"]
  end

  ZVM --> LS
  ZVM --> LG
  CAT --> LS
  CAT --> aws_wrk
  CAT --> azure
  TF --> GEO
  NBX -.-> CAT
  BKP_W --> EC2
  BKP_W --> RDS
  BKP_W -->|cross-account copy| COPY
  COPY --> VAULT
  RSV --> OAI
  RSV --> RG

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000;
  classDef candidate fill:#fff3cd,stroke:#856404,color:#000;
  class LS,LG,NBX,RG,OAI live;
  class ZVM,CAT,TF,GEO,EC2,RDS,BKP_W,VAULT,COPY,RSV candidate;
```

---

## Surface registry (candidate)

| Surface | Domain segment | Example IDs | Backup product |
|---------|----------------|-------------|----------------|
| On-prem control | `ctl` | `hom-lab-ctl-k3s-02` | Zerto PG |
| AWS management | `mgmt` | `hom-lab-mgmt-bkp-tfstate-01` | S3 versioning |
| AWS workload | `wrk` | `hom-lab-wrk-ec2-01` | AWS Backup |
| AWS DR | `dr` | `hom-lab-dr-bkp-01` | cross-account copy |
| Azure AI | `aix` | `oai-hom-lab-aix-api-01` | Recovery Services vault |

Naming detail: [cst-hom-lab-ctl-dia-data-protection-naming-01.md](./cst-hom-lab-ctl-dia-data-protection-naming-01.md).
