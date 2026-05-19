# k3s_hello_world

Deploys a small `hashicorp/http-echo` smoke workload to the homelab K3s
cluster from `mac-dev` using the kubeconfig managed by `k3s_mac_client`.

Apply:

```bash
ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml --tags k3s_hello_world
```

Remove:

```bash
ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml \
  --tags k3s_hello_world -e k3s_hello_world_state=absent
```

Change class: idempotent K3s smoke workload.
