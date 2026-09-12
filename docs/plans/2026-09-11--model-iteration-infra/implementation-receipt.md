# Implementation receipt — model iteration infrastructure

**Date:** 2026-09-11
**Scope:** repository implementation only; no remote download or model swap

## Changes applied

- Added `roles/huggingface_model_weights/` with `present|absent` lifecycle,
  bounded per-lane directories, completion receipts, and resumable download
  invocation.
- Replaced the downloader's asynchronous `poll: 0` tasks with a foreground
  role invocation in `playbooks/download_5090_models.yaml`.
- Corrected the Qwen3 primary artifact to
  `cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit`.
- Kept the model-share target on `HOM-LAB-HVH-01`; the 5090 serving/cache
  target remains the separate K3s guest.
- Added the four HF artifact directory/owner fields to the model catalog and
  left `unc_path` unset until an Ansible apply produces evidence.
- Classified Devstral and GLM GGUF entries as `llama.cpp` evaluation artifacts;
  this does not publish a vLLM or LiteLLM route for them.
- Replaced the damaged plan text with a governed incomplete packet and added a
  packet `README.md`.

## Fresh verification evidence

| Command | Result | Proof |
| --- | --- | --- |
| `bin/codex-env ansible-playbook playbooks/download_5090_models.yaml --syntax-check -i inventory/inventory.yaml` | exit 0 | `playbook: playbooks/download_5090_models.yaml` |
| `bin/codex-env ansible-playbook playbooks/download_5090_models.yaml --list-hosts -i inventory/inventory.yaml` | exit 0 | exactly one target: `HOM-LAB-HVH-01` |
| `bin/codex-env python -m py_compile scripts/download_hf_model.py` | exit 0 | helper compiled successfully |
| `git diff --check` | exit 0 | no whitespace errors |

An earlier syntax attempt failed because the playbook had duplicate YAML
document markers; that was removed. The next attempt failed because the new
role used free-form `include_tasks`; it was corrected to the explicit `file:`
form and the final syntax check passed.

## Not run

- No `--check` remote preview was run because the role's first-run share state
  and the plan's target verification still need to be captured through the
  approved Windows connection surface.
- No live `present` apply was run, so no weight tree is claimed downloaded and
  no catalog `unc_path` was populated.
- No vLLM swap, LiteLLM route change, E1-E4 evaluation, or Kilo probe was run.
- First/second-run Ansible changed counts remain pending live execution.

## Rollback

Use the role with `huggingface_model_weights_state=absent` and an explicit lane
list to remove only owned trees. Runtime rollback remains the existing retained
deployment path in `roles/k3s_vllm_runtime/`.
