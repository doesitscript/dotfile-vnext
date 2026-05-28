---
deprecated: false
sweep_date: 2026-05-28
agent: docs_sweep
policy: WSL is desktop-only (e.g. mac-dev); server/hyperv/k3s/docker lanes must not use WSL automation narrative
---

# WSL scope reform — docs sweep manifest

## Summary

| Metric | Count |
|--------|------:|
| Markdown files archived (single-file moves) | 34 |
| Plan folders archived (with redirect stubs) | 8 |
| **Total archive operations** | **42** |
| Kept in place (policy / desktop / active reform) | 15 |
| Skipped per coordinator (`capture-wsl-systemctl` skill) | 1 |

Coordinator packet: [`docs/plans/2026-05-28--wsl-scope-reform-incomplete/README.md`](../../plans/2026-05-28--wsl-scope-reform-incomplete/README.md)

## Grep classification (all `*.md` with `wsl|WSL`)

| Path | Why it mentions WSL | Desktop-only? | Action |
|------|---------------------|:-------------:|--------|
| `AGENTS.md` | Repo truths: `*-wsl` legacy suffix, `wsl_hosts` group | N/A (policy) | **keep** |
| `README.md` | Root bootstrap narrative (`server-225-wsl`, WSL deploy paths) | No | **keep** — content reform needed (not archived) |
| `.cursor/skills/capture-wsl-systemctl/SKILL.md` | Desktop WSL systemctl diagnostics | Yes | **skip** (skill stays) |
| `.cursor/skills/github-issue-workflow/references/examples.md` | Example issue metadata only | N/A | **keep** |
| `docs/plans/2026-05-28--wsl-scope-reform-incomplete/README.md` | Active WSL reform coordinator | N/A | **keep** |
| `docs/plans/2026-05-28--homelab-hosts-file-linux-windows-incomplete/README.md` | No WSL body (grep false on sibling work) | N/A | **keep** |
| `docs/plans/2026-05-27--name-alignment-netbox-metadata-incomplete/README.md` | `server-225-wsl` dead-code cleanup refs only | N/A | **keep** |
| `docs/codex_framework/partner_process.md` | `wsl_hosts` legacy naming policy | N/A | **keep** |
| `docs/codex_framework/implemented_plans/2026-03-26--troubleshooting-mode.md` | `wsl.exe` vs deprecated `bash.exe` path | N/A | **keep** |
| `docs/lessons-learned/codex/deprecated-or-disproven-paths-must-be-replaced-not-extended.md` | Disproven WSL wrapper paths | N/A | **keep** |
| `docs/lessons-learned/codex/troubleshooting_logic.md` | Connection taxonomy includes `wsl.exe` | Partial | **keep** |
| `docs/lessons-learned/README.md` | Index lists WSL lesson category | Partial | **keep** — index update in ansible reform |
| `docs/diagnostics/openssh--windows--diagnostics.md` | States OpenSSH on Windows, not WSL | N/A | **keep** |
| `docs/diagnostics/hyperv-ubuntu-current-implementation-slice.md` | WSL as historical context only | N/A | **keep** |
| `docs/personal_notes__local__.md` | User local notes on WSL isolation policy | N/A | **keep** (local, not server SSOT) |
| `roles/common/agent_skills/.../selection-guide.md` | AI workload categories (WSL/Linux) | Yes (generic) | **keep** |
| `docs/plans/2026-05-20--decouple-hyper-v-from-wsl/` | WSL/Hyper-V decouple plan | No | **archived** → redirect stub |
| `docs/plans/2026-05-20--decouple-hyper-v-assessment-incomplete/` | WSL coupling assessment | No | **archived** → redirect stub |
| `docs/plans/2026-05-20--hyper-v-bridge-networking-role/` | `wsl_configuration`, `.wslconfig` | No | **archived** → redirect stub |
| `docs/plans/2026-05-20--fail-run-ts-distro-apt-incomplete/` | WSL distro/apt failures | No | **archived** → redirect stub |
| `docs/plans/2026-05-20--docker-ssh-sync-audit-incomplete/` | Docker-over-WSL SSH | No | **archived** → redirect stub |
| `docs/plans/2026-05-20--k3s-cluster-deployment-incomplete/` | k3s + WSL inventory paths | No | **archived** → redirect stub |
| `docs/plans/2026-03-08--logging-loki-alloy-stack-incomplete/` | WSL/Linux log surfaces | No | **archived** → redirect stub |
| `docs/plans/2026-05-20--mcp-server-organization/` | `wsl_hosts` docker build host | No | **archived** → redirect stub |
| All other grep hits under `docs/`, `roles/hyperv_ubuntu_vm/README.md` | Server/hyperv/k3s/docker WSL narrative | No | **archived** (see moves table) |

## Moves (archive location)

| Original path | Archive path | Type | coordinator_review |
|---------------|--------------|------|-------------------|
| `docs/non_binding_project_layout/controller_ssh_vault_depricating_tools.md` | `docs/archive/wsl-deprecating/controller_ssh_vault_depricating_tools-deprecating.md` | file | pending |
| `docs/reports/2026-03-26_project_state_GPT-5/README.md` | `docs/archive/wsl-deprecating/2026-03-26_project_state_GPT-5-deprecating.md` | file | pending |
| `docs/reports/2026-03-26_project_state_GPT-5/current_codex_architecture.md` | `docs/archive/wsl-deprecating/current_codex_architecture-deprecating.md` | file | delete_candidate |
| `docs/reports/2026-03-26_project_state_Gemini-2.5-Pro/README.md` | `docs/archive/wsl-deprecating/2026-03-26_project_state_Gemini-2.5-Pro-deprecating.md` | file | pending |
| `docs/reports/2026-03-26_project_state_Claude-4.6-Sonnet/README.md` | `docs/archive/wsl-deprecating/2026-03-26_project_state_Claude-4.6-Sonnet-deprecating.md` | file | pending |
| `docs/reports/2026-03-26_project_state_Claude-4.6-Sonnet/codex_framework_usage.md` | `docs/archive/wsl-deprecating/codex_framework_usage-deprecating.md` | file | delete_candidate |
| `docs/reports/2026-03-08--ansible-implementation-issues.md` | `docs/archive/wsl-deprecating/2026-03-08--ansible-implementation-issues-deprecating.md` | file | pending |
| `docs/reports/2026-03-08--docker-ssh-fix.md` | `docs/archive/wsl-deprecating/reports/2026-03-08--docker-ssh-fix-deprecating.md` | file | delete_candidate |
| `docs/brainstorming_designs/project_improvements_wiki_github_plugin.md` | `docs/archive/wsl-deprecating/project_improvements_wiki_github_plugin-deprecating.md` | file | delete_candidate |
| `docs/brainstorming_designs/multi-agent-project/gemni-plan-multi-agent_hyperv-ubuntu.md` | `docs/archive/wsl-deprecating/gemni-plan-multi-agent_hyperv-ubuntu-deprecating.md` | file | delete_candidate |
| `docs/lessons-learned/conversation-contexts/conversation--good-very-smart-cursor_chat_name_generation_process.md` | `docs/archive/wsl-deprecating/conversation--good-very-smart-cursor_chat_name_generation_process-deprecating.md` | file | delete_candidate |
| `docs/intake/k3s-on-hyperv-vm.md` | `docs/archive/wsl-deprecating/k3s-on-hyperv-vm-deprecating.md` | file | pending |
| `docs/intake/netbox-jumpstart.md` | `docs/archive/wsl-deprecating/netbox-jumpstart-deprecating.md` | file | pending |
| `docs/intake/next_milestones_works.md` | `docs/archive/wsl-deprecating/next_milestones_works-deprecating.md` | file | delete_candidate |
| `docs/intake/copilot_advise_ubuntu_handsfree.md` | `docs/archive/wsl-deprecating/copilot_advise_ubuntu_handsfree-deprecating.md` | file | delete_candidate |
| `docs/intake/Jupyter Setup for DevOps.md` | `docs/archive/wsl-deprecating/Jupyter Setup for DevOps-deprecating.md` | file | delete_candidate |
| `docs/intake/schema-design-proposal-netbox-ansible-context/Standardized Naming Schema.md` | `docs/archive/wsl-deprecating/Standardized Naming Schema-deprecating.md` | file | delete_candidate |
| `docs/intake/drive-provisioning-rebuildable-data-provision/chat-gpt-intake-drive-provision.md` | `docs/archive/wsl-deprecating/chat-gpt-intake-drive-provision-deprecating.md` | file | delete_candidate |
| `docs/intake/drive-provisioning-rebuildable-data-provision/chat-gpt-intake-drive-provision--backup-subset-of-info.md` | `docs/archive/wsl-deprecating/chat-gpt-intake-drive-provision--backup-subset-of-info-deprecating.md` | file | delete_candidate |
| `docs/non_binding_project_layout/architecture_rules.md` | `docs/archive/wsl-deprecating/architecture_rules-deprecating.md` | file | pending |
| `docs/non_binding_project_layout/bin_tools_depricating_depricating_tools.md` | `docs/archive/wsl-deprecating/bin_tools_depricating_depricating_tools-deprecating.md` | file | pending |
| `docs/non_binding_project_layout/deploy_shell_config.md` | `docs/archive/wsl-deprecating/deploy_shell_config-deprecating.md` | file | pending |
| `docs/diagnostics/debug-ssh-vvv.md` | `docs/archive/wsl-deprecating/debug-ssh-vvv-deprecating.md` | file | delete_candidate |
| `docs/diagnostics/hyperv-ubuntu-vm--windows--lessons-learned.md` | `docs/archive/wsl-deprecating/hyperv-ubuntu-vm--windows--lessons-learned-deprecating.md` | file | delete_candidate |
| `docs/operator_runbook.md` | `docs/archive/wsl-deprecating/operator_runbook-deprecating.md` | file | delete_candidate |
| `docs/ssh_requirements_checklist.md` | `docs/archive/wsl-deprecating/ssh_requirements_checklist-deprecating.md` | file | delete_candidate |
| `docs/setup_openssh_via_winrm_summary.md` | `docs/archive/wsl-deprecating/setup_openssh_via_winrm_summary-deprecating.md` | file | delete_candidate |
| `docs/access_first_play.md` | `docs/archive/wsl-deprecating/access_first_play-deprecating.md` | file | delete_candidate |
| `docs/ansible_project_review.md` | `docs/archive/wsl-deprecating/ansible_project_review-deprecating.md` | file | delete_candidate |
| `docs/ansible_ssh_vault.md` | `docs/archive/wsl-deprecating/ansible_ssh_vault-deprecating.md` | file | delete_candidate |
| `docs/ansible/README_vault_pass.md` | `docs/archive/wsl-deprecating/README_vault_pass-deprecating.md` | file | pending |
| `docs/ansible/access_playbook.md` | `docs/archive/wsl-deprecating/access_playbook-deprecating.md` | file | pending |
| `docs/one_off_tasks/windows-openssh-legacy-cleanup.md` | `docs/archive/wsl-deprecating/windows-openssh-legacy-cleanup-deprecating.md` | file | delete_candidate |
| `roles/hyperv_ubuntu_vm/README.md` | `docs/archive/wsl-deprecating/hyperv_ubuntu_vm-deprecating.md` | file | pending |
| `docs/plans/2026-05-20--decouple-hyper-v-from-wsl/` | `docs/archive/wsl-deprecating/plans/2026-05-20--decouple-hyper-v-from-wsl-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-05-20--decouple-hyper-v-assessment-incomplete/` | `docs/archive/wsl-deprecating/plans/2026-05-20--decouple-hyper-v-assessment-incomplete-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-05-20--hyper-v-bridge-networking-role/` | `docs/archive/wsl-deprecating/plans/2026-05-20--hyper-v-bridge-networking-role-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-05-20--fail-run-ts-distro-apt-incomplete/` | `docs/archive/wsl-deprecating/plans/2026-05-20--fail-run-ts-distro-apt-incomplete-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-05-20--docker-ssh-sync-audit-incomplete/` | `docs/archive/wsl-deprecating/plans/2026-05-20--docker-ssh-sync-audit-incomplete-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-05-20--k3s-cluster-deployment-incomplete/` | `docs/archive/wsl-deprecating/plans/2026-05-20--k3s-cluster-deployment-incomplete-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-03-08--logging-loki-alloy-stack-incomplete/` | `docs/archive/wsl-deprecating/plans/2026-03-08--logging-loki-alloy-stack-incomplete-deprecating/` | plan_folder | delete_candidate |
| `docs/plans/2026-05-20--mcp-server-organization/` | `docs/archive/wsl-deprecating/plans/2026-05-20--mcp-server-organization-deprecating/` | plan_folder | delete_candidate |

Redirect stubs remain at each original `docs/plans/2026-05-20--*` / `2026-03-08--*` path (`README.md` only).

## Link repairs (this sweep)

- `docs/plans/README.md` — WSL archive index section added
- `docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md` — `depends_on_plans` → archive
- `docs/plans/2026-05-27--k3s-hyperv-traefik-homelab-hosts-file-implemented/README.md` — `depends_on_plans` → archive
- `docs/plans/2026-05-28--hyperv-routed-subnet-convergence-and-traefik-name-bridge/README.md` — `depends_on_plans` → archive

## Skipped (coordinator)

| Path | Reason |
|------|--------|
| `.cursor/skills/capture-wsl-systemctl/SKILL.md` | Desktop diagnostics skill — may stay for mac-dev / gaming desktop paths |

## delete_candidate index (coordinator rename → `*-delete.md`)

1. `docs/archive/wsl-deprecating/project_improvements_wiki_github_plugin-deprecating.md`
2. `docs/archive/wsl-deprecating/conversation--good-very-smart-cursor_chat_name_generation_process-deprecating.md`
3. `docs/archive/wsl-deprecating/chat-gpt-intake-drive-provision--backup-subset-of-info-deprecating.md`
4. `docs/archive/wsl-deprecating/debug-ssh-vvv-deprecating.md`
5. `docs/archive/wsl-deprecating/operator_runbook-deprecating.md`
6. `docs/archive/wsl-deprecating/codex_framework_usage-deprecating.md`
7. `docs/archive/wsl-deprecating/next_milestones_works-deprecating.md`
8. `docs/archive/wsl-deprecating/current_codex_architecture-deprecating.md`
9. `docs/archive/wsl-deprecating/copilot_advise_ubuntu_handsfree-deprecating.md`
10. `docs/archive/wsl-deprecating/ssh_requirements_checklist-deprecating.md`
11. `docs/archive/wsl-deprecating/setup_openssh_via_winrm_summary-deprecating.md`
12. `docs/archive/wsl-deprecating/ansible_project_review-deprecating.md`
13. `docs/archive/wsl-deprecating/Jupyter Setup for DevOps-deprecating.md`
14. `docs/archive/wsl-deprecating/gemni-plan-multi-agent_hyperv-ubuntu-deprecating.md`
15. `docs/archive/wsl-deprecating/ansible_ssh_vault-deprecating.md`
16. `docs/archive/wsl-deprecating/windows-openssh-legacy-cleanup-deprecating.md`
17. `docs/archive/wsl-deprecating/Standardized Naming Schema-deprecating.md`
18. `docs/archive/wsl-deprecating/chat-gpt-intake-drive-provision-deprecating.md`
19. `docs/archive/wsl-deprecating/hyperv-ubuntu-vm--windows--lessons-learned-deprecating.md`
20. `docs/archive/wsl-deprecating/access_first_play-deprecating.md`
21. `docs/archive/wsl-deprecating/reports/2026-03-08--docker-ssh-fix-deprecating.md`
22. `docs/archive/wsl-deprecating/plans/2026-05-20--decouple-hyper-v-from-wsl-deprecating/`
23. `docs/archive/wsl-deprecating/plans/2026-05-20--decouple-hyper-v-assessment-incomplete-deprecating/`
24. `docs/archive/wsl-deprecating/plans/2026-05-20--hyper-v-bridge-networking-role-deprecating/`
25. `docs/archive/wsl-deprecating/plans/2026-05-20--fail-run-ts-distro-apt-incomplete-deprecating/`
26. `docs/archive/wsl-deprecating/plans/2026-05-20--docker-ssh-sync-audit-incomplete-deprecating/`
27. `docs/archive/wsl-deprecating/plans/2026-05-20--k3s-cluster-deployment-incomplete-deprecating/`
28. `docs/archive/wsl-deprecating/plans/2026-03-08--logging-loki-alloy-stack-incomplete-deprecating/`
29. `docs/archive/wsl-deprecating/plans/2026-05-20--mcp-server-organization-deprecating/`

**delete_candidate count: 29**

## Follow-ups (not this sweep)

- Root `README.md` still describes `server-225-wsl` bootstrap — needs content reform (WSL-R4 / coordinator).
- `roles/hyperv_ubuntu_vm/README.md` removed — restore non-WSL README or pointer stub in ansible reform pass.
- `docs/lessons-learned/README.md` still indexes missing `wsl-idle-shutdown-and-wslconfig-parsing.md` — reconcile in coordinator review.
