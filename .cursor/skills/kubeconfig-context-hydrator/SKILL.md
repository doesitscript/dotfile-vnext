---
name: kubeconfig-context-hydrator
description: Retrieve K3s kubeconfigs from Ubuntu cluster nodes, merge them on mac-dev, and rewrite localhost or 127.x API server endpoints to the real source host IP or modeled access surface. Use when kubeconfigs copied from remote nodes still point at loopback, when multiple cluster contexts need one merged kubeconfig, or when the user asks to refresh local kubectl access from repo-managed cluster inventory.
---

# Kubeconfig Context Hydrator

Use the repo's existing K3s client automation to pull kubeconfigs from remote
Ubuntu nodes and normalize them for local use on `mac-dev`.

## When to use this skill

Use this skill when:

- kubeconfigs were copied from K3s nodes and still contain `127.0.0.1` or
  `localhost`
- multiple K3s cluster kubeconfigs need to be merged into one local config
- the user wants local `kubectl` access refreshed from repo inventory truth
- a local SSH tunnel or direct host IP needs to replace the node-local API
  endpoint inside a kubeconfig

Do not use this skill when:

- the task is only about generic SSH access
- the cluster inventory or jump-host mapping is being redesigned
- a direct Kubernetes app deploy is requested without kubeconfig/client work

## Authority

| Topic | Source |
|---|---|
| User-facing entrypoint | `playbooks/k3s_mac_client.yaml` |
| Kubeconfig retrieval and rewrite logic | `roles/k3s_mac_client/tasks/present_cluster.yml` |
| Cluster definitions / tunnel mapping | `roles/k3s_mac_client/tasks/main.yml` |
| Mac route setup before kubectl access | `playbooks/k3s_mac_client.yaml` + `hyperv_guest_route_mac` |

## What this skill produces

- refreshed per-cluster kubeconfigs on `mac-dev`
- merged default `~/.kube/config` when the role is configured to manage it
- rewritten API server endpoints that no longer point at loopback on the source
  node
- a verified `kubectl` client path from `mac-dev`

## Instructions

1. Inspect the current cluster contract before making assumptions:
   - `playbooks/k3s_mac_client.yaml`
   - `roles/k3s_mac_client/tasks/main.yml`
   - `roles/k3s_mac_client/tasks/present_cluster.yml`
2. Prefer the repo owner automation over ad hoc kubeconfig edits:
   - run `ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml`
3. Let the role do the normalization:
   - it reads each remote admin kubeconfig from the Ubuntu node
   - it selects the effective API server for that context
   - it replaces the original server entry when the source kubeconfig uses
     node-local loopback
   - it writes the normalized local kubeconfig and merges contexts for bare
     `kubectl`
4. If a context should use direct host IP instead of SSH tunnel, adjust the
   modeled cluster/tunnel variables in inventory or role inputs first. Do not
   hand-edit the generated kubeconfig as the primary fix.
5. Verify after apply:
   - `kubectl config get-contexts`
   - `kubectl get nodes -o wide`
   - confirm the written kubeconfig `clusters[].cluster.server` no longer uses
     `127.0.0.1` or `localhost` unless that loopback tunnel is intentionally the
     modeled access path

## Suggested workflow placement

- `Researcher`: inspect current kubeconfig and cluster/tunnel truth
- `Executor`: run the `k3s_mac_client` playbook and verify merged contexts
- `Steward`: update inventory or client defaults if the modeled access path is
  wrong
