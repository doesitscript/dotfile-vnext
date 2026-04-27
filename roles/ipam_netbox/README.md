# `ipam_netbox` Ansible Role

Deploys NetBox, the leading open-source IPAM and DCIM tool, using Docker Compose. This role is designed to be idempotent and provides a simple, state-based interface for managing the NetBox stack.

## Role Variables

| Variable                                        | Default         | Description                                                                 |
| ----------------------------------------------- | --------------- | --------------------------------------------------------------------------- |
| `ipam_netbox_state`                  | `present`       | The desired state of the NetBox stack (`present` or `absent`).                |
| `ipam_netbox_version`                | `v4.0.2`        | The version of NetBox to deploy.                                            |
| `ipam_netbox_data_path`              | `/opt/netbox`   | The path on the host to store NetBox persistent data and configuration.     |
| `ipam_netbox_user`                   | `root`          | The user that should own the data directories.                              |
| `ipam_netbox_group`                  | `root`          | The group that should own the data directories.                             |
| `ipam_netbox_http_port`              | `"8000:8080"`   | The port mapping for the NetBox web interface.                              |
| `ipam_netbox_remove_volumes_on_absent` | `false`         | Whether to remove Docker volumes when the stack is removed (`state: absent`). |

## Secrets Management

This role uses Ansible Vault to manage secrets. You must provide a vault file with the following variables:

- `vault_netbox_db_name`: The name of the PostgreSQL database.
- `vault_netbox_db_user`: The username for the PostgreSQL database.
- `vault_netbox_db_password`: The password for the PostgreSQL database.
- `vault_netbox_redis_password`: The password for Redis.
- `vault_netbox_secret_key`: NetBox's `SECRET_KEY`.
- `vault_netbox_superuser_name`: The username for the initial NetBox superuser.
- `vault_netbox_superuser_email`: The email for the initial NetBox superuser.
- `vault_netbox_superuser_password`: The password for the initial NetBox superuser.

These variables are used to render an `.env` file, which is then used by Docker Compose.

## Tags

This role does not use any specific tags.

## Example Playbook

```yaml
---
- name: Deploy Source of Truth (NetBox)
  hosts: server-225-ubuntu
  become: true
  roles:
    - role: ipam_netbox
```

To deploy NetBox, run the playbook:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass
```

To remove NetBox:

```bash
ansible-playbook playbooks/deploy_ipam_netbox.yaml --ask-vault-pass -e "ipam_netbox_state=absent"
```
