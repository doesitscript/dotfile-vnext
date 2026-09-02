---
title: Codex multi-terminal promotion
lifecycle: implemented
scope: implementation
depends_on_plans:
  - 2026-09-01--homelab-local-ai-clients-codex
netbox_scope: false
---

# Codex multi-terminal promotion

Promote the discarded one-off trial (`codex-multi-terminal-workflow`) into managed Ansible
capabilities. The live one-off folder is **removed**; the only copy is frozen under
`backup/one-off-source/` (archival — agents must not implement from it).

## Summary

Distributed Codex terminals on `mac-dev`: `cx-deep`, `cx-desktop`, `cx-skills`, `cx-hvh01`,
`cx-research`, plus fzf-tab-completion for bash and Python REPL.

## Capability Packet Boundary

| Field | Value |
| --- | --- |
| Capability identifier | `codex-multi-terminal` |
| Owner manifest | `roles/codex_homelab_profiles/`, `roles/fzf_tab_completion/` |
| Owned files | `cx-*` bashrc.d, `~/.codex/local-*.config.toml`, `codex-homelab` launcher, fzf clone + bashrc.d |
| Integration anchors | `common/shell_config`, `common/bash_completion`, `docs/plans/2026-09-01--homelab-local-ai-clients-codex/` |
| Update behavior | Re-run `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` |
| Uninstall / legacy | `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh`; role `absent` states with explicit file removal |

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags shell_config,bash_completion,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` |
| **Verify** | `cx-de<Tab>` in bash; `python3` REPL Tab; `cx-deep-smoke`; `type cx-deep` — evidence in [EXECUTION-RECEIPT.md](EXECUTION-RECEIPT.md) |
| **Undo** | Set `fzf_tab_completion_state: absent` and `codex_homelab_profiles_multi_terminal_state: absent` (or `codex_homelab_profiles_state: absent` for full removal); re-run **same Apply command**. Documents the real removal path: `fzf_tab_completion` `absent.yml` deletes `~/.bashrc.d/shell-completion.bash`; `codex_homelab_profiles` `multi_terminal_absent.yml` deletes `~/.bashrc.d/codex-multi-terminal.bash` plus owned Codex profile files — not via `common/shell_config`. |
| **Change class** | Idempotent Ansible config |

`common/shell_config` only creates `~/.bashrc.d/`, sources it from `.bashrc`, and deploys `path.bash` / `aliases.bash`. Capability bashrc drops are **role-owned** (`present.yml` / `absent.yml`).

## Checklist

| Item | Status | Evidence |
| --- | --- | --- |
| Governance for `docs/one_off_tasks/` | done | `docs/one_off_tasks/README.md`, `docs/plans/README.md` |
| Archive one-off source | done | `backup/one-off-source/` + `backup/README.md` |
| Remove live one-off folder | done | `docs/one_off_tasks/codex-multi-terminal-workflow/` deleted |
| `fzf_tab_completion` role | done | `roles/fzf_tab_completion/` |
| Extend `codex_homelab_profiles` multi-terminal | done | `tasks/multi_terminal.yml`, `tasks/multi_terminal_absent.yml` |
| `mac-dev` host_vars | done | `fzf_tab_completion_state: present`, `codex_homelab_profiles_multi_terminal_state: present` |
| Legacy host cleanup script | done | `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh` |
| Live Ansible apply on mac-dev | done | [EXECUTION-RECEIPT.md](EXECUTION-RECEIPT.md) |
| Truthful undo for bashrc drops | done | absent converge 2026-09-02: extra-vars absent removed `shell-completion.bash` + `codex-multi-terminal.bash`; present re-apply restored |

## Disposition ledger (archived one-off → managed)

| Archived one-off artifact | Status | Live replacement / note |
| --- | --- | --- |
| `deploy/bashrc.d/codex-multi-terminal_one_off_tasks.bash` | Promoted with reshape | `roles/codex_homelab_profiles/files/codex-multi-terminal.bash` → role deploy |
| `deploy/bashrc.d/shell-completion_one_off_tasks.bash` | Promoted with reshape | `roles/fzf_tab_completion/files/shell-completion.bash` → role deploy |
| `deploy/bashrc.d/python-fzf-tab-completion_one_off_tasks.bash` | Promoted | `templates/python-fzf-tab-completion.bash.j2` |
| `deploy/python/usercustomize_one_off_tasks.py` | Promoted | `files/usercustomize.py` |
| `deploy/python/usercustomize_one_off_tasks.py.example` | Retired, no replacement | archival example only |
| `deploy/bin/codex-homelab_one_off_tasks.sh` | Promoted with reshape | `templates/codex-homelab.sh.j2` |
| `deploy/scripts/render_local_model_catalog_one_off_tasks.sh` | Promoted with reshape | `files/render_local_model_catalog.sh` |
| `deploy/codex/local-deep_one_off_tasks.config.toml` | Promoted | `files/codex-profiles/local-deep.config.toml` |
| `deploy/codex/local-fast_one_off_tasks.config.toml` | Promoted | `files/codex-profiles/local-fast.config.toml` |
| `deploy/codex/local-hvh01_one_off_tasks.config.toml` | Promoted | `files/codex-profiles/local-hvh01.config.toml` |
| `deploy/codex-homelab/desktop_one_off_tasks/config.toml` | Promoted | `templates/desktop-config.toml.j2` |
| `deploy/codex/instructions-*_one_off_tasks.md` | Promoted with reshape | `files/codex-instructions/instructions-*.md` |
| `deploy/scripts/install_fzf_tab_completion_one_off_tasks.sh` | Retired and replaced | `roles/fzf_tab_completion/tasks/present.yml` |
| `deploy/scripts/install_python_repl_fzf_tab_completion_one_off_tasks.sh` | Retired and replaced | same |
| `deploy/scripts/verify_fzf_tab_completion_one_off_tasks.sh` | Open gap | use plan receipt / manual TTY verify |
| `deploy/scripts/verify_python_repl_fzf_tab_completion_one_off_tasks.sh` | Open gap | same |
| `deploy/install_one_off_tasks.sh` | Retired and replaced | playbook converge |
| `deploy/uninstall_one_off_tasks.sh` | Retired and replaced | `scripts/uninstall_*_legacy.sh` + role `absent` |

## Related artifacts

- [EXECUTION-RECEIPT.md](EXECUTION-RECEIPT.md) — historical apply/verify evidence
- [AI-CORRECTION-EVALUATION.md](AI-CORRECTION-EVALUATION.md) — corrective audit
- [AI-DRAFT-SKILL-FAMILY-EVALUATION.md](AI-DRAFT-SKILL-FAMILY-EVALUATION.md) — draft skill family audit
- [documentation/README.md](documentation/README.md) — paired plan-local evaluator and implementer documentation

## Diagram Inventory

| Diagram | Medium | Notes |
| --- | --- | --- |
| Disposition ledger table | Markdown | Full one-off inventory |
| Parent plan architecture | See `2026-09-01--homelab-local-ai-clients-codex/` | Serving-layer diagrams |

## On Deck — user decisions to integrate

| ID | User decision | Target | Status |
| --- | --- | --- | --- |
| — | (none open) | — | — |
