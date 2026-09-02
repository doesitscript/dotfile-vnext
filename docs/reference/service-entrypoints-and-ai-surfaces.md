# Service Entrypoints And AI Surfaces

This is the quickest repo-native place to answer two operator questions:

- "What URLs can I open in a browser right now?"
- "Where are the LiteLLM, Langfuse, and related AI solution surfaces defined?"
- "Which playbook do I run to deploy my changes into the lab?"

## Deployment Entrypoints

Use the owner playbook for the surface you changed.

### Canonical entrypoints

| Goal | Preferred playbook | What it covers |
| --- | --- | --- |
| Broad active-lab converge | `playbooks/site.yaml` | Windows base, access, Hyper-V host infrastructure, guest lifecycle, Docker surfaces, and interim hosts-file publication |
| Hyper-V guest connectivity foundation | `playbooks/hyperv_guest_connectivity_foundation.yaml` | Access foundation, Windows host networking, guest lifecycle, mac guest routes, and hosts-file bridge |
| AI inference stack deploy | `playbooks/deploy_ai_inference_stack.yaml` | Storage/catalog prerequisite, GPU infra, `vLLM`, LiteLLM, Langfuse, client-profile validation, and inference-stack contract validation |

### Most common targeted deploys

| If you changed... | Run this |
| --- | --- |
| Windows LAN publish edge, portproxy, guest routes, or host networking | `ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml -i inventory/inventory.yaml` |
| SSH/access surfaces, controller SSH config, mac hosts-file, or mac kube client | `ansible-playbook playbooks/access.yaml -i inventory/inventory.yaml` |
| Shared backing services on the storage lane | `ansible-playbook playbooks/deploy_network_stacks.yaml -i inventory/inventory.yaml` |
| GPU runtime, K3s GPU node setup, `vLLM`, LiteLLM, Langfuse, Traefik routes, and mac kube refresh | `ansible-playbook playbooks/deploy_gpu_infrastructure.yaml -i inventory/inventory.yaml` |
| Full AI lane with validation at the end | `ansible-playbook playbooks/deploy_ai_inference_stack.yaml -i inventory/inventory.yaml` |
| Recover the shared AI lane after node pressure, eviction churn, or stale LiteLLM route publication | `ansible-playbook playbooks/recover_ai_inference_lane.yaml -i inventory/inventory.yaml` |

### What the AI stack entrypoint validates

`playbooks/deploy_ai_inference_stack.yaml` ends by running:

- `playbooks/validate_ai_agent_client_profiles.yaml`
- `playbooks/validate_ai_inference_stack_contracts.yaml`

That last validation playbook is the repo gate for the local inference contract. It asserts:

- expected LiteLLM lane names remain present
- enabled local gateway routes still exist
- migration/default routes are preserved
- the primary local `vLLM` route and secondary review route still match their declared backends

### Practical deploy order

When you want to push most infrastructure changes out in a safe repo-native order:

```bash
ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml -i inventory/inventory.yaml
ansible-playbook playbooks/access.yaml -i inventory/inventory.yaml
ansible-playbook playbooks/deploy_network_stacks.yaml -i inventory/inventory.yaml
ansible-playbook playbooks/deploy_ai_inference_stack.yaml -i inventory/inventory.yaml
```

If you only changed AI app/runtime surfaces, you can usually start at:

```bash
ansible-playbook playbooks/deploy_ai_inference_stack.yaml -i inventory/inventory.yaml
```

## Browser URLs

| Service | Recommended URL | Alternate / Notes | Source of truth |
| --- | --- | --- | --- |
| NetBox | `http://netbox.hom.lab:8000/` | `http://192.168.50.158:8000/` or `http://192.168.137.10:8000/` | `inventory/group_vars/all/homelab_hosts_file.yml`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |
| Semaphore | `http://semaphore.hom.lab:3001/` | `http://192.168.50.158:3001/` or `http://192.168.137.10:3001/` | `inventory/group_vars/all/homelab_hosts_file.yml`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |
| Loki | `http://loki.hom.lab:3100/ready` | `http://192.168.50.158:3100/ready` or `http://192.168.137.10:3100/ready` | `inventory/group_vars/all/homelab_hosts_file.yml`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |
| Grafana | `http://grafana.hom.lab:3000/` | guest-direct only: `http://192.168.137.10:3000/` | `inventory/group_vars/all/homelab_hosts_file.yml`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |
| Langfuse | `http://langfuse.hom.lab/` | NodePort: `http://langfuse.hom.lab:30000/`; raw IP: `http://192.168.50.158:30000/` or `http://192.168.137.11:30000/` | `inventory/group_vars/all/homelab_hosts_file.yml`, `roles/k3s_langfuse_platform/defaults/main.yml`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |
| LiteLLM | `http://litellm.hom.lab/` | NodePort: `http://litellm.hom.lab:30400/`; raw IP: `http://192.168.50.158:30400/` or `http://192.168.137.11:30400/` | `inventory/group_vars/all/homelab_hosts_file.yml`, `roles/k3s_litellm_gateway/defaults/main.yml`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |
| JupyterLab | `http://jupyter.hom.lab:8888/lab` | `http://192.168.137.11:8888/lab` | `inventory/group_vars/all/homelab_hosts_file.yml`, `roles/dev_jupyterlab_workbench/README.md`, `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md` |

## AI Surfaces

### LiteLLM gateway

- Browser surface: `http://litellm.hom.lab/`
- OpenAI-compatible API base URL for clients: `http://litellm.hom.lab/v1`
- Client profile contract: `inventory/group_vars/all/ai_agent_profiles.yml`
- Gateway and route contract: `roles/k3s_litellm_gateway/defaults/main.yml`

Important:
- `deepreinforce-ai/Ornith-1.0-35B-GGUF` is the client-facing LiteLLM lane alias, not the literal upstream vLLM weights identifier.
- The current primary local backend for that lane is `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ`, with vLLM tool calling enabled through the `hermes` parser.
- Context-overflow handling is owned by LiteLLM:
  - **Driving error (homelab):** Cursor Agent → Ornith returned
    `ContextWindowExceededError` / `Hosted_vllmException` with
    `maximum context length is 32768` / `input_tokens=32769` and
    “requested 0 output tokens”; `Available Model Group Fallbacks=None`.
    A trim budget of ~30000 still failed (`after≈29993` in hook logs vs vLLM
    32769) because of tokenizer skew, Agent `tools` schemas, and
    `max_tokens: 0`. Full write-up:
    `docs/diagnostics/litellm-context-window--k3s--diagnostics.md` and
    `roles/k3s_litellm_gateway/README.md` § Error that drove these custom values.
  - **Local trim hook (default):** server-tuned drivers in
    `roles/k3s_litellm_gateway/defaults/main.yml` — budget **24000**, safety
    **2048**, rewrite `max_tokens: 0` → **256**, subtract estimated `tools`
    size, multimodal hard-cut (**2.5** chars/token), then rollout restart
    (subPath remount; wait **600s**). See role README § Server-tuned trim
    drivers.
  - **Cloud fallback:** with OpenAI configured, oversize requests can also fall
    back toward `gpt-4o-mini`; without OpenAI, local aliases share the same 32k
    vLLM context so there is no larger local overflow path.
- `smart-router` is the LiteLLM complexity auto-router alias (`auto_router/complexity_router`, LiteLLM >= v1.94.x). It classifies SIMPLE/MEDIUM/COMPLEX/REASONING before the call (not confidence handoff). SIMPLE uses `code-review` (vLLM alias); MEDIUM uses Ornith; COMPLEX/REASONING escalate to Claude or `gpt-4o` when provider keys exist.
- `code-review` is a client-facing alias on `vllm-primary` (same Qwen2.5-Coder-32B AWQ backend as Ornith). Desktop Ollama is also published through LiteLLM for explicit, separate coding lanes; it is not an automatic fallback group.

Current client-facing lanes declared in the gateway contract:

| Lane / model name | State | Backend |
| --- | --- | --- |
| `deepreinforce-ai/Ornith-1.0-35B-GGUF` | enabled | primary local `vLLM` |
| `experiment` | enabled | primary local `vLLM` |
| `code-review` | enabled | primary local `vLLM` (alias until secondary runtime) |
| `smart-router` | enabled | LiteLLM complexity auto-router |
| `code-fast` | enabled | HVH-01 Ollama `qwen2.5-coder:1.5b` (same backend as autocomplete 1.5B) |
| `code-autocomplete-1.5b` | enabled | HVH-01 Ollama `qwen2.5-coder:1.5b` |
| `ministral-3-8b@desktop` | experimental | desktop Ollama `ministral`, 24K context; current `codex-homelab desktop` target on mac-dev because it aligns with the repo tool-call surface |
| `qwen2.5-coder-14b@desktop` | experimental | desktop Ollama `qwen2.5-coder:14b`, 12K context; retained only as a concise coding-chat lane because prior Codex runs formed unexecuted tool JSON |
| `gpt-oss-20b` | commissioned in catalog | desktop Ollama `gpt-oss:20b`, ~14GB class; selected in the 2026-09-02 EVAL note for host presence on `dev-workstation-win`, but not yet published as a separate Codex client lane |

The desktop model and context are declared through
`windows_ollama_runtime` host variables, its LiteLLM publication is declared
through `k3s_litellm_gateway` host variables, and the macOS Codex entrypoint is
rendered by `playbooks/deploy_codex_homelab_profiles.yaml`. The launcher looks
up its gateway secret at invocation time rather than placing it in inventory.
| `code-test` | blocked | pending |
| `ripi-private` | blocked | pending |
| `embeddings-local` | blocked | pending |
| `public-research` | blocked | pending |
| `gpt-4o-mini` | enabled migration route | OpenAI |
| `gpt-4o` | enabled cloud escalation | OpenAI (when key set) |
| `claude-sonnet` | optional cloud escalation | Anthropic (when `vault_shared_anthropic_api_key` set) |
| `default` | enabled migration/default route | OpenAI or local-default fallback when OpenAI is absent |

Where to inspect the list:

- lane vocabulary and enablement: `roles/k3s_litellm_gateway/defaults/main.yml`
- actual `model_list` routes exposed by the gateway: `roles/k3s_litellm_gateway/defaults/main.yml`
- client role-to-lane defaults: `inventory/group_vars/all/ai_agent_profiles.yml`

### Langfuse

- Browser surface: `http://langfuse.hom.lab/`
- Alternate NodePort surface: `http://langfuse.hom.lab:30000/`
- Platform hostname contract: `roles/k3s_langfuse_platform/defaults/main.yml`
- LiteLLM callback integration: `roles/k3s_litellm_gateway/defaults/main.yml`

Where to inspect the integration:

- platform hostname / release defaults: `roles/k3s_langfuse_platform/defaults/main.yml`
- LiteLLM success callback -> Langfuse wiring: `roles/k3s_litellm_gateway/defaults/main.yml`
- Jupyter/operator env wiring to Langfuse: `roles/dev_jupyterlab_workbench/README.md`

### Jupyter workbench

- Browser surface: `http://jupyter.hom.lab:8888/lab`
- Operator doc: `roles/dev_jupyterlab_workbench/README.md`
- This workbench is already wired to the shared Langfuse and LiteLLM surfaces, not a separate stack.

## Service Catalog Sources

If you want the actual repo source-of-truth files instead of the rendered URLs:

- Hostname -> verify URL web catalog: `inventory/group_vars/all/homelab_hosts_file.yml`
- Rendered browser/service matrix: `docs/diagrams/cst-hom-lab-ctl-dia-gpu-services-01.md`
- Broader host/guest topology map: `docs/diagrams/cst-hom-lab-ctl-dia-homelab-estate-04.md`
- LiteLLM runtime, model routes, and Langfuse callback contract: `roles/k3s_litellm_gateway/defaults/main.yml`
- Langfuse platform hostname and deployment defaults: `roles/k3s_langfuse_platform/defaults/main.yml`
- Client-facing gateway contract: `inventory/group_vars/all/ai_agent_profiles.yml`

## Quick answer

If you just want the main AI surfaces:

- Langfuse UI: `http://langfuse.hom.lab/`
- LiteLLM gateway UI / ingress: `http://litellm.hom.lab/`
- LiteLLM client API base: `http://litellm.hom.lab/v1`
- Jupyter workbench: `http://jupyter.hom.lab:8888/lab`


##### This workds and i get the swagger endpoitn

version: "3"
agent:
    authtoken: 3GKCxl41fOzNNZUenCH5PWSEfSq_2LwGiXGQBBo5RGbKXboBG
    api_key: 3GKA0nT6tXLQYZIVu73GdLzWwk9_44Q92bUKq8mwjofDPG9Hy

endpoints:
  - name: litellm-internal
    url: http://litellm.internal:30400
    upstream:
      url: http://192.168.50.158:30400

  - name: litellm-public
    url: 
    upstream:
      url: http://192.168.50.158:30400
