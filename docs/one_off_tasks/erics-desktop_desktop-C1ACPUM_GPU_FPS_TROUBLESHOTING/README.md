# On-offs — troubleshooting setting toggles

Tracks **what was turned on or off** during one-off GPU/FPS (and similar) troubleshooting on specific hosts, plus **evidence collected at each step**.

## Column: **What we got**

In every table in this folder, **What we got** means:

- The **same factual evidence** the agent reported in that column during the troubleshooting thread — not a new summary.
- Typical contents: raw registry values, process names/PIDs, file paths and mtimes, event log excerpts, tool export paths, connectivity probe output.
- **Not** interpretation, recommendations, or “should have” notes — those belong in prose sections outside the column.

If a cell says “not collected,” that means no artifact or probe output exists for that layer at that time.

## Related docs

| Doc | Role |
|-----|------|
| [../DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md](../DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md) | Full narrative, DWM/overlay theory, repo changes |
| [../troubleshoot-gpu-and-ssh-Check desktop reachability.md](../troubleshoot-gpu-and-ssh-Check%20desktop%20reachability.md) | Conversation transcript |
| `artifacts/troubleshooting/` | Pulled AMD exports, dxdiag, scripts |

## Host packets

- [DESKTOP-C1ACPUM-gpu-fps.md](./DESKTOP-C1ACPUM-gpu-fps.md) — `dev-workstation-win` / Eric’s gaming desktop
