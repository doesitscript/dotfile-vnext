# Pickup Bookmark — Hyper-V Ubuntu VM And Subagents

Durable pickup note for the current place in:

- the `server-225` Hyper-V Ubuntu VM replacement work
- the Codex subagent enablement work

Created because both tracks have meaningful progress that was split across
plans, uncommitted repo changes, and local Codex session history.

## Fast Summary

### Hyper-V Ubuntu VM track

Current state:

- the replacement direction is approved under issue `#4`
- the new dedicated playbook and role exist in the working tree:
  - [server_225_hyperv_ubuntu_vm.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/server_225_hyperv_ubuntu_vm.yaml)
  - [README.md](/Users/joshc/develop/dotfile-vnext/roles/hyperv_ubuntu_vm/README.md)
- host vars already point `hom-lab-ctl-hvh-02` at the new lifecycle surface:
  - [hom-lab-ctl-hvh-02.yaml](/Users/joshc/develop/dotfile-vnext/inventory/host_vars/hom-lab-ctl-hvh-02.yaml)
- the implementation is not committed yet

Latest real blocker:

- the orchestration gets through host networking, cloud-init seed generation,
  image download, `qemu-img` installation, disk conversion, and VM object
  creation
- the remaining blocker is the boot disk artifact path: Hyper-V still rejects
  the converted `.vhdx` with the sparse/compressed limitation even after
  clearing the visible NTFS flags

Canonical evidence:

- [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/README.md)
- [research.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/research.md)
- [evidence--hyperv-live-runs.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/evidence--hyperv-live-runs.md)

### Subagents track

Current state:

- the repo has project-scoped Codex subagent config in:
  - [config.toml](/Users/joshc/develop/dotfile-vnext/.codex/config.toml)
- configured roles already exist:
  - [default.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/default.toml)
  - [explorer.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/explorer.toml)
  - [worker.toml](/Users/joshc/develop/dotfile-vnext/.codex/agents/worker.toml)
- `Subagents v1` is approved under issue `#10`
- there was real runtime validation of an `explorer` subagent spawn, but that
  evidence originally lived only in local session history

What was missing from visible repo state:

- the home config [config.toml](/Users/joshc/.codex/config.toml) does not show
  the project role mappings
- the real role mapping lives in the project config
- there was no repo-stored runtime evidence artifact yet

Canonical subagent references:

- [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--subagents-v1/README.md)
- [research.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--subagents-v1/research.md)
- [evidence--runtime-validation.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--subagents-v1/evidence--runtime-validation.md)

## Current Honest Status

### Hyper-V Ubuntu VM

Implemented enough to count as real progress:

- approved replacement plan exists
- dedicated control surface exists
- replacement role skeleton and lifecycle paths exist
- host vars have been redirected to the new VM lifecycle
- first end-to-end run produced concrete runtime evidence

Not done yet:

- source-backed fix for the Hyper-V disk artifact problem
- successful boot, IP publication, and SSH verification for `server-225-ubuntu`
- commit of the current working-tree changes

### Subagents

Implemented enough to count as real progress:

- project-scoped multi-agent support is enabled
- `default` / `explorer` / `worker` are mapped in repo config
- one real `explorer` subagent spawn was validated at runtime

Not done yet:

- `critic` agent file
- rule/doc cleanup for the persona-first conflict
- repo-level workflow checkpointing around `critic`
- broader proof that subagents are part of normal workflow rather than a single
  validated example

## Next Recommended Move

### Hyper-V Ubuntu VM

Do next:

- keep using the dedicated playbook only
- stop blind retries on the current `qemu-img -> vhdx` disk path
- do a source-backed research pass on a Hyper-V-compatible Ubuntu cloud-image
  disk creation/import path for Windows
- rerun only after that disk strategy changes

Do not do next:

- cut this into the broad `provision_server_225.yaml` path yet
- delete legacy reference material before replacement verification succeeds

### Subagents

Do next:

- keep the current validated mapping
- add the planned `critic` agent as the first custom role
- resolve the conflict with
  [framework-agent-role-and-persona.mdc](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-agent-role-and-persona.mdc)
- then run one bounded `explorer + critic` validation and store that result in
  the repo

Do not claim yet:

- that the repo is fully multi-agent
- that `Subagents v1` is complete
- that agent spawning is automatic in ordinary repo work

## Resume Order

If picking this work back up later, open in this order:

1. [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--pickup-bookmark-hyperv-and-subagents/README.md)
2. [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/README.md)
3. [evidence--hyperv-live-runs.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/evidence--hyperv-live-runs.md)
4. [README.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--subagents-v1/README.md)
5. [evidence--runtime-validation.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--subagents-v1/evidence--runtime-validation.md)
6. [config.toml](/Users/joshc/develop/dotfile-vnext/.codex/config.toml)

## Change Class

This bookmark is documentation only.

- Apply: add durable pickup notes
- Verify: confirm the referenced files and local session evidence exist
- Undo: remove these notes from git
- Change class: idempotent repo documentation
