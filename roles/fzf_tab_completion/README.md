# fzf_tab_completion

Install [lincheney/fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion) on macOS
controller hosts (`mac-dev`).

## Interface

| Variable | Default | Description |
| --- | --- | --- |
| `fzf_tab_completion_state` | `absent` | `present` or `absent` |

## Delivers

- Homebrew: `fzf`, `gawk`, `grep`, `gnu-sed`, `coreutils`
- Git clone: `~/.local/share/fzf-tab-completion`
- `~/.bashrc.d/shell-completion.bash` — deployed by **this role** (`present.yml`), removed by `absent.yml`
- `~/.bashrc.d/python-fzf-tab-completion.bash` + `usercustomize.py` on PYTHONPATH
- `~/bin/rl_custom_complete` symlink

Python REPL fzf completion is registered on `sys.__interactivehook__` only (TTY
interactive sessions). It must not run at `usercustomize` import time — that
path hits `_pyrepl`/`termios` and prints `Error in usercustomize` on every
non-interactive `python3` invocation.

## Apply / Verify / Undo

Requires `common/shell_config` (`.bashrc.d` directory + sourcing) before this role's bashrc drop.

- **Apply:** `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev`
- **Verify:** `command -v fzf rl_custom_complete`; Tab in bash and `python3` REPL
- **Undo:** set `fzf_tab_completion_state: absent` in host_vars and re-run the same Apply command. `absent.yml` removes `~/.bashrc.d/shell-completion.bash`, python hook, clone, and `rl_custom_complete`.
