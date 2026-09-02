# k3s_vllm_runtime

Deploys an OpenAI-compatible vLLM runtime on `hom-lab-ctl-k3s-02`.

The role uses the official `vllm/vllm-openai` image pattern and fails before
mutation if the node does not expose `nvidia-smi` and Kubernetes
`nvidia.com/gpu` capacity.

## Vault

| Vault file | Variable |
| --- | --- |
| `vault/shared.vault.yml` | `vault_hf_token` — written into the vLLM env Secret as `HF_TOKEN` when set |

```bash
bin/codex-env ansible-vault edit vault/shared.vault.yml
# vault_hf_token: "hf_..."
```

## Apply

```bash
ansible-playbook playbooks/deploy_vllm_runtime.yaml -i inventory/inventory.yaml
```

## Verify

```bash
kubectl get pods -n vllm-runtime
kubectl get svc -n vllm-runtime
kubectl get secret -n vllm-runtime vllm-primary-env
```

Then query the OpenAI-compatible models endpoint:

```bash
curl http://vllm-primary.vllm-runtime.svc.cluster.local:8000/v1/models
```

## Memory policy

KV-cache pressure is **GPU VRAM**, not guest system RAM.

When vLLM fails with insufficient KV cache:

1. Prefer raising `--gpu-memory-utilization` within measured free VRAM.
2. Reduce competing GPU workloads (for example ComfyUI time-share).
3. Do **not** trim model context length unless the operator explicitly asks.

Host-specific tuning: `inventory/host_vars/hom-lab-ctl-k3s-02.yaml`.

## Kilo testing lane (14B AWQ)

When `k3s_vllm_runtime_kilo_testing_active: true` on k3s-02, primary vLLM serves
`Qwen/Qwen2.5-Coder-14B-Instruct-AWQ` with `--max-model-len 32768` and
`--tool-call-parser hermes`.

**Known limitation (Qwen2.5-Coder + hermes):** Qwen2.5-Coder emits tool intent in
`message.content` (`<tools>` JSON) with `tool_calls: null`. vLLM hermes parser does
not extract this format.

**Fix (homelab):** use the community `qwen2_5_coder` parser plugin
(`roles/k3s_vllm_runtime/files/qwen2_5_coder_tool_parser.py`) with
`k3s_vllm_runtime_tool_parser_plugin_enabled: true`. Runbook:
`docs/reference/models/5090-qwen25-coder-14b-vs-32b.md`.

| Action | Playbook |
| --- | --- |
| Apply / change vLLM | `playbooks/deploy_vllm_runtime.yaml` |
| Revert to 32B | Remove testing block in host_vars; redeploy vLLM + gateway |

Investigation: `homelab-reference-library/notes/investigations/2026-09-01--kilo-code-litellm-vllm-context-limits.md`.

## References

- vLLM Docker deployment: https://docs.vllm.ai/en/latest/deployment/docker.html
- vLLM Kubernetes deployment: https://docs.vllm.ai/deployment/k8s.html
