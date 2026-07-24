# K3s Mac Kubeconfig Diagnostic Sources

## Logging Locations

- Managed kubeconfigs: `~/.kube/hom-lab-ctl-k3s-01.yaml`, `~/.kube/hom-lab-ctl-k3s-02.yaml`
- Optional merge (discouraged when separate files are desired): `~/.kube/config`
- Shell export: `~/.bashrc.d/k3s-kubeconfig.bash`
- Ansible play output for `playbooks/k3s_mac_client.yaml`

## Diagnostic Commands

```bash
echo "$KUBECONFIG"
kubectl config get-contexts
kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}{"\n"}'
kubectl get nodes -o wide
nc -vz 192.168.137.11 6443
nc -vz 192.168.138.11 6443
# Tunnel mode only:
lsof -nP -iTCP:16443 -sTCP:LISTEN
lsof -nP -iTCP:26443 -sTCP:LISTEN
```

## Event / Channel Sources

- SSH client errors when jump/tunnel fails (terminal stderr)
- K3s API TLS errors from kubectl (`x509: certificate is valid for …`)

## Vendor / Tooling Diagnostics

- `kubectl version --client`
- k9s / stern / gonzo inherit `KUBECONFIG`; if they see no clusters, the shell export was not sourced
- Role: `roles/k3s_mac_client/`
- Lessons: `docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md`

## Notes

- Prefer **direct** mode failure analysis: route + TLS SAN, not tunnel process.
- Prefer **ssh_tunnel** failure analysis: jump SSH + local listener + rehydrate.
- Do not treat Docker Desktop rewriting `~/.kube/config` as a K3s outage when using separate files + `KUBECONFIG`.
- Exec credential plugins do not fix jump/reachability; document under lessons-learned pattern 4.
- Ansible `delegate_to` / ProxyJump success is **not** evidence that Mac→guest `:6443` works. Prove with `nc`/`ping` from the Mac.
- 2026-07-23: Root cause on HVH-01 was inventory `guest_outbound_nat_enabled: true` keeping `HyperVGuestNat`. After setting `false` and applying `configure_hyperv_windows_hosts.yaml`, Mac→`192.168.138.11:22`/`:6443` matches the HVH-02/137 path. Both clusters use `connection_mode: direct`.
