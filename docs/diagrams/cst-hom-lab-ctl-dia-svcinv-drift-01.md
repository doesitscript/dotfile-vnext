# Service Inventory Drift

This diagram captures the service-inventory mismatch that existed before the
storage-lane recovery work was completed.

## Diagram

```mermaid
flowchart LR
    Repo["Repo-curated NetBox model\nroles/ipam_netbox/defaults/main.yml"]
    Preview["Hybrid preview\nartifacts/netbox-service-inventory/latest.json"]
    NetBox["Live NetBox service objects"]

    subgraph HVH01["hom-lab-ctl-hvh-01 lane"]
      DKR01["hom-lab-ctl-dkr-01\nDocker VM 192.168.138.10"]
      K3S01["hom-lab-ctl-k3s-01\nK3s VM 192.168.138.11"]

      subgraph Expected["Curated storage-lane services"]
        LFEXP["langfuse-web :3000"]
        MINAPIEXP["minio-api :9000"]
        MINCONEXP["minio-console :9001"]
        PGEXP["postgres-fuzlang :5432"]
        REXP["redis-fuzlang :6379"]
        CHEXP["clickhouse-http/:8123\nclickhouse-native/:9004"]
      end

      subgraph Runtime["Observed runtime state before fix"]
        LFBROKE["langfuse container\nrestart / bad env contract"]
        MINBROKE["minio container\nimage/data mismatch"]
        OKINT["postgres / redis / clickhouse\nrunning"]
        TRAEFIK["kube-system/traefik NodePorts\nsystem exposure"]
      end
    end

    Repo -->|"declares"| Expected
    DKR01 -->|"runtime discovery"| Runtime
    Preview -->|"compares curated vs runtime vs NetBox"| Repo
    Preview --> NetBox

    LFEXP -. "runtime miss" .-> LFBROKE
    MINAPIEXP -. "runtime miss" .-> MINBROKE
    MINCONEXP -. "runtime miss" .-> MINBROKE
    PGEXP --> OKINT
    REXP --> OKINT
    CHEXP --> OKINT

    Runtime -->|"noise in preview before filtering"| TRAEFIK

    classDef broken fill:#fee2e2,stroke:#b91c1c,color:#000;
    classDef noisy fill:#fef3c7,stroke:#b45309,color:#000;
    classDef good fill:#d5f5d1,stroke:#2e7d32,color:#000;
    class LFBROKE,MINBROKE broken;
    class TRAEFIK noisy;
    class OKINT good;
```

## What this shows

- The repo and NetBox both expected `langfuse-web`, `minio-api`, and
  `minio-console` on `hom-lab-ctl-dkr-01`.
- Runtime discovery proved those storage-lane endpoints were not actually
  healthy or published yet.
- The preview also surfaced intentional-but-noisy exposures:
  loopback-only Docker ports and `kube-system` K3s NodePorts.
