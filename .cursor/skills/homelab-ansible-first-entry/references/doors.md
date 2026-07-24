# Entry doors

Print live copy via:

```bash
bin/codex-env python .cursor/skills/homelab-ansible-first-entry/scripts/print_entry_doors.py
```

## Door table

| Request shape | Next skill |
| --- | --- |
| Windows tool / Chocolatey / Setup.exe / HVH / AMD desktop | `windows-tool-capability-intake` |
| macOS CLI | `macos-tool-install-decider-and-scaffold` → `tool-capability-intake` |
| HF model weights on share | `hf-model-weight-lifecycle` |
| Generic / unclear OS tool | `tool-capability-intake` |
| Ansible authorship already scoped | `ansible-knowledge-gate` |
| Broad maturity | `project-maturity-router` |

## Windows upstream exe (after Chocolatey wrong/hung)

Preferred modules (in order):

1. `chocolatey.chocolatey.win_chocolatey` when package is healthy
2. `ansible.windows.win_get_url` + `ansible.windows.win_package` for pinned Setup.exe
3. Inventory `install_method` on the owning role — never `playbooks/troubleshoot/_tmp_*`

## Prohibited as primary install

- Custom curl/BITS/PowerShell download+install scripts invented mid-thread
- Temp recovery playbooks that bypass the role
- Ad-hoc `choco install` / `pip install` / scp installers
