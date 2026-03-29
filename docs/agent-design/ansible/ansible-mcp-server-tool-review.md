# ansible-mcp Server — Tool Review for Ansible Architect Team

Review of all tools available in the `ansible-mcp` MCP server against the
planning team's scope. Conducted after the initial skill build to identify
any gaps or additions worth making.

---

## Scope Constraint

The architect team's job is **planning, not execution or diagnosis**.
This review only adds tools that have genuine value in a planning context.
Diagnostic, execution, and vault tools are out of scope unless they directly
support a planning decision.

---

## Already Used — No Change Needed

| Tool | Used by |
|---|---|
| `inventory_graph` | Coordinator Phase 0, Observer Phase 2 |
| `inventory_find_host` | Observer Phase 2 |
| `inventory_parse` | Researcher Phase 3 (full merged view) |
| `project_playbooks` | Observer Phase 2, Planner Phase 2 |
| `ansible_gather_facts` | Researcher Phase 3 (live host state) |

---

## Added in Round 2

| Tool | Added to | Reason |
|---|---|---|
| `validate_yaml` | Observer Phase 2 | Fills gap for raw YAML files (templates, vars, host_vars) that `ansible_lint` does not cover |
| `create_role_structure` | Coordinator Phase 3 (output note) | Recommended execution action when plan includes a new role — not a planning tool, but a handoff note |

---

## Reviewed and Excluded

| Tool | Reason excluded |
|---|---|
| `ansible_inventory` | Redundant with `inventory_graph` — graph gives richer output |
| `ansible_ping` | Connectivity check — execution/diagnostic, not planning |
| `validate_playbook` | Covered by `ansible_lint` from `ansible` server |
| `galaxy_install` | Execution — runs after planning is done |
| `galaxy_lock` | Execution — dependency pinning, post-planning |
| `project_bootstrap`, `register_project`, `list_projects` | Project management — not planning scope |
| `project_run_playbook`, `ansible_playbook` | Execution — runs the plan, not shapes it |
| `create_playbook` | Scaffolding — execution action, not planning |
| `ansible_task` | Ad-hoc execution — not planning |
| `ansible_role` | Role testing in isolation — execution |
| `ansible_remote_command` | Remote execution — not planning |
| `inventory_diff` | Comparing inventory states — edge case, not routine planning |
| `vault_encrypt`, `vault_decrypt`, `vault_view`, `vault_rekey` | Vault operations — separate domain |
| `ansible_fetch_logs` | Diagnostic — troubleshooting domain |
| `ansible_service_manager` | Diagnostic — troubleshooting domain |
| `ansible_diagnose_host` | Diagnostic — troubleshooting domain |
| `ansible_capture_baseline` | Diagnostic — troubleshooting domain |
| `ansible_compare_states` | Diagnostic — troubleshooting domain |
| `ansible_auto_heal` | Automated healing — explicitly gated, never planning |
| `ansible_network_matrix` | Diagnostic — connectivity troubleshooting |
| `ansible_security_audit` | Security audit — separate domain |
| `ansible_health_monitor` | Trend analysis — monitoring domain |
| `ansible_performance_baseline` | Performance — diagnostic domain |

---

## Round 3 — sysoperator Server

The `sysoperator` MCP server was reviewed for coordinator scope additions.

| Tool | Decision | Reason |
|---|---|---|
| `run_ad_hoc` | **Added — Coordinator Phase 3.5** | Live probe when the team is stuck and the right path depends on actual host state. Read-only, narrow. Not a substitute for proper modules — a decision-unblocking tool. |
| `list_tasks` | Already in rules (02--cussorrules) | Coordinator's pre-flight for existing playbooks is covered by framework rules |
| `run_playbook`, `check_syntax` | Excluded | Execution and validation — post-planning |
| `list_inventory` | Excluded | Fallback for `inventory_graph` from ansible-mcp — not needed if ansible-mcp is available |
| `vault_encrypt_string`, `vault_decrypt_string` | Excluded | Vault operations — separate domain |
| All `aws_*`, `terraform` | Excluded | Different domain entirely |

**Honest note on `run_ad_hoc`:** This is the tool agents reach for when they
should be debugging interactively but are forced into batch execution instead.
The real pain is that agents default to either (a) guessing, or (b) dispatching
a researcher for something that a single live probe would answer in 2 seconds.
`run_ad_hoc` with a read-only command is the right tool for that gap.

---

## Notes

`ansible_test_idempotence` was visible in the server list. Not added —
idempotency testing is a post-execution validation step, not a planning tool.
Worth noting to the user when a plan involves a new role: "after execution,
run `ansible_test_idempotence` to confirm no changes on second run."

Future review trigger: if the `ansible-mcp` server adds new tools, bring
the updated list to Cursor (repo agent) for another authoring pass.
Do not ask the skills to evaluate themselves.
