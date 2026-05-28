# Connection surfaces by node

**Authority for automation:** `inventory/hosts_mapping.yaml` → `ansible_surfaces` and matching `inventory/host_vars/<inventory_hostname>.yaml`.

Agents must **not** assume WSL, `wsl.exe`, `bash.exe`, or `*-wsl` inventory names. Use the **primary_connection** (and optional **secondary_connection**) defined for each inventory hostname.

## Rules

1. **Read the surface before connecting** — `primary_connection` is what steady-state Ansible and SSH should use.
2. **WinRM is secondary** on Windows control hosts — bootstrap and troubleshooting unless the play explicitly targets WinRM.
3. **Linux workloads on Hyper-V** use `linux_vm_hosts` (SSH to guest IP, often `192.168.137.x`), not a WSL distro on the Windows host.
4. **Desktop-only optional WSL** — see [desktop-wsl-optional.md](desktop-wsl-optional.md). Never use WSL to reach server lanes (`hom-lab-ctl-hvh-*`, `hom-lab-ctl-dkr-*`, `hom-lab-ctl-k3s-*`).

## Active homelab surfaces (summary)

| inventory_hostname | primary_connection | Typical target | Notes |
|------------------|-------------------|----------------|-------|
| `mac-dev` | local | Joshs-MBP | Ansible controller / execution node |
| `hom-lab-ctl-hvh-02` | ssh | `192.168.50.158` | Windows OpenSSH; WinRM secondary |
| `hom-lab-ctl-hvh-01` | ssh | `192.168.50.234` | Storage lane Windows |
| `hom-lab-ctl-dkr-02` | ssh | guest `.137.10` | Hyper-V Ubuntu VM; ProxyJump via hvh-02 if needed |
| `hom-lab-ctl-k3s-02` | ssh | guest `.137.11` | K3s VM |
| `dev-3090-win` | (deferred) | — | Interactive desktop; not in default deploy scope |

Full fields: `inventory/hosts_mapping.yaml`.

## Controller SSH aliases

Prefer inventory hostname in `~/.ssh/config` (e.g. `hom-lab-ctl-hvh-02`), with `HostName` set to **ansible_connect_target** from hosts_mapping — not legacy NetBIOS names that fail DNS from the Mac.

## Historical WSL-centric docs

Plans and narratives that assumed `server-225-wsl` / WSL bridge automation are archived under `docs/archive/wsl-deprecating/`.
