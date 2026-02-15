# compose/lab_stack

Holds the **Docker Compose template** for the lab stack.

## Files and purpose

| File | Purpose |
|------|--------|
| `docker-compose.yml.j2` | Jinja2 template for the stack: Traefik (v3), whoami, Portainer. Uses `docker_domain` and is rendered by the `docker_stack` role onto the target at `docker_project_dest`. |

The role that deploys this template is `roles/docker_stack`; it uses a copy in `roles/docker_stack/templates/` so the role is self-contained. This folder is the canonical place in the repo layout for the compose definition.
