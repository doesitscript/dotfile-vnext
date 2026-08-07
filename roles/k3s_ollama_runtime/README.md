# k3s_ollama_runtime

Deploys Ollama (OpenAI-compatible `:11434/v1`) on the GPU-lane K3s guest.

Intended as a **GPU swap** with `k3s_vllm_runtime` — only one of them should hold
`nvidia.com/gpu: 1` at a time on a single-GPU node.

## Lifecycle

- `k3s_ollama_runtime_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_ollama_runtime.yaml` |
| **Verify** | `kubectl get pods -n ollama-runtime`; `curl …/api/tags` |
| **Undo** | `k3s_ollama_runtime_state: absent` + re-run; then restore vLLM |
| **Change class** | Idempotent K8s config; model pulls are declarative presence |

## Notes

- Models: `k3s_ollama_runtime_models_present` (Ollama library tags).
- LiteLLM: set `k3s_litellm_gateway_gemma4_chat_api_base` to the in-cluster
  `http://ollama.ollama-runtime.svc.cluster.local:11434/v1` and re-apply the
  LiteLLM gateway playbook so Open WebUI can list the alias.
