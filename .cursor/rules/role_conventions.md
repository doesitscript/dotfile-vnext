# Role Development Conventions

## Multi-OS Task Pattern

Roles that support multiple operating systems use platform-specific task files included from `main.yml`:

```yaml
- name: Include OS-specific tasks
  ansible.builtin.include_tasks: "{{ ansible_os_family | lower }}.yml"
```

Common filenames: `darwin.yml` (macOS), `debian.yml` or `ubuntu.yml` (Linux/WSL), `windows.yml` (Windows).

## Role Categories

1. **Access/Identity roles** (`access_identity_*`, `transport_execnode_*`) — SSH keys, OpenSSH server, authorized_keys
2. **Common roles** (`common/*`) — Shared across all nodes (baseline, shell_config, health_checks)
3. **Node-specific roles** (`server_225/*`, `dev_3090/*`, `network_server/*`) — Hardware or environment specific
4. **Tooling roles** (top-level: `git/`, `python/`, `docker_engine/`, `direnv/`, `cursor/`) — Software installation

## Tagging

Some roles use tags for selective execution. Example: `access_identity_windows` uses `admin` and `user` tags to separate privileged vs unprivileged tasks.

When adding tasks to an existing role, check if it uses tags and follow the same pattern.

## Defaults & Variables

- Role defaults go in `roles/<role>/defaults/main.yml`
- Roles should reference variables from `host_vars` and `group_vars` — not hardcode values
- If a role needs site-specific data, it should come through the inventory variable chain, not from `params/site.yaml` directly

## Task Naming

Every task `name:` describes the **outcome**, not the module being used:

```yaml
# Good
- name: Ensure OpenSSH Server capability is installed

# Bad
- name: Run win_optional_feature for OpenSSH
```

## Handlers

Use handlers for service restarts. Do not restart services inline in tasks.

## Windows-Specific

- Windows tasks use `ansible.windows.*` or `community.windows.*` FQCN modules
- WinRM connection variables are set in `group_vars/windows_hosts.yaml`
- Windows paths use backslashes in templates but may need conversion for WSL interop
