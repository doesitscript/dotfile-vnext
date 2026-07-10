# Connection surfaces by node

**Authority for automation:** `inventory/hosts_mapping.yaml` → `ansible_surfaces` and matching `inventory/host_vars/<inventory_hostname>.yaml`.

Agents must **not** assume WSL, `wsl.exe`, `bash.exe`, or `*-wsl` inventory names. Use the **primary_connection** (and optional **secondary_connection**) defined for each inventory hostname.

## Rules

1. **Read the surface before connecting** — `primary_connection` is what steady-state Ansible and SSH should use.
2. **WinRM is secondary** on Windows control hosts — use SSH first for steady-state work, but `playbooks/access_windows_best_effort.yaml` must automatically fall back to the already-enabled WinRM/PowerShell remoting surface on that same host when SSH is unavailable.
3. **Linux workloads on Hyper-V** use `linux_vm_hosts` (SSH to guest IP, often `192.168.137.x`), not a WSL distro on the Windows host.
4. **Desktop-only optional WSL** — see [desktop-wsl-optional.md](desktop-wsl-optional.md). Never use WSL to reach server lanes (`HOM-LAB-HVH-*`, `hom-lab-ctl-dkr-*`, `hom-lab-ctl-k3s-*`).
5. **WinRM fallback is transport-only** for `access_windows_best_effort.yaml` — this means use existing PowerShell remoting when SSH is down, not a bootstrap script or first-touch machine-setup path.

## Active homelab surfaces (summary)

| inventory_hostname | primary_connection | Typical target | Notes |
|------------------|-------------------|----------------|-------|
| `mac-dev` | local | Joshs-MBP | Ansible controller / execution node |
| `HOM-LAB-HVH-02` | ssh | `192.168.50.158` | Windows OpenSSH; WinRM secondary |
| `HOM-LAB-HVH-02-guest-gw` | ssh | `192.168.137.1` | Guest-switch gateway fallback when LAN SSH is refused |
| `HOM-LAB-HVH-02-ipv6` | ssh | ULA (see hosts_mapping) | IPv6 fallback when IPv4 path fails |
| `HOM-LAB-HVH-01` | ssh | `192.168.50.234` | Storage lane Windows |
| `hom-lab-ctl-dkr-02` | ssh | guest `.137.10` | Hyper-V Ubuntu VM; ProxyJump via hvh-02 if needed |
| `hom-lab-ctl-k3s-02` | ssh | guest `.137.11` | K3s VM |
| `dev-3090-win` | (deferred) | — | Interactive desktop; not in default deploy scope |

Full fields: `inventory/hosts_mapping.yaml`.

## Controller SSH aliases

Prefer inventory hostname in `~/.ssh/config` (e.g. `HOM-LAB-HVH-02`), with `HostName` set to **ansible_connect_target** from hosts_mapping — not legacy NetBIOS names that fail DNS from the Mac.

## Service Publication Preference

For storage-lane runtime services that are meant to be consumed across the LAN,
the canonical client path is the Windows-published surface on
`HOM-LAB-HVH-01` (`192.168.50.234`), not the guest-direct `192.168.138.x`
address. The active shared contract lives in
`inventory/group_vars/all/fuzlang_external_services.yml`, and the publication
mechanism lives in `inventory/host_vars/HOM-LAB-HVH-01.yaml` under
`hyperv_config.guest_published_tcp_ports`.

Use guest-direct `192.168.138.x` only for controller/host management, guest
maintenance, or an explicitly chosen exception.

## Historical WSL-centric docs

Plans and narratives that assumed `server-225-wsl` / WSL bridge automation are archived under `docs/archive/wsl-deprecating/`.
