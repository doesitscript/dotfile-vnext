# Homelab model runbooks

Steady-state operator and research notes for **models this repo actually serves**
through LiteLLM, Ollama, or vLLM.

Use this directory when you are:

- researching a lane swap or quantization change
- re-tuning VRAM / context / concurrency on a GPU host
- documenting probe evidence after a tuning pass

## How this relates to other sources

| Surface | Role |
| --- | --- |
| **`docs/reference/models/*.md`** (here) | Human-readable runbooks: what we picked, why, knobs, probes, lessons |
| **`inventory/group_vars/model_catalog/manifest.yml`** | Catalog SSOT: lane status, HF repo IDs, selection gates |
| **`inventory/host_vars/<host>.yaml`** | Live tuning vars (`k3s_vllm_runtime_*`, Ollama model lists) |
| **`inventory/group_vars/*_hosts/main.yml`** | Client-facing research matrices (Continue, Kilo, etc.) |
| **Plan `diagrams/`** | Visual artifacts tied to a plan slice (VRAM bars, routing) |
| **HRL `notes/investigations/`** | Cross-repo investigation receipts when promoted |

When you complete a tuning or research pass:

1. Run live probes and capture HTTP / `nvidia-smi` evidence.
2. Update the relevant runbook here (decision, knobs, probe date).
3. Update `model_catalog/manifest.yml` status only when selection gates are met.
4. Update host_vars if Ansible defaults changed.
5. Link new diagrams from the runbook (plan `diagrams/` or add under this folder).

## Runbooks

| Model / lane | Doc | Host | Status |
| --- | --- | --- | --- |
| Google Gemini free-tier (LiteLLM cloud) | [gemini-litellm-lanes.md](./gemini-litellm-lanes.md) | `litellm.hom.lab` | **Implemented** — gated on `vault_shared_gemini_api_key` |
| Qwen2.5-Coder 14B vs 32B AWQ on 5090 | [5090-qwen25-coder-14b-vs-32b.md](./5090-qwen25-coder-14b-vs-32b.md) | `hom-lab-ctl-k3s-02` | **32B selected**; 14B rejected |

## Related

- [Local AI chat + image stack](../local-ai-chat-and-image-stack.md)
- [k3s-02 GPU time-share Phase B](../k3s-02-gpu-timeshare-phase-b.md)
- [GPU-P operational contracts](../gpu-p-operational-contracts.md)
- Plan: [homelab-local-ai-clients-cursor-kilo](../../plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/README.md)
