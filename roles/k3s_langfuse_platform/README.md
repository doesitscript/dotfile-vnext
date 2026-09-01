# k3s_langfuse_platform

Deploy Langfuse on K3s with external PostgreSQL, Redis, ClickHouse, and MinIO
resolved through the shared `langfuse_platform_external_*` inventory contract.

## Lifecycle

- `k3s_langfuse_platform_state: present|absent` — standard lifecycle control point.
- `k3s_langfuse_platform_fresh_install: true` — runs absent tasks before present (clean redeploy).
- Fresh-install also resets the external Langfuse PostgreSQL database through
  `k3s_langfuse_platform_postgres_inventory_host` when
  `k3s_langfuse_platform_reset_external_postgres_db_on_fresh_install: true`.

## Fresh redeploy (recommended after credential or chart changes)

```bash
ansible-playbook playbooks/deploy_langfuse_platform.yaml \
  -i inventory/inventory.yaml \
  -e k3s_langfuse_platform_state=absent -vvv

ansible-playbook playbooks/deploy_langfuse_platform.yaml \
  -i inventory/inventory.yaml \
  -e k3s_langfuse_platform_state=present -vvv
```

Or single run with fresh-install flag:

```bash
ansible-playbook playbooks/deploy_langfuse_platform.yaml \
  -i inventory/inventory.yaml \
  -e k3s_langfuse_platform_fresh_install=true -vvv
```

## Secrets

Secrets load from `vault/network.vault.yml` and `vault/shared.vault.yml` via `tasks/load_vault.yml`.
External data-plane connect addresses must use the `langfuse_platform_external_*_connect_address`
inventory contract values, not inventory hostnames.

The Langfuse web and worker workloads live on K3s. External data-plane targets
are owned by `inventory/group_vars/all/langfuse_platform_external_services.yml`; change
that shared contract first if the backing PostgreSQL/Redis/ClickHouse/MinIO
placement moves in a later governed packet.

## Tags

- `k3s_langfuse_platform`
- `langfuse`
- `ai_ml_platform`
