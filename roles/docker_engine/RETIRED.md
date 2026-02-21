# docker_engine — RETIRED

This role has been replaced by the `geerlingguy.docker` Galaxy role, which provides
a well-maintained, battle-tested Docker Engine install with:

- Official Docker apt repository and GPG key management
- docker-ce, docker-ce-cli, containerd.io, docker-compose-plugin
- Docker group membership and service enablement
- Support for Ubuntu, Debian, RHEL, and more

## Migration

- **Engine install**: `playbooks/docker_engine.yaml` now applies `geerlingguy.docker` to `wsl_hosts`.
- **Client setup**: `playbooks/docker_client.yaml` applies `roles/docker_client` to `docker_clients`.
- **Orchestrator**: `playbooks/docker.yaml` chains engine + client + verification.

## Why retired

The original `tasks/main.yml` installed `docker.io` (the Debian-packaged version)
which lags behind the official Docker releases and lacks Compose v2 plugin support.
`geerlingguy.docker` installs from Docker's official repo and keeps feature parity.

The original `tasks/main.yml` is preserved alongside this file for reference.
