# Two Physical Servers — Langfuse & Dependent Services Distribution

## Scope

Read-only retrospective: where Langfuse and its dependency graph are **declared**
to live vs where Ansible playbooks **actually target** today. No changes applied.

**Physical hosts**

| Host | Role (repo) | LAN IP | Guest subnet |
|------|-------------|--------|--------------|
| `hom-lab-ctl-hvh-01` | storage / observability (`hyperv_lane_storage`) | `192.168.50.234` | `192.168.138.0/24` |
| `hom-lab-ctl-hvh-02` | primary GPU / execution (`hyperv_lane_gpu`, RTX 5090) | `192.168.50.158` | `192.168.137.0/24` |

**Linux guests**

| Guest | Physical parent | Guest IP | Lane intent |
|-------|-----------------|----------|-------------|
| `hom-lab-ctl-dkr-01` | hvh-01 | `192.168.138.10` | Storage Docker engine |
| `hom-lab-ctl-k3s-01` | hvh-01 | `192.168.138.11` | Storage K3s stub |
| `hom-lab-ctl-dkr-02` | hvh-02 | `192.168.137.10` | GPU-lane Docker |
| `hom-lab-ctl-k3s-02` | hvh-02 | `192.168.137.11` | GPU-lane K3s |

Related prior work (5090 guests only, incident-driven):
[Singlegeneral-review-single-server-langfuse-two-server-infrastructure-retrospective.md](./Singlegeneral-review-single-server-langfuse-two-server-infrastructure-retrospective.md)

Layer vocabulary: [docs/reference/ai-homelab-layer-model.md](../../reference/ai-homelab-layer-model.md)

---

## Intended vs actual (summary)

```mermaid
flowchart LR
  subgraph intent [Intended split — SSOT + legacy contract]
    H01i["hvh-01 storage"]
    H01i --> DKR01i["dkr-01: Postgres, ClickHouse, Redis, MinIO, Langfuse compose"]
    H01i --> K3S01i["k3s-01: storage K3s / observability"]
    H01i --> SMB["F: HF model catalog SMB"]
    H02i["hvh-02 GPU"]
    H02i --> K3S02i["k3s-02: vLLM, LiteLLM, thin Langfuse edge only"]
  end

  subgraph actual [Actual Ansible targets today]
    H01a["hvh-01: VMs + SMB + Alloy collector"]
    DKR01a["dkr-01: Docker engine only — no Langfuse/Loki playbooks"]
    K3S01a["k3s-01: readiness stub absent"]
    H02a["hvh-02: portproxy + Alloy"]
    DKR02a["dkr-02: Postgres, Loki, Grafana, NetBox, Semaphore + orphan fuzlang data plane"]
    K3S02a["k3s-02: Langfuse Helm, LiteLLM, vLLM, Jupyter, Traefik"]
  end

  intent -.->|"placement drift"| actual
```

**Headline:** The **design** says storage/authoritative data on hvh-01 and a **quiet**
5090 lane focused on inference + gateway + minimal integration. The **running
automation** still concentrates Langfuse, its K3s dependencies, LiteLLM, vLLM,
Jupyter, Loki, NetBox, and Semaphore on the **5090 lane** (`dkr-02` / `k3s-02`).

---

## Homelab context — where both physical servers sit

```mermaid
flowchart TB
  subgraph home ["Home LAN 192.168.50.0/24"]
    router["Router / DNS<br/>hom.lab names"]
    mac["mac-dev<br/>192.168.50.x<br/>Ansible controller<br/>Alloy agent<br/>kubectl / Cursor client"]

    subgraph hvh01box ["hom-lab-ctl-hvh-01 — storage — .234"]
      direction TB
      H01["See Diagram A"]
    end

    subgraph hvh02box ["hom-lab-ctl-hvh-02 — RTX 5090 — .158"]
      direction TB
      H02["See Diagram B"]
    end

    router --> mac
    mac -->|"SSH / WinRM"| hvh01box
    mac -->|"SSH / WinRM"| hvh02box
    mac -->|"SMB read models"| hvh01box
    mac -->|"Langfuse / LiteLLM via portproxy or .137.x"| hvh02box
  end

  classDef context fill:#f3f4f6,stroke:#6b7280,color:#111
  class router,mac context
```

Legend for deployment diagrams:

- **Green** — live service targeted by current Ansible playbooks
- **Yellow** — deployed but likely unused / orphan relative to Langfuse path
- **Gray** — VM or engine present, no Langfuse/AI workload containers or pods
- **Blue dashed** — alternate playbook path exists but is not the live Langfuse stack

---

## Diagram A — Current deployment on `hom-lab-ctl-hvh-01` (storage physical server)

What is running **inside** each surface on this host today (repo automation targets).

```mermaid
flowchart TB
  subgraph hvh01 ["hom-lab-ctl-hvh-01 — 192.168.50.234 — guest subnet 192.168.138.0/24"]
    subgraph win01 ["Windows Server 2025 — directly on host"]
      hv01["Hyper-V + Guest switch NAT"]
      ssh01["OpenSSH Server"]
      alloy01["Grafana Alloy agent<br/>forwards logs outbound"]
      smb01["SMB share F:<br/>\\\\hom-lab-ctl-hvh-01\\public\\models\\huggingface"]
      backup01["Windows Server Backup<br/>scheduled to E: backups"]
    end

    subgraph dkr01vm ["VM hom-lab-ctl-dkr-01 — 192.168.138.10 — Ubuntu"]
      dkr01os["Ubuntu 24.04 + Docker Engine"]
      dkr01note["No active compose stacks<br/>from Langfuse/Loki/NetBox playbooks"]
    end

    subgraph k3s01vm ["VM hom-lab-ctl-k3s-01 — 192.168.138.11 — Ubuntu"]
      k3s01os["Ubuntu 24.04 only"]
      k3s01note["K3s not installed<br/>readiness stub = absent<br/>no pods / no Traefik"]
    end

    hv01 --> dkr01vm
    hv01 --> k3s01vm
    alloy01 -.->|"logs leave host<br/>no local Loki target"| alloy01
  end

  subgraph altpath ["Alternate playbook only — not live Langfuse path"]
    altstack["deploy_network_stacks.yaml → stacks_fuzlang_net<br/>would place Postgres, Redis, ClickHouse,<br/>MinIO, Langfuse compose on dkr-01"]
  end

  altpath -.-> dkr01vm

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000
  classDef idle fill:#f5f5f5,stroke:#9e9e9e,color:#000
  classDef alt fill:#e8eaf6,stroke:#3949ab,color:#000
  class hv01,ssh01,alloy01,smb01,backup01 live
  class dkr01os,k3s01os,dkr01note,k3s01note idle
  class altstack alt
```

**hvh-01 playbook anchors (what actually targets this host):**

| Surface | Service / workload | Role / playbook | Status |
|---------|-------------------|-----------------|--------|
| Windows | Hyper-V VMs | `hyperv_ubuntu_vm` | Live |
| Windows | Alloy log collector | `logging_alloy` / `logging.yaml` | Live |
| Windows | HF model SMB | `windows_file_shares` (host_vars) | Live |
| Windows | Server Backup | `windows_server_backup` | Live |
| `dkr-01` | Docker Engine only | `docker_engine` | Live — **no Langfuse/Loki containers** |
| `dkr-01` | fuzlang compose stack | `deploy_network_stacks.yaml` | **Alternate path — not live DB for Langfuse** |
| `k3s-01` | K3s cluster | `k3s_cluster_network` | VM only — **no K3s workloads** |

---

## Diagram B — Current deployment on `hom-lab-ctl-hvh-02` (5090 physical server)

What is running **inside** each surface on this host today (repo automation targets).

```mermaid
flowchart TB
  operator["LAN clients / mac-dev"]

  subgraph hvh02 ["hom-lab-ctl-hvh-02 — 192.168.50.158 — guest subnet 192.168.137.0/24"]
    subgraph win02 ["Windows Server 2025 — directly on host"]
      hv02["Hyper-V host"]
      ssh02["OpenSSH Server"]
      alloy02["Grafana Alloy agent"]
      portproxy["portproxy + firewall<br/>:80 :30000 :30400 :3100 :8000 :3001"]
      cdrive["C: Patriot P300 — Docker VM VHDX"]
      ddrive["D: SanDisk — K3s VM VHDX"]
    end

    subgraph dkr02vm ["VM hom-lab-ctl-dkr-02 — 192.168.137.10 — Docker containers"]
      direction TB
      pg["PostgreSQL :5432<br/>Langfuse external DB"]
      loki["Loki :3100"]
      graf["Grafana :3000"]
      nb["NetBox :8000"]
      sem["Semaphore :3001"]
      subgraph orphan ["stacks_fuzlang_net compose — langfuse image OFF"]
        d_redis["Redis :6379"]
        d_ch["ClickHouse"]
        d_minio["MinIO :9000 / :9001"]
      end
    end

    subgraph k3s02vm ["VM hom-lab-ctl-k3s-02 — 192.168.137.11 — K3s pods"]
      direction TB
      traefik["Traefik :31461"]
      lf_web["Langfuse web :30000"]
      lf_worker["Langfuse worker"]
      lf_ch["ClickHouse + ZooKeeper"]
      lf_redis["Redis"]
      lf_minio["MinIO / S3"]
      llm["LiteLLM :30400"]
      vllm["vLLM runtime — GPU"]
      jup["JupyterLab :8888"]
      lf_web --> lf_ch
      lf_worker --> lf_ch
      lf_web --> lf_redis
      lf_worker --> lf_redis
      lf_web --> lf_minio
      lf_worker --> lf_minio
    end

    hv02 --> dkr02vm
    hv02 --> k3s02vm
    cdrive --> dkr02vm
    ddrive --> k3s02vm
  end

  operator --> portproxy
  operator -->|"direct 192.168.137.x"| k3s02vm
  portproxy --> traefik
  portproxy --> loki
  portproxy --> nb
  portproxy --> sem
  portproxy --> lf_web
  portproxy --> llm
  alloy02 -->|"push logs"| loki
  lf_web -->|"PostgreSQL 5432"| pg
  lf_worker -->|"PostgreSQL 5432"| pg
  llm -.-> vllm

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000
  classDef orphan fill:#fff4cc,stroke:#997000,color:#000
  classDef publish fill:#dbeafe,stroke:#1d4ed8,color:#000
  class pg,loki,graf,nb,sem,lf_web,lf_worker,lf_ch,lf_redis,lf_minio,llm,vllm,jup,traefik,hv02,ssh02,alloy02 live
  class d_redis,d_ch,d_minio orphan
  class portproxy publish
```

**hvh-02 playbook anchors:**

| Surface | Service | Role / playbook | Target |
|---------|---------|-----------------|--------|
| `dkr-02` Docker | PostgreSQL | `stacks_fuzlang_net` / `deploy_network_stacks_hvh02.yaml` | Active Langfuse DB |
| `dkr-02` Docker | Loki + Grafana | `logging_loki` / `logging.yaml` | `logging_server` |
| `dkr-02` Docker | NetBox | `ipam_netbox` | `hom-lab-ctl-dkr-02` |
| `dkr-02` Docker | Semaphore | `ansible_ui_semaphore` | `hom-lab-ctl-dkr-02` |
| `dkr-02` Docker | Redis / ClickHouse / MinIO compose | `stacks_fuzlang_net` | **Orphan — Langfuse uses K3s copies** |
| `k3s-02` K3s | Langfuse platform | `k3s_langfuse_platform` | web/worker + in-cluster CH/Redis/MinIO |
| `k3s-02` K3s | LiteLLM | `k3s_litellm_gateway` | gateway |
| `k3s-02` K3s | vLLM | `k3s_vllm_runtime` | GPU inference |
| `k3s-02` K3s | Jupyter | `dev_jupyterlab_workbench` | workbench |
| Windows | Alloy | `logging_alloy` | collector |
| Windows | portproxy | `guest_published_tcp_ports` | publication |

---

## Diagram C — `hvh-01` live vs planned (storage lane)

```mermaid
flowchart TB
  subgraph hvh01 ["hom-lab-ctl-hvh-01 — storage lane — 192.168.50.234"]
    subgraph live01 ["Live today"]
      l_smb["HF model SMB"]
      l_alloy["Alloy collector"]
      l_hv["Hyper-V + 2 Ubuntu VMs"]
      l_dkr_idle["dkr-01: Docker engine, no AI/obs stacks"]
      l_k3s_idle["k3s-01: Ubuntu only, no K3s"]
    end

    subgraph planned01 ["Planned / declared — hyperv_lane_storage + layer model"]
      p_pg["Postgres — Langfuse DB"]
      p_ch["ClickHouse"]
      p_redis["Redis"]
      p_minio["MinIO"]
      p_loki["Loki + long-retention logs"]
      p_nb["NetBox / Semaphore"]
      p_lf["Langfuse data plane"]
    end
  end

  live01 -.->|"storage lane not hosting Langfuse stack yet"| planned01

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000
  classDef planned fill:#e8eaf6,stroke:#3949ab,color:#000
  class l_smb,l_alloy,l_hv,l_dkr_idle,l_k3s_idle live
  class p_pg,p_ch,p_redis,p_minio,p_loki,p_nb,p_lf planned
```

---

## Diagram D — `hvh-02` live vs planned (5090 lane)

```mermaid
flowchart TB
  subgraph hvh02 ["hom-lab-ctl-hvh-02 — RTX 5090 lane — 192.168.50.158"]
    subgraph live02 ["Live today — concentrated stack"]
      l_dkr["dkr-02 Docker:<br/>Postgres, Loki, Grafana, NetBox, Semaphore<br/>+ orphan CH/Redis/MinIO compose"]
      l_k3s["k3s-02 K3s:<br/>Langfuse, LiteLLM, vLLM, Jupyter, Traefik"]
      l_pub["Windows portproxy publication"]
    end

    subgraph planned02 ["Stated goal — quiet 5090 integration lane"]
      p_vllm["vLLM — large models"]
      p_llm["LiteLLM gateway"]
      p_edge["Thin edge only — join rest of Langfuse infra"]
      p_no_data["No authoritative Postgres / Loki / NetBox here"]
    end
  end

  live02 -.->|"5090 lane carries full data + app stack today"| planned02

  classDef live fill:#d5f5d1,stroke:#2e7d32,color:#000
  classDef planned fill:#e8eaf6,stroke:#3949ab,color:#000
  class l_dkr,l_k3s,l_pub live
  class p_vllm,p_llm,p_edge,p_no_data planned
```

---

## Diagram E — Cross-server dependencies (Langfuse data flow)

```mermaid
sequenceDiagram
  participant Client as LAN / mac-dev
  participant PP as hvh-02 portproxy
  participant T as k3s-02 Traefik
  participant LF as Langfuse web/worker
  participant PG as dkr-02 PostgreSQL
  participant CH as k3s-02 ClickHouse
  participant S3 as k3s-02 MinIO
  participant LLM as k3s-02 LiteLLM
  participant VLM as k3s-02 vLLM

  Client->>PP: langfuse.hom.lab :80 or :30000
  PP->>T: or direct NodePort 30000
  T->>LF: HTTP
  LF->>PG: SQL 5432 cross-guest
  LF->>CH: analytics
  LF->>S3: events/media
  Client->>PP: litellm.hom.lab :30400
  PP->>LLM: gateway
  LLM->>VLM: inference lane
  Note over PG,CH: Postgres on Docker guest;<br/>CH/Redis/MinIO on K3s guest
```

---

## Redundancy evaluation (from Diagrams A–D)

These findings are tied to what the deployment diagrams **show**, not guest
names alone.

### Confirmed redundant on `hvh-02` (Diagram B)

| What the diagram shows | Verdict | Why |
|------------------------|---------|-----|
| **Two ClickHouse instances** — Docker `d_ch` on `dkr-02` **and** K3s `lf_ch` on `k3s-02` | **Duplicate** | Langfuse Helm uses only the in-cluster ClickHouse. Docker ClickHouse is from `stacks_fuzlang_net` with compose Langfuse disabled — no playbook wires Langfuse to `192.168.137.10` ClickHouse. |
| **Two Redis instances** — Docker `d_redis` **and** K3s `lf_redis` | **Duplicate** | Same pattern: K3s Langfuse uses `langfuse-redis-master`; Docker Redis is orphan. |
| **Two MinIO instances** — Docker `d_minio` **and** K3s `lf_minio` | **Duplicate** | Langfuse events/media go to in-cluster MinIO; Docker MinIO is a second S3 endpoint on the same physical server. |
| **Langfuse HTTP via Traefik `:80` and NodePort `:30000`** | **Redundant publication** | Both are live paths through Windows portproxy. Operators can hit the same UI two ways. |
| **LiteLLM via Traefik hostname and NodePort `:30400`** | **Redundant publication** | Same dual-path pattern as Langfuse. |

**Not redundant (but structurally coupled):** PostgreSQL on `dkr-02` is the
**only** Langfuse database — K3s chart has `postgres_deploy: false`. That is
intentional split-DB, not duplication.

### Cross-server: not duplicate today, but latent duplicate risk (Diagrams A + B)

| What the diagrams show | Verdict | Why |
|------------------------|---------|-----|
| `hvh-01` `dkr-01` has Docker but **no live stacks** (Diagram A gray) | **Idle capacity — not duplicate yet** | Storage guest is empty of Langfuse workloads. |
| `deploy_network_stacks.yaml` alternate path on `dkr-01` (Diagram A dashed) | **Latent duplicate risk** | If applied while `dkr-02` stack stays up, you would get **second** Postgres / Redis / ClickHouse / MinIO / Langfuse compose on the **other physical server** with no migration plan. |
| HF SMB on `hvh-01` + vLLM on `hvh-02` | **Intentional split** | Model files vs inference runtime — correct, not duplicate. |
| Alloy on **both** Windows hosts | **Intentional** | Collectors on each physical server; not duplicate services. |

### Placement drift visible when comparing Diagram C vs Diagram D

| Live (diagrams) | Planned (diagrams) | Assessment |
|-----------------|-------------------|------------|
| Diagram B: Loki, NetBox, Semaphore, Postgres on `dkr-02` | Diagram C: those on `hvh-01` storage lane | **Wrong physical server** for observability/authoritative data — not duplicate, but opposite of design intent. |
| Diagram B: full Langfuse + deps on `k3s-02` | Diagram D: 5090 should be vLLM + LiteLLM + thin edge only | **Overloaded 5090 lane** — Langfuse stateful deps should not live here in target state. |
| Diagram A: storage VMs idle for Langfuse | Diagram C: storage hosts data plane | **Underused storage lane** — half of the two-server distribution is not doing its job. |

### Summary count

| Category | Count on `hvh-02` today |
|----------|-------------------------|
| **True duplicates** (same role, same server, one unused) | 3 — Docker Redis, ClickHouse, MinIO vs K3s copies |
| **Redundant publication paths** | 2 — Langfuse and LiteLLM dual ingress |
| **Cross-guest coupling** (not duplicate) | 1 — Postgres Docker ↔ Langfuse K3s |
| **Cross-server latent duplicate** | 1 — `deploy_network_stacks` on `dkr-01` if ever applied alongside `dkr-02` |
| **Correct intentional splits** | 2 — HF SMB on hvh-01; Alloy per host |

---

## Service placement matrix (Langfuse ecosystem)

| Service | Intended lane (design docs) | Actual target (playbooks) | Duplicate elsewhere? |
|---------|---------------------------|---------------------------|----------------------|
| Langfuse web/worker | hvh-01 or storage K3s | **k3s-02** | Docker compose disabled on dkr-02 |
| PostgreSQL (Langfuse DB) | hvh-01 / dkr-01 | **dkr-02** | Docker fuzlang stack also on dkr-01 if `deploy_network_stacks` run |
| ClickHouse | hvh-01 (intent) | **k3s-02 in-cluster** | **Yes — docker clickhouse on dkr-02 (orphan)** |
| Redis | hvh-01 (intent) | **k3s-02 in-cluster** | **Yes — docker redis on dkr-02 (orphan)** |
| MinIO / S3 | hvh-01 (intent) | **k3s-02 in-cluster** | **Yes — docker minio on dkr-02 (orphan)** |
| LiteLLM gateway | 5090 K3s | **k3s-02** | No |
| vLLM | 5090 K3s | **k3s-02** | No |
| Jupyter | dev on K3s | **k3s-02** | No |
| Loki / Grafana | storage / observability | **dkr-02** | No on hvh-01 |
| Alloy collectors | both Windows hosts | **hvh-01 + hvh-02** | No — by design |
| HF model files | hvh-01 SMB | **hvh-01 SMB** | No |

---

## Alignment with stated goals

| Goal | Current state |
|------|----------------|
| **hvh-01 = storage + collector** | **Partial** — SMB model catalog and Alloy yes; Loki/Langfuse/Postgres authoritative stack still on 5090 lane |
| **hvh-02 = quiet 5090 + large models + minimal integration** | **Not met** — 5090 lane hosts full Langfuse Helm chart, LiteLLM, vLLM, Jupyter, plus Docker infra (Loki, NetBox, Semaphore, Postgres) |
| **Distributed between two physical servers** | **Physical separation exists** (two Hyper-V hosts), but **Langfuse runtime is not distributed** — it is consolidated on hvh-02 with storage lane mostly idle for this stack |

---

## Evidence surfaces (repo)

- `inventory/group_vars/hyperv_lane_storage/main.yml`
- `inventory/group_vars/hyperv_lane_gpu/main.yml`
- `inventory/host_vars/hom-lab-ctl-hvh-01.yaml`
- `inventory/host_vars/hom-lab-ctl-hvh-02.yaml`
- `inventory/host_vars/hom-lab-ctl-dkr-01.yaml`
- `inventory/host_vars/hom-lab-ctl-dkr-02.yaml`
- `inventory/host_vars/hom-lab-ctl-k3s-01.yaml`
- `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`
- `inventory/inventory.yaml` — `logging_server`, `k3s_cluster_*`
- `roles/k3s_langfuse_platform/defaults/main.yml` — external Postgres, in-cluster CH/Redis/MinIO
- `roles/stacks_fuzlang_net/templates/docker-compose.yml.j2`
- `playbooks/deploy_network_stacks.yaml`, `deploy_network_stacks_hvh02.yaml`
- `playbooks/deploy_langfuse_platform.yaml`, `deploy_litellm_gateway.yaml`, `deploy_vllm_runtime.yaml`
- `docs/reference/ai-homelab-layer-model.md`
- `contracts/fuzlang.contract.yaml` (legacy placement scaffold)

Live runtime may differ from last apply; this document reflects **automation SSOT**
and declared inventory, not a live probe pass.

---

## Diagram inventory

### Included

- Homelab context (LAN + mac-dev + both physical servers)
- **Diagram A** — `hvh-01` current deployment (Windows + VM internals)
- **Diagram B** — `hvh-02` current deployment (Windows + Docker containers + K3s pods)
- **Diagram C** — `hvh-01` live vs planned
- **Diagram D** — `hvh-02` live vs planned
- **Diagram E** — cross-guest Langfuse data flow
- Intended vs actual summary (top of doc)

### Available on request

- Portproxy / Traefik / NodePort publication-only view
- Disk / VHDX placement (from prior 5090 incident doc)
- Target-state diagram after storage-lane convergence
