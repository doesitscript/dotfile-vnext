# Zerto Infrastructure World Map

**Canonical ID:** `cst-hom-lab-ctl-dia-zerto-infra-world-map-01`

One-page map for how the repo infrastructure world, Terraform stack world, and
Zerto product world line up. Companion plan:
[zerto-infrastructure-world-mapping-plan.md](../zerto-infrastructure-world-mapping-plan.md).

**Status:** brainstorm-only. Zerto codes and object names are candidate
extensions until promoted through the active naming registry.

---

## Diagram

```mermaid
flowchart TB
  subgraph infra [Repo infrastructure world]
    NBX["NetBox + live-object-registry\nsource of truth for host VM service facts"]
    HVH01["HOM-LAB-HVH-01\nstorage Hyper-V host"]
    HVH02["HOM-LAB-HVH-02\nGPU Hyper-V host"]
    DKR01["hom-lab-ctl-dkr-01"]
    K3S01["hom-lab-ctl-k3s-01"]
    DKR02["hom-lab-ctl-dkr-02"]
    K3S02["hom-lab-ctl-k3s-02"]
  end

  subgraph tf [Terraform stack world]
    ZVM_UNIT["shared/data-protection/zerto/zvm-01"]
    VRA01_UNIT["lane-storage/data-protection/zerto/vra-hvh-01"]
    VRA02_UNIT["lane-gpu/data-protection/zerto/vra-hvh-02"]
    VPG_K3S["lane-*/data-protection/zerto/vpg-k3s-01/02"]
    VPG_DKR["lane-*/data-protection/zerto/vpg-dkr-01/02"]
    JRN_UNIT["lane-storage/data-protection/zerto/journal-store-01"]
  end

  subgraph zerto [Zerto product world]
    ZVM["ZVM\ncandidate hom-lab-ctl-zrt-01"]
    VRA01["VRA\nvendor object attached to hvh-01"]
    VRA02["VRA\nvendor object attached to hvh-02"]
    VPG1["VPG k3s\nprotects k3s VMs"]
    VPG2["VPG docker\nprotects dkr VMs"]
    JOURNAL["journals\nper protected VM or VPG policy"]
  end

  NBX -. "authoritative names" .-> HVH01
  NBX -. "authoritative names" .-> HVH02

  HVH01 --> DKR01
  HVH01 --> K3S01
  HVH02 --> DKR02
  HVH02 --> K3S02

  ZVM_UNIT --> ZVM
  VRA01_UNIT --> VRA01
  VRA02_UNIT --> VRA02
  VPG_K3S --> VPG1
  VPG_DKR --> VPG2
  JRN_UNIT --> JOURNAL

  VRA01 -. "attaches to" .-> HVH01
  VRA02 -. "attaches to" .-> HVH02
  VPG1 -. "protects" .-> K3S01
  VPG1 -. "protects" .-> K3S02
  VPG2 -. "protects" .-> DKR01
  VPG2 -. "protects" .-> DKR02
  VPG1 --> JOURNAL
  VPG2 --> JOURNAL
  ZVM --> VRA01
  ZVM --> VRA02

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000;
  classDef candidate fill:#fff3cd,stroke:#856404,color:#000;
  classDef product fill:#e0f2fe,stroke:#0369a1,color:#000;
  class NBX,HVH01,HVH02,DKR01,K3S01,DKR02,K3S02 live;
  class ZVM_UNIT,VRA01_UNIT,VRA02_UNIT,VPG_K3S,VPG_DKR,JRN_UNIT candidate;
  class ZVM,VRA01,VRA02,VPG1,VPG2,JOURNAL product;
```

---

## Naming Legend

| Shape | Example | Meaning |
|-------|---------|---------|
| `HOM-LAB-HVH-02` | live infrastructure name | NetBox/inventory host or VM identity |
| `vra-hvh-02` | Terraform unit | Zerto VRA attached to the `hvh-02` host |
| `vpg-k3s-02` | Terraform unit / policy object | VPG protecting K3s workload in a lane |
| `hom-lab-ctl-zrt-01` | candidate L4 service or VM | Zerto manager identity if promoted |
| `hom-lab-ctl-bkp-journal-01` | candidate storage purpose | journal storage target, not Zerto manager |

## Guardrail

Do not render placement, product, object type, host, and ordinal into one giant
hostname. Keep placement in the path, product object type in the module/unit,
and durable infrastructure identity in NetBox/inventory.
