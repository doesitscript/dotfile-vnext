# Downstream update commands (work Mac)

Run from the sibling checkout after `git pull`. Vault via `vault_pass.sh`.
Always skip `hosts_file` on day-2 unless refreshing the hosts catalog.

```bash
cd ~/Documents/develop/work-laptop-ai-tools
git pull --ff-only
```

## Full update

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --check --diff
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file
```

## Grouped updates (capability tags)

Prefer the smallest group that covers the change. Catalog:
`group_vars/all/work_laptop_capabilities.yml`.

```bash
# Default AI refresh (clients + related MCP integrations).
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_tools --check --diff
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_tools

# Clients only (Continue/Cline/Codex/OpenCode/Kilo/Aider/Zed).
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags ai_clients

# Jan local runtime/RAG only (no weight download).
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags model_runtime

# AI MCP integrations only.
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags mcp
```

## Recent-change windows (playbook role-list tail)

Use when the sync only touched the sequential day-2 role tail.

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags recent_10
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml \
  --skip-tags hosts_file --tags recent_15
```

Authority: packet `AGENTS.md`. Apply skill: `work-laptop-day2-apply`.
This file is refreshed on every `work-laptop-packet-ops` / export-pack sync.
