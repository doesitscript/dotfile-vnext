# playbooks

Playbooks that run the lab stack roles.

## Files and purpose

| File | Purpose |
|------|--------|
| `docker_deploy.yaml` | Targets `server_225`; loads vault, runs `docker_engine`, `docker_stack`, `verify_docker`. Use `--tags docker` to deploy, `--tags verify` to verify only. |

## Run

Deploy:

```bash
ansible-playbook playbooks/docker_deploy.yaml -i inventory/inventory.yaml --tags docker --ask-vault-pass
```

Verify only:

```bash
ansible-playbook playbooks/docker_deploy.yaml -i inventory/inventory.yaml --tags verify
```

You need an inventory that defines the `server_225` group and host(s).
