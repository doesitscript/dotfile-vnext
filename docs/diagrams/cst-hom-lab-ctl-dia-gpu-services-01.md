# GPU Lane Service Exposure

This diagram shows where the current GPU-lane services actually run and how
they are exposed after the router-side routed-subnet fix.

## Diagram

```mermaid
flowchart TB
    subgraph DKR["hom-lab-ctl-dkr-02 192.168.137.10"]
      NBX["NetBox\n:8000"]
      SEM["Semaphore\n:3001"]
      LOKI["Loki\n:3100"]
      GRAF["Grafana\n:3000"]
      PGS["Postgres\n:5432"]
      MINAPI["MinIO API\n:9000"]
      MINCON["MinIO Console\n:9001"]
    end

    subgraph K3S["hom-lab-ctl-k3s-02 192.168.137.11"]
      LFS["Langfuse NodePort\n:30000"]
      LLM["LiteLLM NodePort\n:30400"]
    end

    subgraph HVH["hom-lab-ctl-hvh-02 192.168.50.158"]
      PP["Windows portproxy publish layer"]
    end

    Direct["Direct routed guest-IP access\nfrom mac-dev and routed LAN clients"]
    LAN["LAN-published access\nthrough 192.168.50.158"]

    Direct --> NBX
    Direct --> SEM
    Direct --> LOKI
    Direct --> GRAF
    Direct --> PGS
    Direct --> MINAPI
    Direct --> MINCON
    Direct --> LFS
    Direct --> LLM

    LAN --> PP
    PP -->|"8000"| NBX
    PP -->|"3001"| SEM
    PP -->|"3100"| LOKI
    PP -->|"30000"| LFS
    PP -->|"30400"| LLM

    classDef direct fill:#d5f5d1,stroke:#2e7d32,color:#000;
    classDef publish fill:#dbeafe,stroke:#1d4ed8,color:#000;
    class Direct direct;
    class LAN,PP publish;
```

## Direct guest-IP endpoints

| Service | Direct path |
|---|---|
| NetBox | `http://192.168.137.10:8000/` |
| Semaphore | `http://192.168.137.10:3001/` |
| Loki | `http://192.168.137.10:3100/` |
| Grafana | `http://192.168.137.10:3000/` |
| Postgres | `postgresql://192.168.137.10:5432/` |
| MinIO API | `http://192.168.137.10:9000/` |
| MinIO Console | `http://192.168.137.10:9001/` |
| Langfuse | `http://192.168.137.11:30000/` |
| LiteLLM | `http://192.168.137.11:30400/` |

## Windows LAN-published endpoints

| Service | LAN-published path |
|---|---|
| NetBox | `http://192.168.50.158:8000/` |
| Semaphore | `http://192.168.50.158:3001/` |
| Loki | `http://192.168.50.158:3100/` |
| Langfuse | `http://192.168.50.158:30000/` |
| LiteLLM | `http://192.168.50.158:30400/` |

## Notes

- Grafana is direct guest-IP only right now; it is not currently published
  through the Windows LAN portproxy surface.
- Postgres and MinIO are also direct guest-IP paths in the current repo state.
