# stern_cli

Installs Stern on macOS through the Homebrew `stern` formula and renders a
managed usage note on `mac-dev` so operators and AI agents have a durable,
repo-owned Stern reference on the machine.

Upstream source: <https://github.com/stern/stern>

Supplemental operating context source:
- Context7 Kubernetes docs result surfacing Stern usage examples from the
  Kubernetes blog on July 23, 2026

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags stern_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `stern_cli_state` | `present` | `present` or `absent` |
| `stern_cli_homebrew_formula` | `stern` | Homebrew formula to manage |
| `stern_cli_verify` | `true` | Verify requested formula state after convergence |
| `stern_cli_install_bash_completion` | `true` | Install the managed Stern bash completion file |
| `stern_cli_bash_completion_path` | `$(brew --prefix)/etc/bash_completion.d/stern` | Managed Stern bash completion path |
| `stern_cli_install_usage_note` | `true` | Install the managed Stern AI/operator usage note |
| `stern_cli_usage_note_path` | `~/.config/dotfile-vnext/ai/tool-guides/stern.md` | Managed Stern usage note path |

## Installed Guidance

When `stern_cli_install_usage_note: true`, the role writes a managed Stern
usage note to:

```text
~/.config/dotfile-vnext/ai/tool-guides/stern.md
```

That note includes:

- query model and resource-vs-regex selection
- high-value flags such as `--namespace`, `--selector`, `--since`,
  `--timestamps`, `--output`, and `--template`
- homelab-tailored context examples for `mac-dev`
- troubleshooting guidance
- repo-managed shell completion guidance

## Shell Completion

When `stern_cli_install_bash_completion: true`, the role generates:

```text
$(brew --prefix)/etc/bash_completion.d/stern
```

The shared `common/bash_completion` role loads Homebrew's
`bash-completion` profile script from `~/.bashrc.d/bash_completion.bash`, so
new Bash sessions pick up the Stern completion automatically after:

```bash
source ~/.bashrc
```

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags stern_cli --limit mac-dev`
- **Verify:** `brew list --formula stern`, `stern --version`, `test -f "$(brew --prefix)/etc/bash_completion.d/stern"`, and `test -f ~/.config/dotfile-vnext/ai/tool-guides/stern.md`
- **Undo:** same playbook with `-e stern_cli_state=absent`
- **Change class:** idempotent controller-local package install
