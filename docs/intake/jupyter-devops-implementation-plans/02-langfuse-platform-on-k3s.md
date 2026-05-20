# 02 - Langfuse Platform On K3s

## Goal

Deploy Langfuse on k3s with Helm as the observability platform for traces,
prompts, evals, datasets, and experiment visibility.

## Preliminary Project Structure And Resources

Expected project areas:

- `roles/k3s_langfuse_platform/`: new Helm-based role for Langfuse and required
  platform dependencies.
- `playbooks/`: add a k3s platform playbook or extend the K3s application
  playbook with `k3s_langfuse_platform` tags.
- `inventory/group_vars/`: define namespace, chart version, release name,
  storage classes, ingress hostnames, resource sizes, and persistence settings.
- `inventory/group_vars/*/vault.yml` or existing vault surface: store Langfuse,
  database, Redis/Valkey, MinIO, and encryption secrets outside plaintext.
- `roles/ipam_netbox/`: later model service endpoints, DNS names, and ownership
  tags for Langfuse.
- `docs/reference/naming-standards/`: add schema entries if service names or
  endpoint names are missing.

Expected Kubernetes resources:

- namespace
- Helm release
- Langfuse web deployment/service
- Langfuse worker deployment
- Postgres resources or external connection
- ClickHouse resources or external connection
- Redis/Valkey resources or external connection
- MinIO/S3 configuration
- ingress or internal service endpoint

## Implementation Intent

- Role name candidate: `k3s_langfuse_platform`.
- Deploy via Helm, not Docker Compose.
- Include or configure dependencies:
  - Langfuse web
  - Langfuse worker
  - Postgres
  - ClickHouse
  - Redis/Valkey
  - MinIO/S3-compatible blob storage
- Configure secrets, persistence, service exposure, and ingress or internal
  access.
- Prefer the storage/network server lane for storage-heavy platform services
  unless later hardware placement says otherwise.

## Acceptance Criteria

- Langfuse web/API is reachable from the Mac and from notebook/app workloads.
- Worker, database, cache, ClickHouse, and object storage are healthy.
- SDK traces can be accepted by the Langfuse API.
- Persistent data paths are explicit and backed by the intended server lane.

## Implementation Status

**COMPLETED** - May 20, 2026

### What Was Deployed

- Role: `k3s_langfuse_platform` created with Helm-based deployment
- Playbook: `playbooks/deploy_langfuse_platform.yaml` created
- Components running on `hom-lab-ctl-k3s-02`:
  - Langfuse web (1 replica) - running
  - Langfuse worker (1 replica) - running
  - PostgreSQL (10Gi persistent storage) - running
  - ClickHouse (single shard, 20Gi storage) - running
  - Redis (8Gi storage) - running
  - Zookeeper (single node for ClickHouse coordination) - running
  - S3-compatible storage - running

### Key Decisions

- Used official Langfuse Helm chart: `https://langfuse.github.io/langfuse-k8s`
- Chart name: `langfuse/langfuse` (v1.5.29 available)
- Secrets structured as `{value: "..."}` maps per chart requirements
- Single-node topology:
  - ClickHouse: 1 shard, 1 replica (no multi-shard replication)
  - Zookeeper: 1 node (minimum for ClickHouse coordination)
- Access: NodePort service at `http://192.168.137.11:30000`

### Sources Checked

- Langfuse Helm chart docs: https://langfuse.com/self-hosting/deployment/kubernetes-helm
- Langfuse GitHub: https://github.com/langfuse/langfuse-k8s
- Helm values reference: charts/langfuse/values.yaml
