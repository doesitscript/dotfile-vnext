# Intake: Hyper-V Ubuntu VM (Docker Host) — Replacing Multipass

**Date:** 2026-03-26
**Source:** ChatGPT conversation (docs/brainstorming_designs/hyper-v-full-vm-calassical-implementation.md)
**Repo target:** `server-225-ubuntu` in `linux_vm_hosts`
**Replaces:** `multipass_ubuntu_vm` role and its dependency on Multipass MSI

---

## Decision

Abandon Multipass as the VM provisioning mechanism for `server-225-ubuntu`.

### Why Multipass fails on this host

Multipass on Windows Server 2025 expects the Windows 10 `Default Switch` networking
surface. Windows Server 2025 does not expose that surface. The result is that
`multipass networks` reports `The Hyper-V Hypervisor is disabled` even when all
Hyper-V features are enabled and `HypervisorPresent` is true. This is a host
compatibility gap, not a configuration error.

Evidence in repo:

- `roles/multipass_ubuntu_vm/README.md` — "Multipass on Windows Server is not
  currently supported in the same way as Windows 10 because the Windows Server
  Hyper-V networking surface does not provide the Windows 10 Default Switch
  Multipass expects."
- `docs/diagnostics/multipass--windows--diagnostics.md`

The replacement does not require any new networking infrastructure.
`hyperv_networking` already creates the External Switch that the new VM will
attach to. That is the only prerequisite.

---

## What "External Switch" means in Hyper-V terms

External Switch is Hyper-V's implementation of bridged networking. It is not
Windows Network Bridge (the Control Panel adapter bridge). Do not use Windows
Network Bridge — that path breaks host connectivity. When `hyperv_networking`
creates an External Switch, the VM NIC attached to it receives a real LAN IP
from your router, appears on the same subnet as the host, and is reachable from
other devices without NAT or port forwarding. This is the correct networking
surface for a VM that will host Docker workloads and be managed by Ansible.

---

## Replacement approach

Replace Multipass with a Hyper-V Generation 2 VM built from an Ubuntu cloud image,
using cloud-init for Day-0 bootstrap. This aligns with how real cloud and bare-metal
Ubuntu VMs are built, gives clean networking, and maps directly to an Ansible-driven
lifecycle.

### VM specifications

| Setting | Value |
|---|---|
| Generation | 2 |
| vCPU | 2 minimum |
| RAM | 8 GB |
| Disk | 40–60 GB VHDX |
| Network | External Switch (created by `hyperv_networking`) |
| OS | Ubuntu Server 24.04 LTS |
| User | `ubuntu` (cloud image default) |
| Bootstrap | cloud-init (SSH key injection, hostname, packages) |

### Image source

Ubuntu cloud images (official):
`https://cloud-images.ubuntu.com/`

Direct 24.04 LTS example:
`https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img`

Or 22.04 LTS:
`https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img`

### Image conversion (cloud image to VHDX)

The `.img` file is not directly usable in Hyper-V. It must be converted to VHDX
before attaching to a VM. This is done with `qemu-img`, which can be installed
via Chocolatey on the Windows host, or the conversion can be scripted via
`win_powershell` in the new role.

```powershell
qemu-img convert -O vhdx noble-server-cloudimg-amd64.img ubuntu-noble.vhdx
```

The resulting VHDX is the boot disk for the VM. It is not a template — it is the
actual disk for one instance. For multiple VMs, either download fresh or convert
a new copy.

### cloud-init delivery

The cloud image reads cloud-init configuration from a small ISO file attached as
a second virtual DVD drive. The ISO contains two files:

- `meta-data` — instance-id and hostname
- `user-data` — SSH authorized keys, packages, initial setup commands

This ISO is created on the Windows host (from the controller, via WinRM) and
attached when the VM is created. After first boot, cloud-init runs once and
configures the guest. The role already has a Jinja2 template for `user-data`
at `roles/multipass_ubuntu_vm/templates/cloud-init-user-data.yaml.j2` — this
template is reusable as-is or with minor adjustments.

Reference: `https://cloudinit.readthedocs.io/en/latest/`

---

## Repo implementation plan

### Option A — New role `hyperv_ubuntu_vm`

Create a new role that owns the full lifecycle for a Hyper-V-native Ubuntu VM:
download image, convert to VHDX, build cloud-init ISO, create VM, attach disk
and ISO, boot, wait for SSH, publish SSH target.

This is the cleanest path. It removes all Multipass dependency and is fully
idempotent over `hyperv_ubuntu_vm_state: present | absent`.

**Lifecycle control point:**
```yaml
hyperv_ubuntu_vm_state: present | absent
```

### Option B — Rename and rewrite `multipass_ubuntu_vm`

Keep the same role name, strip all Multipass-specific logic, replace with
Hyper-V native VM management. The public interface (state, VM name, cloud-init
vars, SSH publishing) stays the same. The implementation switches entirely to
`win_powershell` + Hyper-V module calls.

This is simpler in terms of inventory/playbook changes but muddles the role's
stated purpose.

**Recommended: Option A.** Name the new role `hyperv_ubuntu_vm`. Deprecate
`multipass_ubuntu_vm` and remove it once the new role is proven.

---

## What carries forward from `multipass_ubuntu_vm`

- `lifecycle contract` — `state: present | absent` with the same variables
- `cloud-init template` — `roles/multipass_ubuntu_vm/templates/cloud-init-user-data.yaml.j2`
  reusable with the new role
- `SSH key injection` — same pattern: controller key bootstrapped into the guest
  via cloud-init `authorized_keys`
- `SSH publishing` — same outcome: VM published as a real SSH target reachable
  from inventory as `server-225-ubuntu`
- `troubleshooting controls` — `ansible_troubleshooting_mode`, `debug_remote_output`,
  `debug_collect_component_evidence` variables and evidence tag pattern
- `immutable bootstrap principle` — cloud-init is Day-0 only; treat as recreate-worthy
  if bootstrap config changes

---

## What does NOT carry forward

- Multipass MSI install
- `multipass launch`, `multipass stop`, `multipass delete` commands
- `multipass networks` probe and bridged-network workaround logic
- Multipass Event Viewer diagnostics surface
- Any `win_powershell` blocks calling the `multipass` CLI

---

## Inventory impact

No inventory changes required. `server-225-ubuntu` stays in `linux_vm_hosts`.
The host moves from being Multipass-backed to being Hyper-V VM-backed. The
inventory hostname, SSH config, and group membership are unchanged.

```yaml
linux_vm_hosts:
  hosts:
    server-225-ubuntu:
      # Now: Hyper-V Gen 2 VM on server-225 (replaces Multipass)
```

---

## Prerequisites (already satisfied)

- `hyperv_networking` role — External Switch already exists on `server-225-win`
- Controller SSH key — already in `~/.ssh/id_ed25519_ansible`
- Ansible WinRM connection to `server-225-win` — already working

---

## Prerequisites (new, needed in new role)

- `qemu-img` on Windows host — for `.img` → `.vhdx` conversion
  OR: download a pre-converted VHDX directly (Ubuntu does not provide these;
  conversion is the standard path)
- `mkisofs` or `oscdimg` — for building the cloud-init ISO on the Windows host
  (`oscdimg` is available in Windows ADK; `mkisofs` via Chocolatey)

---

## Reference links

| Resource | URL |
|---|---|
| Ubuntu cloud images index | https://cloud-images.ubuntu.com/ |
| cloud-init documentation | https://cloudinit.readthedocs.io/en/latest/ |
| Microsoft: Linux on Hyper-V | https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-linux-and-freebsd-virtual-machines-for-hyper-v-on-windows |
| Microsoft: supported Ubuntu on Hyper-V | https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/supported-ubuntu-virtual-machines-on-hyper-v |
| Microsoft: create a Hyper-V VM | https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/get-started/create-a-virtual-machine-in-hyper-v |
| Microsoft: Hyper-V networking | https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-hyper-v-networking-in-windows-server |

---

## Change contract

| Field | Value |
|---|---|
| Apply | `win_powershell` tasks on `server-225-win` via WinRM: download image, convert to VHDX, build cloud-init ISO, `New-VM`, attach disks, `Start-VM`, wait for SSH |
| Verify | SSH to `server-225-ubuntu` from `mac-dev`; `kubectl`/`docker` command if those are installed via cloud-init |
| Undo | `Remove-VM` + delete VHDX and cloud-init ISO artifacts from Windows host |
| Change class | Bootstrap for VM creation; idempotent config for cloud-init content and SSH publishing |
| Lifecycle control | `hyperv_ubuntu_vm_state: present \| absent` |
