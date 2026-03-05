# Cursor Rules — Source Storage

This folder is the **source of truth** for all Cursor AI rules used in this project.
Files here are stored with a `.cursor` suffix so Cursor does not activate them directly.
The Ansible `cursor` role is responsible for deploying them to their active locations.

---

## Rule Hierarchy (Three Layers)

### Layer 1 — Always On: `.cursorrules` (project root)
**Most reliable.** A single flat file at the root of the project.
Cursor injects its entire contents into the system prompt for **every agent session**,
with no exceptions. Context window pressure does not affect it.

- Bootstraps awareness of all other rules at session start
- Explicitly lists every active `.mdc` rule so the agent knows to load them
- Contains: Ansible Architect role context, MCP tools mandate, structural guidelines
- Stored here as: `.cursorrules.cursor`
- Active location: `../../.cursorrules`

### Layer 2 — Project Rules: `.cursor/rules/*.mdc`
**Conditionally reliable.** A folder of `.mdc` files with YAML frontmatter.
Rules with `alwaysApply: true` are intended to load every session, but Cursor's
relevance engine may skip them when the context window fills. Layer 1 compensates
by listing all rule names so the agent knows to seek them out.

Each `.mdc` file covers a specific domain. Active files:

| File | Purpose |
|---|---|
| `ansible-mcp-first.mdc` | MCP tool priority — full tool reference for all 3 servers |
| `ansible-declarative-enforcement.mdc` | No scripting, use native modules, violation levels |
| `ansible-kubernetes-declarative.mdc` | Kubernetes label/taint declarative enforcement |
| `winrm-ansible.mdc` | WinRM env setup required before any Windows Ansible work |
| `k3s-cluster.mdc` | k3s lab cluster constraints, GPU boundary, anti-overengineering |
| `REQUIRED-EVIDENCE-NO-ASSUMPTIONS-ON-FAILURE.mdc` | Failure investigation protocol |
| `devops.mdc` | General DevOps and Ansible standards |

Stored here with `.cursor` suffix appended (e.g. `k3s-cluster.mdc.cursor`).
Active location: `../../.cursor/rules/`

### Layer 3 — Global: Cursor Settings → Rules for AI
**Most global.** Configured in Cursor's user settings, not in this repo.
Applies across **all projects**, not just this one. Use for cross-project standards
that should never be absent regardless of which repo is open.

---

## Deploying Rules

When the `cursor` Ansible role is wired to deploy rules, it will:
1. Copy each `*.mdc.cursor` file to `.cursor/rules/` stripping the `.cursor` suffix
2. Copy `.cursorrules.cursor` to `.cursorrules` at the project root

Until that task is written, keep `.cursor/rules/` and `.cursorrules` in sync manually
by editing both the active file and its `.cursor` counterpart here.

---

## Adding a New Rule

1. Create the rule as `roles/cursor/rules/<name>.mdc.cursor`
2. Copy it to `.cursor/rules/<name>.mdc`
3. Add the filename and purpose to the table in Layer 2 above
4. Add it to the rule list in `.cursorrules` (Layer 1) so it is always announced at session start
