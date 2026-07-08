# k3s_langfuse_platform

Deploy Langfuse on K3s with external PostgreSQL, Redis, ClickHouse, and MinIO
on the storage-lane Docker network stack.

## Lifecycle

- `k3s_langfuse_platform_state: present|absent` — standard lifecycle control point.
- `k3s_langfuse_platform_fresh_install: true` — runs absent tasks before present (clean redeploy).

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
External data-plane connect addresses must use the `fuzlang_external_*_connect_address`
inventory contract values, not inventory hostnames.

The intended runtime path for those external services is the Windows-published
LAN surface on `hom-lab-ctl-hvh-01` (`192.168.50.234`). Do not swap this role
back to the guest-direct `192.168.138.x` addresses unless that preference is
explicitly changed in the shared inventory contract.

## Tags

- `k3s_langfuse_platform`
- `langfuse`
- `ai_ml_platform`
