# hyperv_ubuntu_vm

Stateful role for a Hyper-V-native Ubuntu VM on a Windows host.

## Purpose

- keep the public lifecycle state-based: `present|absent`
- use the existing `hyperv_networking` role for host prerequisites and switch ownership
- support multiple image source modes behind the same lifecycle surface
- current source modes:
  - `azure_cloud_image`
  - `quick_create_desktop`
  - `server_iso_installer`
- build a NoCloud `CIDATA` seed image from the controller only for the
  `azure_cloud_image` path
- optionally seed Azure cloud-image root filesystems offline before first
  Hyper-V boot when NoCloud handoff is not enough; server lanes must not use
  `wsl.exe --mount` (see `hyperv_ubuntu_vm_cloud_image_offline_seed_mount_provider`)
- download Canonical's published source artifact and reconcile it into a
  role-owned VHDX on the Windows host
- publish the guest back into the configured Ubuntu inventory identity

## Status

New replacement role for the retired Multipass path.

This role is the reusable Hyper-V Ubuntu VM primitive. Capability-specific
playbooks such as Docker or future k3s VM orchestration map their public
variables into this role.

Current active direction:

- the Azure cloud-image path remains preserved in the role as researched work,
  but it is no longer the only candidate
- the Canonical Hyper-V Quick Create VHDX path is now preserved as a validated
  Hyper-V-native fallback/checkpoint
- the official Ubuntu Server ISO installer path is the active implementation
  target because it is aligned with the eventual SSH/Docker server target

## Lifecycle Contract

Primary control point:

```yaml
hyperv_ubuntu_vm_state: present | absent
```

The role treats the VM as one capability:

- `present` means the VM exists, has a role-owned boot disk, is started, and
  follows the selected source-mode behavior
- `absent` means the VM and its role-owned artifacts are removed and the SSH
  publication is cleared

## Apply / Verify / Undo / Change Class

- Apply Docker VM orchestration through [hyperv_ubuntu_docker_vm.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_ubuntu_docker_vm.yaml)
- Future VM classes should add their own playbook-level lifecycle contract and
  map into this generic role at include time
- Verify: confirm the VM exists in Hyper-V, gets an IPv4 address, and accepts
  the verification expected by the selected source mode
- Undo: rerun with `hyperv_ubuntu_vm_state=absent`
- Change class: bootstrap plus idempotent lifecycle management

## Existing K3s VM Storage Relocation

Use the dedicated relocation playbook after declaring
`hyperv_ubuntu_k3s_vm_host_vhdx_path` in the owning Hyper-V host inventory.
The playbook previews the exact source, destination, free space, VM state, and
checkpoint count before it requests a graceful guest shutdown.

```bash
# Preview without shutting down or moving the VM
ansible-playbook playbooks/hyperv_move_k3s_vm_storage.yaml \
  -i inventory/inventory.yaml --limit hom-lab-ctl-hvh-02 --check

# Apply the controlled-outage move
ansible-playbook playbooks/hyperv_move_k3s_vm_storage.yaml \
  -i inventory/inventory.yaml --limit hom-lab-ctl-hvh-02
```

- Verify: rerun the preview and confirm `source == destination`; verify the
  guest is reachable and its workloads are healthy.
- Undo: declare the previous internal-disk VHDX path, verify that destination
  has enough free space, and run the same controlled-outage playbook.
- Change class: idempotent desired-state check plus controlled-outage storage
  relocation.
- Never target an external USB backup disk for an active VM VHDX.

## Troubleshooting controls

Standard variables:

```yaml
ansible_troubleshooting_mode: false
debug_remote_output: false
debug_collect_component_evidence: false
```

Useful tags:

- `evidence`
- `debug_resources`

When troubleshooting mode or debug evidence collection is enabled, the role
emits:

- the primary output locations before the start path runs
- VHD and filesystem attribute probes for the boot disk
- Hyper-V VM, disk-attachment, and firmware probes around the start path
- a troubleshooting report with identified, collected, and missing evidence
  surfaces
- the full structured diagnostics block for the current failure

Reference diagnostics note:

- [hyperv-ubuntu-vm--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--diagnostics.md)
- [hyperv-ubuntu-vm--windows--lessons-learned.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--lessons-learned.md)

Dedicated saved-artifact playbook:

- [collect_hyperv_ubuntu_vm_artifacts.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/troubleshoot/collect_hyperv_ubuntu_vm_artifacts.yaml)

## Notes

- Host feature and switch ownership stay with `hyperv_networking`
- Active VM workload disks should use a dedicated internal SSD when one is
  available. Do not place active VHDXs on external USB backup disks.
- Keep the Windows system disk focused on Windows and host tooling. A K3s guest
  that stores its OS, containerd data, and persistent volumes in one VHDX can
  transfer a database I/O storm directly into Windows when that VHDX is on
  `C:`.
- Override `hyperv_ubuntu_vm_host_vhdx_path` from the capability-specific
  wrapper inventory to place a VM boot VHDX on the intended internal workload
  disk. Moving an existing VHDX is a controlled-outage operation and must be
  previewed and performed separately before converging the new path. Use
  [hyperv_move_k3s_vm_storage.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/hyperv_move_k3s_vm_storage.yaml)
  for the K3s VM relocation workflow.
- `absent` now preserves cached source artifacts such as downloaded ISOs and
  Quick Create archives under the host root directory so repeated loops do not
  redownload large files unnecessarily
- When `hyperv_config.internal_ics_switch_enabled: true`, this role prefers the
  configured guest switch over the older Wi-Fi-backed External switch path
- Linux guests default to Secure Boot disabled unless inventory opts in. That
  matches the current lab evidence and avoids restarting a healthy VM to chase
  a Hyper-V firmware state that does not persist on the Azure image path.
- In routed-private-subnet mode, this role expects:
  - the Windows host to prove it can reach guest SSH first
  - the controller-side route role to make the guest private subnet reachable
    from `mac-dev` before direct guest routing is expected
- The default first-boot payload is intentionally minimal:
  - reuse the image's built-in cloud-init, Python, and OpenSSH baseline
  - inject the controller key
  - apply installer-side package updates through the supported autoinstall
    `updates` setting
  - normalize the GRUB console line to `console=tty1` so VMConnect shows real
    boot progress instead of appearing frozen behind `ttyS0`
  - prove baseline SSH reachability before layering extra package work
- Current source-mode intent:
  - `azure_cloud_image`
    - keep as the cloud-image/bootstrap research path
    - now supports the same static guest-network contract used by the
      installer path, rendered through cloud-init when
      `hyperv_ubuntu_vm_autoinstall_network_method: static`
    - can apply an idempotent offline seed to the VHDX rootfs when
      `hyperv_ubuntu_vm_cloud_image_offline_seed_enabled: true`
    - mount provider `wsl` uses legacy `wsl.exe --mount` (desktop/bootstrap only);
      server Hyper-V lanes must keep the default `disabled` or use
      `linux_openssh_delegate` once implemented
    - the offline seed writes the bootstrap user, controller SSH key, static
      netplan config, hostname, passwordless sudo for automation, and SSH
      service enablement directly into the image
    - the offline seed uses a Windows-side signature file and only stops/mounts
      the VM when those seed inputs change
    - still publishes the seed media for compatibility, but the offline seed is
      the deterministic bootstrap source for Azure images in this lab
  - `quick_create_desktop`
    - keep as a validated Hyper-V-native bootability checkpoint
    - validate the archive with a HEAD probe plus `SHA256SUMS` and download it
      through a BITS-backed path so large transfers stay observable and
      checksum-backed
    - treat it as a console-first desktop fallback unless
      `hyperv_ubuntu_vm_publish_connection_facts: true` is explicitly set
  - `server_iso_installer`
    - use the official Ubuntu Server ISO as the active server-aligned target
    - validate the ISO with a HEAD probe plus `SHA256SUMS` and download it
      through a BITS-backed path on Windows
    - create a blank role-owned VM disk, attach the installer ISO, and boot the
      VM into the installer
    - remaster the installer path for autoinstall and attach a `cidata` seed
    - keep the ISO-root `autoinstall.yaml` handoff aligned with Ubuntu
      installer docs by using the `autoinstall` kernel argument and an explicit
      installation-system-relative `subiquity.autoinstallpath=cdrom/autoinstall.yaml`
      pointer
    - render the ISO-root `autoinstall.yaml` in direct installation-media
      format while keeping the attached `cidata` seed in cloud-config format
    - patch the Hyper-V UEFI boot image to source an ESP-local GRUB config that
      searches for the ISO root before loading the autoinstall menu
    - routed-subnet guest target comes from inventory host variables
    - current milestone:
      - guest static IP `192.168.137.10/24` is proven
      - host/controller SSH reachability is proven
      - the configured Ubuntu guest SSH surface is active
      - package update behavior is now part of the autoinstall bootstrap path

Current verification commands:

- Windows host:
  - `Get-VM -Name hom-lab-ctl-dkr-02 | Select-Object Name,State,Status,Uptime`
  - `Get-VMDvdDrive -VMName hom-lab-ctl-dkr-02`
  - `Test-Connection 192.168.137.10 -Count 1`
  - `Test-NetConnection -ComputerName 192.168.137.10 -Port 22`
- Mac/controller:
  - `route -n get 192.168.137.10`
  - `nc -vz -G 2 192.168.137.10 22`
  - `ssh -i ~/.ssh/id_ed25519_ansible -o IdentitiesOnly=yes joshc@192.168.137.10`
- Guest console:
  - `ip -br addr`
  - `ip route`
  - `systemctl is-active ssh`
  - `ss -ltnp | grep ':22'`
- This role intentionally reuses the controller public key and SSH publication
  patterns from the earlier Multipass implementation

Related layout note:

- [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)
