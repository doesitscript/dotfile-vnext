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
2. second checkpoint
   - introduce a new `hyperv_ubuntu_vm` role instead of rewriting
     `multipass_ubuntu_vm` in place
3. third checkpoint
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

## First Checkpoint Scope

This checkpoint is intentionally narrow.

In scope now:

- set the active Multipass control surface to `absent`
- reframe active playbooks/docs as legacy teardown paths
- preserve the old capability only long enough to retire it safely
- commit that state as a durable checkpoint

Not in scope for this checkpoint:

- creating the new Hyper-V-native role
- running remote teardown without explicit user confirmation
- deleting the old Multipass role from the repo

## Apply / Verify / Undo / Change Class

Apply:
- update host vars, inventory comments, and active playbook/role docs so the
  repo drives the legacy Multipass path to `absent`

Verify:
- syntax-check touched playbooks
- inspect the active control surfaces to confirm they now describe deprecation
  instead of active provisioning

Undo:
- restore `multipass_ubuntu_vm_state: present`
- revert the doc/playbook comment changes

Change class:
- idempotent repo/config change for this checkpoint
- real host cleanup later will be destructive/teardown execution
