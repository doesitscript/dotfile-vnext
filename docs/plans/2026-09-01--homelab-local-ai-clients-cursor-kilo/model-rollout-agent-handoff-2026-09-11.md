# New-agent handoff: 5090 model rollout and validation

Copy the prompt below into a new agent chat.

```text
You are taking over the remaining 5090 model rollout work in
/Users/joshc/develop/dotfile-vnext.

Goal: finish the model deployment and validation phase without repeating the
completed K3s storage migration. First establish a current plan/receipt, then
implement only through repository-owned Ansible roles/playbooks, and prove live
state plus idempotence.

Completed prerequisite — do not redo unless drift is found:
- hom-lab-ctl-k3s-02 has separate 300 GiB /mnt/k3s-cache and 32 GiB
  /mnt/k3s-logs guest VHDXs.
- containerd, local-path, HF cache, and native podLogsDir are off root.
- Root is approximately 21% used; node is Ready and DiskPressure=False.
- The three HVH-02 SSDs are separate NTFS host volumes, not RAID0.
- Current active vLLM deployment is 1/1 Ready and serves
  cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit with
  HF_HUB_CACHE=/mnt/k3s-cache/hf/hub.
- Storage evidence: docs/plans/2026-09-10--k3s-02-storage-upgrade/post_2026-09-11.md,
  implementation-receipt.md, and validation_todo_2026-09-11.md.

Read these before changing anything:
1. docs/brainstorming_designs/2026-09-10--5090-model-lane-evaluation/model-selection-reasoning.md
2. docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/README.md
3. docs/plans/2026-09-10--k3s-02-storage-upgrade/README.md and post_2026-09-11.md
4. inventory/group_vars/model_catalog/manifest.yml and SOURCE-ROUTING.md
5. docs/plans/2026-09-10--validations-agent-lane-fitness/README.md plus the
   existing lite-eval entry/report/results
6. roles/k3s_vllm_runtime/, roles/k3s_litellm_gateway/,
   roles/continue_ide/, roles/opencode_cli/, and their meta/defaults/tasks

Relevant playbooks:
- playbooks/download_5090_models.yaml
- playbooks/deploy_vllm_runtime.yaml
- playbooks/deploy_litellm_gateway.yaml
- playbooks/deploy_ai_inference_stack.yaml
- playbooks/validate_ai_inference_stack_contracts.yaml
- playbooks/validate_kilo_litellm_probes.yaml
- playbooks/deploy_continue_model_lanes.yaml
- playbooks/deploy_continue_ide.yaml and playbooks/deploy_opencode_cli.yaml
- playbooks/recover_ai_inference_lane.yaml

Resolve these contradictions before implementation:
- Research names five candidates (Qwen3-Coder, Qwen3.6, gpt-oss-20b,
  Devstral Small 2, GLM-4.6), but download_5090_models.yaml downloads only
  four.
- The catalog says the primary selected repo is Qwen/Qwen3-Coder..., the
  downloader requests an unsloth GGUF, while the live vLLM deployment uses a
  cyankiwi AWQ repo. Establish one authoritative artifact per lane and record
  why.
- Model catalog entries are still downloading/selected with null UNC paths and
  pending HRL packs. Do not mark them deployed from catalog status alone.
- The Kilo plan is beta/incomplete and still has unchecked Qwen3/Kilo items.
- A single vLLM Deployment cannot serve all large candidates simultaneously
  within one 32 GiB 5090 without an explicit swap/multi-model design. Decide
  whether the phase is sequential model swapping, separate compatible lanes,
  or evaluation-only downloads.

Required work:
1. Discover current files, weights, routes, deployments, GPU/VRAM, and live
   API behavior. Preserve raw evidence and do not assume downloads completed.
2. Produce a small implementation plan and model disposition table:
   selected, downloaded, deployed, validated, deferred, rejected, or
   catalog-only. Include exact artifact repo/quantization, path, runtime,
   route/model ID, and rollback.
3. Replace fire-and-forget or non-idempotent downloader behavior with an
   Ansible-owned, resumable, observable, repeatable workflow if downloads are
   still required. Do not use an ad-hoc installer or background shell job.
4. Implement model deployment/swap and LiteLLM/client route changes through
   existing roles. Keep storage paths on /mnt/k3s-cache and do not introduce
   RAID0, root-backed cache, pagefile/hibernation relocation, or unowned
   symlinks.
5. Validate each model actually selected for deployment: pod readiness, model
   endpoint, inference, tool-calling where applicable, GPU/VRAM fit, cache
   location, DiskPressure, and client/gateway route behavior.
6. Run the existing lite-eval suite and Kilo probes where their scope applies;
   report skipped tests honestly.
7. Run every changed present-state playbook twice. The second run must be
   changed=0. Test safe drift repair for route/config/cache declarations.
8. Update the appropriate model plan, catalog statuses, implementation receipt,
   and a dated follow-up note. Keep historical brainstorm/v0 documents
   explicitly historical; do not leave them looking executable.

Stop conditions:
- Stop before destructive downloads, disk changes, or model swaps if exact
  artifact identity, target, capacity, or rollback is unresolved.
- Do not claim all models are deployed unless each has live evidence.
- Do not conflate a LiteLLM route with downloaded weights or a Ready pod with
  successful inference.

Final output must include: files changed, exact live disposition for every
candidate, commands/playbooks run, first/second-run changed counts, validation
results, remaining work, and rollback instructions.
```
