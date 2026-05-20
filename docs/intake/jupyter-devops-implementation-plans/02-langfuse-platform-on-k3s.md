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
