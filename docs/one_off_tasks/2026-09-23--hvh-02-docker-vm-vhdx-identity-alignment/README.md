---
title: "HVH-02 Docker VM VHDX identity alignment"
status: reconciled
authority: operator
retrieved_at: "2026-09-23"
last_reviewed_at: "2026-09-23"
---

# HOM-LAB-HVH-02 Docker VM VHDX identity alignment

## Request and authority

The user asked to finish the leftover identity migration for
`hom-lab-ctl-dkr-02`: rename the live VHDX (and sidecars) still named
`server-225-ubuntu.*` to the canonical basename.

## Scope

- Hyper-V VM name was already `hom-lab-ctl-dkr-02`.
- Move/repoint attached VHDX:
  `...\hom-lab-ctl-dkr-02\server-225-ubuntu.vhdx`
  → `...\hom-lab-ctl-dkr-02\hom-lab-ctl-dkr-02.vhdx`
- Rename leftover `server-225-ubuntu-cidata.iso` and
  `server-225-ubuntu-state.json` to the canonical basenames.
- Update inventory `hyperv_ubuntu_docker_vm_host_vhdx_path` after live
  convergence; clear `hyperv_ubuntu_docker_vm_legacy_hyperv_name`.
- Remove leftover empty-ish legacy config tree
  `D:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\`.
- Brief controlled outage (VM Off while the VHDX is moved).

## Apply / Verify / Undo / Change class

- Apply:
  `ansible-playbook playbooks/troubleshoot/align_hom_lab_ctl_dkr_02_identity.yaml -i inventory/inventory.yaml -e hyperv_identity_alignment_apply=true`
- Verify: playbook asserts no legacy VM, running canonical VM, and canonical
  VHDX path; guest hostname `hom-lab-ctl-dkr-02`.
- Undo: stop VM, reverse VHDX/sidecar names, repoint disk, update inventory
  back (manual same-window recovery).
- Change class: controlled-outage migration.

## Preflight evidence

2026-09-23 read-only probe:

- `hom-lab-ctl-dkr-02`: exists, `Running`, VHDX at
  `...\hom-lab-ctl-dkr-02\server-225-ubuntu.vhdx` (~35 GB).
- `server-225-ubuntu` Hyper-V VM: absent.
- Sidecars still used the legacy basename.
- Guarded playbook preflight (`preflight_only`) succeeded
  (`ok=5`, `changed=0`).

## Result and disposition

`reconciled` on 2026-09-23.

- Role `align_legacy_vm_identity.yml` extended to:
  - apply disk/sidecar alignment when the target VM already exists
  - skip directory merge when both legacy and target dirs are populated
  - rename `{legacy}-cidata.iso` / `{legacy}-state.json`
- Playbook `align_hom_lab_ctl_dkr_02_identity.yaml` upgraded to the
  dkr-01 preflight/apply/verify shape.
- Live apply: VHDX and sidecars renamed; VM restarted `Running` with
  canonical disk path; guest hostname already `hom-lab-ctl-dkr-02`.
- Inventory updated to canonical VHDX path; legacy Hyper-V name var removed.
- Stale leftover config tree under `...\server-225-ubuntu\` removed after
  confirm it held only old `.vmcx`/`.VMRS` remnants.
