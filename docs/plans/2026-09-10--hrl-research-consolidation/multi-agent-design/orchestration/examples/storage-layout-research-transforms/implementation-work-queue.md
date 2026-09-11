# Implementation work queue

This queue is **Implementer-owned and dynamic**. It is not a static campaign
script written once by a human or parent.

## Source of truth for what to chunk

1. Read the refined technical handoff first:
   `orchestration/05-refined-technical-handoff--storage-layout.md`
2. Treat its **functional areas** as the agnostic work map.
3. Propose or refresh the rows below as the smallest coherent owner groups that
   realize one area’s target state for Evaluator review.
4. While Evaluator reviews a frozen chunk, propose/start the next
   non-overlapping area.

The parent may seed an empty or provisional queue; Implementer must align it to
the refined handoff before claiming a Light pass is on-track.

## Queue rules

1. Select the first `ready` item with satisfied dependencies.
2. Handoff includes `chunk_id`, owners, changed-file SHA-256 values, owner-only
   diff, targeted validation, and `available_next_chunk`.
3. Evaluator reviews that frozen snapshot and those owners only.
4. After snapshot freeze, Implementer may start the next independent item during
   review when owners, playbooks, queue state, and handoff artifacts do not
   overlap.
5. Feedback returns only the affected chunk to `changes-requested`.
6. A chunk is committable once source validation, snapshot, and Evaluator
   outcome are recorded. Git commit remains optional.
7. Evaluator’s first verdict is whether the declared target state is present.

## Current queue (seeded from refined handoff functional areas)

Implementer may reorder, split, or merge rows when that better matches
non-overlapping owners — update this table in the same pass and cite the area
ID from the refined handoff.

| Order | ID | State | Target state / owners | Targeted validation | Next |
| --- | --- | --- | --- | --- | --- |
| 1 | `FA-hf-cache-desired-state` | ready | HF cache converges on `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`; no `TRANSFORMERS_CACHE` / deprecated CLI. Owners: `roles/k3s_vllm_runtime/**`; related vLLM deploy owner | one bundled whitespace, syntax/lint, template/argument-contract check | FA-containerd-imagefs-bind |
| 2 | `FA-containerd-imagefs-bind` | ready | containerd imagefs bind offload converges on NVMe layout; server/TLS untouched. Owners: `roles/k3s_storage_offload/**`; `playbooks/deploy_k3s_data_disk.yaml`; `playbooks/deploy_k3s_storage_expansion.yaml` | one bundled whitespace, syntax/lint, exact normal-state idempotence check | FA-local-path-new-only |
| 3 | `FA-local-path-new-only` | ready | new local-path backing under `/mnt/k3s-cache/local-path`; existing PVs immutable. Owners: k3s storage / local-path surfaces already in repo | syntax/lint on touched files | FA-capacity-signal |
| 4 | `FA-capacity-signal` | ready | monitor emits usable capacity signal via owned stack. Owners: `roles/storage_capacity_monitor/**`; `roles/logging_alloy/**` only if required | monitor fixture/template test, syntax/lint | FA-ansible-tag-hygiene |
| 5 | `FA-ansible-tag-hygiene` | ready | storage `include_role` sites that need tags use `apply:`. Owners: storage deploy/report playbooks touching the above roles | controller-local `--list-tasks` on touched plays | live-attach-and-apply |
| 6 | `live-attach-and-apply` | blocked-full-lane | exact disk identity + Apply + proof | Full Orchestration only | n/a |

## Active decision boundary

Functional areas use the refined technical handoff as the technical decision.
Light does not recreate safety-contract fixtures. A concrete source/runtime
contradiction may request a narrow Expert clarification; otherwise continue.

## Snapshot and scheduling boundary

Use a top-level `review_ready_for_evaluator_<timestamp>.md` with campaign
identity plus `chunk_id` / hashes / `available_next_chunk`. Stored diff/hashes
keep Evaluator on the frozen chunk while Implementer may advance the next
independent area.
