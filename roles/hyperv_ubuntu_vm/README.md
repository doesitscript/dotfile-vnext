# hyperv_ubuntu_vm

Stateful role for a Hyper-V-native Ubuntu cloud-image VM on a Windows host.

## Purpose

- keep the public lifecycle state-based: `present|absent`
- use the existing `hyperv_networking` role for host prerequisites and switch ownership
- build an Azure-style `ovf-env.xml` UDF seed image from the controller
- download Canonical's Azure VHD archive, normalize the extracted source VHD,
  and convert it natively into a VM-owned fixed VHDX on the Windows host
- publish the guest back into the reserved inventory identity `server-225-ubuntu`

## Status

New replacement role for the retired Multipass path.

This role is intended to become the supported provisioning direction for
`server-225-ubuntu`, but the broad cutover should happen only after runtime
verification through the dedicated playbook.

## Lifecycle Contract

Primary control point:

```yaml
hyperv_ubuntu_vm_state: present | absent
```

The role treats the VM as one capability:

- `present` means the VM exists, has a converted boot disk, has an Azure-style
  OVF seed image attached, is started, and is published as an SSH target
- `absent` means the VM and its role-owned artifacts are removed and the SSH
  publication is cleared

## Apply / Verify / Undo / Change Class

- Apply: run [server_225_hyperv_ubuntu_vm.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm.yaml) against `execution_nodes,server-225-win`
- Verify: confirm the VM exists in Hyper-V, gets an IPv4 address, accepts SSH, and publishes `server-225-ubuntu` facts
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
- When `hyperv_config.internal_ics_switch_enabled: true`, this role prefers the
  Internal guest switch over the older Wi-Fi-backed External switch path
- In that ICS/Internal-switch topology, the guest's `192.168.137.x` address is
  a valid guest-network address but not automatically a controller-reachable
  `ansible_host` from the Mac-side LAN
- Azure cloud images should be bootstrapped through the Azure datasource path,
  not a NoCloud `CIDATA` seed
- This role intentionally reuses the controller public key and SSH publication
  patterns from the earlier Multipass implementation

Related layout note:

- [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)
