---
campaign_id: hrl-storage-implementation-beta-01
run_id: cursor-direct-s3-cache-idempotence-20260911T184543Z
role: implementer
upstream_plan_sha256: "2a1466c9c81ea613ec5a916777d834050245169af51546f67f35d44ed7338d2c"
responds_to: null
chunk_id: S3-cache-idempotence
available_next_chunk: FA-containerd-imagefs-bind
---

# review_ready — S3-cache-idempotence (`FA-hf-cache-desired-state`)

Cursor-direct Implementer pass (no multiagents). Inputs were the work queue row,
`performance-layout-adoption.md`, C1–C3, and the refined technical handoff.

## Target state claimed

- Deployment env uses `HF_HUB_CACHE` under the HF cache mount (default
  `/mnt/k3s-cache/hf/hub`).
- No `TRANSFORMERS_CACHE` in role desired-state / extra-args contract.
- No `huggingface-cli` shelling in this owner (C2 documented; C3 not in this
  owner — containerd template stays out of Light unless authorized).
- Token remains durable-root Secret (`HF_TOKEN`), not on NVMe cache tree.
- Already-cut-over `host_path` reruns skip migrate + post-cutover live gates
  unless cleanup apply is set.

## Owners changed (SHA-256)

| Path | SHA-256 |
| --- | --- |
| `roles/k3s_vllm_runtime/tasks/present.yml` | `c538871745cdacf50c20d28121e2d8535d8a04f34434db34ecc55af1179ec56a` |
| `roles/k3s_vllm_runtime/defaults/main.yml` | `26fce788c4425e6bcd0ed22c1f1a7f516af09498877f197f8beb280743366b42` |
| `roles/k3s_vllm_runtime/meta/argument_specs.yml` | `491edeabb3c8954a58742e42b98ad844f60555e96a29020315f6660fb5e482b9` |
| `roles/k3s_vllm_runtime/README.md` | `c00591013b61430bf49b9d1a133f859419eaa46bc4a4b21a6b53cf5b1e1028c4` |

## Bundled source validation (this turn)

| Check | Result |
| --- | --- |
| `ansible-playbook playbooks/deploy_vllm_runtime.yaml --syntax-check` | pass |
| `ansible-lint` on touched role YAML (`present.yml`, `defaults`, `argument_specs`) | pass (0 failure / 0 warning) |
| Owner search: no active `TRANSFORMERS_CACHE` / `huggingface-cli` task use | pass (comments/docs only) |

## Runtime companion (same turn; not Evaluator scope)

Patched Light parent blockers so a later multiagent run can start from the queue:

- scrub invalid tool `approval_mode: never` → `approve`
- force `workerAgentType='codex'`
- hard-fail Evaluator near-miss filenames (`ready_for_review_by_coordinator_*`)
- refuse Full-era tip resume under Light unless `allow_full_tip_resume: true`
- tip reset note: `coordination/light-tip-reset-2026-09-11.md`

## Evaluator ask

Does S3 / FA-hf-cache desired state land cleanly in `roles/k3s_vllm_runtime/**`
(Ansible-clean only)? No SSH, no S1–S6 matrix, no safety playbooks.
