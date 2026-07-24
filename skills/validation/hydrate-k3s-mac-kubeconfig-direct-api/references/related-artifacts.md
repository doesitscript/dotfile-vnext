# Related Artifacts

## Apply

```bash
bin/codex-env ansible-playbook playbooks/k3s_mac_client.yaml \
  -i inventory/inventory.yaml --tags k3s_mac_client --limit mac-dev
```

## Inventory knobs (`inventory/host_vars/mac-dev.yaml`)

- `k3s_mac_client_clusters[].connection_mode: direct`
- `k3s_mac_client_manage_default_kubeconfig: false`
- `k3s_mac_client_shell_kubeconfig_export: true`
- `k3s_mac_client_default_context`

## Shell

- `~/.bashrc.d/k3s-kubeconfig.bash` — managed `KUBECONFIG=`
- Requires `common/shell_config` so login shells source `.bashrc.d`

## Swap clusters

```bash
kubectl config use-context hom-lab-ctl-k3s-01
kubectl config use-context hom-lab-ctl-k3s-02
```
