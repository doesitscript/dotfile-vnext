# 04 - vLLM Runtime And Hugging Face Model Cache

## Goal

Deploy a first GPU-backed vLLM runtime and model cache path, starting with a
small model before scaling up.

## Preliminary Project Structure And Resources

Expected project areas:

- `roles/k3s_node_gpu_prereqs/`: prepare Ubuntu/k3s GPU node prerequisites if
  not already covered by baseline automation.
- `roles/k3s_nvidia_gpu_operator/` or equivalent: expose GPU resources to k3s.
- `roles/k3s_vllm_runtime/`: deploy vLLM runtime workloads and services.
- `roles/hf_model_cache/`: manage Hugging Face token/cache conventions and
  optional prefetch behavior.
- `playbooks/`: add or extend a GPU/runtime playbook with tags for prereqs,
  GPU validation, vLLM, and Hugging Face cache.
- `inventory/group_vars/`: define GPU target lane, model ID, image tag, cache
  PVC size, GPU count, service port, and LiteLLM route name.
- Vault or ignored secret files: store Hugging Face token and any gated model
  credentials.
- NetBox: track GPU-capable server/VM placement and runtime service endpoints.

Expected Kubernetes resources:

- GPU validation pod or job
- NVIDIA device plugin/GPU Operator resources
- namespace
- Hugging Face token secret
- model cache PVC
- vLLM deployment using `vllm/vllm-openai`
- vLLM service on port 8000
- optional ingress
- LiteLLM route to the vLLM service

## Implementation Intent

- Role name candidates:
  - `k3s_vllm_runtime`
  - `hf_model_cache`
- Target the RTX 5090 server lane for inference unless the storage/network
  server GPU is proven suitable for the selected model.
- Validate GPU visibility in the Ubuntu k3s VM first.
- Install NVIDIA driver/container runtime prerequisites and device plugin or GPU
  Operator as needed.
- Deploy `vllm/vllm-openai` with a Hugging Face model ID and persistent model
  cache volume.
- Start with a small model such as `Qwen/Qwen3-0.6B` to prove CUDA,
  Kubernetes GPU scheduling, Hugging Face download/cache, vLLM service routing,
  and LiteLLM integration.
- Treat OpenClaw as a client/tool layer unless a specific model ID is later
  selected.

## Acceptance Criteria

- A CUDA/GPU test pod works on the target k3s node.
- vLLM serves an OpenAI-compatible API on port 8000.
- Model weights are cached in a persistent Hugging Face cache volume.
- LiteLLM routes to the vLLM service with a friendly model name.
- Larger models are deferred until the first small-model pipe is proven.
