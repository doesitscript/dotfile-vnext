# k3s Workloads Role

Deploys application manifests to the k3s cluster.

This role:

- Waits for cluster readiness
- Creates ai-infra namespace
- Deploys StatefulSets (Postgres)
- Deploys Deployments (Model Server, Log Collector, Dashboard)
- Deploys Services and Ingress
- Waits for all workloads to be Ready

## Variables

- `workload_namespace` – Kubernetes namespace (default: ai-infra)
- `postgres_replica_count` – Postgres replicas (default: 1)
- `model_server_replica_count` – Model server replicas (default: 2)
- `log_collector_enabled` – Enable log collection (default: true)
- `dashboard_enabled` – Enable dashboard UI (default: true)

## Tasks

1. `main.yml` – Full deployment (namespace, storage, workloads)
2. `manifests.yml` – Apply individual manifests
3. `wait_ready.yml` – Wait for all workloads to reach Ready state

## Usage

```yaml
- include_role:
    name: k3s_workloads
  vars:
    workload_namespace: "ai-infra"
    model_server_replica_count: 2
```
