# common/bash_completion

Installs the appropriate Homebrew Bash completion runtime on macOS and deploys a
small loader into
`~/.bashrc.d` so repo-managed CLI completion files under Homebrew's
`etc/bash_completion.d` directory load in new Bash sessions.

This role is the shared completion substrate for controller-local tools such as
Gonzo, Dstl8, Stern, and K9s. The role owns the shell loader and the
`bash-completion` package; each tool role still owns generation of its own
completion script.

## Usage

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags bash_completion --limit mac-dev

ansible-playbook playbooks/deploy_k8s_cli_tools.yaml -i inventory/inventory.yaml \
  --tags bash_completion --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `common_bash_completion_state` | `present` | `present` or `absent` |
| `common_bash_completion_formula` | `auto` | Homebrew formula override, or `auto` to select by Bash major version |
| `common_bash_completion_formula_legacy` | `bash-completion` | Formula used for Bash 3.x compatibility |
| `common_bash_completion_formula_modern` | `bash-completion@2` | Formula used for Bash 4.2+ |
| `common_bash_completion_loader_path` | `~/.bashrc.d/bash_completion.bash` | Managed shell loader path |
| `common_bash_completion_managed_files` | `['gonzo', 'dstl8', 'kubectl', 'kubectx', 'kubens', 'k9s', 'stern', 'helm', 'kustomize', 'k8sgpt']` | Completion files sourced eagerly by the loader |
| `common_bash_completion_verify` | `true` | Verify requested formula and loader state after convergence |

## Managed Surfaces

When present, the role:

- detects the active login-shell Bash binary from `$SHELL` when it is Bash,
  instead of assuming the first `bash` on `PATH`
- installs `bash-completion@2` for Bash 4.2+ and falls back to the legacy
  `bash-completion` formula only for Bash 3.x compatibility cases
- removes the conflicting Homebrew completion formula so the runtime is unambiguous
- resolves the active Homebrew prefix dynamically
- ensures `$(brew --prefix)/etc/bash_completion.d` exists
- renders a loader into `~/.bashrc.d/bash_completion.bash` that sources
  `$(brew --prefix)/etc/profile.d/bash_completion.sh`
- eagerly sources the repo-managed completion files listed in
  `common_bash_completion_managed_files`
- verifies `_get_comp_words_by_ref` is available after sourcing the managed loader

Tool-specific completion files are written separately by the owning tool roles.

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags bash_completion --limit mac-dev` or `deploy_k8s_cli_tools.yaml --tags bash_completion --limit mac-dev`
- **Verify:** `brew list --formula bash-completion@2` on modern Bash hosts, `test -f ~/.bashrc.d/bash_completion.bash`, `test -f "$(brew --prefix)/etc/profile.d/bash_completion.sh"`, and `bash -lc 'source ~/.bashrc.d/bash_completion.bash; declare -F _get_comp_words_by_ref >/dev/null'`
- **Undo:** same playbook with `-e common_bash_completion_state=absent`
- **Change class:** idempotent controller-local package and shell-loader management
