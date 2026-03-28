# verify_docker

Non-destructive validation role for Docker. Makes no changes -- only checks that Docker is installed and reachable.

## Task files

- **`tasks/main.yml`** -- Engine-side verification. Runs `docker version` and `docker compose version` directly on the host where Docker Engine is installed. Use this against the Ubuntu VM engine hosts after those `*-ubuntu` identities are functioning as direct SSH targets.
- **`tasks/client.yml`** -- Client-side verification. Runs `docker info` through the SSH-based Docker context to confirm the client can reach the remote engine. Works on both macOS and Windows clients.

## Playbooks

| Playbook | How this role is used |
|----------|----------------------|
| `playbooks/docker.yaml` | Orchestrator calls `tasks/client.yml` via `include_role` with `tasks_from: client.yml` against `docker_clients` after engine and client setup |

You can also run the engine-side check standalone:

```bash
ansible-playbook playbooks/verify_docker.yaml -i inventory/inventory.yaml --tags verify
```

## Related roles

- **`docker_client`** -- installs Docker CLI and creates the SSH context that `client.yml` validates
- **`geerlingguy.docker`** -- installs Docker Engine (what `main.yml` validates)
