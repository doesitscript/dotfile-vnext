---
title: evaluator simple feedback
created_at: 2026-09-02T1118
author: evaluator-simple
status: partial
decision: not satisfactory
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Evaluator feedback

Work is still **not satisfactory**.

## Open blockers
- Plan Update behavior row is not self-contained.
- Plan Undo contract still does not document the real removal path.
- common/shell_config still sweeps roles/*/files/bashrc.d/*.bash, so static bashrc ownership is not truly role-local yet.
- fzf_tab_completion absent tasks do not remove shell-completion.bash.
- codex_homelab_profiles does not remove codex-multi-terminal.bash on absent.
- fzf_tab_completion README still publishes the wrong undo/apply contract.

## Check matrix

| Check | Result | Detail |
| --- | --- | --- |
| `skills-metadata` | pass | project skill metadata validation ok |
| `skills-catalog` | pass | project skills catalog validation ok |
| `plan-update-behavior` | fail | 29:| Update behavior | see Apply row below | |
| `plan-apply-row` | pass | 36:| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` | |
| `plan-disposition-ledger` | pass | Disposition ledger present |
| `plan-undo-contract` | fail | 38:| **Undo** | Set `fzf_tab_completion_state: absent` and `codex_homelab_profiles_multi_terminal_state: absent` (or `codex_homelab_profiles_state: absent` for full removal); re-run **same Apply command**. Roles remove owned bashrc drops and multi-terminal artifacts explicitly (not via unconditional `shell_config` sweep). | |
| `shell-config-static-bash-ownership` | fail | Generic bashrc.d contribution sweep still present in roles/common/shell_config/tasks/unix.yml |
| `fzf-absent-static-bash` | fail | No shell-completion.bash removal in tasks/absent.yml |
| `codex-absent-static-bash` | fail | No explicit absent removal for codex-multi-terminal.bash in multi_terminal_absent.yml |
| `fzf-readme-contract` | fail | 22:- **Apply:** `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion --limit mac-dev` |
| `codex-readme-contract` | pass | README no longer claims simple absent-only undo |
