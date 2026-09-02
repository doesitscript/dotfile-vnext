---
title: evaluator simple feedback
created_at: 2026-09-02T112027
author: evaluator-simple
status: partial
decision: not satisfactory
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Evaluator feedback

Work is still **not satisfactory**.

## Open blockers
- Plan Undo contract still does not document the real removal path.
- fzf_tab_completion README still publishes the wrong undo/apply contract.

## Check matrix

| Check | Result | Detail |
| --- | --- | --- |
| `skills-metadata` | pass | project skill metadata validation ok |
| `skills-catalog` | pass | project skills catalog validation ok |
| `plan-update-behavior` | pass | 29:| Update behavior | Re-run `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` | |
| `plan-apply-row` | pass | 36:| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` | |
| `plan-disposition-ledger` | pass | Disposition ledger present |
| `plan-undo-contract` | fail | 38:| **Undo** | Set `fzf_tab_completion_state: absent` and `codex_homelab_profiles_multi_terminal_state: absent` (or `codex_homelab_profiles_state: absent` for full removal); re-run **same Apply command**. **Real removal path:** `fzf_tab_completion` `absent.yml` deletes `~/.bashrc.d/shell-completion.bash`; `codex_homelab_profiles` `multi_terminal_absent.yml` deletes `~/.bashrc.d/codex-multi-terminal.bash` plus owned Codex profile files — not via `common/shell_config`. | |
| `shell-config-static-bash-ownership` | pass | No generic shell_config sweep for role bashrc.d files |
| `fzf-absent-static-bash` | pass | shell-completion.bash removal present |
| `codex-absent-static-bash` | pass | codex-multi-terminal.bash removal present |
| `fzf-readme-contract` | fail | 24:- **Apply:** `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` 26:- **Undo:** set `fzf_tab_completion_state: absent` in host_vars and re-run the same Apply command. `absent.yml` removes `~/.bashrc.d/shell-completion.bash`, python hook, clone, and `rl_custom_complete`. |
| `codex-readme-contract` | pass | README no longer claims simple absent-only undo |
