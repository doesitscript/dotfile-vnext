---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-evaluator-4
role: evaluator
event_id: hrl-storage-implementation-beta-01-parent-20260911t074328z-evaluator-4:1
responds_to: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/review_ready_for_evaluator_2026-09-11T075622Z.md"
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: changes-requested
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t074328z-ppid66027
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T074328Z/run/owned-processes.json
---

# Evaluator feedback — implementation pass 4

Decision: accept the S2 source-backed no-change conclusion and the repaired
exact-command receipt. Do not approve the whole campaign: S3-S6 remain open,
the requested additional-storage/offload outcome has not been implemented, and
current `DiskPressure` still prevents the affected workloads from scheduling.
This is feedback, not waiting, because the reviewed source is new and safe
repository research/design work remains before the missing user choices become
the only dependency.

## Reviewed identity and source state

- Reviewed Implementer outbox:
  `review_ready_for_evaluator_2026-09-11T075622Z.md`, SHA-256
  `eaa684572984f244880008b86cb5be8f82f60085c3c46585e01687c1b3af841d`.
- Reviewed receipt:
  `receipts/2026-09-11T075622Z-s2-owner-and-exact-evidence.md`, SHA-256
  `fac9c5c534d9a9f409d860ad1ebba7928a2c313185afb76866737f38cabe4175`.
- Git HEAD: `3613377069bcb3ed815f4b0763df0ed6d668692d`.
- Current reviewed digests: `playbooks/report_storage.yaml`
  `99d2342b12f5cf1987f2569ad24cb975662cf4e95b280b85db08dab908678cd1`;
  campaign `README.md`
  `a19613122f22e153e3db90568eb8bcbaefe5c285393c57187668e6234c15b9c6`;
  accounting
  `ba7fabb744b18ebf5f60781e5e743115f302cfe909bb07588d491134394cbdee`;
  authorization ledger
  `159bf4a6f02ef3d6d5ec469ae64485534959b6ceab972f231bc0b18f72db957c`.
- Scoped source change since the prior evaluator pass: four mandatory read-only
  K3s/containerd owner probes in `report_storage.yaml`, plus the receipt,
  accounting, authorization and plan-obligation updates named by the handoff.
  Previously reviewed vLLM role/inventory changes remain dirty but unchanged;
  unrelated worktree state was preserved and not evaluated.
- The intake checker exited `0`, matched the campaign/upstream identity and
  digest, and again reported both live-Apply authority and implementation
  approval as `false`.

Project type: managed rollout / Ansible capability implementation with designed
plan and receipt outputs and separately authorized future mutation.

## Fresh independent evidence

| Check | Exit | Current evaluator evidence |
| --- | ---: | --- |
| `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/report_storage.yaml --syntax-check` | 0 | `playbook: playbooks/report_storage.yaml`. |
| `bin/codex-env ansible-playbook -i inventory/inventory.yaml playbooks/report_storage.yaml --limit hom-lab-ctl-k3s-02 --list-hosts --list-tags` | 0 | Exactly `hom-lab-ctl-k3s-02`; task tags are `always`, `k3s_storage_report`, and `storage_report`; summary has zero hosts under the limit. |
| `bin/codex-env ansible-lint --offline playbooks/report_storage.yaml` | 0 | Production profile; zero failures and zero warnings in the changed file. |
| Bounded live `report_storage.yaml --limit hom-lab-ctl-k3s-02 --tags k3s_storage_report` | 0 | `ok=12 changed=0 unreachable=0 failed=0`; every mandatory probe succeeded. The added probes report K3s 1.31.12, containerd 2.0.5, only generated `config.toml`, NVIDIA and runc runtime handlers, `RuntimeReady=true`, `NetworkReady=true`, and no containerd deprecation warning. |
| Current incident state in the same report | 0 | `/dev/sda1` remains 85% used with 11.8 GiB free; `DiskPressure=True`; local-path PVC remains on root; vLLM cache is 22 GiB; containerd is 30 GiB; kubelet reports about 3.79 GB requested reclaim and zero eligible image bytes. |

The four added probes are read-only `ansible.builtin.command` loop items, inherit
the existing explicit-limit gate, use `changed_when: false`, and are included in
the mandatory result assertion. They list configuration filenames/metadata and
runtime state without reading K3s configuration or credential file contents.

Official K3s documentation confirms that K3s generates
`agent/etc/containerd/config.toml` and uses `config-v3.toml.tmpl` or the legacy
template for customization. Official Kubernetes documentation assigns unused
image/container garbage collection to kubelet, warns against external garbage-
collection tools, and describes the observed 85/80 high/low thresholds. The S2
conclusion is therefore supported by both current host evidence and current
upstream ownership guidance.

## Whole-campaign check matrix

| Slice | Status | Evaluator finding / required evidence |
| --- | --- | --- |
| S1 | in progress; current evidence accepted | Target, disk/root/PVC/cache/runtime and scheduler/monitoring-surface discovery is current. The final map/receipt must remain aligned with the eventual S4/S5 design. |
| S2 | accepted no-change conclusion | Kubelet is the normal GC owner; effective thresholds are already 85/80; no custom containerd template exists; about 368 KiB of exited/sandbox layers and zero eligible image bytes do not justify external prune, deletion, restart or a custom template. Preserve this as a no-Apply disposition, not a capacity fix. |
| S3 | blocked on storage decision and implementation | The fail-closed vLLM gate is accepted, but approved backing, cache migration, binding/mount, workload readiness, `/health`, `/v1/models`, integrity and rollback evidence do not exist. |
| S4 | blocked on user decision and implementation | No selected second-VHDX capacity/path, guest mount/data path, retained backup, outage window, data-preserving Ansible owner/apply, or new-storage-use proof exists. |
| S5 | blocked on policy decision; owner design open | No selected monitoring owner/cadence/threshold/route, scoped job/rule implementation, behavior test, or disable/undo evidence exists. Repo search finds existing Loki/Grafana logging surfaces but no proven Prometheus storage-alert owner; do not conflate logging retention with node-storage monitoring. |
| S6 | in progress | Exact-command receipt and a first obligation inventory now exist. Final source/module matrix, granular obligation closure, final diagrams/docs, implementation receipts and current HRL disposition remain required. |

## Open blockers and next implementation work

- **S3/S4 data-preserving owner:** inspect the existing
  `hyperv_ubuntu_vm`, `hyperv_move_vm_storage.yaml`, guest mount and vLLM/local-
  path owners, then scaffold the bounded second-VHDX → persistent guest mount →
  cache/PVC migration workflow. Keep capacity, host path, mount/data path,
  retained backup and outage window as required inputs. Include `present|absent`
  lifecycle, exact target preview, dependency order, backup/integrity gates and
  a safe reversal contract. Do not apply it and do not use the destructive
  installed-node `k3s_storage_prep` shortcut.
- **S5 owner decision package:** finish source/installed-surface research for a
  node-storage metrics and alerting owner. Compare the repo's current
  Loki/Grafana surfaces with a bounded Prometheus-compatible or host-native
  alternative, name the metrics actually available, and produce a recommended
  owner plus the smallest required policy choices. Do not implement guessed
  cadence, thresholds or alert routing.
- **Durable user decision request:** after those independent designs are
  concrete, publish one decision handoff covering the recommended S3/S4
  capacity and placement, exact target/path choices, backup/source, outage
  window, S5 owner/cadence/threshold/route, risks and the exact mutation
  authority requested. If that leaves no independent work, the next evaluator
  state should be waiting on those named answers rather than repeated feedback.
- **Plan-verification granularity:** the new S1-S6/C-01-C-03 inventory is an
  honest current summary, but expand it before readiness so each selected
  Apply/Verify/Undo, target/backup/integrity, workload-health, monitoring-
  behavior, diagram and designed-deliverable gate has its own testable evidence
  row. Keep `blocked` and `pending` rows out of any completion claim.

## Feedback disposition

- Prior exact-command receipt blocker: closed by the current receipt.
- Prior S2 owner/config blocker: closed with an accepted no-change disposition.
- S3/S4 and S5 work: still open; the current pass did not repeat the same full
  blocker set, so the repeated-blocker research gate does not trigger.
- Live mutation: neither authorized nor performed; no rollback action is needed
  for this pass.

## Next action

Implementer: perform one finite pass on the S3/S4 data-preserving owner design
and S5 owner/decision package, update the obligation inventory and exact-command
receipt, and write one new `review_ready_for_evaluator_*` artifact. Do not mutate
the hypervisor, guest storage, cache/PVC, workloads or monitoring until the
authorization ledger contains the selected values, verified target, baseline,
backup/reversal, preview and specific user authority.

## Sources checked

- Repo campaign contract, accounting, authorization ledger, current handoff and
  `receipts/2026-09-11T075622Z-s2-owner-and-exact-evidence.md`.
- Changed `playbooks/report_storage.yaml` plus current inventory/role searches.
- K3s Advanced Options / Configuring containerd:
  <https://docs.k3s.io/advanced>.
- Kubernetes Garbage Collection:
  <https://v1-34.docs.kubernetes.io/docs/concepts/architecture/garbage-collection/>.
- Kubernetes kubelet reference:
  <https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/>.
