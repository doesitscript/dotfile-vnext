# Service Entrypoints And AI Surfaces

This is the quickest repo-native place to answer two operator questions:

- "What URLs can I open in a browser right now?"
- "Where are the LiteLLM, Langfuse, and related AI solution surfaces defined?"

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

Current client-facing lanes declared in the gateway contract:

| Lane / model name | State | Backend |
| --- | --- | --- |
| `code-deep` | enabled | primary local `vLLM` |
| `experiment` | enabled | primary local `vLLM` |
| `code-review` | enabled | secondary local `Ollama` on `HOM-LAB-HVH-01` |
| `code-fast` | blocked | pending |
| `code-test` | blocked | pending |
| `ripi-private` | blocked | pending |
| `embeddings-local` | blocked | pending |
| `public-research` | blocked | pending |
| `gpt-4o-mini` | enabled migration route | OpenAI |
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
