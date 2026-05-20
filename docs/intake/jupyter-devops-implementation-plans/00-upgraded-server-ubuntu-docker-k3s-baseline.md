# 00 - Upgraded Server Ubuntu/Docker/K3s Baseline

## Goal

Adapt and target the existing Ansible work that provisions baseline Ubuntu VMs,
Docker VMs, K3s VMs, and NetBox-backed host/VM/IP/role modeling so both upgraded
server lanes are ready for the later platform work.

## Preliminary Project Structure And Resources

Expected project areas:

- `inventory/`: add or reconcile host/group entries for the two upgraded
  physical servers, their Hyper-V control surfaces, Docker/service VMs, and
  K3s VMs.
- `inventory/netbox.yml`: keep NetBox dynamic inventory available for read-only
  comparison and later adoption.
- `roles/ipam_netbox/`: seed or reconcile NetBox objects for physical servers,
  Hyper-V clusters, VMs, interfaces, IPs, roles, tags, and config context.
- Existing Ubuntu baseline role/playbooks: generalize inputs so the same base
  VM work supports Docker and K3s lanes.
- Existing Docker role/playbooks: ensure Docker work only targets Docker/service
  VMs.
- Existing K3s role/playbooks: ensure K3s work only targets Kubernetes VMs.
- `docs/reference/naming-standards/`: use compact schema names and role codes
  before introducing new inventory or NetBox names.
- Future official plan packet: promote this intake slice to
  `docs/plans/YYYY-MM-DD--upgraded-server-baseline/README.md` before
  implementation.

Expected resource categories:

- physical server objects
- Hyper-V host/cluster objects
- Ubuntu VM objects
- VM interfaces and management IPs
- Docker/service VM role assignments
- K3s VM role assignments
- workload-placement tags or config context

## Target Servers

```text
storage/network server
  - more storage and RAM
  - intended home for platform services where appropriate:
    Langfuse, MinIO, Postgres, ClickHouse, Redis/Valkey, LiteLLM,
    JupyterLab workbench, model cache, and backups

RTX 5090 server
  - stronger GPU/inference host
  - intended home for GPU-enabled k3s and vLLM runtime work
  - expected Hyper-V + Ubuntu VM split:
    one Ubuntu VM for Kubernetes/k3s and one Ubuntu VM for Docker/services
```

## Implementation Intent

- Reuse and adapt the generic Ubuntu VM baseline automation.
- Apply Docker setup only to the Docker/service VM lane.
- Apply K3s setup to the Kubernetes VM lane on each upgraded server.
- Use NetBox to record physical servers, Hyper-V clusters/hosts, Ubuntu VMs,
  interfaces, IPs, roles, and workload-placement metadata.
- Keep the two server lanes explicit; do not collapse platform and GPU runtime
  placement onto one server by accident.

## Acceptance Criteria

- Both physical server lanes are represented in NetBox or queued for NetBox seed
  reconciliation.
- Each intended Ubuntu VM has a clear role: baseline, Docker/service, or K3s.
- Docker targeting excludes K3s-only VMs.
- K3s targeting excludes Docker-only VMs.
- The later Jupyter/Langfuse/LiteLLM/vLLM plans have concrete inventory targets.
