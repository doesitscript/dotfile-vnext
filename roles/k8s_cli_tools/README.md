# k8s_cli_tools

Installs essential Kubernetes CLI tools on macOS for cluster management, debugging, and GitOps workflows.

## Description

This role installs a comprehensive suite of Kubernetes CLI tools via Homebrew, including:

**Core Management Tools:**
- **K9s** - Interactive TUI for cluster management with single-key shortcuts
- **kubecolor** - Syntax highlighting for kubectl output
- **Stern** - Multi-pod log streaming with regex support
- **kubectx/kubens** - Fast context and namespace switching
- **Helm** - Kubernetes package manager

**Plugin Manager:**
- **Krew** - kubectl plugin manager
  - **kubent** (plugin) - API deprecation checker
  - **kubectl-tree** (plugin) - Resource ownership visualizer

**GitOps Tools:**
- **kubeseal** - Sealed Secrets for secure GitOps
- **Kustomize** - Template-free configuration management

**AI-Powered Tools:**
- **K8sGPT** - AI-powered cluster diagnostics and error analysis

## Requirements

- macOS system (Darwin)
- Homebrew package manager
- kubectl (installed separately, e.g., via k3s_mac_client role)

## Role Variables

### Lifecycle Control

- `k8s_cli_tools_state: present` - Install (present) or remove (absent) all tools
- `k8s_cli_tools_install_bash_completion: true` - Install managed bash completion files for K9s and Stern

### Version Contracts

All versions pinned via `k8s_tooling_version_contract` in `inventory/group_vars/all.yaml`:
- `k8s_cli_tools_k9s_version`
- `k8s_cli_tools_kubecolor_version`
- `k8s_cli_tools_stern_version`
- `k8s_cli_tools_kubectx_version`
- `k8s_cli_tools_helm_version`
- `k8s_cli_tools_krew_version`
- `k8s_cli_tools_kubeseal_version`
- `k8s_cli_tools_kustomize_version`
- `k8s_cli_tools_k8sgpt_version`

### Krew Plugins

```yaml
k8s_cli_tools_krew_plugins:
  - name: kubent
    enabled: true
  - name: tree
    enabled: true
```

## Dependencies

For shell completion on Bash, this role expects the shared `common/bash_completion`
role to be present in the playbook path. It otherwise remains independent and
complements:
- `k3s_mac_client` - Provides kubectl and kubeconfig
- `docker_client` - Container runtime tools

## Tags

- `k8s_cli_tools` - All tasks
- `k8s`, `kubernetes` - All K8s-related tasks
- Individual tool tags: `k9s`, `kubecolor`, `stern`, `kubectx`, `kubens`, `helm`, `krew`, `krew_plugins`, `kubeseal`, `kustomize`, `k8sgpt`

## Example Playbook

```yaml
- name: Install K8s CLI tools on macOS
  hosts: mac_development
  roles:
    - role: k8s_cli_tools
      k8s_cli_tools_state: present
```

## Idempotency

- All tasks are idempotent
- Supports `present` and `absent` states
- Krew plugin installation detects existing plugins
- K9s and Stern bash completion files converge into Homebrew's `etc/bash_completion.d`
- Safe to re-run without changes

## Shell Completion

When `k8s_cli_tools_install_bash_completion: true`, the role generates:

```text
$(brew --prefix)/etc/bash_completion.d/k9s
$(brew --prefix)/etc/bash_completion.d/stern
```

The shared `common/bash_completion` role loads Homebrew's
`bash-completion` profile script from `~/.bashrc.d/bash_completion.bash`, so
new Bash sessions pick up the K9s and Stern completions automatically after:

```bash
source ~/.bashrc
```

## Apply / Verify / Undo / Change Class

**Apply:**
```bash
ansible-playbook playbooks/deploy_k8s_cli_tools.yaml
```

**Verify:**
```bash
# Check installed tools
k9s version
kubecolor version
stern --version
kubectx --version
helm version
kubectl krew version
kubectl krew list
kubeseal --version
kustomize version
k8sgpt version
test -f "$(brew --prefix)/etc/bash_completion.d/k9s"
test -f "$(brew --prefix)/etc/bash_completion.d/stern"
```

**Undo:**
```bash
ansible-playbook playbooks/deploy_k8s_cli_tools.yaml -e k8s_cli_tools_state=absent
```

**Change Class:** Idempotent configuration management

## Notes

- Krew plugins require Krew to be installed first (handled automatically)
- Plugins are installed via `kubectl krew install`
- KREW_ROOT defaults to `~/.krew`
- All tools support `state: absent` for clean removal

## License

MIT

## Author

Generated for homelab K8s development environment
