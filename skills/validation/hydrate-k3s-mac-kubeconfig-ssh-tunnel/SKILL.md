---
name: hydrate-k3s-mac-kubeconfig-ssh-tunnel
description: "Use when mac-dev kubectl/k9s/stern/gonzo access to homelab K3s should use SSH local-forward tunnels (ssh -L) to the API, with separate per-cluster kubeconfig files and a bash KUBECONFIG export. Use when guest :6443 is not directly reachable from the Mac. Do not use when connection_mode direct already works."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "hydrate-k3s-mac-kubeconfig-direct-api, single-host-ansible-rollout"
requires_summary: "playbooks/k3s_mac_client.yaml; roles/k3s_mac_client; bin/codex-env"
title: Hydrate K3s Mac Kubeconfig SSH Tunnel
technology: k3s
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - k3s
  - mac-dev
  - kubectl
related:
  - playbooks/k3s_mac_client.yaml
  - roles/k3s_mac_client/
  - docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md
tags:
  - skill
  - k3s
  - kubeconfig
  - ssh-tunnel
  - mac
---

# Skill: Hydrate K3s Mac Kubeconfig SSH Tunnel

On-demand Mac kubectl access via **SSH local forward** (`ssh -f -N -L`). Same
separate-file + `KUBECONFIG` pattern as the direct-api skill. Tunnels are
started by the playbook; they are not a permanent LaunchAgent.

## When to use / not use

Use when the Mac cannot open TCP to guest `:6443` but can SSH to the Hyper-V
jump host.

Do not use when direct guest API works — prefer
`hydrate-k3s-mac-kubeconfig-direct-api`.

## Inputs

- Clusters with `connection_mode: ssh_tunnel` and distinct `tunnel_local_port`
- Prefer `k3s_mac_client_manage_default_kubeconfig: false` + shell export

## Workflow

1. Set inventory clusters to `ssh_tunnel` with unique local ports (e.g. 16443 / 26443).
2. Apply `playbooks/k3s_mac_client.yaml --tags k3s_mac_client --limit mac-dev`.
3. Role probes/repairs `ssh -L` then writes kubeconfigs with `https://127.0.0.1:<port>`.
4. New shell / source `~/.bashrc.d/k3s-kubeconfig.bash`.
5. Verify contexts and `kubectl get nodes` per cluster.
6. After sleep/Wi-Fi, re-run this hydrate — tunnels die; that is expected.

## Handoffs

- `hydrate-k3s-mac-kubeconfig-direct-api` when routes make tunnels unnecessary
- `single-host-ansible-rollout` for apply evidence discipline

## Outputs

- Per-cluster `~/.kube/<context>.yaml` pointing at loopback tunnel ports
- Background `ssh -L` listeners while the session lasts
- Optional `KUBECONFIG` export for tooling

## Validation

- `lsof` / `wait_for` shows local ports listening after apply
- `kubectl get nodes` works; after lid-close failure, rehydrate restores access

## Failure boundaries

- Stop guessing when jump host SSH fails — capture SSH errors first
- Do not leave `manage_default_kubeconfig: true` if Docker Desktop fights `~/.kube/config`

## Prohibited behavior

- Treating tunnels as always-on without documenting relaunch
- Raw `scp` of node `k3s.yaml` without this role’s rewrite

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking evidence.
- Load `references/related-artifacts.md` for ports and commands.
- Patterns research: `docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md`
