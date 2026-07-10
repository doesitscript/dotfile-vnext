# Desktop-only bootstrap (WSL)

Scripts here configure **optional WSL on a development Windows desktop**. They are
**not** used for Hyper-V server lanes (`HOM-LAB-HVH-*`, `hom-lab-ctl-dkr-*`,
`hom-lab-ctl-k3s-*`).

| Script | Purpose |
|--------|---------|
| `bootstrap-wsl.ps1` | Install WSL feature + distro; write `*-wsl` host_vars |
| `bootstrap-ansible-local.ps1` | Run `bootstrap-local.sh` inside WSL, then `fz` |
| `bootstrap-local.sh` | OpenSSH inside WSL distro |

**Server Windows bootstrap:** `bin/bootstrap-local.ps1` (WinRM/OpenSSH host_vars only;
`-ConfigureWSL` is opt-in and calls scripts in this folder).

**Connection policy:** [docs/reference/connection-surfaces.md](../../docs/reference/connection-surfaces.md)
