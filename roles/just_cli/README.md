# just_cli

Installs [`just`](https://github.com/casey/just) on macOS through the Homebrew
`just` formula and generates managed shell completion files from the installed
binary.

By default, this role installs Bash completion into Homebrew's
`etc/bash_completion.d` directory so the shared `common/bash_completion` loader
activates it in new Bash sessions on `mac-dev`.

Optional Zsh completion is also supported through `just --completions zsh`.

## Usage

```bash
bin/codex-env ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml \
  --tags just_cli --limit mac-dev
```

## Variables

| Variable | Default | Description |
|---|---|---|
| `just_cli_state` | `present` | `present` or `absent` |
| `just_cli_homebrew_formula` | `just` | Homebrew formula to manage |
| `just_cli_verify` | `true` | Verify requested formula state after convergence |
| `just_cli_install_completions` | `true` | Generate managed completion files from `just --completions <shell>` |
| `just_cli_completion_shells` | `['bash']` | Completion shells to manage; supported values are `bash` and `zsh` |
| `just_cli_bash_completion_path` | `$(brew --prefix)/etc/bash_completion.d/just` | Managed Bash completion path |
| `just_cli_zsh_completion_path` | `$(brew --prefix)/share/zsh/site-functions/_just` | Managed Zsh completion path |

## Shell Completion

When `just_cli_install_completions: true`, the role generates completion files
from the managed `just` binary instead of checking in static scripts:

- `bash` -> `$(brew --prefix)/etc/bash_completion.d/just`
- `zsh` -> `$(brew --prefix)/share/zsh/site-functions/_just`

The shared `common/bash_completion` role loads the Bash completion path in new
Bash sessions. Zsh completion can be enabled by adding `zsh` to
`just_cli_completion_shells` on hosts that already load Homebrew's
`share/zsh/site-functions` through their shell startup.

## Apply / Verify / Undo / Change class

- **Apply:** `deploy_development_nodes.yaml --tags just_cli --limit mac-dev`
- **Verify:** `brew list --formula just`, `just --version`, and `test -f "$(brew --prefix)/etc/bash_completion.d/just"`
- **Undo:** same playbook with `-e just_cli_state=absent`
- **Change class:** idempotent controller-local package install
