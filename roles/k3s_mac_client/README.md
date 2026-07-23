# k3s_mac_client

Configures `mac-dev` as a `kubectl` client for one or more homelab K3s clusters
(k9s, stern, gonzo, bare kubectl).

Apply:

```bash
bin/codex-env ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml --tags k3s_mac_client
```

What it does:

- installs the official macOS `kubectl` binary under `~/.local/bin`
- generates Bash completion for `kubectl` into Homebrew's
  `etc/bash_completion.d/kubectl`
- copies each cluster’s admin kubeconfig from `/etc/rancher/k3s/k3s.yaml`
- rewrites `server:` for Mac use:
  - `connection_mode: ssh_tunnel` → `https://127.0.0.1:<local-port>` + starts `ssh -L`
  - `connection_mode: direct` → `https://<guest ansible_host>:6443` (needs Mac guest routes)
- writes **per-cluster** files under `~/.kube/<context>.yaml`
- optionally merges into `~/.kube/config` (`k3s_mac_client_manage_default_kubeconfig`)
- optionally exports `KUBECONFIG` via `~/.bashrc.d/k3s-kubeconfig.bash`
  (`k3s_mac_client_shell_kubeconfig_export`) — preferred when not managing the default merge
- validates `kubectl get nodes` per managed cluster

Completion note:

- `kubectl` completion depends on the shared `common/bash_completion` runtime
  on macOS
- this role now generates the `kubectl` completion file from the managed binary
  instead of assuming a Homebrew-installed `kubectl`

`mac-dev` inventory currently prefers **direct** + **separate configs** (no default merge).

Undo:

```bash
bin/codex-env ansible-playbook playbooks/k3s_mac_client.yaml -i inventory/inventory.yaml --tags k3s_mac_client \
  -e k3s_mac_client_state=absent
```

Change class: idempotent macOS client configuration.

Skills:

- `hydrate-k3s-mac-kubeconfig-direct-api`
- `hydrate-k3s-mac-kubeconfig-ssh-tunnel` (also bridged as `kubeconfig-context-hydrator`)

See `docs/lessons-learned/mac/k3s-mac-kubectl-access-patterns.md` and
`docs/diagnostics/k3s-mac-kubeconfig--macos--diagnostics.md`.
