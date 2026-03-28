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
- publish the guest back into the reserved inventory identity `server-225-ubuntu`

## Status

New replacement role for the retired Multipass path.

This role is intended to become the supported provisioning direction for
`server-225-ubuntu`, but the broad cutover should happen only after runtime
verification through the dedicated playbook.

Current pivot:

- the Azure cloud-image path remains preserved in the role as researched work,
  but it is no longer the only candidate
- the Canonical Hyper-V Quick Create VHDX path is now preserved as a validated
  Hyper-V-native fallback/checkpoint
- the next active target is the official Ubuntu Server ISO installer path
  because it is better aligned with the eventual SSH/Docker server target

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

- Apply: run [server_225_hyperv_ubuntu_vm.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm.yaml) against `execution_nodes,server-225-win`
- Faster iterative apply: run [server_225_hyperv_ubuntu_vm_lifecycle_only.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm_lifecycle_only.yaml) when controller identity, host networking, and controller routing are already converged
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
    from `mac-dev` before the guest IP is published as `ansible_host`
- The default first-boot payload is intentionally minimal:
  - reuse the image's built-in cloud-init, Python, and OpenSSH baseline
  - inject the controller key
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
    - use the official Ubuntu Server ISO as the active next server-aligned
      target
    - validate the ISO with a HEAD probe plus `SHA256SUMS` and download it
      through a BITS-backed path on Windows
    - create a blank role-owned VM disk, attach the installer ISO, and boot the
      VM into the installer
    - remaster the installer path for autoinstall and attach a `cidata` seed
    - current routed-subnet guest target:
      - `192.168.137.10/24`
      - gateway `192.168.137.1`
    - current milestone:
      - host ping and host/controller `22/tcp` reachability are proven
      - remaining blocker is SSH authentication acceptance, not guest-network
        reachability

Current verification commands:

- Windows host:
  - `Get-VM -Name server-225-ubuntu | Select-Object Name,State,Status,Uptime`
  - `Get-VMDvdDrive -VMName server-225-ubuntu`
  - `Test-Connection 192.168.137.10 -Count 1`
  - `Test-NetConnection -ComputerName 192.168.137.10 -Port 22`
- Mac/controller:
  - `route -n get 192.168.137.10`
  - `nc -vz -G 2 192.168.137.10 22`
  - `ssh -i ~/.ssh/id_ed25519_ansible -o IdentitiesOnly=yes ubuntu@192.168.137.10`
- Guest console:
  - `ip -br addr`
  - `ip route`
  - `systemctl is-active ssh`
  - `ss -ltnp | grep ':22'`
- This role intentionally reuses the controller public key and SSH publication
  patterns from the earlier Multipass implementation

Related layout note:

- [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)
