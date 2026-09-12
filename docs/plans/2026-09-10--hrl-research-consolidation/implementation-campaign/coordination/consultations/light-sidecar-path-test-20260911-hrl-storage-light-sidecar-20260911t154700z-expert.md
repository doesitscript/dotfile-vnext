---
contract_version: 1
run_id: hrl-storage-light-sidecar-20260911t154700z-coordinator-consultation
role: onsite-expert-coordinator
return_to: implementer
status: recommendation_ready
---

# Light consultation: capacity-signal owner fork

## Request

Request: `docs/plans/2026-09-10--hrl-research-consolidation/implementation-campaign/coordination/requests/light-sidecar-path-test-20260911.md`.

The fork is which single existing owner should receive the first source-local
Light change when the handoff still leaves ownership ambiguous.

## Best recommendation

Implement exactly one non-overlapping chunk: the existing
`roles/storage_capacity_monitor/**` owner for `FA-capacity-signal`, with no
changes to `roles/k3s_vllm_runtime/**`. Keep the mechanism in the existing
role's lifecycle interface (`storage_capacity_monitor_state: present|absent`)
and use the existing `playbooks/deploy_storage_capacity_monitor.yaml` as the
deployment placement. The smallest source-local validation is the existing
`playbooks/verify_storage_capacity_monitor_safety.yaml` controller fixture;
do not create a sidecar role, wrapper, or new parallel monitor playbook.

This is the best fit because the role already owns the systemd timer/service,
journald event, mount list, threshold contract, and Alloy prerequisite. The
playbook composes Alloy before the monitor and requires an explicit `--limit`
before any host mutation. The vLLM cache area remains discovery-gated and must
not absorb this capacity-signal work.

## Evidence

- The request selects `FA-hf-cache-desired-state` and `FA-capacity-signal`,
  requires existing-owner extension, and forbids live mutation in Light
  (`.../coordination/requests/light-sidecar-path-test-20260911.md:23-35`).
- The readiness brief says the vLLM path still requires running-image,
  cache/PVC, mount, and StorageClass inspection, while capacity monitoring has
  an existing owner gap only at the broader policy/topology level
  (`.../upstream/research/current-phase-readiness-brief.md:27-30`).
- The selected host variables already commission the monitor with `/` required
  and `/mnt/k3s-cache` optional, 75/90 thresholds, and Alloy required
  (`inventory/host_vars/hom-lab-ctl-k3s-02.yaml:86-95`). This is inventory
  evidence, not proof that a live target may be mutated during this pass.
- The role preserves the public present/absent lifecycle split
  (`roles/storage_capacity_monitor/tasks/main.yml:2-16`).
- The deployment playbook targets the classified intersection
  `container_orchestrator_k3s:&gpu_workload_nodes`, composes Alloy first, and
  refuses an unbounded run without `--limit`
  (`playbooks/deploy_storage_capacity_monitor.yaml:2-26`).
- Fresh source-local validation passed after redirecting Ansible's unwritable
  default `/Users/joshc/.ansible/tmp` to writable `/private/tmp`:
  `bin/codex-env ansible-playbook playbooks/verify_storage_capacity_monitor_safety.yaml`
  completed `localhost : ok=11 changed=5 unreachable=0 failed=0 skipped=0`.
  The assertions covered warning parsing at 85%, optional missing mount
  success, and required missing mount failure (`.../verify_storage_capacity_monitor_safety.yaml:39-119`).

## Hard corrections and assumptions

- Preserve the refined-handoff boundary: source-local work only; no Apply,
  host mutation, cleanup, cache deletion, relocation, or physical target
  selection occurs in this consultation.
- Do not infer current host/device identity from historical reports or the
  inventory alias. Any later Apply must first capture alias-to-connect target,
  mount identity, and baseline evidence, then use an explicit verified limit.
- Do not move the capacity signal into `k3s_vllm_runtime`; that role remains
  reserved for the separately discovery-gated HF/vLLM cache desired state.
- The 75/90 values and `/mnt/k3s-cache` optionality are current repo desired
  state for the selected host vars, not a claim that those thresholds are
  operationally validated on a live host.

## Affected owners and validation expectations

Primary owner: `roles/storage_capacity_monitor/**`.

Placement owner: `playbooks/deploy_storage_capacity_monitor.yaml`.

Validation owner: `playbooks/verify_storage_capacity_monitor_safety.yaml`.

The Implementer should apply this answer only to the monitor chunk and return
a fresh review-ready handoff showing the changed role/playbook/template scope,
the passing fixture output, and an explicit statement that no vLLM owner or
live target was changed. Any later host Apply remains separately gated by
read-only target verification, explicit limit, and the plan's Apply/Verify/Undo
receipt requirements.

## return_to

`implementer`
