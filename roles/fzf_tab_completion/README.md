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
- `roles/fzf_tab_completion/files/bashrc.d/shell-completion.bash` via `common/shell_config`
- `~/.bashrc.d/python-fzf-tab-completion.bash` + `usercustomize.py` on PYTHONPATH
- `~/bin/rl_custom_complete` symlink

## Apply / Verify / Undo

- **Apply:** `ansible-playbook playbooks/deploy_development_nodes.yaml --tags fzf_tab_completion --limit mac-dev`
- **Verify:** `command -v fzf rl_custom_complete`; Tab in bash and `python3` REPL
- **Undo:** `fzf_tab_completion_state: absent` and re-run playbook
