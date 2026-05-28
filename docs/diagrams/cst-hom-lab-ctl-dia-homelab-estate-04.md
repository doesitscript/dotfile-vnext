# Homelab Estate — Topology, Deployments, and Roles

Durable overview of the **hom.lab** control-plane estate: what runs where, how
lanes connect, and which NetBox/Ansible role codes apply. Complements the
GPU-focused slices in `cst-hom-lab-ctl-dia-gpu-*` and DNS-3 in
`cst-hom-lab-ctl-dia-homelab-hosts-file-01.md`.

**Sources:** `inventory/inventory.yaml`, `inventory/group_vars/all/homelab_hosts_file.yml`,
`roles/ipam_netbox/defaults/main.yml`, `inventory/group_vars/k3s_cluster.yaml`,
`docs/reference/naming-standards/live-object-registry.yml` (2026-05-27).

**Legend**

| Marker | Meaning |
|--------|---------|
| **Active** | In `windows_hosts` / `linux_vm_hosts` and observed or intended steady-state |
| **Inventory** | Modeled in inventory/NetBox; reachability or full stack may still be converging |
| **Deferred** | Known host; not in routine Ansible execution groups |

---

## 1 — Full estate topology (both Hyper-V lanes)

```mermaid
flowchart TB
  subgraph LAN["LAN 192.168.50.0/24"]
    Router["GT6 router\n192.168.50.1"]
    Mac["mac-dev\ncontroller / execution node\n~192.168.50.33"]
    HVH02["hom-lab-ctl-hvh-02\nWindows Hyper-V host\n192.168.50.158\nrole: hvh · lane: GPU"]
    HVH01["hom-lab-ctl-hvh-01\nWindows Hyper-V host\n192.168.50.234\nrole: hvh · lane: storage"]
    DeferredWin["dev-workstation-win · dev-3090-win\n(deferred / offline)"]
  end

  subgraph Guest137["Guest subnet 192.168.137.0/24\nroute: via 192.168.50.158"]
    DKR02["hom-lab-ctl-dkr-02\n192.168.137.10\nrole: dkr"]
    K3S02["hom-lab-ctl-k3s-02\n192.168.137.11\nrole: k3s"]
  end

  subgraph Guest138["Guest subnet 192.168.138.0/24\nroute: via 192.168.50.234"]
    DKR01["hom-lab-ctl-dkr-01\n192.168.138.10\nrole: dkr"]
    K3S01["hom-lab-ctl-k3s-01\n192.168.138.11\nrole: k3s"]
  end

  Mac --> Router
  Router --> HVH02
  Router --> HVH01
  HVH02 --> DKR02
  HVH02 --> K3S02
  HVH01 --> DKR01
  HVH01 --> K3S01
  DKR02 --> Router
  K3S02 --> Router
  DKR01 --> Router
  K3S01 --> Router

  classDef active fill:#2d4a2d,stroke:#81c784,color:#e8f5e9
  classDef storage fill:#1e3a5f,stroke:#64b5f6,color:#e3f2fd
  classDef deferred fill:#2a2a2a,stroke:#9e9e9e,color:#bdbdbd
  class Mac,HVH02,DKR02,K3S02 active
  class HVH01,DKR01,K3S01 storage
  class DeferredWin deferred
```

---

## 2 — What is deployed on each node (services and stacks)

```mermaid
flowchart TB
  subgraph MacNode["mac-dev — execution / operator"]
    MacCtl["Ansible controller\nDocker CLI context → hom-lab-ctl-dkr-02\nhomelab_hosts_file_mac\nSSH client config render"]
  end

  subgraph HVH02Node["hom-lab-ctl-hvh-02 — Hyper-V + LAN publish"]
    HVHRoles["Roles: hyperv_networking · hyperv_ubuntu_vm\nhyperv_docker_runtime · openssh_server\nportproxy :80 → Traefik :31461\n:8000 :3001 :3100 :30000 :30400"]
  end

  subgraph DKR02Node["hom-lab-ctl-dkr-02 — Docker VM (active)"]
    DKR02Svc["ipam_netbox :8000\nansible_ui_semaphore :3001\nlogging_loki :3100 · grafana :3000\nfuzlang-net: postgres :5432 · minio :9000/9001\nredis · clickhouse\nDocker engine"]
  end

  subgraph K3S02Node["hom-lab-ctl-k3s-02 — K3s VM (active)"]
    K3S02Svc["K3s server · Traefik kube-system\nk3s_langfuse_platform → :30000\nk3s_litellm_gateway → :30400\nJupyter workbench :8888\nPostgres consumer → 192.168.137.10"]
  end

  subgraph HVH01Node["hom-lab-ctl-hvh-01 — storage lane host"]
    HVH01Roles["hyperv_networking · hyperv_ubuntu_vm\nNAT guest egress today\n(storage convergence planned)"]
  end

  subgraph DKR01Node["hom-lab-ctl-dkr-01 — storage Docker VM"]
    DKR01Svc["docker_engine present\nauthoritative-data lane\nLoki/logging target (inventory)\nNetBox + stacks (lane model)"]
  end

  subgraph K3S01Node["hom-lab-ctl-k3s-01 — storage K3s VM"]
    K3S01Svc["k3s_cluster_network server\nVM stub / prep inventory"]
  end

  MacNode -->|"SSH ProxyJump"| HVH02Node
  MacNode --> DKR02Node
  MacNode --> K3S02Node
  HVH02Node --> DKR02Node
  HVH02Node --> K3S02Node
  MacNode --> HVH01Node
  HVH01Node --> DKR01Node
  HVH01Node --> K3S01Node

  classDef mac fill:#4a3f2e,stroke:#ffb74d,color:#fff8e1
  classDef gpu fill:#2d4a2d,stroke:#81c784,color:#e8f5e9
  classDef store fill:#1e3a5f,stroke:#64b5f6,color:#e3f2fd
  class MacNode mac
  class HVH02Node,DKR02Node,K3S02Node gpu
  class HVH01Node,DKR01Node,K3S01Node store
```

### Service placement table (operator-facing)

| hom.lab hostname | Resolves to (interim hosts file) | Workload | Host / path |
|------------------|-----------------------------------|----------|-------------|
| `langfuse.hom.lab` | `192.168.50.158` | Langfuse web (K3s) | k3s-02 → portproxy `:30000` or Traefik `:80` |
| `litellm.hom.lab` | `192.168.50.158` | LiteLLM gateway (K3s) | k3s-02 → portproxy `:30400` |
| `jupyter.hom.lab` | `192.168.137.11` | JupyterLab | k3s-02 guest direct |
| `netbox.hom.lab` | `192.168.50.158` | NetBox UI | dkr-02 → portproxy `:8000` |
| `semaphore.hom.lab` | `192.168.50.158` | Semaphore UI | dkr-02 → portproxy `:3001` |
| `loki.hom.lab` | `192.168.50.158` | Loki | dkr-02 → portproxy `:3100` |
| `grafana.hom.lab` | `192.168.137.10` | Grafana | dkr-02 guest direct only |

---

## 3 — NetBox role codes, runtime planes, and Ansible groups

```mermaid
flowchart LR
  subgraph Roles["NetBox / schema role codes"]
    HVH["hvh\nHyper-V Windows host"]
    DKR["dkr\nDocker runtime VM"]
    K3S["k3s\nKubernetes VM"]
  end

  subgraph Hosts["Inventory host → roles"]
    A["hom-lab-ctl-hvh-02 → hvh"]
    B["hom-lab-ctl-dkr-02 → dkr"]
    C["hom-lab-ctl-k3s-02 → k3s"]
    D["hom-lab-ctl-hvh-01 → hvh"]
    E["hom-lab-ctl-dkr-01 → dkr"]
    F["hom-lab-ctl-k3s-01 → k3s"]
    G["mac-dev → execution only"]
  end

  subgraph Groups["Ansible groups (capability)"]
    G1["execution_nodes → mac-dev"]
    G2["windows_hosts → hvh-01, hvh-02"]
    G3["linux_vm_hosts → dkr-01/02, k3s-01/02"]
    G4["hyperv_lane_gpu → hvh-02, dkr-02"]
    G5["hyperv_lane_storage → hvh-01, dkr-01, k3s-01"]
    G6["k3s_cluster_gpu → k3s-02"]
    G7["k3s_cluster_network → k3s-01"]
    G8["logging_server → dkr-02"]
    G9["docker_clients → mac-dev, hvh-01, hvh-02"]
  end

  HVH --> A
  HVH --> D
  DKR --> B
  DKR --> E
  K3S --> C
  K3S --> F

  classDef role fill:#1e3a5f,stroke:#90caf9,color:#e3f2fd
  classDef host fill:#2a2a2a,stroke:#bdbdbd,color:#fafafa
  class Roles,Hosts,Groups role
```

### Runtime planes (from host_vars — what automation enables)

| Host | `runtime_planes` / `node_classes` (summary) |
|------|---------------------------------------------|
| **hom-lab-ctl-hvh-02** | `hyperv_host`, `hyperv_docker_vm`, `hyperv_k3s_vm`, `docker_client`, `gpu_host` |
| **hom-lab-ctl-dkr-02** | `docker_engine` (via roles), logging/NetBox stacks |
| **hom-lab-ctl-k3s-02** | `k3s_node` · `k3s_runtime`, `ai_worker`, GPU classes |
| **hom-lab-ctl-hvh-01** | `hyperv_host`, `hyperv_docker_vm`, `hyperv_k3s_vm`, `storage_observability` |
| **hom-lab-ctl-dkr-01** | `docker_engine`, `storage_observability`, authoritative-data policy |
| **hom-lab-ctl-k3s-01** | K3s network cluster server (inventory) |
| **mac-dev** | `execution_nodes`, `docker_clients`, `homelab_hosts_file_mac` |

---

## 4 — hom.lab name resolution and Traefik front door (GPU lane)

```mermaid
flowchart LR
  Browser["Operator browser\nmac-dev / LAN client"]
  HostsMac["/etc/hosts on mac-dev\nhomelab_hosts_file_mac"]
  HostsLinux["/etc/hosts on dkr-02, k3s-02\nhomelab_hosts_file_linux"]
  Publish158["192.168.50.158\nhom-lab-ctl-hvh-02 portproxy"]
  Traefik80[":80 → guest :31461\nTraefik NodePort"]
  Direct137["Direct 192.168.137.x\ngrafana · jupyter"]

  Browser --> HostsMac
  Browser --> HostsLinux
  HostsMac -->|"langfuse/netbox/…"| Publish158
  HostsLinux --> Publish158
  HostsLinux --> Direct137
  Publish158 --> Traefik80
  Publish158 -->|"8000 3001 3100"| DKRDirect["dkr-02 services"]
  Traefik80 --> K3SIngress["k3s-02 Ingress\nlangfuse · litellm"]

  classDef dns fill:#5a4a1a,stroke:#ffca28,color:#fffde7
  classDef path fill:#1e3a5f,stroke:#64b5f6,color:#e3f2fd
  class HostsMac,HostsLinux dns
  class Publish158,Traefik80,K3SIngress,DKRDirect,Direct137 path
```

---

## 5 — site.yaml convergence order (automation layers)

```mermaid
flowchart TD
  Site["playbooks/site.yaml"]
  Site --> W1["windows_base"]
  Site --> W2["access · SSH config"]
  Site --> W3["hyperv_windows_host"]
  Site --> W4["windows_file_shares"]
  Site --> W5["hyperv_ubuntu_docker_vm"]
  Site --> W6["hyperv_ubuntu_k3s_vm"]
  Site --> W7["docker clients + engine verify"]
  Site --> W8["homelab_hosts_file\nmac + linux guests"]

  classDef phase fill:#2a2a2a,stroke:#9e9e9e,color:#fafafa
  class Site,W1,W2,W3,W4,W5,W6,W7,W8 phase
```

---

## Diagram inventory

### Diagrams included

- **Estate topology** — LAN, router routes, GPU vs storage guest subnets
- **Deployments by node** — services/stacks and operator paths
- **Roles and Ansible groups** — hvh / dkr / k3s and capability groups
- **hom.lab interim DNS** — hosts-file + portproxy + Traefik
- **site.yaml phase order** — automation layering

### Related diagrams in this folder

| File | Focus |
|------|--------|
| [cst-hom-lab-ctl-dia-gpu-topology-01.md](cst-hom-lab-ctl-dia-gpu-topology-01.md) | GPU lane routing detail |
| [cst-hom-lab-ctl-dia-gpu-services-01.md](cst-hom-lab-ctl-dia-gpu-services-01.md) | GPU service ports and portproxy |
| [cst-hom-lab-ctl-dia-gpu-control-01.md](cst-hom-lab-ctl-dia-gpu-control-01.md) | Operator SSH and Docker client paths |
| [cst-hom-lab-ctl-dia-homelab-hosts-file-01.md](cst-hom-lab-ctl-dia-homelab-hosts-file-01.md) | DNS-3 hosts-file data flow |

### Additional diagrams available on request

- Storage-lane steady-state only (`138.x` authoritative stack)
- NetBox object hierarchy (site → cluster → VM → services)
- Future AdGuard authoritative DNS replacement for interim hosts file
