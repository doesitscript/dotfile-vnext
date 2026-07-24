# Mac kubectl access to homelab K3s — patterns

**Date:** 2026-07-23  
**Context:** Mac client for `hom-lab-ctl-k3s-01` / `hom-lab-ctl-k3s-02` (k9s, stern, gonzo, kubectl).  
**Chosen steady state:** direct guest API + separate kubeconfigs + bash `KUBECONFIG` export.

## Problem

K3s admin kubeconfigs on the node use `https://127.0.0.1:6443`. That is correct
on the node and wrong on the Mac. Something must rewrite `server:` and keep
credentials usable. Background `ssh -L` tunnels die after sleep / network
changes, which looks like “kubectl randomly broken.”

## Pattern inventory (all options researched)

### 1. Always-on tunnel (LaunchAgent / persistent `ssh -L`)

Keep local forwards up continuously.

- **Pros:** Simple kubeconfig (`127.0.0.1:<port>`).
- **Cons:** Sleep/Wi-Fi still break tunnels; you own process supervision.
- **Fit here:** Optional if direct routes never work; not the preferred default.

### 2. On-demand hydrate + temporary tunnel (`connection_mode: ssh_tunnel`)

Playbook starts `ssh -f -N -L`, writes kubeconfigs, verifies. Re-run after sleep.

- **Pros:** No permanent daemon; matches jump-host reality.
- **Cons:** Failure mode is “dead tunnel”; must rehydrate.
- **Skill:** `hydrate-k3s-mac-kubeconfig-ssh-tunnel`
- **Fit here:** Fallback when Mac cannot open TCP to guest `:6443`.

### 3. Direct API + Mac routes (`connection_mode: direct`) — preferred

Mac reaches `https://<guest ansible_host>:6443` after `hyperv_guest_route_mac`.
Hydrate kubeconfig only; no background SSH.

- **Pros:** Closer to cloud “update kubeconfig, talk to API”; failure mode is routing/TLS, not silent tunnel death.
- **Cons:** Requires working guest routes and API TLS SANs that match the IP/name used.
- **Skill:** `hydrate-k3s-mac-kubeconfig-direct-api`
- **Fit here:** Current `mac-dev` inventory choice.

### 4. kubectl exec auth / credential plugin (EKS-like)

Kubeconfig `users[].exec` plugin refreshes short-lived credentials (certs/OIDC tokens).

- **Pros:** Credential rotation story; good once the API is a stable, reachable endpoint.
- **Cons:** Does **not** remove reachability/jump/tunnel problems for a private K3s API. Helps after you put a reachable API (and usually short-lived auth) in front.
- **Fit here:** Defer until there is a public/stable API front (ingress/LB + short-lived auth). Not a substitute for routes or tunnels today. OIDC is optional later; the useful idea is “reachable API + short-lived creds,” not OIDC itself.

### 5. Separate configs, never fight `~/.kube/config`

Write `~/.kube/hom-lab-ctl-k3s-01.yaml` and `…-k3s-02.yaml`. Export:

```bash
export KUBECONFIG="$HOME/.kube/hom-lab-ctl-k3s-01.yaml:$HOME/.kube/hom-lab-ctl-k3s-02.yaml"
```

Swap with `kubectl config use-context …` or `kubectx`.

- **Pros:** Docker Desktop / other tools won’t clobber a managed merge of `~/.kube/config`.
- **Cons:** Bare shells without the export won’t see contexts until profile is sourced.
- **Fit here:** Required for both skills; role template `~/.bashrc.d/k3s-kubeconfig.bash`.

### 6. Always kubectl on the node / Ansible-only

Never install a Mac client; run `kubectl` over SSH or via Ansible/`kubectl` modules on the node.

- **Pros:** No Mac kubeconfig drift.
- **Cons:** Poor interactive UX for k9s/stern/gonzo on the Mac.
- **Fit here:** Fine for automation; not the interactive-tooling path.

### 7. Port-proxy / published API on Hyper-V host

Expose `:6443` via host portproxy / published endpoint and point kubeconfig there.

- **Pros:** Mac talks to a LAN address without guest routes.
- **Cons:** Extra exposure surface; must stay modeled in inventory.
- **Fit here:** Alternative if guest routes stay unreliable; document before adopting.

## Current repo contract

| Knob | `mac-dev` value |
| --- | --- |
| `connection_mode` | `direct` for both k3s-01 and k3s-02 |
| `k3s_mac_client_manage_default_kubeconfig` | `false` |
| `k3s_mac_client_shell_kubeconfig_export` | `true` |
| Default context | `hom-lab-ctl-k3s-02` (AI/LiteLLM lane) |
| Entrypoint | `playbooks/k3s_mac_client.yaml` |

### Live evidence

**2026-07-23 (before fix):** Mac could open `192.168.137.11:6443` but timed out on `192.168.138.11`. HVH-01 still had `HyperVGuestNat` because inventory had `guest_outbound_nat_enabled: true`.

**2026-07-23 (after fix):** Set HVH-01 `guest_outbound_nat_enabled: false`, ran `configure_hyperv_windows_hosts.yaml --limit HOM-LAB-HVH-01`. Playbook removed `HyperVGuestNat`. Mac `nc` to `192.168.138.11:22` and `:6443` open; both clusters on `connection_mode: direct`.

Flip a cluster back to `ssh_tunnel` only if Mac `nc -vz <guest-ip> 6443` fails again.

## Operator notes

- New shells need `.bashrc.d` sourcing (via `common/shell_config`).
- With **direct**, if kubectl fails, check HVH `HyperVGuestNat` / routes / TLS — not “is ssh still listening.”
- `guest_outbound_nat_enabled: false` is the steady-state for routed lanes (role ensures NetNat absent).

## Related

- `docs/diagnostics/k3s-mac-kubeconfig--macos--diagnostics.md`
- `roles/k3s_mac_client/README.md`
- Skills under `skills/validation/hydrate-k3s-mac-kubeconfig-*`
