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
- `absent` now preserves cached source artifacts such as downloaded ISOs and
  Quick Create archives under the host root directory so repeated loops do not
  redownload large files unnecessarily
- When `hyperv_config.internal_ics_switch_enabled: true`, this role prefers the
  configured guest switch over the older Wi-Fi-backed External switch path
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
    - still expects seed media and SSH publication
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
      installer docs by using the `autoinstall` kernel argument without forcing
      a leading-slash `subiquity.autoinstallpath`
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
  - `Get-VM -Name server-225-ubuntu | Select-Object Name,State,Status,Uptime`
  - `Get-VMDvdDrive -VMName server-225-ubuntu`
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
