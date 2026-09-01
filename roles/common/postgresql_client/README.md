# common/postgresql_client

Installs the PostgreSQL client (`psql`) for operator diagnostics.

## Scope

- macOS: Homebrew `libpq`
- Ubuntu: `postgresql-client`

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml --limit mac-dev --tags postgresql_client
```

## Lifecycle

| Variable | Default | Purpose |
|---|---|---|
| `postgresql_client_state` | `present` | `present` or `absent` |

## Notes

Use `psql` against **connect addresses** (`host_ip`, `ansible_host`, or
`langfuse_platform_external_postgres_connect_address`). Do not pass Ansible inventory
hostnames into connection strings unless they are also resolvable SSH/DNS names.
