---
name: kubeconfig-context-hydrator
description: "Router for Mac K3s kubeconfig hydration. Prefer hydrate-k3s-mac-kubeconfig-direct-api when guest :6443 is reachable via Mac routes; use hydrate-k3s-mac-kubeconfig-ssh-tunnel when ssh -L is required. Both use separate per-cluster kubeconfigs and bash KUBECONFIG export for kubectl/k9s/stern/gonzo."
---

# Kubeconfig Context Hydrator (router)

This name is retained for discoverability. Use one of the project skills:

| Situation | Skill |
| --- | --- |
| Mac can reach guest `192.168.13x.11:6443` (no tunnel) | `hydrate-k3s-mac-kubeconfig-direct-api` |
| Need `ssh -L` through Hyper-V jump | `hydrate-k3s-mac-kubeconfig-ssh-tunnel` |

Both skills:

- Prefer **separate** `~/.kube/<context>.yaml` files (not fighting `~/.kube/config`)
- Export `KUBECONFIG` via `~/.bashrc.d/k3s-kubeconfig.bash`
- Drive apply through `playbooks/k3s_mac_client.yaml`

Patterns and options:
`docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md`
