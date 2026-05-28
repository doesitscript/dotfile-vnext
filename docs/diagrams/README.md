# Diagrams

This folder holds project diagrams that are durable enough to be referenced by
docs, plans, and troubleshooting notes.

## Naming convention

Diagram files in this folder use a schema-shaped documentation pattern derived
from the active canonical ID pattern:

```text
<namespace>-<tenant>-<environment>-<domain>-<resource_class>-<name>-<idx>
```

Applied here as:

```text
cst-hom-lab-ctl-dia-<topic>-<idx>.md
```

Where:

- `cst` = namespace
- `hom` = tenant
- `lab` = environment
- `ctl` = control-plane domain
- `dia` = local diagram resource class for this folder
- `<topic>` = short diagram topic
- `<idx>` = two-digit ordinal

## Current diagrams

| File | Purpose |
|---|---|
| [cst-hom-lab-ctl-dia-gpu-topology-01.md](cst-hom-lab-ctl-dia-gpu-topology-01.md) | Post-router target topology for the GPU Hyper-V lane, including router, Windows host, guest VMs, subnets, and primary traffic paths |
| [cst-hom-lab-ctl-dia-gpu-services-01.md](cst-hom-lab-ctl-dia-gpu-services-01.md) | Service exposure map for the GPU lane, showing direct guest endpoints versus Windows LAN-published endpoints |
| [cst-hom-lab-ctl-dia-gpu-control-01.md](cst-hom-lab-ctl-dia-gpu-control-01.md) | Control-plane and operator access map for the GPU lane, including SSH, Ansible, NetBox, Docker, and K3s-related paths |
| [cst-hom-lab-ctl-dia-svcinv-drift-01.md](cst-hom-lab-ctl-dia-svcinv-drift-01.md) | Pre-fix service inventory drift map for the storage lane, showing curated expectations versus broken runtime state |
| [cst-hom-lab-ctl-dia-svcinv-remediation-02.md](cst-hom-lab-ctl-dia-svcinv-remediation-02.md) | Recovery sequence for the storage-lane stack and NetBox hybrid preview cleanup |
| [cst-hom-lab-ctl-dia-svcinv-steady-03.md](cst-hom-lab-ctl-dia-svcinv-steady-03.md) | Final steady-state diagram for curated repo data, runtime discovery, and live NetBox service agreement |
| [cst-hom-lab-ctl-dia-homelab-hosts-file-01.md](cst-hom-lab-ctl-dia-homelab-hosts-file-01.md) | Interim DNS-3 hosts-file bridge (`homelab_hosts_file_*`, Traefik registry, portproxy web catalog) |

## Notes

- These are Markdown documents containing Mermaid diagrams.
- The existing `logging-architecture.html` remains as a legacy standalone
  artifact; new durable diagrams should prefer this Markdown + Mermaid shape.
