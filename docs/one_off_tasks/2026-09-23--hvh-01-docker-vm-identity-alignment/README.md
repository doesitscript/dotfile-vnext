# HOM-LAB-HVH-01 Docker VM identity alignment

## Request and authority

The user requested correction of the active legacy `nsrv-dkr-01` identity
drift and a maturity pass on the upstream project. This record owns the
controlled-outage execution instance; the role, inventory, naming registry,
and NetBox seed remain desired-state authorities.

## Scope

- Rename the running Hyper-V VM `nsrv-dkr-01` to `hom-lab-ctl-dkr-01`.
- Move its F: artifact directory to the canonical name.
- Rename and repoint its attached VHDX to the canonical path.
- Start the VM and prove its canonical identity.
- Update inventory only after live convergence, then run NetBox/repo
  consistency validation.

## Apply / Verify / Undo / Change class

- Apply: `ansible-playbook playbooks/troubleshoot/align_hom_lab_ctl_dkr_01_identity.yaml -i inventory/inventory.yaml -e hyperv_identity_alignment_apply=true`
- Verify: the playbook asserts no legacy VM, a running canonical VM, and the
  canonical F: VHDX path; then run `scripts/validate_netbox_repo_consistency.sh`.
- Undo: stop the canonical VM, reverse the VM/directory/VHDX names, and repoint
  its disk. This is manual recovery during the same maintenance window.
- Change class: controlled-outage migration.

## Preflight evidence

2026-09-23 read-only Hyper-V probe reported:

- `nsrv-dkr-01`: exists, `Running`, VHDX at
  `F:\ProgramData\Ansible\hyperv_ubuntu_vm\nsrv-dkr-01\nsrv-dkr-01.vhdx`.
- `hom-lab-ctl-dkr-01`: does not exist.
- The legacy artifact root exists; the canonical root does not.

The guarded playbook preflight also ran successfully with its default
`preflight_only` mode (`ok=5`, `changed=0`, `failed=0`, `skipped=4`). It
confirmed the same running legacy VM and absent canonical VM without invoking
the rename, directory move, VHDX move/repoint, or restart tasks.

## Result and disposition

`reconciled` on 2026-09-23 after the user approved the controlled outage.

- Hyper-V VM: `nsrv-dkr-01` was renamed to `hom-lab-ctl-dkr-01`.
- Artifact root: moved on the same F: volume to the canonical directory.
- VHDX: renamed and repointed to
  `F:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-dkr-01\hom-lab-ctl-dkr-01.vhdx`.
- VM: restarted successfully; the legacy VM and artifact root are absent.
- Guest hostname: converged to `hom-lab-ctl-dkr-01`.
- Workloads: Postgres, Redis, ClickHouse, and MinIO containers were healthy
  after restart.
- Inventory: updated to canonical VM/VHDX paths and normal lifecycle management
  is no longer blocked.
- NetBox/repo consistency validation passed after the inventory reconciliation.

## Readiness receipt

2026-09-23 post-migration readiness checks reported:

- Hyper-V: legacy VM absent; `hom-lab-ctl-dkr-01` `Running` with its canonical
  F: VHDX path.
- Guest: static hostname `hom-lab-ctl-dkr-01`.
- Containers: Postgres, Redis, ClickHouse, and MinIO all `healthy`.
- Endpoints: ClickHouse `/ping` returned `Ok.`; MinIO `/minio/health/ready`
  returned HTTP success.
