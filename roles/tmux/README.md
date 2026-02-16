# tmux

Installs and configures tmux.

## What it does

1. Detects existing tmux installation (does **not** install — installation is managed manually or via package manager outside this role).
2. Templates `~/.tmux.conf` from `templates/tmux.conf.j2`.
3. Deploys shell aliases into `~/.bashrc.d/tmux.bash` (sourced by `common/shell_config`).

## Variables

| Variable | Default | Description |
|---|---|---|
| `tmux_default_shell` | `{{ ansible_env.SHELL \| default('/bin/bash') }}` | Default shell for new tmux windows |
| `tmux_history_limit` | `10000` | Scrollback buffer size |
| `tmux_mouse` | `on` | Enable mouse support |
| `tmux_prefix` | `C-a` | Prefix key (overrides default `C-b`) |
| `tmux_base_index` | `1` | Start window numbering at 1 |

Override any variable in `group_vars` or `host_vars` as needed.
