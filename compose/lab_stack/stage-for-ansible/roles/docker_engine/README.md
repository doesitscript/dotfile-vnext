# docker_engine role

Ensures Docker is installed and running on the target host so the lab stack can be deployed.

## Files and purpose

| Path | Purpose |
|------|--------|
| `tasks/main.yml` | Installs Docker (package or `community.docker.docker`), ensures the Docker service is running. No handlers; idempotent. |

## When it runs

Before `docker_stack`. The playbook runs this role so `docker_compose` has a working Docker daemon. If your host already has Docker, the role is effectively a no-op.
