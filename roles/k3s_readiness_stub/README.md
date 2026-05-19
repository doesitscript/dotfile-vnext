# k3s_readiness_stub

Read-only readiness checks for the future K3s Ubuntu VM lane.

This role intentionally does not install K3s. It verifies that a prepared
Ubuntu VM is reachable, has enough base memory and root disk for the planned
single-node K3s path, and does not already have `k3s` or `k3s-agent` services.

Apply:

```bash
ansible-playbook playbooks/k3s_vm_stub.yaml -i inventory/inventory.yaml
```

Verify:

- target is in `k3s_vm_stub_hosts`
- host facts report Ubuntu 24.04 or newer
- `k3s.service` and `k3s-agent.service` are absent

Undo:

- no host changes are made by this role

Change class: read-only validation.
