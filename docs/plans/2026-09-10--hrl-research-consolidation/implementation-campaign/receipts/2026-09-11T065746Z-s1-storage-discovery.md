---
contract_version: 1
pipeline_id: hrl-research-consolidation
task_id: hrl-research-consolidation
campaign_id: hrl-storage-implementation-beta-01
stage_id: implementation
run_id: hrl-storage-implementation-beta-01-parent-20260911t065212z-implementer-1
role: implementer
event_id: hrl-storage-implementation-beta-01-parent-20260911t065212z-implementer-1:1
responds_to: null
upstream_run_id: hrl-preparation-20260911-r2
upstream_plan_sha256: 2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c
status: evidence-captured
next_actor: Implementer
mode: orchestrated
session_id: hrl-research-consolidation-implementation-hrl-storage-implementation-beta-01-parent-20260911t065212z-ppid35538
owner_manifest_path: /Users/joshc/develop/oneoffs/hrl-storage-implementation-beta-01-parent-20260911T065212Z/run/owned-processes.json
---

# S1 storage discovery and Ansible knowledge receipt

Captured `2026-09-11T06:54Z`–`06:58Z`. This is read-only discovery, not an
Apply receipt. No managed-host state changed.

## Intake and target proof

- Intake checker: exit `0`; campaign `hrl-storage-implementation-beta-01`,
  upstream run `hrl-preparation-20260911-r2`, and plan digest matched. The
  checker reported both live Apply and implementation approval as `false`.
- Guest list-hosts: exit `0`; exact limit `hom-lab-ctl-k3s-02` selected one host.
- Guest classification: exit `0`, recap `ok=21 changed=0 failed=0`; execution
  role `k3s-ai-plane`, runtime plane `k3s_node`, `policy_ok: true`.
- Hyper-V list-hosts: exit `0`; exact limit `HOM-LAB-HVH-02` selected one host.
- Hyper-V classification: exit `0`, recap `ok=18 changed=0 failed=0`; execution
  role `primary-ai-compute`, runtime planes include `hyperv_host` and
  `hyperv_k3s_vm`, `policy_ok: true`.

## Observed storage map and baseline

| Layer | Current observation |
| --- | --- |
| Inventory | `hom-lab-ctl-k3s-02` connects at the configured guest alias and maps to parent `HOM-LAB-HVH-02`. |
| Hyper-V VM | Running VM `hom-lab-ctl-k3s-02`; one SCSI attachment at controller `0:0`. |
| VHDX | Fixed 80 GiB file at `D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-k3s-02\hom-lab-ctl-k3s-02.vhdx`; no second guest disk observed. |
| Host capacity | Hyper-V host `D:` is NVMe, 931.5 GiB total, 373.6 GiB free. No capacity is selected for use. |
| Guest filesystem | One 80 GiB virtual disk (`/dev/sda`); `/dev/sda1` is the 79 GiB root filesystem. `df` reports 77 GiB total, 65 GiB used, 12 GiB free, 85% used. |
| Persistent mounts | Only root, `/boot`, and `/boot/efi`; no cache/offload mount. |
| K3s | `v1.31.12+k3s1`; service active/running, no drop-ins, no storage mount ordering beyond normal system targets. |
| Kubelet storage policy | Image GC high/low thresholds 85%/80%; hard eviction `nodefs.available: 10%`; minimum reclaim includes `imagefs.available: 10%` and `nodefs.available: 10%`. |
| Pressure and workloads | `DiskPressure=True`. Langfuse web/worker, LiteLLM, and vLLM controllers are `0/1`; their pods are Pending due to the disk-pressure taint. |
| Image GC | `FreeDiskSpaceFailed`: kubelet attempted to free 3,778,818,867 bytes and found 0 eligible image bytes. `crictl imagefsinfo` reports 22,866,526,208 used bytes. |
| Removable-runtime candidates | Five exited CRI containers and five NotReady sandboxes were observed. They were not removed. |
| vLLM cache/PVC | Bound `local-path` PVC requests 120 GiB but is backed on the same root filesystem; actual cache directory uses 22 GiB. StorageClass does not allow expansion. |
| Containerd/local-path | `/var/lib/rancher/k3s/agent/containerd` uses 30 GiB; `/var/lib/rancher/k3s/storage` uses 22 GiB. |
| Journals | Archived and active journals use 157.6 MiB; journal vacuum alone cannot materially solve the pressure. |
| Monitoring/scheduler | No Prometheus/PrometheusRule/Alertmanager API resources are installed. Only standard OS timers were observed; no storage retention timer was identified. |

## Commands and results

All Ansible commands used `bin/codex-env`; the runtime-only SSH control path was
redirected to `/private/tmp/hrl-storage-implementation-beta-01-ansible-cp`
because the sandbox cannot write `~/.ansible/cp`.

| Command intent | Exit | Result |
| --- | ---: | --- |
| `bun .../check-implementation-handoff.ts .../implementation-campaign` | 0 | Verified intake. |
| `ansible-playbook playbooks/classify_homelab_hosts.yaml --limit hom-lab-ctl-k3s-02 --list-hosts` | 0 | One guest target. |
| Same classifier without `--list-hosts` | 0 | Read-only policy classification; no change. |
| `ansible-playbook playbooks/report_storage.yaml --limit hom-lab-ctl-k3s-02 --list-hosts` | 0 | One guest target. |
| Same storage report with `--syntax-check` | 0 | Syntax valid. |
| Same storage report live | 0 after one environment correction | Read-only guest evidence above; recap `ok=7 changed=0 failed=0`. Initial attempt failed locally before connection because `/Users/joshc/.ansible/cp` was unwritable. |
| Classifier/list-hosts/report with `--limit HOM-LAB-HVH-02` | 0 | Read-only Hyper-V mapping; report recap `ok=6 changed=0 failed=0`. |

Warnings about invalid inventory group-name characters and a reserved variable
named `tags` predate this focused report and did not change target selection or
command exit status.

## Ansible knowledge gate

Repo surfaces checked: `playbooks/report_storage.yaml`,
`playbooks/classify_homelab_hosts.yaml`, `playbooks/recover_ai_inference_lane.yaml`,
`playbooks/deploy_vllm_runtime.yaml`, `playbooks/hyperv_move_vm_storage.yaml`,
`roles/k3s_vllm_runtime/`, `roles/k3s_comfyui_runtime/tasks/storage.yml`,
`roles/hyperv_ubuntu_vm/`, guest/Hyper-V host vars, and `policy/*.yml`.

Authority checked: Context7 `/ansible/ansible-documentation/v2_17_13`, Context7
`/ansible-collections/ansible.windows`, and local `ansible-doc`. The Ansible MCP
Zen, best-practices, and environment calls were attempted but unavailable
because this managed run has `approval_policy: never` and those calls requested
approval.

Operational surfaces: Linux/Windows facts, filesystem and mount reporting,
Hyper-V disk attachment reporting, read-only K3s/CRI commands, and structured
display of registered results.

| Surface | Module | Evidence | Fit |
| --- | --- | --- | --- |
| Host facts | `ansible.builtin.setup` | local `ansible-doc` | yes |
| Guard explicit limit | `ansible.builtin.assert` | local `ansible-doc` | yes |
| Linux/K3s read-only CLI | `ansible.builtin.command` | Context7 and local `ansible-doc`; forced `check_mode: false`, `changed_when: false` | yes, for known read-only commands |
| Windows volume/Hyper-V queries | `ansible.windows.win_powershell` | Context7 and local `ansible-doc`; `$Ansible.Changed = $false`, `error_action: stop` | yes |
| Human-readable receipt output | `ansible.builtin.debug` | local `ansible-doc` | yes |

Module conclusion: no shell fallback is needed for this discovery playbook.
Commands are limited to product-native read-only queries. Live cleanup needs a
separate owner/contract and explicit authority; it must not be smuggled into the
report.

## Design impact and open gaps

- Ordinary image pruning is not supported as the sole response: active image
  inventory is small and kubelet reports zero eligible image bytes.
- The declared 120 GiB PVC is overcommitted against a 77 GiB root filesystem;
  it does not prove backing capacity.
- The existing single-VHDX placement has no additional storage/offload surface.
- `playbooks/recover_ai_inference_lane.yaml` contains mutation steps and cannot
  be used without a separately recorded exact authorization.
- S1 is materially advanced but not campaign-complete. S2–S5 remain open and
  vLLM health cannot pass while the pod is Pending.

## Apply / Verify / Undo / Change class

- Apply: none; repository-only report refinement plus read-only discovery.
- Verify: target previews, policy classification, syntax checks, and live
  read-only reports on the exact guest and Hyper-V aliases.
- Undo: revert only the `playbooks/report_storage.yaml` report refinement; no
  host rollback exists because no host mutation occurred.
- Change class: idempotent/read-only evidence automation and documentation.

