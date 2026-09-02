# Execution receipt — codex multi-terminal promotion

Historical apply and verification evidence. Contract lives in `README.md`.

## Implemented in repo (2026-09-02)

- Governance README rewritten at `docs/one_off_tasks/README.md`.
- Plan packet created with archival backup; live one-off tree deleted.
- New role `fzf_tab_completion`; extended `codex_homelab_profiles` for multi-terminal.
- Playbook + `mac-dev` inventory wired.
- Legacy uninstall script run on operator Mac (removed `*_one_off_tasks` host files).

## Live converge

| Run | Command | Result |
| --- | --- | --- |
| Initial apply | `deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` | **ok** — 69 ok, 12 changed |
| Idempotent re-run | same tags | **ok** — 69 ok, 3 changed |
| Dedicated profile playbook | `deploy_codex_homelab_profiles.yaml --limit mac-dev` | **ok** — 15 ok, 1 changed |
| Fix redeploy | after removing stray `---` from `shell-completion.bash` | **ok** — 56 ok, 2 changed |

## Post-apply verification (mac-dev)

| Check | Result |
| --- | --- |
| `bash -lc 'type cx-deep cx-desktop cx-skills cx-hvh01 cx-research'` | pass — all functions defined |
| `type codex-homelab rl_custom_complete` | pass — binaries in `~/bin` |
| Artifact files (`shell-completion.bash`, `codex-multi-terminal.bash`, `local-deep.config.toml`, fzf clone) | pass — all present |
| `bash -lc 'source ~/.bashrc.d/shell-completion.bash'` | pass after YAML frontmatter fix |
| `cx-hvh01-smoke` | pass — `qwen2.5-coder-1.5b@hvh01` replied `pong` |
| `cx-deep-smoke` | pass — `qwen2.5-coder-32b@k3s02-vllm` replied `pong` |
| Legacy one-off cleanup | pass — `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh` |
| Interactive Tab (`cx-de<Tab>`, Python REPL Tab) | pending — requires TTY |

## Absent converge / Undo verification (2026-09-02)

Absent converge on `mac-dev` via extra-vars (host_vars left at `present`):

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags fzf_tab_completion,codex_homelab_profiles --limit mac-dev \
  -e fzf_tab_completion_state=absent \
  -e codex_homelab_profiles_multi_terminal_state=absent
```

| Check | Result |
| --- | --- |
| Play recap | **ok** — 54 ok, 10 changed, 0 failed |
| `test ! -f ~/.bashrc.d/shell-completion.bash` | pass |
| `test ! -f ~/.bashrc.d/codex-multi-terminal.bash` | pass |
| `test ! -d ~/.local/share/fzf-tab-completion` | pass |

Restored present from inventory:

```bash
ansible-playbook playbooks/deploy_development_nodes.yaml \
  --tags fzf_tab_completion,codex_homelab_profiles --limit mac-dev
```

| Check | Result |
| --- | --- |
| Play recap | **ok** — 59 ok, 7 changed, 0 failed |
| `test -f ~/.bashrc.d/shell-completion.bash` | pass |
| `test -f ~/.bashrc.d/codex-multi-terminal.bash` | pass |
| `type cx-deep-smoke` | pass — function defined after restore |

## Bug fixes recorded

- `shell-completion.bash` YAML frontmatter leak (removed).
- Undo semantics: bashrc drops moved to role-owned deploy/remove (not `shell_config` sweep only).
