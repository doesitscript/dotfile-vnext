# hyperv_ubuntu_vm

Stateful role for a Hyper-V-native Ubuntu cloud-image VM on a Windows host.

## Purpose

- keep the public lifecycle state-based: `present|absent`
- use the existing `hyperv_networking` role for host prerequisites and switch ownership
- build a NoCloud `CIDATA` seed ISO from the controller
- convert an Ubuntu cloud image into a VM-owned VHDX on the Windows host
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

- `present` means the VM exists, has a converted boot disk, has a NoCloud seed
  ISO attached, is started, and is published as an SSH target
- `absent` means the VM and its role-owned artifacts are removed and the SSH
  publication is cleared

## Apply / Verify / Undo / Change Class

- Apply: run [server_225_hyperv_ubuntu_vm.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm.yaml) against `execution_nodes,server-225-win`
- Verify: confirm the VM exists in Hyper-V, gets an IPv4 address, accepts SSH, and publishes `server-225-ubuntu` facts
- Undo: rerun with `hyperv_ubuntu_vm_state=absent`
- Change class: bootstrap plus idempotent lifecycle management

## Notes

- Host feature and switch ownership stay with `hyperv_networking`
- Cloud-init is Day-0 bootstrap input; treat major changes as recreate-worthy
- This role intentionally reuses the controller public key and SSH publication
  patterns from the earlier Multipass implementation
