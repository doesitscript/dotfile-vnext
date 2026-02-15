# stage-for-ansible

Staged Ansible project for the **lab stack**: Traefik reverse proxy, whoami, Portainer, with vault and role-based layout. This folder mirrors the target repo structure so you can copy it into your real project or run from here.

## What’s in this folder

| Path | Purpose |
|------|--------|
| `compose/lab_stack/` | Compose template(s) for the stack (Traefik, whoami, Portainer). |
| `roles/docker_engine/` | Ensures Docker is installed and running on the host. |
| `roles/docker_stack/` | Creates project dir, templates compose, deploys with `docker_compose`. |
| `roles/verify_docker/` | Verifies Docker and that the Traefik container is running. |
| `group_vars/` | Group variables for `server_225` and encrypted vault placeholder. |
| `playbooks/` | Playbook that runs the three roles. |

## What you do with it

1. Copy this tree into your repo (or use it as the project root).
2. Create the vault: `ansible-vault create group_vars/vault.yml` and add `vault_traefik_dashboard_password` (and any other secrets).
3. Run: `ansible-playbook playbooks/docker_deploy.yaml -i inventory/inventory.yaml --tags docker` to deploy; `--tags verify` to verify only.

**Note:** This staged tree does not include an inventory; use your own `inventory/inventory.yaml` (or `-i` path) that defines the `server_225` group and host(s).

Each subfolder has a short README describing its files and purpose.
