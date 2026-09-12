# AI CLI infra cogs — ASCII layout

Companion to [`ai_cli_apps.yml`](./ai_cli_apps.yml) intake. Shows the
**software and servers** that turn when commissioned model lanes move.

```text
                         ┌─────────────────────────────────────┐
                         │  CLIENT EDGE (no GPU models here)   │
                         │  mac-dev  ·  work-laptop (packet)   │
                         │                                     │
                         │  Continue  Cline  OpenCode  Kilo    │
                         │  Aider     Codex profiles           │
                         │  apiBase → http://litellm.hom.lab/v1│
                         └──────────────────┬──────────────────┘
                                            │
                                            │  model@host ids
                                            │  (ai_cli_commissioned_models)
                                            ▼
                         ┌─────────────────────────────────────┐
                         │  GATEWAY COG                        │
                         │  litellm.hom.lab  (K3s on k3s-02)   │
                         │  role: k3s_litellm_gateway          │
                         │  /v1/models  /v1/chat/completions   │
                         │  /v1/completions  /v1/embeddings    │
                         └─┬─────────────┬───────────────┬─────┘
                           │             │               │
           ┌───────────────┘             │               └───────────────┐
           ▼                             ▼                               ▼
┌─────────────────────┐    ┌─────────────────────────┐    ┌─────────────────────┐
│ PRIMARY CHAT COG    │    │ DESKTOP OLLAMA COG      │    │ HVH-01 OLLAMA COG   │
│ HOM-LAB-HVH-02      │    │ dev-workstation-win     │    │ HOM-LAB-HVH-01      │
│ guest: k3s-02       │    │ RX 9060 XT 16GB         │    │ GTX 1060 6GB        │
│ GPU: RTX 5090 32GB  │    │                         │    │                     │
│                     │    │ windows_ollama_runtime  │    │ windows_ollama_     │
│ k3s_vllm_runtime    │    │ :11434                  │    │ runtime :11434      │
│ Qwen3.6 / Coder     │    │                         │    │                     │
│ qwen3.6-35b-a3b     │    │ 14b  → edit             │    │ 1.5b-base → FIM     │
│ (k3s-02 vLLM note)  │    │                         │    │                     │
│                     │    │ 7b   → apply            │    │ nomic    → embed    │
│ (do not park aux    │    │ gpt-oss / ministral …   │    │ (instruct 1.5b keep)│
│  FIM/embed here)    │    │ *@desktop               │    │ *@hvh01             │
└─────────────────────┘    └─────────────────────────┘    └─────────────────────┘

Optional cloud cog (same LiteLLM face):
  Gemini flash/pro/lite  ·  gemini-embedding-001@google~embeddings
```

## Cog → Ansible role

| Cog | Inventory host | Role / playbook |
| --- | --- | --- |
| Client edge | `mac-dev` | `continue_ide`, `cline_ide`, `opencode_cli`, `kilo_ide`, `aider`, `codex_homelab_profiles` via `deploy_development_nodes` `--tags ai_cli_apps` |
| Gateway | `hom-lab-ctl-k3s-02` | `k3s_litellm_gateway` / `deploy_litellm_gateway.yaml` |
| Primary chat | `hom-lab-ctl-k3s-02` | `k3s_vllm_runtime` |
| Desktop Ollama | `dev-workstation-win` | `windows_ollama_runtime` / `deploy_dev_workstation_ollama_runtime.yaml` |
| HVH-01 Ollama | `HOM-LAB-HVH-01` | `windows_ollama_runtime` / `deploy_hvh01_secondary_model_runtime.yaml` |

## How the cogs ring on a Continue keystroke / action

```text
Autocomplete (typing)
  Continue → LiteLLM → HVH-01 Ollama 1.5b-base  (/v1/completions FIM)

Embed (@Codebase)
  Continue → LiteLLM → HVH-01 Ollama nomic-embed-text  (/v1/embeddings)

Edit
  Continue → LiteLLM → desktop Ollama 14b  (/v1/chat/completions)

Apply
  Continue → LiteLLM → desktop Ollama 7b

Chat / Agent
  Continue → LiteLLM → k3s-02 vLLM Qwen3.6  (or Gemini / gpt-oss routes)
```

## Related

- Dependents table: [`ai_cli_apps-INTAKE.md`](./ai_cli_apps-INTAKE.md)
- Worked placement plan: `docs/plans/2026-09-12-mac_and_model_recommend/`
