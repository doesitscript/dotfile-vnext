# k3s_mac_client

Configures `mac-dev` as a `kubectl` client for the homelab K3s cluster.

Apply:

```bash
ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml --tags k3s_mac_client
```

What it does:

- installs the official macOS `kubectl` binary under `~/.local/bin`
- copies the K3s admin kubeconfig from `hom-lab-ctl-k3s-01`
- rewrites the kubeconfig server to a local API tunnel through the modeled
  Hyper-V jump host alias for the selected cluster node (currently
  `HOM-LAB-HVH-01` for `hom-lab-ctl-k3s-01`)
- installs the managed kubeconfig as `~/.kube/config` by default so bare
  `kubectl get nodes` works from any terminal
- skips clusters that are intentionally absent or mid-rebuild, removes any
  stale local kubeconfig for that cluster, and keeps the remaining contexts
  usable
- validates `kubectl get nodes` from macOS

Undo:

```bash
ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml --tags k3s_mac_client \
  -e k3s_mac_client_state=absent
```

Change class: idempotent macOS client configuration.
