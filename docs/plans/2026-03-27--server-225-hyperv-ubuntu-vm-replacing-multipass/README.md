# Server-225 Hyper-V Ubuntu VM Replacing Multipass

Canonical approved plan for replacing the deprecated Multipass-backed
`server-225-ubuntu` surface with a Hyper-V-native Ubuntu VM on `server-225-win`.

Tracked in GitHub issue [#4](https://github.com/doesitscript/dotfile-vnext/issues/4).

## Summary

Abandon Multipass as the provisioning mechanism for `server-225-ubuntu`.

The repo direction is now:

- keep `server-225-ubuntu` as the inventory host
- retire the existing `multipass_ubuntu_vm` capability through its `absent`
  lifecycle
- replace it with a new Hyper-V-native Ubuntu VM role built around:
  - Ubuntu cloud image
  - VHDX conversion
  - cloud-init ISO
  - External Switch networking
  - SSH publication back into inventory/controller config

## Adapted Repo-Specific Direction

The intake note is already close to the right answer. The main repo-specific
adaptation is sequencing:

1. first checkpoint
   - stop driving Multipass as `present`
   - keep the legacy role and playbooks only as teardown/deprecation paths
   - commit that checkpoint
2. cleanup checkpoint
   - run the legacy `absent` path to remove the old Multipass package/runtime
   - remove active Multipass playbooks, host vars, and troubleshooting
     entrypoints from the repo
   - keep only background evidence and temporary reference material
3. replacement checkpoint
   - introduce a new `hyperv_ubuntu_vm` role instead of rewriting
     `multipass_ubuntu_vm` in place
4. cutover checkpoint
   - switch active server-225 provisioning to the new Hyper-V-native role
   - remove the old Multipass role/playbook once the replacement is proven

## Why This Order

- the repo already has a working `absent` path for the old capability
- using that path first is safer than deleting Multipass surfaces before the
  old VM is intentionally retired
- it gives a clean git checkpoint between deprecation and replacement
- it preserves the reusable cloud-init/bootstrap ideas without pretending the
  old implementation is still the desired direction

## Chosen Replacement Shape

Recommended path:

- new role: `hyperv_ubuntu_vm`
- keep lifecycle state-based:
  - `hyperv_ubuntu_vm_state: present | absent`
- carry forward from `multipass_ubuntu_vm`:
  - cloud-init template pattern
  - SSH key bootstrap pattern
  - SSH publication outcome
  - troubleshooting-mode evidence vocabulary where it still fits

Do not carry forward:

- Multipass MSI install
- `multipass` CLI calls
- Multipass-specific networking probes and diagnostics as part of normal VM
  lifecycle

## Current Checkpoint Scope

The completed cleanup work is still intentionally narrow.

In scope now:

- set the active Multipass control surface to `absent`
- reframe active playbooks/docs as legacy teardown paths
- preserve the old capability only long enough to retire it safely
- commit that state as a durable checkpoint
- run host-side teardown and remove active deprecated Multipass entrypoints
  from the repo

Not in scope for this checkpoint:

- creating the new Hyper-V-native role
- deleting the old Multipass role from the repo
- implementing the new Hyper-V-native role

## Apply / Verify / Undo / Change Class

Apply:
- run the legacy `absent` path to remove Multipass from `server-225-win`
- remove active Multipass playbooks, host vars, and troubleshooting entrypoints
  from the repo

Verify:
- verify the Multipass MSI/runtime is gone from `server-225-win`
- syntax-check touched playbooks
- inspect the active control surfaces to confirm they no longer advertise
  Multipass as a supported path

Undo:
- restore the deleted playbooks/vars/docs from git
- reinstall/recreate Multipass only as a deliberate exception, not as the
  default direction

Change class:
- destructive host teardown plus idempotent repo cleanup
