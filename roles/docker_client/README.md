# docker_client

Installs the Docker CLI and creates an SSH-based Docker context on client machines. The Docker daemon itself runs on a managed Linux VM host (installed by `geerlingguy.docker` via the `docker_engine` playbook) -- this role only sets up the **client** side.

No TCP ports are exposed. Clients connect to the engine over SSH using `docker context`.

## How it works

`tasks/main.yml` dispatches to OS-specific task files following the same pattern as `roles/git/tasks/`:

- **`mac.yml`** -- installs `docker` and `docker-compose` via Homebrew (CLI only, not Docker Desktop).
- **`windows.yml`** -- installs Docker CLI via `winget` and creates the context using `win_powershell`.

After the CLI is installed, shared tasks in `main.yml` create a Docker context pointing at the Linux VM engine and set it as the default.

## Playbooks

| Playbook | Purpose |
|----------|---------|
| `playbooks/docker_client.yaml` | Runs this role against the `docker_clients` inventory group |
| `playbooks/docker.yaml` | Orchestrator -- runs engine install, then this client role, then verification |

## Inventory

This role targets the `docker_clients` group defined in `inventory/inventory.yaml`, which includes:

- `execution_nodes` (mac-dev)
- `server-225-win`

## Defaults

| Variable | Default | Description |
|----------|---------|-------------|
| `docker_context_name` | `{{ physical_node \| default('linux-docker') }}` | Name of the Docker context |
| `docker_engine_ssh_user` | `{{ ansible_user }}` | SSH user for the engine connection |
| `docker_engine_ssh_host` | `{{ ansible_host \| default('localhost') }}` | Inventory/delegation identity of the Docker engine |
| `docker_engine_ssh_context_host` | `{{ docker_engine_ssh_host }}` | Reachable hostname or IP written into the Docker SSH context |
| `docker_engine_ssh_port` | `22` | SSH port for the engine connection |

Override these in `host_vars/` per client. See `host_vars/mac-dev.yaml` and `host_vars/server-225-win.yaml` for examples.

## Example commands

```bash
# All docker clients
ansible-playbook playbooks/docker_client.yaml -i inventory/inventory.yaml

# Mac only
ansible-playbook playbooks/docker_client.yaml -i inventory/inventory.yaml --limit mac-dev

# Windows only
ansible-playbook playbooks/docker_client.yaml -i inventory/inventory.yaml --limit server-225-win
```

## Related roles

- **`geerlingguy.docker`** -- installs the Docker Engine on Linux VM hosts (called by `playbooks/docker_engine.yaml`)
- **`verify_docker`** -- validates client-to-engine connectivity (`tasks/client.yml`)
- **`access_identity_controller`** -- generates the SSH keypair used by the Docker context
