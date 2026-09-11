---
contract_version: 1
pipeline_id: "hrl-research-consolidation"
stage_id: "preparation"
task_id: "hrl-research-consolidation"
run_id: "hrl-preparation-20260911-r2"
mode: "orchestrated"
session_id: "hrl-research-consolidation-preparation-ppid42220"
owner_manifest_path: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/runtime/processes-42220.json"
source_plan_root: "/Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-10--hrl-research-consolidation"
preparation_output_root: "/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2"
project_root: "/Users/joshc/develop/dotfile-vnext"
status: "ready"
next_actor: "Coordinator"
---

# Current-phase readiness brief

Routing: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/coordination/current-phase-routing.md`.
No upstream handoff was supplied. Parent observation at `2026-09-11T03:59:47.715216+00:00` records dashboard `http://127.0.0.1:7900` reachable and healthy for the named session; this role did not probe runtime or hosts.

## Evidence and recommended slices

| Slice | Current evidence and conclusion | Owner surface or first discovery | Status |
| --- | --- | --- | --- |
| Containerd/image reclamation | `generated/context7/containerd/image-store-disk-reclamation/decision.yaml` supports normal GC and `crictl rmi --prune`; it rejects invented cadence and warns that `ctr content prune references` is repair-only. `discard_unpacked_layers` needs the K3s template merge/replace answer. | Existing `playbooks/recover_ai_inference_lane.yaml` already captures storage receipts; no dedicated cleanup role/playbook is evidenced. First slice: read-only capture of K3s version, effective containerd config/template, `crictl imagefsinfo`, image/snapshot use, and dry-run-safe command availability. | Discovery before any cleanup/config change. |
| HF/vLLM cache | `huggingface-hub/cache-disk-management` supports inspection and cache cleanup; `vllm/cache-and-artifact-offload` selects native environment variables and corrects stale `huggingface-cli` guidance. The current vLLM role mounts PVC `vllm-primary-hf-cache` at `/root/.cache/huggingface`; host vars now select a Qwen3 model. | `roles/k3s_vllm_runtime/{defaults,tasks/present}.yml`, `playbooks/deploy_vllm_runtime.yaml`, and `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`. First slice must inspect the running image's `hf cache --help`, actual cache/PVC usage, mount and StorageClass before choosing relocation or deletion. | Bounded discovery; do not use historical 19GB/model values as current state. |
| K3s imagefs/PVC capacity | Kubernetes packs support DiskPressure/image-GC mechanics and a mount-at-containerd-path approach; they explicitly leave effective K3s flags, local-path behavior, and logging/mount wiring unresolved. A PVC request is not proof of available physical capacity. | `playbooks/report_storage.yaml` is an existing read-only storage report; `k3s_comfyui_runtime/tasks/storage.yml` and vLLM role own current PVC declarations. First slice: read-only `kubectl` node/PVC/StorageClass/events plus `df`, `crictl imagefsinfo`, mount, and effective K3s/kubelet configuration receipts. | Discovery before resizing, offload, or threshold tuning. |
| VHDX/mount offload | `windows-server/storage-offload-targets/decision.yaml`, `k3s/storage-offload-targets/decision.yaml`, and `implementation-guides/storage/storage-offload-taxonomy.md` are present. Source-reported USB/VHDX viability is historical, not a selected target. | `roles/hyperv_ubuntu_vm/` has VHDX/shared-cache mechanisms; `playbooks/hyperv_move_vm_storage.yaml` is an existing relocation surface. Neither establishes ownership of a second model-cache VHDX. First slice: read-only Hyper-V disk/VM attachment and guest block-device/mount/fstab receipt, then a design decision. | Ownership unknown; no target selection. |
| Retention and monitoring | `ansible/recurring-runs-and-artifact-retention` supports find/age/state patterns but gives no approved policy; Prometheus retention material exists at `generated/context7/prometheus/tsdb-storage-and-retention/`. | No current storage-monitoring or retention owner was proven. `report_storage.yaml` is on-demand evidence, not monitoring. First slice: read-only discovery of deployed Prometheus/alerting topology, metric names, scheduler/AWX ownership, and existing retention jobs. | Discovery before scheduling or deletion. |

## Ansible gate and gaps

Repo surfaces checked: the three named roles, `playbooks/report_storage.yaml`, `playbooks/recover_ai_inference_lane.yaml`, `playbooks/deploy_vllm_runtime.yaml`, `playbooks/hyperv_move_vm_storage.yaml`, and `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`. The host alias is an inventory/NetBox schema alias, not proof of a current guest identity.

The project `ansible-knowledge-gate` requires repo-first evidence, official/runtime module confirmation, and an intent-to-module matrix before any new shell fallback. HRL's Ansible advisory ranks installed runtime and repo implementation above prose and records Context7 gaps. The five source-reported missing topics (role contracts, import/include reuse, scaling, quality gates, and layout/collections) do not block the read-only discovery slices. They block final role/playbook design only where they determine interface, tag behavior, validation, or execution scale.

Minimum follow-up research: inspect existing `meta/argument_specs.yml`, playbook tag/list-task conventions, `ansible.cfg`/collections, CI/lint/Molecule configuration, and `ansible-playbook --list-tasks/--list-tags` for the selected owner. Then run Context7 or `ansible-doc` for each proposed module and record a module matrix. No callable Context7 resource was available in this role session, so no new retrieval claim is made.

## Rejected or deferred patterns

- Do not schedule blanket containerd pruning, stale-snapshot repair, HF deletion, or retention cleanup from source-reported pressure alone.
- Do not author a K3s containerd template until its merge/replace behavior and effective runtime config are captured; replacing generated configuration could lose NVIDIA/CNI/registry settings.
- Do not choose a host, USB device, VHDX path, mount point, capacity, threshold, or retention window from the historical report.
- Do not treat Context7 packs or configured tooling as live/callable proof; the checked evidence is library/source material, not current host state.

## Required later preflight, execution, and evidence

All future changes are change-class `planned infrastructure change`, with separate user authorization for Apply. Before mutation, capture target identity and baseline: inventory alias-to-connect target, Hyper-V VM/disk attachment, guest block devices/mounts/free space, K3s/Kubelet/containerd effective configuration, node/PVC/StorageClass/events, vLLM image and `hf cache --help`, cache contents, current scheduler/monitoring ownership, and backups/rollback location.

Apply only the selected slice after that receipt. Verify with before/after storage and imagefs figures, expected mounts/PVC binding, workload readiness and vLLM `/health` plus `/v1/models`, no new DiskPressure events, and an Ansible idempotence/check-mode or targeted validation receipt where applicable. Undo must be designed per selected change: restore captured config and prior mount/PVC/deployment values, detach only the newly identified VHDX after data safety confirmation, and restore from the named backup; never claim containerd/HF deletion is reversible without a retained source or backup.

## Plan and diagram requirements

The Coordinator plan must map each source obligation to a slice or explicit discovery disposition, name exact owner surfaces only where proven, and include measurable Implementer/Evaluator evidence above. It must include a baseline architecture diagram showing only logical surfaces (Hyper-V host, K3s guest, root/image/cache/PVC/monitoring planes) with unknown physical placement labelled; a capability-routing diagram for discovery/Apply/Verify/Undo ownership; and a naming/modeling section that preserves inventory aliases versus actual discovered host/device names. No diagram may invent live topology.

Event: `research_ready`.

Artifact: `/Users/joshc/develop/oneoffs/hrl-research-consolidation-preparation-20260911-r2/research/current-phase-readiness-brief.md`.

Next actor: `Coordinator`.
