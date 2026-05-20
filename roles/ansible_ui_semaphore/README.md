# ansible_ui_semaphore

Deploys [Semaphore](https://semaphoreui.com/) — a web UI for running Ansible playbooks — as a Docker Compose stack on the target host.

## Capability

Semaphore provides a browser-based interface for managing Ansible projects, inventories, environments, and playbook runs. This role deploys it as a single-container stack using BoltDB (embedded) so no external database is required.

## Naming Schema

Role name follows the project's `<capability_domain>_<implementation>` pattern:
- `ansible_ui` = the capability domain (web UI for Ansible automation)
- `semaphore` = the specific implementation

All role variables are prefixed with `ansible_ui_semaphore_`.

## Requirements

- Docker and `community.docker` collection installed on the target
- `vault.yml` at the project root encrypted with Ansible Vault containing the variables listed below

## Vault Variables Required

| Variable | Purpose |
|---|---|
| `vault_semaphore_admin_username` | Admin login username |
| `vault_semaphore_admin_name` | Admin display name |
| `vault_semaphore_admin_email` | Admin email address |
| `vault_semaphore_admin_password` | Admin login password |
| `vault_semaphore_access_key_encryption` | Encryption key for stored SSH/API keys (>= 32 chars) |

## Role Variables

| Variable | Default | Description |
|---|---|---|
| `ansible_ui_semaphore_state` | `present` | `present` or `absent` |
| `ansible_ui_semaphore_version` | `v2.17.38` | Semaphore image tag |
| `ansible_ui_semaphore_data_path` | `/opt/semaphore` | Host path for data and compose files |
| `ansible_ui_semaphore_user` | `root` | Owner of data directories |
| `ansible_ui_semaphore_group` | `root` | Group of data directories |
| `ansible_ui_semaphore_http_port` | `3001:3000` | Port mapping (host:container). Host port 3001 is used because 3000 is reserved for Grafana. |
| `ansible_ui_semaphore_remove_volumes_on_absent` | `false` | Remove Docker volumes when absent |

## Network Access

Semaphore listens on container port 3000, mapped to host port 3001.

| Access path | URL |
|---|---|
| From inside the VM | `http://127.0.0.1:3001/` |
| From the Windows host (direct) | `http://192.168.137.10:3001/` |
| From the LAN (Mac or other hosts) | `http://192.168.50.158:3001/` |

LAN access requires a `guest_published_tcp_ports` entry on the Windows Hyper-V host (`inventory/host_vars/hom-lab-ctl-hvh-02.yaml`) creating a `netsh portproxy` rule and Windows Firewall inbound rule. See `playbooks/configure_hyperv_windows_hosts.yaml`.

## Playbook

```yaml
ansible-playbook playbooks/deploy_ansible_ui_semaphore.yaml
```

To remove the stack (preserving volumes by default):

```yaml
ansible-playbook playbooks/deploy_ansible_ui_semaphore.yaml -e ansible_ui_semaphore_state=absent
```

## Design Notes

- Uses BoltDB (embedded) — no external Postgres/MySQL needed for homelab scale
- `.env` file rendered at `/opt/semaphore/.env`, mode 0600, never stored in repo
- Upgrade: change `ansible_ui_semaphore_version` and re-run; BoltDB is preserved in the named volume
