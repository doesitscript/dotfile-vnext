# Zerto Homelab Topology (T0)

**Canonical ID:** `cst-hom-lab-ctl-dia-zerto-homelab-topology-01`

T0 layout from
[terraform-cloudposse-zerto-layout-plan.md](../terraform-cloudposse-zerto-layout-plan.md).
All hostnames use baseline pattern `hom-lab-ctl-<role>-<idx>`.

**Status:** `hom-lab-ctl-zrt-01` and role code `zrt` are **candidate** — not in
`live-object-registry.yml` yet.

---

## Live anchors (integrated)

| inventory_hostname | role | lane_group | guest / LAN |
|--------------------|------|------------|-------------|
| `HOM-LAB-HVH-01` | `hvh` | `hyperv_lane_storage` | LAN `192.168.50.234`, guests `192.168.138.0/24` |
| `HOM-LAB-HVH-02` | `hvh` | `hyperv_lane_gpu` | LAN `192.168.50.158`, guests `192.168.137.0/24` |
| `hom-lab-ctl-dkr-01` | `dkr` | `hyperv_lane_storage` | `192.168.138.10` |
| `hom-lab-ctl-dkr-02` | `dkr` | `hyperv_lane_gpu` | `192.168.137.10` |
| `hom-lab-ctl-k3s-01` | `k3s` | `hyperv_lane_storage` | `192.168.138.11` |
| `hom-lab-ctl-k3s-02` | `k3s` | `hyperv_lane_gpu` | `192.168.137.11` |

---

## Diagram

```mermaid
flowchart TB
  subgraph mgmt [Management — hom-lab-ctl shared]
    ZVM["hom-lab-ctl-zrt-01\nZVM candidate\nL4: hom-lab-ctl-zrt-01\nL6: cst-hom-lab-ctl-service-zerto-01"]
  end

  subgraph lane_s [hyperv_lane_storage]
    HVH01["HOM-LAB-HVH-01"]
    VRA01["VRA on hvh-01\nattr: vra-hvh-01"]
    DKR01["hom-lab-ctl-dkr-01"]
    K3S01["hom-lab-ctl-k3s-01"]
    PG_DKR01["PG → dkr-01"]
    PG_K3S01["PG → k3s-01"]
    JRN01["journal-store-01\nhom-lab-ctl-bkp-journal-01 candidate"]
  end

  subgraph lane_g [hyperv_lane_gpu]
    HVH02["HOM-LAB-HVH-02"]
    VRA02["VRA on hvh-02\nattr: vra-hvh-02"]
    DKR02["hom-lab-ctl-dkr-02"]
    K3S02["hom-lab-ctl-k3s-02"]
    PG_DKR02["PG → dkr-02"]
    PG_K3S02["PG → k3s-02"]
  end

  ZVM --> VRA01
  ZVM --> VRA02
  HVH01 --- VRA01
  HVH02 --- VRA02
  VRA01 --> PG_DKR01
  VRA01 --> PG_K3S01
  VRA02 --> PG_DKR02
  VRA02 --> PG_K3S02
  PG_K3S01 --> JRN01
  PG_DKR01 --> JRN01

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000;
  classDef candidate fill:#fff3cd,stroke:#856404,color:#000;
  class HVH01,HVH02,DKR01,DKR02,K3S01,K3S02 live;
  class ZVM,VRA01,VRA02,PG_DKR01,PG_K3S01,PG_DKR02,PG_K3S02,JRN01 candidate;
```

---

## Terraform unit map (T0)

| Terragrunt unit | Protects (inventory_hostname) | Module |
|-----------------|----------------------------|--------|
| `shared/.../zvm-01` | — (creates ZVM) | `modules/data-protection/zerto/zvm` |
| `lane-storage/.../vra-hvh-01` | `HOM-LAB-HVH-01` | `zerto/vra` |
| `lane-storage/.../protection-group-dkr-01` | `hom-lab-ctl-dkr-01` | `zerto/protection-group` |
| `lane-storage/.../protection-group-k3s-01` | `hom-lab-ctl-k3s-01` | `zerto/protection-group` |
| `lane-storage/.../journal-store-01` | journal path on storage lane | `zerto/journal` |
| `lane-gpu/.../vra-hvh-02` | `HOM-LAB-HVH-02` | `zerto/vra` |
| `lane-gpu/.../protection-group-dkr-02` | `hom-lab-ctl-dkr-02` | `zerto/protection-group` |
| `lane-gpu/.../protection-group-k3s-02` | `hom-lab-ctl-k3s-02` | `zerto/protection-group` |

Stack root: `terraform/stacks/on-prem/hom/lab/ctl/`.
