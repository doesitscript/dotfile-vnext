# import-pre-process

Short readme for this folder and the material in `all.md`.

## What is being done here

- **Process transcription:** Requests from the user are recorded in `process-transcription.md` with clear “what was asked,” steps taken, and reasoning, so the work can be redone without the user (or by the agent) given the same material.
- **Processing `all.md`:** The content of `all.md` is summarized below so any folder, file, or snippet derived from it has a single place that states what the spec tells the agent to do.

## What `all.md` tells you to do (summary)

`all.md` is a single consolidated spec for building a **production-style, lab-appropriate Docker stack** with Ansible. It instructs:

| Area | Instruction |
|------|-------------|
| **Target** | Clean Docker lab stack: reverse proxy (Traefik), proper compose structure, Ansible templating, vault usage, clean separation. No hardcoded secrets. |
| **Architecture** | Server runs Traefik → whoami (test), Portainer (optional). Access via `http://server-ip`, `http://whoami.server-ip`. |
| **Repo layout** | `compose/lab_stack/docker-compose.yml.j2`, roles: `docker_engine`, `docker_stack`, `verify_docker`, `group_vars/server_225.yml`, `group_vars/vault.yml` (encrypted), `playbooks/docker_deploy.yaml`. |
| **Vault** | Create with `ansible-vault create group_vars/vault.yml`; store `vault_traefik_dashboard_password` (and similar) encrypted. |
| **group_vars** | `server_225.yml`: `docker_project_name`, `docker_project_dest`, `docker_domain`, `traefik_dashboard_user`. |
| **Compose template** | `docker-compose.yml.j2`: Traefik v3, whoami, Portainer; Traefik labels for dashboard and whoami routing by `docker_domain`. |
| **docker_stack role** | Ensure project dir, template compose, deploy with `community.docker.docker_compose`. |
| **verify_docker role** | Gather docker info, assert traefik container is running. |
| **Playbook** | `docker_deploy.yaml`: hosts `server_225`, load vault, run `docker_engine` → `docker_stack` → `verify_docker`. |
| **Run** | Deploy: `--tags docker`. Verify only: `--tags verify`. |

When implementing from snippets in `all.md`, use these paths and this structure; keep secrets in vault and follow the workspace Ansible/cursor rules.
