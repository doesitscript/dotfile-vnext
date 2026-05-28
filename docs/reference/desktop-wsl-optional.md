# Desktop WSL — optional, not server automation

WSL may exist on a **development Windows desktop** (e.g. gaming PC). This repo does **not** model server or Hyper-V lane work through WSL.

## When WSL is acceptable

- Operator chooses to run Git/Ansible **from inside WSL on their own desktop** for convenience
- Desktop diagnostics (e.g. `.cursor/skills/capture-wsl-systemctl` on a commissioned dev machine)
- Explicit **desktop bootstrap** with `mount_provider: wsl` on `hyperv_ubuntu_vm` cloud-image offline seed — opt-in only, not server default

## When WSL is wrong

- Reaching `hom-lab-ctl-hvh-02`, `hom-lab-ctl-dkr-02`, or `hom-lab-ctl-k3s-02` automation targets
- Substituting `wsl.exe` for OpenSSH to a Windows host or SSH to a Hyper-V guest
- Inventory groups or hostnames implying `*-wsl` are the production Linux surface

## Useful desktop tips (consolidated)

| Topic | Guidance |
|-------|----------|
| Idle shutdown | WSL 2.x may stop when no `wsl.exe` holds the VM; use keepalive or `vmIdleTimeout=-1` on desktops that need persistent Docker — see archived lesson `docs/archive/wsl-deprecating/` if migrated |
| `.wslconfig` | CRLF breaks parsing; use LF-only; treat as **user policy** on desktop, not Ansible-managed on servers |
| UTF-8 from PowerShell | If a desktop bootstrap script calls `wsl.exe`, set `WSL_UTF8=1` in the task environment |
| Docker context | Prefer explicit SSH to a defined engine host per [connection-surfaces.md](connection-surfaces.md), not a stale `server-225-wsl` context name |

## Server path (use instead)

[connection-surfaces.md](connection-surfaces.md) — OpenSSH on Windows control IP, SSH to `linux_vm_hosts`, portproxy on hvh-02 for LAN services.
