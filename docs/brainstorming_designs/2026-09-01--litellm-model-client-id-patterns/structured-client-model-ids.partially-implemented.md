---
title: "Structured LiteLLM client model IDs (partially implemented)"
status: partially-implemented
implemented_at: 2026-09-01
execution_status: partially-implemented
authority: homelab-operator-session
supersedes_client_ids:
  - deepreinforce-ai/Ornith-1.0-35B-GGUF
  - code-fast
  - devstral-24b
  - smart-router
---

# Structured LiteLLM client model IDs (partially implemented)

Homelab choice for **client-facing** LiteLLM `model_list[].model_name` values.
This file is the brainstorm design record for what was built and deployed; repo
SSOT for the variable map is
`roles/k3s_litellm_gateway/defaults/main/model_client_ids.yml`.

Compare with [chatgpt-infrastructure-neutral-model-naming-notes.md](chatgpt-infrastructure-neutral-model-naming-notes.md)
(infrastructure-neutral IDs — **not** what the gateway exposes today).

---

## Syntax

```text
<model-slug>@<host-slug>~<friendly-lane>
```

| Segment | Meaning |
| --- | --- |
| `model-slug` | Backend weight id (`:` and `/` → `-`) |
| `@` | Separates **model** from **server** |
| `host-slug` | Homelab surface (`desktop`, `hvh01`, `k3s02-vllm`, `openai`, `anthropic`, `litellm`) |
| `~` | Separates **server** from **purpose** |
| `friendly-lane` | Invented client purpose (`code-fast`, `kilo-main`, `smart-router`, …) |

**Why `@` and `~`?** They are rare in model tags and HF repo ids, so a single
string stays machine-parseable without ambiguous hyphen runs.

---

## Entry kinds (comments in Ansible + `model_info`)

| Kind | Meaning | Example |
| --- | --- | --- |
| **FRIENDLY ALIAS** | One backend `model` + `api_base` | `qwen2.5-coder-32b@k3s02-vllm~kilo-main` |
| **MODEL GROUP** | Router; tier values are other client `model_name` aliases | `litellm-complexity-auto-router@litellm~smart-router` |

Set `model_info.client_model_id_kind` to `friendly_alias` or `model_group` where
the route is built. Add a `notes` line such as:

- `FRIENDLY ALIAS — qwen2.5-coder-32b@k3s02-vllm~kilo-main`
- `MODEL GROUP — LiteLLM complexity auto-router; tier values are other client model_name aliases.`

---

## Catalog vs client ID

| Surface | Holds | Example |
| --- | --- | --- |
| Client `model_name` | Structured homelab id | `qwen2.5-coder-32b@k3s02-vllm~coder-primary` |
| `model_info.model_lane` | Short catalog / trace slug | `Qwen/Qwen2.5-Coder-32B-Instruct-AWQ` |
| `k3s_litellm_gateway_lane_contract[].lane` | Vocabulary + enablement | `code-fast`, `smart-router` |

Do not collapse these three layers without an explicit migration plan.

---

## Example map (live)

| Client `model_name` | Kind | Backend |
| --- | --- | --- |
| `qwen2.5-coder-32b@k3s02-vllm~coder-primary` | FRIENDLY ALIAS | vLLM Qwen2.5-Coder-32B AWQ on 5090 |
| `qwen2.5-coder-32b@k3s02-vllm~kilo-main` | FRIENDLY ALIAS | Same 5090 backend — Kilo Code primary |
| `qwen2.5-coder-1.5b@hvh01~kilo-autocomplete` | FRIENDLY ALIAS | Ollama on HVH-01 (1060) |
| `devstral-24b@desktop~open-webui-coder` | FRIENDLY ALIAS | Desktop Ollama — Open WebUI, not Kilo |
| `qwen2.5-coder-14b@k3s02-vllm~kilo-lite` | FRIENDLY ALIAS | 5090 vLLM 14B AWQ — **smoke/chat only** (Kilo agent tools broken) |
| `ministral-3-8b@desktop~kilo-fast` | FRIENDLY ALIAS | Desktop Ollama — interim Kilo agent fallback; API tool_calls OK |
| `litellm-complexity-auto-router@litellm~smart-router` | MODEL GROUP | Complexity auto-router |

Full list: `roles/k3s_litellm_gateway/defaults/main/model_client_ids.yml`.

---

## Implemented in repo (2026-09-01)

- `roles/k3s_litellm_gateway/` — `model_client_ids.yml`, `defaults/main.yml`,
  `build_helm_values.yml`, README client-ID section
- `inventory/group_vars/all/ai_agent_profiles.yml` — gateway lane strings
- `roles/continue_ide/defaults/main.yml`, `inventory/host_vars/mac-dev.yaml`
- `.cursor/rules/framework-ai-agent-model-lanes.mdc`
- `playbooks/validate_ai_inference_stack_contracts.yaml`,
  `playbooks/recover_ai_inference_lane.yaml`
- LiteLLM gateway **redeployed** — `GET http://litellm.hom.lab/v1/models` exposes
  structured ids only (no legacy flat aliases)

---

## Not done / open (why `.partially-implemented`)

- [ ] Converge older docs, diagrams, and catalog rows still citing flat ids
      (`code-fast`, `deepreinforce-ai/Ornith-1.0-35B-GGUF`, …)
- [ ] Optional **legacy alias** routes for backward-compatible clients
- [ ] Display-metadata layer (human titles in Open WebUI / Kilo separate from
      `model_name`) — related to ChatGPT notes
- [ ] Evaluate infrastructure-neutral public ids + host in `model_info` only
      if migration pain exceeds benefit
- [ ] NetBox / live-object-registry cross-links for new client id vocabulary

---

## Operator instructions

**Clients (Kilo, Continue, Cursor custom models):** use the structured
`model_name` from `model_client_ids.yml`, base URL `http://litellm.hom.lab/v1`.

**Adding a route:**

1. Add `k3s_litellm_gateway_client_model_id_*` in `model_client_ids.yml` with a
   comment `# FRIENDLY ALIAS` or `# MODEL GROUP`.
2. Reference the variable in `defaults/main.yml` or `build_helm_values.yml`.
3. Set host `*_api_base` on `hom-lab-ctl-k3s-02` when the backend is gated.
4. Redeploy: `ansible-playbook playbooks/deploy_litellm_gateway.yaml --limit hom-lab-ctl-k3s-02 -t k3s_litellm_gateway`
5. Verify: `curl -s -H 'Authorization: Bearer …' http://litellm.hom.lab/v1/models`

**Do not** invent ad-hoc flat aliases in client configs; extend the contract file
first.

---

## Apply / Verify / Undo / Change class

| | |
| --- | --- |
| **Apply** | Edit `model_client_ids.yml` + gateway role; redeploy LiteLLM |
| **Verify** | `/v1/models` + completion probe per new id |
| **Undo** | Revert Ansible commit; redeploy; update clients |
| **Change class** | Idempotent config (gateway routes); client id change is **breaking** for IDEs until updated |
