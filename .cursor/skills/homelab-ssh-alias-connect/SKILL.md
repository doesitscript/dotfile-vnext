---
name: homelab-ssh-alias-connect
description: >-
  Force controller SSH to managed hosts via the repo SSH alias that matches the
  Ansible inventory hostname (e.g. ssh dev-workstation-win). Use before any
  interactive SSH, when tempted to build connection strings from ansible_host
  IP/user/key by hand, or when connection discovery feels invented. Resolves
  target from ansible-inventory and verifies Host exists in ~/.ssh/config.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "homelab-ansible-first-entry"
requires_summary: "AGENTS.md §11; docs/reference/connection-surfaces.md; roles/access_identity_controller ssh_config.j2"
title: Homelab SSH Alias Connect
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - ssh
  - windows
  - linux
related:
  - AGENTS.md
  - docs/reference/connection-surfaces.md
  - roles/access_identity_controller/templates/ssh_config.j2
  - inventory/hosts_mapping.yaml
tags:
  - skill
  - ssh
  - connection
  - anti-ad-hoc
---

# Skill: Homelab SSH Alias Connect

Interactive SSH to managed hosts is **one command**: the inventory hostname as
the `~/.ssh/config` `Host` alias. Do not invent connection logic.

## Correct pattern (only)

```bash
# 1) Confirm inventory hostname (example)
bin/codex-env ansible-inventory -i inventory/inventory.yaml --list --yaml | rg 'dev-workstation-win'

# 2) Resolve alias + prove Host exists
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py \
  --host dev-workstation-win

# 3) Connect — nothing else
ssh dev-workstation-win
```

That is the full interactive path. `HostName` / `User` / `IdentityFile` /
`Port` already live in the Ansible-managed `~/.ssh/config` block
(`access_identity_controller` → `Host {{ inventory_hostname }}`).

## When to use / not use

**Use** before interactive SSH, when debugging Windows/Linux hosts, or when an
agent starts composing `ssh -i … user@192.168…`.

**Do not use** to replace Ansible playbook transport — playbooks keep
`ansible_connection` from inventory. This skill owns **operator/agent shell SSH**.

## Hard stop — PROHIBITED

- Building SSH from raw `ansible_host` IP + guessed user/key in ad-hoc commands
- Inventing ProxyJump / port / identity outside `~/.ssh/config`
- Using NetBIOS / physical hostname / WinRM as the “SSH” path when an OpenSSH
  alias exists for the inventory name
- “Connection discovery” scripts that re-derive what `ssh <inventory_hostname>`
  already does

## Nested skill rule

If you entered `homelab-ansible-first-entry` (or any install/mutate skill) and
need a shell on the host, **nest into this skill** for the SSH step, then return
to the parent skill. Do not leave skill scope to freestyle connection.

## Ansible playbooks

Playbooks already use inventory SSH when `ansible_connection: ssh`. Prefer
inventory hostname in `--limit`. Do not override connection with made-up
`ansible_ssh_extra_args` unless diagnosing a documented alias failure.

## Resolve script

```bash
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py --host <inventory_hostname>
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py --list-ssh-hosts
```

Exit non-zero if `Host <inventory_hostname>` is missing from `~/.ssh/config`
(then fix via `access_identity_controller` / SSH config apply — not a one-off).

## Remote command order (avoid quote/escape hell)

When you need to run commands on the target:

1. **Preferred:** write a local `.ps1` / `.sh`, `scp` it to the host, then
   `ssh <inventory_hostname> powershell -File ...` (or `bash ...`).
2. **Long-running work** (multi‑GB curl, installs): start via Ansible
   `async`/`poll: 0` or a session-detached process so Windows OpenSSH does
   **not** kill children when the SSH session ends.
3. **Last resort only:** nested `ansible -m win_shell -a "..."` with heavy
   quoting. Do not invent `user@ip` / `-i` / `-p`.

Helper:

```bash
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/run_remote_command.py \
  --host <inventory_hostname> --shell powershell --stdin-file /tmp/probe.ps1
```

## References

- AGENTS.md item 11 (SSH alias = inventory hostname)
- `docs/reference/connection-surfaces.md`
- `roles/access_identity_controller/templates/ssh_config.j2`
