# Langfuse Two-Server Infrastructure Retrospective

## Scope

This retrospective maps the Langfuse-related services across the two Linux
guests hosted by `HOM-LAB-HVH-02`. It combines repo-declared topology with
live troubleshooting evidence gathered after the Windows host experienced a
slow login, a prolonged black screen, and a stalled Server Manager splash.

There are exactly two Linux guests on this 5090 Hyper-V host: the Docker guest
`hom-lab-ctl-dkr-02` and the K3s guest `hom-lab-ctl-k3s-02`. Loki, Grafana, and
Langfuse's external PostgreSQL database run on the Docker guest. The Langfuse
web/worker application and its K3s-side dependencies run on the K3s guest.
They behave like separate servers at the service layer, but both depend on the
same physical Windows Hyper-V host. During the incident both VM disks shared
`C:`; after the immediate repair, the Docker VM remains on `C:` and the K3s VM
runs from `D:`.

## Current Layout After Immediate Repair

```mermaid
flowchart TB
  operator["LAN clients and operator"]
  alloy["Grafana Alloy<br/>Windows event-log collector"]

  subgraph hvh["HOM-LAB-HVH-02 - Windows Server / Hyper-V - 192.168.50.158"]
    portproxy["Windows portproxy publication<br/>80, 30000, 30400, 3100"]
    cdrive["C: Patriot P300 512 GB NVMe<br/>Windows OS and Docker VM VHDX"]
    ddrive["D: SanDisk Ultra 3D NVMe<br/>K3s VM VHDX after June 6 move"]

    subgraph dkr["hom-lab-ctl-dkr-02 - Docker VM - 192.168.137.10"]
      docker["Docker Engine"]
      postgres["External PostgreSQL<br/>Langfuse system-of-record database"]
      loki["Grafana Loki<br/>log aggregation"]
      grafana["Grafana"]
      dockerdata["Docker data and service volumes<br/>inside 40 GB guest VHDX"]
      docker --> postgres
      docker --> loki
      docker --> grafana
      postgres --> dockerdata
      loki --> dockerdata
      grafana --> dockerdata
    end

    subgraph k3s["hom-lab-ctl-k3s-02 - K3s VM - 192.168.137.11"]
      traefik["K3s Traefik<br/>NodePort 31461"]
      nodeport["Langfuse NodePort<br/>30000"]
      litellm["LiteLLM gateway<br/>NodePort 30400"]
      web["Langfuse web"]
      worker["Langfuse worker"]
      clickhouse["ClickHouse<br/>analytics and events"]
      redis["Redis / Valkey"]
      minio["MinIO / S3"]
      zookeeper["ZooKeeper"]
      k3sdata["Single 80 GB root VHDX<br/>OS, containerd, K3s and every PVC"]

      traefik --> web
      nodeport --> web
      web --> clickhouse
      worker --> clickhouse
      web --> redis
      worker --> redis
      web --> minio
      worker --> minio
      clickhouse --> zookeeper
      clickhouse --> k3sdata
      redis --> k3sdata
      minio --> k3sdata
    end

    cdrive -->|"40 GB VHDX"| dkr
    ddrive -->|"80 GB VHDX"| k3s
  end

  operator -->|"HTTP 80"| portproxy
  operator -->|"Langfuse 30000"| portproxy
  operator -->|"LiteLLM 30400"| portproxy
  portproxy -->|"80 to 31461"| traefik
  portproxy -->|"30000 to 30000"| nodeport
  portproxy -->|"30400 to 30400"| litellm
  alloy -->|"Loki push via 192.168.50.158:3100"| portproxy
  portproxy -->|"3100 to 192.168.137.10:3100"| loki
  web -->|"PostgreSQL 5432"| postgres
  worker -->|"PostgreSQL 5432"| postgres

  classDef issue fill:#ffe0e0,stroke:#a11,color:#111;
  classDef unused fill:#fff4cc,stroke:#997000,color:#111;
  class k3sdata,traefik,nodeport issue;
```

### What The Incident Proved

- `hom-lab-ctl-k3s-02.vhdx` continuously read at roughly 135 MB/s from the
  Windows `C:` drive while ClickHouse repeatedly attempted MergeTree merges.
- ClickHouse was near its former 1536 MiB memory limit, had been OOM-killed,
  and accumulated thousands of failed readiness probes.
- Scaling ClickHouse to zero stopped the VHDX reads and immediately returned
  Windows storage queue depth and guest I/O wait to normal.
- Before the immediate repair, the Windows host, both Linux guests, and all K3s
  persistent volumes competed for the same Patriot P300 system disk.
- On June 6, 2026, the entire K3s VHDX was moved from `C:` to `D:`. The Docker
  guest remains on `C:`, and the K3s OS, containerd, and PVCs remain combined
  inside one VHDX on `D:`.
- After the move, `D:` has roughly 14 GB free. ClickHouse no longer saturates
  the Windows system disk, but its accumulated merge backlog still encounters
  memory-limit rejections. Increasing memory further is not safe without a
  separate capacity and ClickHouse tuning decision.
- The healthy Toshiba external USB disk is mounted as `E:` with label
  `backups`, and no active VM VHDX uses it. A native-host-recovery backup task
  targets `E:`, but its latest scheduled result is `1` (failed), so backups
  must not be treated as verified until that task is repaired and a restore is
  tested.

## Redundancy And Layout Findings

| Finding | Assessment | Correction |
| --- | --- | --- |
| Langfuse is published through both a dedicated NodePort and Traefik | Redundant publication paths increase configuration and troubleshooting surface | Select Traefik as the normal HTTP front door; retain a direct NodePort only as an explicitly documented recovery path |
| Windows portproxy fronts Docker and K3s services | Necessary with the current routed-private guest layout, but it is a publication single point and stale-listener risk | Keep it automated and verified; prefer direct routed guest access or a dedicated ingress/load-balancer address as the network matures |
| Docker and K3s each provide service, storage, and publication surfaces | Intentional platform separation can be useful, but it duplicates operations and capacity overhead | Keep Docker for shared infrastructure and K3s for clustered application workloads; document ownership and avoid deploying the same service in both |
| PostgreSQL runs on Docker while Langfuse runs on K3s | Reasonable separation of durable database and application lifecycle, but creates a cross-guest dependency | Keep only if PostgreSQL has explicit backup, readiness, and network verification |
| Loki used an impossible in-container shell-and-`wget` healthcheck | Incorrect: the distroless Loki image contains neither a shell nor `wget`, so Docker reported a false unhealthy state | Clear the invalid Docker healthcheck and perform the official `/ready` probe from the Docker host with a recurring systemd timer |
| Both VM VHDXs lived on Windows `C:` during the incident | Incorrect for sustained database and container I/O; the K3s VHDX has now been moved to `D:` | Keep active K3s storage off `C:` and separately evaluate the Docker VM placement |
| K3s root, containerd, and all PVCs share one VHDX | High blast radius and no I/O isolation; ClickHouse activity can stall the guest and Windows host | Split guest OS and workload data into separate VHDXs and mounts |
| ClickHouse used an undersized memory limit | Incorrect for the observed merge workload; caused OOM and recovery churn | Use explicit requests and limits, monitor merges, and size from observed workload |

## Recommended Target Layout

```mermaid
flowchart TB
  clients["LAN clients and operators"]

  subgraph hvh["HOM-LAB-HVH-02 - Windows Server / Hyper-V"]
    ctarget["C: Patriot P300<br/>Windows OS and host tools only"]
    dtarget["D: SanDisk Ultra 3D NVMe<br/>VM and active workload storage"]
    backup["External USB storage<br/>backup copies only"]
    publish["One documented publication path<br/>automated and health-verified"]

    subgraph dkr["hom-lab-ctl-dkr-02 - Docker infrastructure VM"]
      dkr_os["Small OS VHDX"]
      dkr_data["Dedicated data VHDX<br/>/var/lib/docker or /srv/data"]
      shared["PostgreSQL, Loki and Grafana"]
      dkr_os --> shared
      shared --> dkr_data
    end

    subgraph k3s["hom-lab-ctl-k3s-02 - K3s application VM"]
      k3s_os["Small OS VHDX"]
      k3s_data["Dedicated data VHDX<br/>/var/lib/rancher/k3s"]
      ingress["Traefik as normal HTTP front door"]
      apps["Langfuse and LiteLLM"]
      stateful["ClickHouse, Redis and MinIO"]
      k3s_os --> apps
      ingress --> apps
      apps --> stateful
      stateful --> k3s_data
    end

    dtarget --> dkr_os
    dtarget --> dkr_data
    dtarget --> k3s_os
    dtarget --> k3s_data
    dkr_data -. "scheduled backup" .-> backup
    k3s_data -. "scheduled backup" .-> backup
  end

  clients --> publish
  publish --> ingress
  publish --> shared
  apps -->|"PostgreSQL 5432"| shared

  classDef os fill:#e6f2ff,stroke:#286090,color:#111;
  classDef data fill:#e3f6e8,stroke:#287a3d,color:#111;
  classDef backup fill:#fff4cc,stroke:#997000,color:#111;
  class ctarget,dkr_os,k3s_os os;
  class dtarget,dkr_data,k3s_data data;
  class backup backup;
```

## Recommended Sequence

1. Stabilize ClickHouse and verify it no longer creates sustained disk queueing.
2. Back up both guests and confirm recovery procedures.
3. Completed June 6, 2026: during a controlled outage, move the K3s guest VHDX
   from `C:` to `D:` as the immediate performance correction.
4. Add separate data VHDXs and migrate Docker and K3s workload data to their
   dedicated mounts.
5. Consolidate Langfuse publication around Traefik and document any retained
   direct NodePort as recovery-only.
6. Add capacity, disk-latency, ClickHouse-merge, and endpoint-readiness
   monitoring before expanding the AI service stack.

## Evidence Surfaces

- `inventory/host_vars/HOM-LAB-HVH-02.yaml`
- `inventory/host_vars/hom-lab-ctl-dkr-02.yaml`
- `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`
- `roles/hyperv_ubuntu_vm/defaults/main.yml`
- `roles/k3s_langfuse_platform/`
- `roles/logging_loki/`
- Live Hyper-V VHDX counters, Windows disk counters, K3s pod state, and
  ClickHouse logs gathered during the incident.
