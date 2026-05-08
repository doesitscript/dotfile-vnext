# `ipam_netbox` Ansible Role

Deploys NetBox, the leading open-source IPAM and DCIM tool, using Docker Compose. This role is designed to be idempotent and provides a simple, state-based interface for managing the NetBox stack.

## Role Variables

| Variable                                        | Default         | Description                                                                 |
| ----------------------------------------------- | --------------- | --------------------------------------------------------------------------- |
| `ipam_netbox_state`                  | `present`       | The desired state of the NetBox stack (`present` or `absent`).                |
| `ipam_netbox_version`                | `v4.0.2`        | The version of NetBox to deploy.                                            |
| `ipam_netbox_data_path`              | `/opt/netbox`   | The path on the host to store NetBox persistent data and configuration.     |
| `ipam_netbox_user`                   | `root`          | The user that should own the data directories.                              |
| `ipam_netbox_group`                  | `root`          | The group that should own the data directories.                             |
| `ipam_netbox_http_port`              | `"8000:8080"`   | The port mapping for the NetBox web interface.                              |
| `ipam_netbox_remove_volumes_on_absent` | `false`         | Whether to remove Docker volumes when the stack is removed (`state: absent`). |

## Secrets Management

This role uses Ansible Vault to manage secrets. You must provide a vault file with the following variables:

- `vault_netbox_db_name`: The name of the PostgreSQL database.
- `vault_netbox_db_user`: The username for the PostgreSQL database.
- `vault_netbox_db_password`: The password for the PostgreSQL database.
- `vault_netbox_redis_password`: The password for Redis.
- `vault_netbox_secret_key`: NetBox's `SECRET_KEY`.
- `vault_netbox_superuser_name`: The username for the initial NetBox superuser.
- `vault_netbox_superuser_email`: The email for the initial NetBox superuser.
- `vault_netbox_superuser_password`: The password for the initial NetBox superuser.

These variables are used to render an `.env` file, which is then used by Docker Compose.

API-driven seed tasks also require `vault_netbox_api_token`. Use a dedicated
NetBox token for this repo, not the initial admin/bootstrap token, and keep it
encrypted in the local root `vault.yml`. That file is intentionally ignored by
Git in this repo.

## Tags

### Ansible Play Tags

These control which tasks run when `--tags` is passed to `ansible-playbook`.

| Tag | Selects |
| --- | ------- |
| `ipam_netbox` | Entire capability — deploy **or** remove, depending on `ipam_netbox_state` |
| `ipam_netbox_present` | Deploy path only (directories, config, images, compose up) |
| `ipam_netbox_absent` | Remove path only (compose down) |
| `ipam_netbox_smoke_test` | Health check only — confirms the web UI is responding |
| `ipam_netbox_api_token` | Ensures the dedicated repo NetBox API token exists from vault |
| `ipam_netbox_seed_tags` | Seeds canonical object tags into NetBox via the API (requires `netbox.netbox` collection) |
| `ipam_netbox_seed_server_225_model_preview` | Preview the first Server-225 NetBox object model without API mutation |
| `ipam_netbox_seed_server_225_model` | Seed the first Server-225 NetBox object model via the API |

Examples:

```bash
# Run only the NetBox capability inside a larger site playbook
ansible-playbook playbooks/site.yaml --tags ipam_netbox

# Re-run the smoke test without re-deploying
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass --tags ipam_netbox_smoke_test

# Preview the first NetBox source-of-truth modeling slice
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model_preview

# Ensure the dedicated repo API token exists from encrypted vault data
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_api_token

# Remove NetBox (combine with the absent state variable)
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  -e ipam_netbox_state=absent --tags ipam_netbox_absent

# Skip NetBox in a larger playbook
ansible-playbook playbooks/site.yaml --skip-tags ipam_netbox
```

### NetBox Object Tags (Inside NetBox)

NetBox has its own first-class Tag model (`extras/tag`). These tags are labels
applied to objects *within* NetBox — devices, prefixes, IP addresses, VMs, etc.
They are a separate concern from Ansible play tags above.

The `netbox.netbox` Ansible collection's `netbox_tag` module manages these via
the NetBox API. A future `tasks/seed_tags.yml` task file should seed at minimum:

| Tag name | Slug | Purpose |
| --- | --- | --- |
| `ansible-managed` | `ansible-managed` | Any object whose state is owned by this repo |
| `homelab` | `homelab` | Scopes objects to this environment |
| `ipam-netbox-role` | `ipam-netbox-role` | Identifies resources provisioned by this specific role |

Once seeded, you can query tagged objects via the NetBox API:
```
GET /api/extras/tags/ansible-managed/tagged-objects/
```

The `netbox.netbox` collection (`ansible-galaxy collection install netbox.netbox`)
and a NetBox API token are required. The token should be stored in Ansible Vault
under `vault_netbox_api_token` when this layer is wired.

## First Server-225 Model Slice

The first NetBox modeling slice is intentionally small. It seeds only enough
objects to represent the current Server-225 world:

- site: `Homelab`
- device: `server-225`
- cluster: `server-225-hyperv`
- VM: `server-225-ubuntu`
- platforms: Windows Server 2025 and Ubuntu 24.04
- tags: `ansible-managed`, `homelab`, `hyperv`, `docker`, `infra`

Preview the slice before mutation:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model_preview
```

Apply the slice after `vault_netbox_api_token` exists in `vault.yml`:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model
```

Do not wire the seed path to an ad hoc or placeholder-looking admin token. The
apply tag is the point where NetBox starts becoming a source of truth for this
repo, so the token should be intentionally named, write-scoped for automation,
and stored as `vault_netbox_api_token`.

## Shadow Dynamic Inventory

`inventory/netbox.yml` is a shadow inventory source for comparison only. It
uses the NetBox inventory plugin and reads the API token from `NETBOX_TOKEN`.
Do not switch playbooks to this inventory until its generated groups and host
vars have been compared against `inventory/inventory.yaml`.

## Example Playbook

```yaml
---
- name: Deploy Source of Truth (NetBox)
  hosts: server-225-ubuntu
  become: true
  roles:
    - role: ipam_netbox
```

To deploy NetBox, run the playbook:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass
```

To remove NetBox:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass -e "ipam_netbox_state=absent"
```

## Network Access From The LAN

The `ipam_netbox` role deploys NetBox on `server-225-ubuntu`, which sits on a
private Hyper-V subnet (`192.168.137.0/24`). The role only manages the
application on the VM — it does not configure the Windows host's port-proxy.

To make NetBox reachable from the LAN (e.g. your Mac at `http://192.168.50.158:8000`),
an entry must exist in `hyperv_config.guest_published_tcp_ports` in
`inventory/host_vars/server-225-win.yaml`:

```yaml
# NetBox IPAM/DCIM web UI (roles/ipam_netbox, playbooks/deploy_ipam_netbox.yaml)
- name: "netbox"
  listen_address: "192.168.50.158"
  listen_port: 8000
  connect_address: "192.168.137.10"
  connect_port: 8000
```

This entry is applied by running:

```bash
ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml \
  --limit server-225-win --tags hyperv_networking
```

That playbook creates the `netsh interface portproxy` rule and the
`Hyper-V Guest Published TCP netbox` Windows Firewall rule on `server-225-win`.
This entry is already present in the current inventory.
