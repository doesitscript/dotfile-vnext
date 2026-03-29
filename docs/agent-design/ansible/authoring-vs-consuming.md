# Ansible Architect — Authoring vs Consuming (Ansible-Specific)

See the general principle: `docs/agent-design/authoring-vs-consuming.md`

This file covers the Ansible-specific application of that principle.

---

## What the Ansible Architect Team Consumes

These are the MCP tools and resources the skills call during planning sessions.
They do not modify these tools. They use them.

| Tool / Resource | Server | Used by |
|---|---|---|
| `zen_of_ansible` | `ansible` | Coordinator (Phase 0), Planner (Phase 2) |
| `FetchMcpResource guidelines://ansible-content-best-practices` | `ansible` | Planner (Phase 2), Researcher (Phase 3), Observer (Phase 3) |
| `ade_environment_info` | `ansible` | Coordinator (Phase 0), Planner (Phase 2), Researcher (Phase 3) |
| `adt_check_env` | `ansible` | Researcher (Phase 3) — when ADT env health is the question |
| `ansible_lint` | `ansible` | Observer (Phase 3) — validates task syntax on flagged items |
| `inventory_graph` | `ansible-mcp` | Coordinator (Phase 0), Observer (Phase 2) |
| `inventory_find_host` | `ansible-mcp` | Observer (Phase 2) |
| `project_playbooks` | `ansible-mcp` | Observer (Phase 2), Planner (Phase 2) |
| `list_tasks` | `sysoperator` | Planner (Phase 2) — when existing playbooks are candidate homes |
| `inventory_parse` | `ansible-mcp` | Researcher (Phase 3) — when full merged view is needed |
| `ansible_gather_facts` | `ansible-mcp` | Researcher (Phase 3) — live host state |

---

## MCP Tool Pass Status

The skill files were updated with the above tool assignments in the session
that created `docs/agent-design/`. The pass is complete.

If new tools are added to the `ansible` MCP server, bring them to the repo
agent (Cursor) for another authoring pass. Do not ask the skills to update
themselves.
