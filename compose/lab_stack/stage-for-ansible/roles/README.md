# roles

Ansible roles used by the lab-stack playbook.

## Roles and purpose

| Role | Purpose |
|------|--------|
| **docker_engine** | Ensures Docker is installed and running on the target host (Linux). Run before deploying the stack. |
| **docker_stack** | Creates the project directory, renders the compose template, and deploys the stack with `community.docker.docker_compose`. Tag: `docker`. |
| **verify_docker** | Gathers Docker host info and asserts that the Traefik container is running. Tag: `verify`. |

Playbook order: `docker_engine` → `docker_stack` → `verify_docker`. Use `--tags docker` to deploy, `--tags verify` to only verify.
