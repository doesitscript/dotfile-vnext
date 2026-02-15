# Docker Engine — Resources (Idempotent Infra-as-Code)

This document specifies the **resources** that must be created or ensured on target hosts (e.g. Ubuntu 24.04 in WSL) for a clean Docker CE installation. The role `docker_engine` implements these as Ansible tasks. No snap; official Docker CE packages only.

## Target

- **Host group:** `wsl_hosts`
- **Playbook:** `playbooks/docker_engine.yaml`
- **Role:** `roles/docker_engine`

## Resources to Ensure (Idempotent)

### 1. Prerequisite packages (APT)

- **Resource type:** APT packages, present.
- **Names:** `ca-certificates`, `curl`, `gnupg`, `lsb-release`.
- **Scope:** Required for adding the Docker repository and GPG verification.

### 2. Directory: APT keyrings

- **Path:** `/etc/apt/keyrings`
- **State:** Directory, mode `0755`.
- **Purpose:** Hold signed-by key for Docker APT repo.

### 3. File: Docker GPG key

- **Path:** `/etc/apt/keyrings/docker.asc`
- **Source:** `https://download.docker.com/linux/ubuntu/gpg`
- **Mode:** `0644`.
- **Purpose:** APT repo signing verification.

### 4. APT repository: Docker CE

- **Resource type:** APT repository, present.
- **Definition:** `deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu {{ ansible_distribution_release }} stable`
- **Purpose:** Official Docker CE package source.

### 5. Docker and plugin packages (APT)

- **Resource type:** APT packages, present.
- **Names:** `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`.
- **Scope:** Engine, CLI, runtime, Buildx, and Compose plugin.

### 6. Group: docker

- **Name:** `docker`
- **State:** Present.
- **Purpose:** Membership grants unprivileged access to Docker socket.

### 7. User membership: docker group

- **Resource type:** User group membership.
- **User:** `{{ ansible_user_id }}`
- **Group:** `docker`
- **Append:** Yes (do not replace other groups).
- **Purpose:** Allow Ansible user to run `docker` / `docker compose` without sudo after re-login.

### 8. Systemd service: docker

- **Name:** `docker`
- **Enabled:** true (start on boot).
- **State:** started (running).
- **Purpose:** Docker daemon managed by systemd.

## Post-apply

- User must **log out of WSL and reconnect** (or start a new login session) for `docker` group membership to take effect.
- Verify: `docker version`, `docker compose version`.

## Why this approach

- Official Docker CE repository (apt, not snap).
- Systemd-managed service.
- Idempotent: safe to re-run.
- Compatible with WSL 24 and with Ansible `community.docker` modules.
