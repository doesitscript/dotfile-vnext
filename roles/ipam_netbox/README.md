# `ipam_netbox` Ansible Role

Deploys NetBox, the leading open-source IPAM and DCIM tool, using Docker Compose. This role is designed to be idempotent and provides a simple, state-based interface for managing the NetBox stack.

## First-Run Prerequisites

Follow these steps in order when setting up a fresh clone of this repo or when
rebuilding the NetBox integration from scratch.

### 1. Install Ansible collections

```bash
ansible-galaxy collection install -r requirements.yml
```

This installs `netbox.netbox` (required for API seeding and later dynamic
inventory).

### 2. Install Python dependencies

The `netbox.netbox` collection requires `pynetbox` and `pytz` on the Ansible
controller. Run the dev-tools role or install manually:

```bash
# Via Ansible (preferred — keeps the repo venv consistent)
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags ansible_dev_tools --limit localhost

# Or directly in the repo venv
.venv/bin/pip install pynetbox pytz
```

### 3. Deploy NetBox

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass
```

This runs the full Docker Compose stack on `server-225-ubuntu`. Confirm the
web UI is reachable at `http://192.168.50.158:8000/` before proceeding.

### 4. Create a dedicated NetBox API token

In the NetBox UI: **Admin → API Tokens → Add**. Name it something like
`dotfile-vnext Ansible automation`. Copy the token value.

Do not reuse the superuser/admin token. A dedicated token scoped for this
repo keeps credentials compartmentalized and makes rotation easier.

### 5. Encrypt the token into vault.yml

```bash
ansible-vault encrypt_string 'YOUR_TOKEN_HERE' \
  --name 'vault_netbox_api_token' >> vault.yml
```

`vault.yml` is ansible-vault encrypted and committed to git. The vault
password lives in `.vault_pass` (git-ignored).

### 6. Seed the first source-of-truth model

Preview first (no NetBox mutation):

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model_preview
```

Then apply:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model
```

Verify in the NetBox UI: you should see site `homelab`, tenant `home`,
device `home-lab-auth-hvh-02`, cluster `server-225-hyperv`, VM
`server-225-ubuntu` with primary IP, and tags including `ansible-managed`,
`home`, `lab`, `auth`, `homelab`, `hyperv`, `docker`, and `infra`. You should
also see application services on `server-225-ubuntu` for `netbox-web`,
`semaphore-web`, `loki-http`, and `grafana-web`.

### Repo Consistency Gate

Any NetBox identity/modeling update must update the repo in the same change.
The project-safe path is:

1. Update repo seed/config first.
2. Run the repo consistency gate.
3. Apply the NetBox seed/update third.

Run this gate before or with NetBox seed work:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_repo_consistency
```

The NetBox seed preview/apply tags also run this gate automatically. It fails
when retired NetBox names remain in active inventory, playbooks, scripts, or
planning docs outside explicit legacy-alias or migration contexts.

---

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
NetBox token for this repo, not the initial admin/bootstrap token. Encrypt
it with `ansible-vault encrypt_string` and store it in the root `vault.yml`.
That file is ansible-vault encrypted and committed to git — the vault password
(`.vault_pass`) is what stays out of version control.

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
| `ipam_netbox_repo_consistency` | Verifies repo references match NetBox naming/modeling decisions before seed work |
| `ipam_netbox_seed_tags` | Seeds canonical object tags into NetBox via the API (requires `netbox.netbox` collection) |
| `ipam_netbox_seed_server_225_model_preview` | Preview the first Server-225 NetBox object model without API mutation |
| `ipam_netbox_seed_server_225_model` | Seed the first Server-225 NetBox object model via the API |
| `ipam_netbox_seed_network_server_vm_model_preview` | Preview the network-server Hyper-V VM model without API mutation |
| `ipam_netbox_seed_network_server_vm_model` | Seed the network-server Hyper-V VM model via the API |

Examples:

```bash
# Run only the NetBox capability inside a larger site playbook
ansible-playbook playbooks/site.yaml --tags ipam_netbox

# Re-run the smoke test without re-deploying
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass --tags ipam_netbox_smoke_test

# Preview the first NetBox source-of-truth modeling slice
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model_preview

# Preview the network-server VM modeling slice
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_network_server_vm_model_preview

# Verify the repo is not carrying stale active NetBox names before apply
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_repo_consistency

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

- site: `homelab`
- tenant: `home`
- device: `home-lab-auth-hvh-02`
- legacy device aliases: `server-225-win`, `server-225`, `exec-hvh-01`
- cluster: `server-225-hyperv`
- VM: `server-225-ubuntu`
- application services on `server-225-ubuntu`:
  - `netbox-web` at `tcp/8000`
  - `semaphore-web` at `tcp/3001`
  - `loki-http` at `tcp/3100`
  - `grafana-web` at `tcp/3000`
- platforms: Windows Server 2025 and Ubuntu 24.04
- tags: `ansible-managed`, `home`, `lab`, `auth`, `homelab`, `hyperv`,
  `docker`, `infra`, `execution`, `experimental`, `non-authoritative-data`,
  `service-endpoint`, `web-ui`, `observability`

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

## Network-Server VM Model Slice

The network-server VM slice seeds the Hyper-V objects that live under
`home-lab-auth-hvh-01` without installing K3s:

- device: `home-lab-auth-hvh-01`
- legacy/control aliases: `network-server`, `primary-hvh-01`, and the retired
  network-server Windows control alias
- cluster: `home-lab-auth-hvh-01-hyperv`
- Docker VM: `nsrv-dkr-01`
- K3s placeholder VM: `nsrv-k3s-01`
- VM roles: `docker-engine`, `k3s-node`
- tags: includes `docker`, `k3s`, `hyperv`, `authoritative-data`, and
  `lan-exposed-services`

Preview the slice before mutation:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_network_server_vm_model_preview
```

Apply after the preview and repo consistency gate are clean:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_network_server_vm_model
```

This slice models `nsrv-k3s-01` as a VM stub target only. It does not add the
host to the live `k3s_cluster` server group and does not install K3s.

## Reproducibility and Recovery

### The Code-First Rule

**Never create or modify a NetBox object in the UI without first writing the
Ansible seed task.**

For this repo, "code first" means repo seed/config first, the
`ipam_netbox_repo_consistency` gate second, and NetBox apply third. A NetBox UI
or API change is not complete until the repo can recreate it and the gate passes.

When this rule is followed, the Ansible code in this repo is the full recovery
path for a lost NetBox instance. No separate backup is needed to recreate the
source-of-truth model.

### Full Recovery From Code (preferred path)

If NetBox is lost and the code-first rule was followed:

```bash
# Step 1: redeploy the NetBox stack
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass

# Step 2: re-seed the source-of-truth model
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_seed_server_225_model
```

Verify at `http://192.168.50.158:8000/` — objects should be back.

### Database Backup (safety net)

Take an on-demand `pg_dump` backup to `artifacts/netbox-backups/`:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass \
  --tags ipam_netbox_backup_db
```

The dump lands at `artifacts/netbox-backups/netbox-<timestamp>.dump` on the
controller (custom pg_dump format). The same dump is kept at
`/opt/netbox/backups/` on `server-225-ubuntu`.

Backups are git-ignored — they are binary artifacts, not source files.

### Restoring From a Database Backup

```bash
# Step 1: deploy a fresh NetBox stack (creates empty database)
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass

# Step 2: copy the backup file to the host
ansible server-225-ubuntu -m ansible.builtin.copy \
  -a "src=artifacts/netbox-backups/<file>.dump dest=/tmp/<file>.dump"

# Step 3: restore into the running postgres container
# (ssh to server-225-ubuntu as root/sudo)
docker cp /tmp/<file>.dump netbox-postgres-1:/tmp/<file>.dump
docker exec -e PGPASSWORD=<db-password> netbox-postgres-1 \
  pg_restore -U netbox -d netbox --clean /tmp/<file>.dump

# Step 4: restart NetBox to pick up restored data
docker compose -f /opt/netbox/docker-compose.yml restart netbox netbox-worker
```

The DB password is in `vault.yml` under `vault_netbox_db_password`.

### When to Back Up

- Before any significant NetBox schema or data migration
- Before upgrading the NetBox version (`ipam_netbox_version`)
- Periodically as part of homelab maintenance

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

NetBox models these published endpoints as application services on the VM that
runs them. For current access, use:

| Service | LAN URL | Direct guest URL | NetBox parent |
|---|---|---|---|
| NetBox | `http://192.168.50.158:8000/` | `http://192.168.137.10:8000/` | `server-225-ubuntu` |
| Semaphore | `http://192.168.50.158:3001/` | `http://192.168.137.10:3001/` | `server-225-ubuntu` |
| Loki | `http://192.168.50.158:3100/loki/api/v1/push` | `http://192.168.137.10:3100/` | `server-225-ubuntu` |
| Grafana | N/A | `http://192.168.137.10:3000/` | `server-225-ubuntu` |

NetBox does not natively model application-level port forwarding/PAT as a
first-class relationship, so the service comments record the Windows
`netsh portproxy` publishing path through `home-lab-auth-hvh-02`.
Grafana is Docker-published on the Ubuntu VM but is not currently published
through the Windows LAN portproxy.

That playbook creates the `netsh interface portproxy` rule and the
`Hyper-V Guest Published TCP netbox` Windows Firewall rule on `server-225-win`.
This entry is already present in the current inventory.
