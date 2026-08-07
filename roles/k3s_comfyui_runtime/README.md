# k3s_comfyui_runtime

ComfyUI on the GPU-lane K3s guest (`hom-lab-ctl-k3s-02` / RTX 5090).

**Time-share:** only one of `k3s_comfyui_runtime` / `k3s_vllm_runtime` /
`k3s_ollama_runtime` should hold `nvidia.com/gpu: 1` at a time.

**Operator flip (Phase B on/off + playbooks):**
[`docs/reference/k3s-02-gpu-timeshare-phase-b.md`](../../docs/reference/k3s-02-gpu-timeshare-phase-b.md)

## Lifecycle

- `k3s_comfyui_runtime_state: present|absent` (default `absent`)

## Apply / Verify / Undo

| | |
| --- | --- |
| **Apply** | Set `k3s_vllm_runtime_state: absent` then `k3s_comfyui_runtime_state: present`; run `playbooks/deploy_comfyui_runtime.yaml` (and vLLM playbook for absent) |
| **Verify** | `curl http://comfyui.hom.lab:30188/system_stats` (or LAN publish IP) |
| **Undo** | `k3s_comfyui_runtime_state: absent` + re-run; restore `k3s_vllm_runtime_state: present` for Ornith |
| **Change class** | Idempotent K8s; first image pull is long |

## Models (Phase B starter)

PVC mount: `/mnt/comfy-models` (symlinked into `/root/ComfyUI/models/*` by
`files/pre-start.sh`).

Selected weights (role defaults):

- `flux1-dev-fp8.safetensors` — primary stills (`diffusion_models/`)
- `sd_xl_base_1.0.safetensors` — LoRA / ControlNet companion (`checkpoints/`)
- `clip_l.safetensors` + `t5xxl_fp8_e4m3fn.safetensors` — text encoders
- `ae.safetensors` — FLUX VAE
- `ltx-video-2b-v0.9.5.safetensors` — starter I2V

Downloads: `k3s_comfyui_runtime_download_models: true` (default) via
`tasks/download_models.yml`.

## Module matrix

- `k3s_node_gpu_prereqs`
- `kubernetes.core.k8s` / `k8s_info`
- `ansible.builtin.command` (`kubectl exec`) for PVC downloads
