---
name: capture-wsl-systemctl
description: Captures systemctl diagnostics from a WSL Ubuntu distro over SSH and saves to logs/wsl-systemctl/ with a timestamped filename. Use when the user asks to capture, collect, or log systemctl output from WSL, or when diagnosing WSL service state.
---

# Capture WSL systemctl Output

Collects systemctl diagnostics from a WSL distro via SSH and writes a timestamped log
to `logs/wsl-systemctl/` in the project root.

## What gets captured

- `systemctl status` — top-level system state
- `systemctl list-units --type=service --all` — all services
- `systemctl list-units --failed` — failed units
- `systemctl status keepwsl.service` — keepalive service state
- `journalctl -b -n 150` — last 150 lines from current boot

## Steps

1. Determine the SSH target. Default is `server-225-wsl` (resolves via `~/.ssh/config`
   to the Ubuntu WSL distro on DESKTOP-VLLM). If the user specifies a different host,
   use that instead.

2. Build the output filename:
   ```
   TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
   OUT="logs/wsl-systemctl/${TIMESTAMP}_<ssh_target>.log"
   ```

3. Run the collector script from the project root:
   ```bash
   cd /Users/joshc/develop/dotfile-vnext
   bash .cursor/skills/capture-wsl-systemctl/scripts/collect.sh server-225-wsl "${OUT}"
   ```

4. Report the written path and any `FAILED` units found in the output.
   Highlight `keepwsl.service` state explicitly.

## SSH alias reference

| Alias              | Port | Lands in         | Use for                        |
|--------------------|------|------------------|--------------------------------|
| `server-225-wsl`   | 22   | WSL bash (Ubuntu) | systemctl — use this           |
| `HOM-LAB-HVH-02`   | 2222 | WSL bash (Ubuntu) | same, alternate name           |
| `HOM-LAB-HVH-02-powershell` | 2223 | PowerShell  | Windows-only tasks  |

Both `server-225-wsl` and `HOM-LAB-HVH-02` connect to port 2222 on DESKTOP-VLLM and
land directly in WSL bash — no `wsl` wrapper needed, run `systemctl` directly.

**Requires WSL to be running.** If WSL is down, re-deploy keepwsl.service:
```
ansible-playbook playbooks/access_windows.yaml --limit HOM-LAB-HVH-02 --tags wsl
```

## Output location

```
logs/wsl-systemctl/YYYYMMDD_HHMMSS_<host>.log
```

Example: `logs/wsl-systemctl/20260310_143022_server-225-wsl.log`
