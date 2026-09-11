---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-1
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t104646z-implementer-1:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/feedback_for_review_by_evaluator_2026-09-11T083117Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: evidence-captured
next_actor: Evaluator
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t104646z-ppid29198
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T104646Z/run/owned-processes.json
expert_recommendation_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/eval_feature/response_on-site_expert/2026-09-11T085155Z-onsite-expert-recommendation.md
decision_authority_profile_path: /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/decision-authority-profiles.md
---

# S4 final source-boundary correction receipt

## Authorized recommendation disposition

The `lab_recreatable_autonomy` profile adopts the Expert's three evidence-backed
Best recommendations inside the existing S4 scope. This pass changes repository
owners and controller-local tests only. It does not grant or exercise live Apply
authority, select an unknown guest device, or assert whole-campaign completion.

## Corrections

- `roles/linux_data_disk_mount/tasks/absent.yml` now uses
  `findmnt --mountpoint` for both live and fstab lookups, so an existing but
  already-unmounted directory produces `rc=1` and no root-filesystem source.
- Linux present, absent and partition-derivation gates require a whole-disk path
  under `/dev/disk/by-id/` and independently reject a `-partN` suffix before
  `community.general.parted` can run.
- `roles/hyperv_vm_data_disk/tasks/present.yml` passes `HostReserveBytes` into
  the mutation operation and re-reads the qualified host drive immediately
  before `New-VHD`; insufficient current free space throws before creation.
- `playbooks/verify_k3s_data_disk_safety.yaml` adds populated raw-device and
  partition-suffix negative fixtures, an already-unmounted empty-source fixture,
  a crossed-reserve fixture, and parsed-source assertions proving the reserve
  check precedes `New-VHD`.

## Knowledge and module receipt

- Entry door: `homelab-ansible-first-entry` → existing-role
  `ansible-knowledge-gate`; one-off exception: no.
- Owner role/playbook: `roles/linux_data_disk_mount/`,
  `roles/hyperv_vm_data_disk/`, `playbooks/deploy_k3s_data_disk.yaml`.
- Operational surfaces: exact Linux mount identity, pre-partition stable device
  input, and current Hyper-V host capacity at creation time.
- Module matrix reused from the current reviewed campaign receipt:

  | Surface | Owner/module | Evidence | Fit |
  | --- | --- | --- | --- |
  | Exact mount and fstab lookup | role-owned `findmnt --mountpoint` read-only command | Evaluator probe plus util-linux semantics cited in governed feedback | yes |
  | Whole-disk initialization | `community.general.parted` after by-id/serial gates | current role and prior `ansible-doc` receipt | yes |
  | Hyper-V create/attach | `ansible.windows.win_powershell` structured parameters | current role and prior `ansible-doc` receipt | yes |

No new shell fallback or unowned configuration was introduced.

## Verification evidence

- Intake: `bin/codex-env bun .../check-implementation-handoff.ts .../implementation-campaign`
  - Exit `0`; `intake: verified`; live Apply and implementation approval both `false`.
- Syntax: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --syntax-check`
  - Exit `0`; output names `playbooks/deploy_k3s_data_disk.yaml`.
- Focused lint: `bin/codex-env ansible-lint --offline playbooks/deploy_k3s_data_disk.yaml playbooks/verify_k3s_data_disk_safety.yaml roles/hyperv_vm_data_disk roles/linux_data_disk_mount`
  - Exit `0`; production profile, `0` failures and `0` warnings in 17 processed files.
- Safety fixtures: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/verify_k3s_data_disk_safety.yaml`
  - Exit `0`; final fresh rerun is recorded in the outbox. The earlier green run
    reached `ok=44 changed=0 failed=0 rescued=8`; a later fixture increment is
    deliberately reverified before handoff.
- Target preview: `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/deploy_k3s_data_disk.yaml --limit 'hom-lab-ctl-k3s-02,HOM-LAB-HVH-02' --list-hosts`
  - Exit `0`; guest plays contain only `hom-lab-ctl-k3s-02`, and the Windows play
    contains only `HOM-LAB-HVH-02`.
- `git diff --check`: exit `0` before documentation refresh; final fresh result
  is recorded in the outbox.

Two informed validation corrections were required: Node was replaced with the
documented Bun TypeScript runner after `ERR_UNKNOWN_FILE_EXTENSION`, and an
invalid `LC_ALL=C` Ansible override was removed after Ansible reported a
non-UTF-8 locale. A strict-boolean fixture issue was then corrected from
string-returning `regex_search` to the boolean `match` test. Subsequent proving
commands used the repo wrapper and exited successfully. Shell startup continues
to warn that controller `C.UTF-8` is unavailable; the wrapper supplied the
working Ansible runtime environment.

## Apply / Verify / Undo / Change class

- Apply: repository source corrections only; no managed-host mutation ran.
- Verify: intake, syntax, focused lint, populated controller-local safety
  fixtures, exact limited target preview, hashes and diff checks.
- Undo: revert these source changes. Runtime lifecycle remains data-preserving
  unmount/fstab removal before exact detach; no VHDX or filesystem deletion is
  encoded.
- Change class: idempotent desired-state safety correction with destructive-
  capable operations still disabled and identity/backup/authority gated.

## Remaining obligations

S4 remains incomplete until current slot identity is reconfirmed, the attached
disk's by-id/serial is discovered, authorized Apply runs, and S3/S4 health,
integrity and rollback evidence is captured. S3, S5 and S6 remain open per the
campaign obligation inventory. Independent Evaluator review is mandatory.
