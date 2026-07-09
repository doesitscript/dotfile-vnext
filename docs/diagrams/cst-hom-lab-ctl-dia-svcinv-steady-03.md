# Service Inventory Steady State

This diagram shows the final steady-state after the storage-lane runtime and
the NetBox hybrid preview were brought back into agreement.

## Diagram

```mermaid
flowchart TB
    subgraph Repo["Repo source of truth"]
      Curated["Curated service model\nipam_netbox"]
      StackRole["stacks_fuzlang_net\ncompose + env contract"]
    end

    subgraph StorageLane["HOM-LAB-HVH-01 storage lane"]
      HVH["HOM-LAB-HVH-01\nWindows Hyper-V host"]
      DKR["hom-lab-ctl-dkr-01\nDocker VM 192.168.138.10"]
      K3S["hom-lab-ctl-k3s-01\nK3s VM 192.168.138.11"]

      LF["Langfuse web\n:3000"]
      MINAPI["MinIO API\n:9000"]
      MINCON["MinIO Console\n:9001"]
      PG["Postgres\n:5432"]
      CH["ClickHouse\n:8123 / :9004"]
      REDIS["Redis\n:6379 loopback-only"]
    end

    subgraph Reconcile["Hybrid preview + evidence"]
      Runtime["Docker/K3s runtime discovery"]
      Artifact["artifacts/netbox-service-inventory/latest.json"]
      NetBox["Live NetBox service objects"]
    end

    Curated --> StackRole
    StackRole --> HVH
    HVH --> DKR
    HVH --> K3S

    DKR --> LF
    DKR --> MINAPI
    DKR --> MINCON
    DKR --> PG
    DKR --> CH
    DKR --> REDIS

    Curated --> Runtime
    Runtime --> Artifact
    NetBox --> Artifact
    Curated --> Artifact

    Artifact -->|"clean result"| Good["runtime_misses=[]\nnetbox_misses=[]\nruntime_unmodeled_exposures=[]"]

    classDef runtime fill:#d5f5d1,stroke:#2e7d32,color:#000;
    classDef ctl fill:#dbeafe,stroke:#1d4ed8,color:#000;
    classDef report fill:#f3e8ff,stroke:#7e22ce,color:#000;
    class LF,MINAPI,MINCON,PG,CH,REDIS runtime;
    class Curated,StackRole,HVH ctl;
    class Runtime,Artifact,NetBox,Good report;
```

## Storage-lane service state

| Service | Expected state after fix |
|---|---|
| `langfuse-web` | Published on `hom-lab-ctl-dkr-01:3000` and discovered by preview |
| `minio-api` | Published on `hom-lab-ctl-dkr-01:9000` and healthy |
| `minio-console` | Published on `hom-lab-ctl-dkr-01:9001` and healthy |
| `postgres-fuzlang` | Published on `hom-lab-ctl-dkr-01:5432` |
| `clickhouse-*` and `redis-fuzlang` | Intentionally internal-only or loopback-oriented where modeled |
