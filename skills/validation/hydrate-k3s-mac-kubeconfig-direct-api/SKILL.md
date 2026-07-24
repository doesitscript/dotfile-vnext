---
name: hydrate-k3s-mac-kubeconfig-direct-api
description: "Use when mac-dev kubectl/k9s/stern/gonzo access to homelab K3s should use direct guest API URLs (no ssh -L tunnel), with separate per-cluster kubeconfig files and a bash KUBECONFIG export. Use for connection_mode direct, hyperv_guest_route_mac, swap contexts between k3s-01 and k3s-02. Do not use when SSH local-forward tunnels are required."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "hydrate-k3s-mac-kubeconfig-ssh-tunnel, single-host-ansible-rollout"
requires_summary: "playbooks/k3s_mac_client.yaml; hyperv_guest_route_mac; inventory/host_vars/mac-dev.yaml; bin/codex-env"
title: Hydrate K3s Mac Kubeconfig Direct API
technology: k3s
document_type: skill
status: reviewed
authority: internal
source_type: internal
last_reviewed_at: "2026-07-23"
applies_to:
  - k3s
  - mac-dev
  - kubectl
related:
  - playbooks/k3s_mac_client.yaml
  - roles/k3s_mac_client/
  - inventory/host_vars/mac-dev.yaml
  - docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md
tags:
  - skill
  - k3s
  - kubeconfig
  - direct
  - mac
---

# Skill: Hydrate K3s Mac Kubeconfig Direct API

On-demand Mac kubectl access via **direct** `https://<guest-ip>:6443` (no
background `ssh -L`). Separate kubeconfig files + `KUBECONFIG` export for
context swapping.

## When to use / not use

Use when Mac routes to guest subnets work (`hyperv_guest_route_mac`) and you
want EKS-like “hydrate when needed” without tunnel death after sleep.

Do not use when the Mac cannot reach guest `:6443` — use
`hydrate-k3s-mac-kubeconfig-ssh-tunnel` instead.

## Inputs

- `inventory/host_vars/mac-dev.yaml` with `connection_mode: direct`
- `k3s_mac_client_manage_default_kubeconfig: false`
- `k3s_mac_client_shell_kubeconfig_export: true`

## Workflow

1. Confirm Mac guest routes (playbook includes `hyperv_guest_route_mac`).
2. Confirm inventory clusters use `connection_mode: direct`.
3. Apply:

```bash
bin/codex-env ansible-playbook playbooks/k3s_mac_client.yaml \
  -i inventory/inventory.yaml --tags k3s_mac_client --limit mac-dev
```

4. Open a **new** shell (or `source ~/.bashrc.d/k3s-kubeconfig.bash`).
5. Verify:

```bash
echo "$KUBECONFIG"
kubectl config get-contexts
kubectl config use-context hom-lab-ctl-k3s-01
kubectl get nodes -o wide
kubectl config use-context hom-lab-ctl-k3s-02
kubectl get nodes -o wide
```

6. Point k9s/stern/gonzo at the same `KUBECONFIG` (they inherit the env).

## Handoffs

- `hydrate-k3s-mac-kubeconfig-ssh-tunnel` if direct TCP to `:6443` fails
- `single-host-ansible-rollout` for preview/apply evidence discipline

## Outputs

- `~/.kube/hom-lab-ctl-k3s-01.yaml`, `~/.kube/hom-lab-ctl-k3s-02.yaml`
- `~/.bashrc.d/k3s-kubeconfig.bash` exporting colon-separated `KUBECONFIG`
- No requirement to own `~/.kube/config`

## Validation

- Each cluster file has `server: https://192.168.13x.11:6443` (not `127.0.0.1`)
- `kubectl get nodes` works per context after route apply
- TLS errors → check K3s TLS SAN / docs diagnostics note

## Failure boundaries

- Stop and switch to ssh-tunnel skill when routes or TLS SAN block direct API
- Do not enable `insecure-skip-tls-verify` without an explicit operator decision

## Prohibited behavior

- Hand-editing kubeconfigs as the primary fix
- Merging into `~/.kube/config` when inventory asks for separate files
- Claiming tunnels are required for this path

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` for evidence ranking.
- Load `references/related-artifacts.md` for inventory knobs and commands.
- Patterns research: `docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md`
