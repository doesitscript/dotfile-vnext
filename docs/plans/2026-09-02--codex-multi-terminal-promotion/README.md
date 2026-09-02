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
| Update behavior | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags codex_homelab_profiles,fzf_tab_completion --limit mac-dev` |
| Uninstall / legacy | `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh`; role `absent` states |

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_development_nodes.yaml --tags fzf_tab_completion,codex_homelab_profiles,shell_config --limit mac-dev` |
| **Verify** | `cx-de<Tab>` in bash; `python3` REPL Tab; `cx-deep-smoke`; `type cx-deep` |
| **Undo** | `fzf_tab_completion_state: absent`, `codex_homelab_profiles_multi_terminal_state: absent`; re-run playbook |
| **Change class** | Idempotent Ansible config |

## Checklist

| Item | Status | Evidence |
| --- | --- | --- |
| Governance for `docs/one_off_tasks/` | done | `docs/one_off_tasks/README.md`, `docs/plans/README.md` |
| Archive one-off source | done | `backup/one-off-source/` + `backup/README.md` |
| Remove live one-off folder | done | `docs/one_off_tasks/codex-multi-terminal-workflow/` deleted |
| `fzf_tab_completion` role | done | `roles/fzf_tab_completion/` |
| Extend `codex_homelab_profiles` multi-terminal | done | `tasks/multi_terminal.yml`, `files/bashrc.d/codex-multi-terminal.bash` |
| `mac-dev` host_vars | done | `fzf_tab_completion_state: present`, `codex_homelab_profiles_multi_terminal_state: present` |
| Legacy host cleanup script | done | `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh` |
| Live Ansible apply on mac-dev | done | Playbook runs + smoke tests — see Execution receipt |

## Promotion map (one-off → Ansible)

| Trial artifact | Promoted to |
| --- | --- |
| `shell-completion_one_off_tasks.bash` | `roles/fzf_tab_completion/files/bashrc.d/shell-completion.bash` |
| `python-fzf-tab-completion_one_off_tasks.bash` | `roles/fzf_tab_completion/templates/python-fzf-tab-completion.bash.j2` |
| `install_fzf_tab_completion_*.sh` | `roles/fzf_tab_completion/tasks/present.yml` |
| `codex-multi-terminal_one_off_tasks.bash` | `roles/codex_homelab_profiles/files/bashrc.d/codex-multi-terminal.bash` |
| `local-*_one_off_tasks.config.toml` | `roles/codex_homelab_profiles/files/codex-profiles/` (plan SSOT names) |
| `codex-homelab_one_off_tasks.sh` | `roles/codex_homelab_profiles/templates/codex-homelab.sh.j2` (+ `hvh01`, `exec`) |
| `render_local_model_catalog_one_off_tasks.sh` | `roles/codex_homelab_profiles/files/render_local_model_catalog.sh` |

## Execution receipt (2026-09-02)

**Implemented in repo:**

- Governance README rewritten at `docs/one_off_tasks/README.md`.
- Plan packet created with archival backup; live one-off tree deleted.
- New role `fzf_tab_completion`; extended `codex_homelab_profiles` for multi-terminal.
- Playbook + `mac-dev` inventory wired.
- Legacy uninstall script run on operator Mac (removed `*_one_off_tasks` host files).

**Live converge (2026-09-02):**

| Run | Command | Result |
| --- | --- | --- |
| Initial apply | `deploy_development_nodes.yaml --tags shell_config,fzf_tab_completion,codex_homelab_profiles --limit mac-dev` | **ok** — 69 ok, 12 changed |
| Idempotent re-run | same tags | **ok** — 69 ok, 3 changed |
| Dedicated profile playbook | `deploy_codex_homelab_profiles.yaml --limit mac-dev` | **ok** — 15 ok, 1 changed |
| Fix redeploy | after removing stray `---` from `shell-completion.bash` | **ok** — 56 ok, 2 changed |

**Post-apply verification (2026-09-02, mac-dev):**

| Check | Result |
| --- | --- |
| `bash -lc 'type cx-deep cx-desktop cx-skills cx-hvh01 cx-research'` | pass — all functions defined |
| `type codex-homelab rl_custom_complete` | pass — binaries in `~/bin` |
| Artifact files (`shell-completion.bash`, `codex-multi-terminal.bash`, `local-deep.config.toml`, fzf clone) | pass — all present |
| `bash -lc 'source ~/.bashrc.d/shell-completion.bash'` | pass after fix (was failing: line 1 `---` YAML frontmatter) |
| `cx-hvh01-smoke` | pass — model `qwen2.5-coder-1.5b@hvh01` replied `pong` |
| `cx-deep-smoke` | pass — model `qwen2.5-coder-32b@k3s02-vllm` replied `pong` |
| Legacy one-off cleanup | pass — `scripts/uninstall_codex_multi_terminal_one_off_legacy.sh` run earlier |
| Interactive Tab (`cx-de<Tab>`, Python REPL Tab) | not automatable without TTY — open a **new terminal** and confirm manually |

**Bug fixed during verification:** `roles/fzf_tab_completion/files/bashrc.d/shell-completion.bash` had a stray
`---` on line 1 (YAML frontmatter leak). Removed and redeployed.

## Diagram Inventory

| Diagram | Medium | Notes |
| --- | --- | --- |
| Promotion map table | Markdown | One-off → role mapping |
| Parent plan architecture | See `2026-09-01--homelab-local-ai-clients-codex/` | Serving-layer diagrams |

## On Deck — user decisions to integrate

| ID | User decision | Target | Status |
| --- | --- | --- | --- |
| — | (none open) | — | — |
