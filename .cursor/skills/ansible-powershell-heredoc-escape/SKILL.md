---
name: ansible-powershell-heredoc-escape
description: Use bash heredoc to escape nested PowerShell quoting when running ad-hoc ansible win_powershell commands. Prevents "failed at splitting arguments" errors from arrays, nested quotes, or complex scripts.
---

# Skill: Ansible PowerShell Heredoc Escape

## When to use

Use this pattern when **all four** conditions are true:

1. You are running an **ad-hoc** ansible command (not a playbook, not the wrapper)
2. The module supports **free-form / raw parameters** (like `shell`, `command`, `raw`, `script`)
3. The command/script contains **nested quotes**, **arrays**, **complex strings**, or **multi-line content**
4. You are about to hit "failed at splitting arguments" or three-layer shell quoting hell

**Note:** `ansible.windows.win_powershell` does **not** support raw params via `-a`, so for that module specifically, use a playbook with `script: |` block or the `run_remote_command.py` wrapper.

## When NOT to use

- **Playbooks** — use YAML block scalar `script: |` instead (cleanest)
- **Interactive probing** — use `run_remote_command.py --stdin-file` (repo wrapper exists for this)
- **Simple one-liners** — if the script has no nested quotes, heredoc is overkill

## The Pattern

**For modules that support raw params (shell, command, raw, script):**
```bash
ansible <host> -i inventory/inventory.yaml -m ansible.builtin.shell -a "$(cat <<'SHELLEOF'
<your shell command here with all the nested quotes you want>
SHELLEOF
)"
```

**For win_powershell specifically (raw params not supported):**
Use a playbook instead:
```yaml
- name: Run complex PowerShell
  ansible.windows.win_powershell:
    script: |
      <your PowerShell script with nested quotes>
```

Or use the wrapper:
```bash
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/run_remote_command.py \
  --host <hostname> --shell powershell --stdin-file /tmp/script.ps1
```

**Critical details:**
- `'PSEOF'` with quotes prevents bash variable expansion inside the heredoc
- The `$(cat <<'...')` subshell captures the heredoc output as a single string
- All PowerShell quotes, arrays, and variables pass through **untouched**
- No escaping needed inside the script block

## Example: The Failure That Created This Skill

**What broke (three-layer quoting):**
```bash
ansible HOM-LAB-HVH-01 -m ansible.windows.win_powershell \
  -a "script='foreach ($root in @('F:\shares\public\models','F:\shares\public\studio')) { ... }'"
# ERROR: failed at splitting arguments, either an unbalanced jinja2 block or quotes
```

**Attempted heredoc fix (doesn't work — win_powershell doesn't support raw params):**
```bash
# This fails: "Action 'ansible.windows.win_powershell' does not support raw params"
ansible HOM-LAB-HVH-01 -i inventory/inventory.yaml -m ansible.windows.win_powershell -a "$(cat <<'PSEOF'
...
PSEOF
)"
```

**Actual fix (playbook with YAML block scalar):**
```yaml
- name: Probe model directories
  ansible.windows.win_powershell:
    script: |
      foreach ($root in @('F:\shares\public\models','F:\shares\public\studio')) {
        if (Test-Path $root) {
          Write-Output "=== $root ==="
          Get-ChildItem $root -Directory -ErrorAction SilentlyContinue | ForEach-Object {
            $sz = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            '{0,-45} {1,10:N2} GB' -f $_.Name, ($sz/1GB)
          }
        }
      }
```

**When heredoc DOES work (shell module example):**
```bash
ansible some-linux-host -m ansible.builtin.shell -a "$(cat <<'SHELLEOF'
for file in /path/to/*.log; do
  echo "Processing: $file"
  grep -E 'ERROR|WARNING' "$file" | tail -10
done
SHELLEOF
)"
```

## Why It Works

**The three quoting layers:**
1. **Bash shell** — parses the command line
2. **Ansible arg parser** — parses `key='value'` syntax
3. **PowerShell** — parses the script

**With nested quotes:**
- Each layer strips quotes meant for the next layer
- PowerShell arrays like `@('a','b')` confuse the Ansible parser
- You end up fighting all three parsers at once

**With heredoc:**
- Bash heredoc produces a literal string (no quote stripping)
- That string becomes the entire value of `script=`
- Ansible sees `script=<one big string>`, no nested parsing
- PowerShell receives the script exactly as written

## Decision Tree

```
Need to run PowerShell remotely?
├─ Is it a repeatable automation task?
│  └─ YES → Write a playbook with `script: |` block
│
├─ Is it an interactive diagnostic probe?
│  └─ YES → Use `run_remote_command.py --stdin-file /tmp/script.ps1`
│
└─ Ad-hoc command with complex PowerShell?
   ├─ Simple script, no nested quotes?
   │  └─ YES → Plain `ansible ... -a "script='...'"`
   │
   └─ Arrays, nested quotes, or variables?
      └─ YES → **Use this skill** (heredoc escape)
```

## References

- `AGENTS.md` §9a — shell/terminal error gate (prefer wrapper for multi-line PS)
- `.cursor/rules/102--ansible-powershell-encoding.mdc` — PowerShell quoting rules
- `.cursor/skills/homelab-ssh-alias-connect/scripts/run_remote_command.py` — wrapper alternative
- This failure: 2026-09-10 conversation, trying to probe HVH-01 model directories

## Why This Skill Exists

Agents (including Claude) will choose ad-hoc commands over playbooks or wrappers for various reasons—speed, context, or just preference. Rather than force every agent to always use the "right" tool, this skill gives them a third option that works when they've already committed to the ad-hoc path.

It's a safety net, not a first choice.
