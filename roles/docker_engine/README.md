# docker_engine -- RETIRED

This role has been replaced by the `geerlingguy.docker` Galaxy role. See `RETIRED.md` for migration details.

## Why retired

The original `tasks/main.yml` installed `docker.io` (the Debian-packaged version), which lags behind official Docker releases and lacks the Compose v2 plugin. `geerlingguy.docker` installs from Docker's official apt repository and handles GPG keys, service enablement, and user group membership.

## Current setup

- **Engine install**: `playbooks/docker_engine.yaml` operates on the `*-wsl` inventory hosts, but all work is delegated through the companion `*-win` host via `wsl.exe`. The `wsl_hosts` group should only contain Linux companion surfaces that are meant to be direct SSH targets.
- **Client setup**: `playbooks/docker_client.yaml` applies `roles/docker_client` to `docker_clients`.
- **Orchestrator**: `playbooks/docker.yaml` chains engine + client + verification.

## Related

- **`geerlingguy.docker`** -- the replacement (installed to `roles/galaxy/` via `requirements.yml`)
- **`docker_client`** -- installs Docker CLI on Mac and Windows
- **`verify_docker`** -- validates the installation
