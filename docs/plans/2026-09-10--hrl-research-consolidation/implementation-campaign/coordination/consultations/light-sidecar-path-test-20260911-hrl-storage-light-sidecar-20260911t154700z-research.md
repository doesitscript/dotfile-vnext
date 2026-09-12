---
contract_version: 1
run_id: hrl-storage-light-sidecar-20260911t154700z-researcher-consultation
role: researcher
return_to: implementer
status: recommendation_confirmed
---

# Light consultation: capacity-signal owner fork

## Request

Request path: `docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/coordination/requests/light-sidecar-path-test-20260911.md`.

Reviewed Expert artifact: `docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/coordination/consultations/light-sidecar-path-test-20260911-hrl-storage-light-sidecar-20260911t154700z-expert.md`.

## Recommendation disposition

**Best recommendation confirmed.** Implement one non-overlapping source-local
chunk for `FA-capacity-signal` in `roles/storage_capacity_monitor/**`. Preserve
the role's `storage_capacity_monitor_state: present|absent` lifecycle and place
deployment through `playbooks/deploy_storage_capacity_monitor.yaml`. Use the
existing `playbooks/verify_storage_capacity_monitor_safety.yaml` as the
controller-local template/fixture validation. Do not modify
`roles/k3s_vllm_runtime/**`, create a sidecar or wrapper role, add a parallel
monitor playbook, or run Apply.

## Evidence coverage

- The refined handoff maps `FA-capacity-signal` to the existing storage monitor
  owner and specifies template/fixture plus syntax/lint validation; it separately
  maps `FA-hf-cache-desired-state` to `roles/k3s_vllm_runtime/**` and keeps live
  attach/apply out of Light:
  `docs/plans/2026-09-10--hrl-research-consolidation/multi-agent-design/orchestration/05-refined-technical-handoff--storage-layout.md`.
- The monitor role has an explicit present/absent lifecycle in
  `roles/storage_capacity_monitor/tasks/main.yml`.
- The deployment playbook composes `logging_alloy` before
  `storage_capacity_monitor`, targets the classified K3s/GPU intersection, and
  requires an explicit non-empty `--limit` before mutation:
  `playbooks/deploy_storage_capacity_monitor.yaml`.
- Selected host variables commission the monitor with `/` required,
  `/mnt/k3s-cache` optional, 75/90 thresholds, and Alloy required:
  `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`. These are desired-state source
  facts, not live target or device identity proof.
- The readiness brief keeps HF/vLLM cache work discovery-gated and says not to
  use historical cache usage as current state:
  `docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/upstream/research/current-phase-readiness-brief.md`.
- Rechecked the cited controller fixture with:
  `bin/codex-env ansible-playbook -e ansible_local_tmp=/private/tmp/hrl-light-researcher-ansible-local -e ansible_remote_tmp=/private/tmp/hrl-light-researcher-ansible-remote playbooks/verify_storage_capacity_monitor_safety.yaml`.
  Result: `localhost : ok=11 changed=5 unreachable=0 failed=0 skipped=0`;
  both optional-missing and required-missing assertions passed. The initial
  invocation failed only because Ansible attempted unwritable
  `/Users/joshc/.ansible/tmp`; the corrected explicit temp variables produced
  the passing result.

## Assumptions and hard corrections

- This is source-local Light work only. No host mutation, cache deletion,
  relocation, cleanup, physical disk selection, or Apply is authorized here.
- Preserve the owner boundary: capacity signaling stays in
  `storage_capacity_monitor`; HF/vLLM cache desired state remains separately
  discovery-gated in `k3s_vllm_runtime`.
- Do not infer host, guest, mount, by-id, serial, or device identity from the
  inventory alias or historical reports. Any later Apply needs fresh read-only
  identity/baseline evidence and an explicit verified limit.
- The 75/90 thresholds and optional `/mnt/k3s-cache` entry are current repo
  desired state, not live operational validation.

## Affected owners

- Primary implementation owner: `roles/storage_capacity_monitor/**`
- Placement owner: `playbooks/deploy_storage_capacity_monitor.yaml`
- Validation owner: `playbooks/verify_storage_capacity_monitor_safety.yaml`
- Explicitly unaffected in this chunk: `roles/k3s_vllm_runtime/**`

## return_to

`implementer`
