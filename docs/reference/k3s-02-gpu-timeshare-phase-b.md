# k3s-02 GPU time-share — Phase B on vs off

`hom-lab-ctl-k3s-02` has one GPU. Two mutually exclusive setups share it.

Inventory source of truth:
`inventory/host_vars/hom-lab-ctl-k3s-02.yaml`
(`k3s_vllm_runtime_state` / `k3s_comfyui_runtime_state`).

## What ComfyUI is (Phase B)

From the upstream project ([ComfyUI](https://github.com/Comfy-Org/ComfyUI)):

> The most powerful and modular diffusion model GUI, api and backend with a
> graph/nodes interface.
>
> ComfyUI is the AI creation engine for visual professionals who demand control
> over every model, every parameter, and every output. Its powerful and modular
> node graph interface empowers creatives to generate images, videos, 3D models,
> audio, and more…

In this lab, Phase B means ComfyUI runs on the RTX 5090 via
`roles/k3s_comfyui_runtime` / `playbooks/deploy_comfyui_runtime.yaml`
(`http://comfyui.hom.lab:30188/`).

## Setup A — Phase B off (steady-state)

| Piece | State |
| --- | --- |
| Ornith / vLLM | **present** (LiteLLM chat backend) |
| ComfyUI | **absent** |
| LiteLLM gateway | stays up |

Inventory:

```yaml
k3s_vllm_runtime_state: present
k3s_comfyui_runtime_state: absent
k3s_ollama_runtime_state: absent
```

Apply (Comfy down first, then Ornith up):

```bash
ansible-playbook playbooks/deploy_comfyui_runtime.yaml --limit hom-lab-ctl-k3s-02
ansible-playbook playbooks/deploy_vllm_runtime.yaml --limit hom-lab-ctl-k3s-02
```

Verify: LiteLLM `http://litellm.hom.lab` liveliness; vLLM models via the
cluster service; ComfyUI URL should not respond.

## Setup B — Phase B on

| Piece | State |
| --- | --- |
| ComfyUI | **present** (holds the GPU) |
| Ornith / vLLM | **absent** |
| LiteLLM gateway | stays up (desktop Ollama lanes still work; Ornith lane pauses) |

Inventory:

```yaml
k3s_vllm_runtime_state: absent
k3s_comfyui_runtime_state: present
k3s_ollama_runtime_state: absent
```

Apply (Ornith down first, then Comfy up):

```bash
ansible-playbook playbooks/deploy_vllm_runtime.yaml --limit hom-lab-ctl-k3s-02
ansible-playbook playbooks/deploy_comfyui_runtime.yaml --limit hom-lab-ctl-k3s-02
```

Verify: `curl -sS http://comfyui.hom.lab:30188/system_stats`

## Notes

- Only one of `k3s_vllm_runtime` / `k3s_comfyui_runtime` / `k3s_ollama_runtime`
  should request `nvidia.com/gpu: 1` at a time.
- Guest root disk is tight (~77 Gi). Large Comfy model PVCs plus a fresh vLLM
  image pull can trigger DiskPressure — keep free space before flipping.
- Phase A image gen (A1111 on HVH-01) is separate and does not use this flip.

Related: [local-ai-chat-and-image-stack.md](local-ai-chat-and-image-stack.md) ·
`roles/k3s_comfyui_runtime/README.md` · `roles/k3s_vllm_runtime/README.md`
