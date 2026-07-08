# FUZLANG Infrastructure

**Project version:** `0.7.0` ([VERSION](VERSION))

Multi-node AI product engineering homelab automation using Ansible. This repo
is currently locked to one durable operating model:

- **NetBox owns infrastructure facts and naming intent**
- **Ansible owns lifecycle execution and convergence**
- **`inventory/netbox.yml` stays shadow/comparison-only** until reconciliation
  evidence is consistently green

Layer model: [docs/reference/ai-homelab-layer-model.md](docs/reference/ai-homelab-layer-model.md)  
Estate map: [docs/diagrams/cst-hom-lab-ctl-dia-homelab-estate-04.md](docs/diagrams/cst-hom-lab-ctl-dia-homelab-estate-04.md)

## Current Operating Model

Project-safe NetBox work follows this order:

1. repo seed/config and naming schema
2. repo consistency gate
3. NetBox apply or read-only reconciliation

Do not leave live NetBox state ahead of inventory, role defaults, seed tasks,
docs, or aliases in this repo.

Connection surfaces are authoritative per inventory hostname:
[docs/reference/connection-surfaces.md](docs/reference/connection-surfaces.md)

## Active Entry Points

These are the current steady-state control surfaces.

| Surface | Purpose |
|---|---|
| `playbooks/site.yaml` | Canonical full-stack lab converge |
| `playbooks/deploy_development_nodes.yaml` | Development tooling on commissioned development surfaces |
| `playbooks/mac/mcp_servers.yaml` | Controller-local MCP server convergence on `mac-dev` |
| `playbooks/deploy_ipam_netbox.yaml` | NetBox deploy, seed, preview, and lifecycle control |
| `playbooks/reconcile_netbox.yaml` | Read-only NetBox authority reconciliation |

The NetBox lifecycle control point remains `ipam_netbox_state: present|absent`.

## Local Verification Surfaces

This repo stays local-first for verification in this slice. Use existing
operator-invoked commands and scripts; do not rely on new remote runners,
GitHub Actions, or new git hook enforcement.

| Command | Purpose |
|---|---|
| `scripts/validate_netbox_repo_consistency.sh` | Verify repo references match NetBox naming/modeling decisions |
| `bin/netbox-authority-gate.sh --static-only` | Packet/governance and NetBox-scoped static checks |
| `bin/netbox-authority-gate.sh` | Full read-only reconciliation, inventory compatibility, and artifact capture |
| `ansible-playbook playbooks/site.yaml -i inventory/inventory.yaml --check --tags site_preview,hyperv_windows_host_preview,docker_vm_preview,docker_engine_preview` | Read-only scope preview for the active lab entrypoint |

See [roles/ipam_netbox/README.md](roles/ipam_netbox/README.md) for NetBox
preview/apply tags and reconciliation details.

## NetBox Transition

NetBox is the preferred source of truth for durable infrastructure facts.
Ansible remains the execution layer.

Run the repo consistency gate directly:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml -i inventory/inventory.yaml \
  --tags ipam_netbox_repo_consistency
```

Run the full read-only authority path:

```bash
bin/netbox-authority-gate.sh
```

See:

- [docs/plans/2026-05-08--netbox-naming-and-ansible-integration/README.md](docs/plans/2026-05-08--netbox-naming-and-ansible-integration/README.md)
- [roles/ipam_netbox/README.md](roles/ipam_netbox/README.md)

## Common Commands

Full active-lab converge:

```bash
ansible-playbook playbooks/site.yaml -i inventory/inventory.yaml
```

Development tooling on the Mac controller:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  -i inventory/inventory.yaml --limit mac-dev
```

Controller-local MCP servers on the Mac:

```bash
ansible-playbook playbooks/mac/mcp_servers.yaml \
  -i inventory/inventory.yaml --limit mac-dev
```

Deploy or converge NetBox:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml \
  -i inventory/inventory.yaml
```

Read-only NetBox reconciliation:

```bash
ansible-playbook playbooks/reconcile_netbox.yaml \
  -i inventory/inventory.yaml --tags netbox_authority_reconciliation
```

## Current Nodes

- `mac-dev`: macOS controller / execution node
- `hom-lab-ctl-hvh-02`: Windows Server 2025 GPU lane control host
- `hom-lab-ctl-hvh-01`: Windows Server 2025 storage lane control host
- `hom-lab-ctl-dkr-02`: Docker VM on the GPU lane
- `hom-lab-ctl-k3s-02`: K3s VM on the GPU lane
- `hom-lab-ctl-dkr-01`: Docker VM on the storage lane
- `hom-lab-ctl-k3s-01`: K3s VM on the storage lane
- `dev-3090-win`: deferred desktop GPU surface

## Historical Bootstrap Notes

Older bootstrap and WSL-centric narratives are not the active operator path for
steady-state work.

- Do not treat missing historical playbooks such as
  `playbooks/bootstrap_execution_node.yaml`,
  `playbooks/boostrap_windows_ssh_via_winrm.yaml`,
  `playbooks/bootstrap_server_225.yaml`,
  `playbooks/bootstrap_local.yml`, or
  `playbooks/deploy_shell_config.yaml` as current entrypoints.
- Use [docs/reference/connection-surfaces.md](docs/reference/connection-surfaces.md)
  and the active playbooks above instead.
- Historical WSL-centric material lives under
  [docs/archive/wsl-deprecating/](docs/archive/wsl-deprecating/).

## Quick Start

- See [AGENTS.md](AGENTS.md) for durable repo-specific Codex guidance.
- See [docs/codex_framework/README.md](docs/codex_framework/README.md) for the
  active framework surfaces.
- See [docs/codex_framework/partner_process.md](docs/codex_framework/partner_process.md)
  for the working contract.
- See [docs/tool_access/README.md](docs/tool_access/README.md) for shell, IDE,
  MCP, and agent tool access.
- See [docs/ansible/quality-gate.md](docs/ansible/quality-gate.md) for the
  repo-local Ansible lint and syntax gate.

## Contract

All configuration is driven by `contracts/fuzlang.contract.yaml`.
