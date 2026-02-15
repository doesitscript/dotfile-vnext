# docker_stack role

Deploys the lab stack: creates the project directory, templates the compose file, and runs `docker_compose`.

## Files and purpose

| Path | Purpose |
|------|--------|
| `templates/docker-compose.yml.j2` | Jinja2 compose template (Traefik, whoami, Portainer). Uses `docker_domain`. |
| `tasks/main.yml` | Ensures `docker_project_dest` exists, templates compose into it, runs `community.docker.docker_compose` with `state: present`. Tag: `docker`. |

## Variables used

- `docker_project_dest` — directory on the host where the stack is deployed (e.g. `/opt/lab_stack`).
- `docker_domain` — hostname domain for Traefik routing (e.g. `server-225.local`).

Secrets stay in vault; this role does not touch them.
