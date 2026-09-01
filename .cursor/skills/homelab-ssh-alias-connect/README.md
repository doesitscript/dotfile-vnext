# Homelab SSH Alias Connect

Interactive SSH uses the Ansible inventory hostname as the `~/.ssh/config`
`Host` alias.

```bash
bin/codex-env python .cursor/skills/homelab-ssh-alias-connect/scripts/resolve_ssh_alias.py --host dev-workstation-win
ssh dev-workstation-win
```

Do not invent `user@ip` / `-i` / `-p` from inventory fields by hand.

Windows probes: use `run_remote_command.py` or `ansible.windows.win_powershell`
— not `ssh ... powershell -Command "..."` one-liners. See `SKILL.md`.
