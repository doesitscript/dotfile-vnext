# Homelab Ansible-First Entry

Wide front door for install/download/configure/remove work on managed hosts.
Forces Ansible-first routing before agents invent custom installers.

## Quick start

```bash
bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py
```

Then open the printed skill and continue. Do not invent `_tmp_` playbooks or
role `files/*.ps1` downloaders when `win_get_url` / `win_package` /
`win_chocolatey` apply.
