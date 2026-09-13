---
title: Common model-lane setup and handoff plan
status: planned
owner: model-lane-parameter-reconciler
---

# Common setup plan for a newly commissioned model

## Purpose

Adding a model is a contract-reconciliation task, not only a model download
or a single YAML edit. A model is usable only when the following chain agrees:

```text
model identity and capabilities
        ↓
runtime (vLLM or Ollama)
        ↓
LiteLLM gateway route and Helm-rendered configuration
        ↓
client model catalog and request defaults
        ↓
real request → response / streaming / tool / embedding behavior
```

Every new model therefore needs an intake, an authority map, parameter
reconciliation, runtime commissioning, gateway publication, client wiring,
and behavioral verification. A passing Ansible syntax check or a visible
catalog row is not proof that the model can serve the intended workload.

## Scope and non-goals

This plan applies to a new chat, edit, apply, autocomplete, embedding, vision,
or agent model added to this homelab. It covers both directions of handoff:

- upstream: a model/runtime change is handed to gateway and client owners;
- downstream: a client or gateway failure is traced back to the authoritative
  model and runtime parameters.

It does not authorize live Apply by itself. Source changes, generated
configuration, peer/evaluator approval, and live deployment remain separate
evidence layers. A model must not be advertised as active until its intended
runtime and client behavior are verified.

## Required intake fields

Create a record for each model before changing routes or clients. Values marked
`decision` require an explicit choice; they must not be inferred from a model
name.

| Field | Required decision or evidence |
| --- | --- |
| Canonical model ID | Stable client-facing slug; preserve provider/path requirements where a client requires them |
| Upstream repository and revision | Official repository, tag/commit, quantization, tokenizer, license, and checksum where applicable |
| Model family/variant | Instruct/chat, base/FIM, embedding, reranker, vision, reasoning, or tool-capable variant |
| Intended roles | `chat`, `edit`, `apply`, `autocomplete`, `embed`, `rerank`, `vision`, `agent`, or an explicitly bounded combination |
| Context limit | Model/runtime-supported maximum, in tokens; distinguish context window from output budget |
| Input budget | Gateway/client safe input cap after reserving output and any tool/template overhead |
| Output budget | Default and hard maximum; ensure input plus output does not exceed the effective context limit |
| Sampling | Temperature, top-p, top-k, repetition penalty, seed, stop strings, and whether clients may override them |
| Chat template | Required template, reasoning mode, tool format, special tokens, and tokenizer compatibility |
| Tool contract | Tool-call parser, auto-tool-choice flags, JSON/schema behavior, and known unsupported tools |
| Embedding contract | Dimensions, normalization, distance metric, endpoint, and sole owner of the `embed` role |
| Runtime placement | Host, GPU, VRAM budget, concurrency, tensor/pipeline parallelism, and whether the lane is sequential |
| Availability state | Candidate, staged, enabled, retired, or blocked; never use `enabled` as a substitute for validation |
| Client owners | Exact Continue, Cline, Codex, OpenCode, Kilo, or other client surfaces that consume the route |
| Verification workload | Small smoke, long-context prompt, tool call, streaming, embedding/indexing, or client round trip |

## Authority and surface map

Use the highest applicable authority first. Do not patch a rendered client file
or a deployed ConfigMap as a substitute for its source.

| Concern | Authoritative surface | What must be reconciled |
| --- | --- | --- |
| Commissioned model catalog | `inventory/group_vars/all/ai_cli_apps.yml` and model catalog manifest | Canonical ID, roles, enabled state, context, max output, sampling, placement, and ownership |
| vLLM runtime | `inventory/host_vars/<runtime-host>.yaml` plus `roles/k3s_vllm_runtime/` | Model revision, served name, max model length, GPU utilization, dtype/quantization, parallelism, chat template, tool parser, and extra args |
| vLLM Helm/Kubernetes layer | The vLLM role templates/values and rendered workload | Image, arguments, mounts/cache, Service, readiness, rollout, GPU requests, and identity-bound served model |
| Ollama runtime | Commissioned Ollama host vars/role and model pull contract | Exact library tag, host, API base, model availability, context/options, and service health |
| LiteLLM gateway defaults | `roles/k3s_litellm_gateway/defaults/main.yml` | Provider, backend model, API base, gateway defaults, lane contract, and route enablement |
| LiteLLM route builder | `roles/k3s_litellm_gateway/tasks/build_helm_values.yml` | `model_name`, `litellm_params`, `model_info`, caps, lane metadata, and route-specific sampling |
| LiteLLM Helm/Kubernetes layer | Gateway chart values, Secrets, ConfigMaps, Deployment, Service | Rendered route, provider credentials, external DB contract, rollout health, and published endpoint |
| Continue | Work-laptop packet host vars and rendered `~/.continue/config.yaml` | Model ID/base URL, roles, context length, `maxTokens`, embedding owner, API key path, and endpoint compatibility |
| Cline | Work-laptop packet host vars and rendered Cline model/provider JSON | Model ID/base URL, context window, `max_output_tokens`, sampling, provider authentication, and streaming |
| Other clients | Their commissioned source host vars/templates | Exact client parameter names and endpoint/request format; do not assume Continue names map directly |
| Handoff state | `scripts/recent_and_next.md` in the active subproject | Only the next commands for the next operator, replaced at every handoff |

## Implementation phases

### Phase 0 — Intake and authority mapping

1. Read the assessment, model card, runtime constraints, and any prior failure.
2. Assign the canonical model ID and variant; explicitly retire conflicting
   aliases or stale routes.
3. Fill every required intake field above, including fields that are “not
   applicable.” Record why an option is disabled rather than leaving ambiguity.
4. Identify all clients and the single intended owner for each role. Embedding
   ownership is exclusive: one active embedding route must serve the indexer.
5. Determine whether the GPU can host the model concurrently. For a single GPU,
   record a sequential lane and do not publish mutually incompatible routes as
   simultaneously active.

### Phase 1 — Model-level parameter reconciliation

Verify the model's own technical limits against its official source and runtime
implementation:

- tokenizer and chat template match the selected variant;
- effective context length is known, including runtime reductions;
- `input_budget + output_budget <= effective_context_length`;
- output reserve includes tool schemas, reasoning tokens, and client overhead;
- sampling values match the model card unless an intentional project override
  is recorded;
- tool-call format is compatible with the selected parser and client;
- embedding dimensions and normalization match the consuming vector store;
- quantization, dtype, and GPU memory requirements fit the target host.

For the Qwen3-Coder example, the reconciled contract was a 32,768-token cup,
28,672 input tokens, and 4,096 output tokens. Those values are an example of
the budget relationship, not universal defaults for every future model.

### Phase 2 — Runtime commissioning

For vLLM:

1. Add or update the host-level model identity and served model name.
2. Set `--max-model-len` and all memory/parallelism arguments from the intake.
3. Set the chat template and tool parser explicitly when the model requires it.
4. Render the Helm/Kubernetes workload and inspect the actual arguments,
   image, mounts, GPU requests, and Service selector.
5. Wait for readiness, then query the runtime's `/v1/models` and a direct
   completion request. A Ready pod alone is insufficient.

For Ollama:

1. Commission the exact model library tag on the selected host.
2. Verify the model is pulled, loaded, and reachable through its OpenAI-
   compatible API path.
3. Confirm context/options and tool or embedding behavior directly.
4. Record the host/API base used by the gateway; do not leave a route pointing
   at an uncommissioned or ambiguous desktop endpoint.

### Phase 3 — LiteLLM gateway publication

1. Add the route through the gateway's source defaults and route builder.
2. Keep the stable client-facing `model_name` separate from provider model
   paths and placement metadata.
3. Set provider/backend fields, API base, authentication reference, and route
   sampling values.
4. Populate `model_info` with at least mode, model lane, backend runtime,
   placement, source revision, and explicit input/output caps.
5. For embeddings, publish one gateway route and mark the local/client duplicate
   disabled rather than publishing two active `embed` owners.
6. Run Ansible argument validation and render inspection before live deployment.
7. Deploy only after approval; verify rollout, route listing, model identity,
   and a real request through LiteLLM.

### Phase 4 — Client integration

For every commissioned client, map gateway concepts to that client's names:

| Contract concept | Continue | Cline | General requirement |
| --- | --- | --- | --- |
| Context | `contextLength` | `context_window` | Must not exceed runtime/gateway effective context |
| Output reserve | `maxTokens` | `max_output_tokens` | Must agree with the reconciled output budget |
| Sampling | `temperature`, `topP` | `temperature`, `top_p` | Match route defaults unless intentionally overridden |
| Endpoint | `apiBase`/provider path | provider `baseUrl` | Must target the published gateway route |
| Identity | `model` | model catalog entry | Must resolve to the LiteLLM `model_name` |
| Role | `roles` | model roles/catalog metadata | Must not advertise unsupported capabilities |

Then verify both directions of communication:

1. client sends the expected model ID, budget, sampling, and auth headers;
2. gateway resolves that ID to the intended provider route;
3. runtime receives the request and returns the expected model identity;
4. gateway returns the response/stream without rewriting incompatible fields;
5. client renders the response, tool call, or embedding result correctly.

### Phase 5 — Verification and evidence

Collect evidence at each layer:

- source: changed files and exact values;
- rendered: generated config, Helm values, client JSON/YAML;
- runtime: pod/service/model identity and direct request;
- gateway: `/v1/models`, route metadata, logs, and request result;
- client: actual config and client-side round trip;
- behavior: long-context budget, streaming, tool call, or embedding smoke.

Do not collapse these into one “playbook passed” claim. A successful playbook
proves only the tasks it executed; it does not prove model availability or
client behavior unless those checks are included and captured.

## Acceptance gates

The lane is ready for handoff only when all applicable gates pass:

- [ ] Canonical ID, variant, roles, owner, and lifecycle state are explicit.
- [ ] Model context and input/output budgets are mathematically compatible.
- [ ] vLLM or Ollama identity is present on the intended host and responds.
- [ ] Helm/runtime arguments match the approved source values.
- [ ] LiteLLM route resolves to the intended backend and exposes model metadata.
- [ ] Gateway route caps and sampling are explicit and verified.
- [ ] Exactly one active embedding owner exists for the consuming client.
- [ ] Continue/Cline/other client values use their native parameter names.
- [ ] A client request reaches the intended backend and returns successfully.
- [ ] Tool, streaming, autocomplete, or embedding behavior is tested when in scope.
- [ ] No stale route, alias, or retired model remains looking active.
- [ ] Evidence is identity-bound to the current run/source hash where the workflow supports it.
- [ ] `scripts/recent_and_next.md` contains only the next operator's commands.

## Standard handoff procedure

Before handing off upstream or downstream:

1. Summarize the current state and the single remaining decision, if any.
2. Put only the next commands into `scripts/recent_and_next.md`; replace the
   previous contents instead of appending a log.
3. Include the direction of travel in the commands: source → runtime → gateway
   → client, or client failure → gateway → runtime → source.
4. Name the exact files, host, inventory, run ID, and evidence artifact needed
   by the next operator.
5. Stop at the requested terminal gate. Do not dispatch another role or Apply
   merely because an artifact was created.

For the commissioned work-laptop convergence handoff, the next command is:

```bash
cd ~/Documents/develop/work-laptop-ai-tools
ANSIBLE_VAULT_PASSWORD_FILE=/path/to/parent/.vault_pass \
ansible-playbook playbook.yaml -i inventory.yaml --tags ai_cli_apps
```

The hostname assertion remains a safety control. If this command is run from a
controller or non-commissioned Mac, report the mismatch and hand it to the
actual laptop operator; do not override the assertion.

## Common failure interpretation

| Symptom | What it proves | What it does not prove | Next investigation |
| --- | --- | --- | --- |
| YAML or Ansible syntax passes | Source is parseable | Runtime/model/client compatibility | Render values and run direct identity-bound smoke |
| Pod is Ready | Workload is healthy enough for readiness | Correct model loaded or tool format works | Query `/v1/models`, logs, and direct completion |
| LiteLLM `/v1/models` lists route | Gateway publication exists | Backend serves the model or client uses the same ID | Send a real gateway request and inspect provider resolution |
| Client config contains a model | Template rendered a row | Correct endpoint, auth, budget, or response behavior | Inspect request and client round trip |
| Embedding row exists | A catalog entry exists | It is the sole active owner | Count active `embed` roles and test indexing |
| Context-window error | Budget contract is inconsistent or overloaded | Model weights are wrong | Reconcile context, input, output, tools, and client reserve |
| Hostname mismatch | Current machine is not the commissioned target | The playbook or vault is broken | Run on the commissioned laptop or explicitly stop |

## Documentation Provenance

This plan was formalized from the recurring model-lane reconciliation pattern,
the Qwen3-Coder configuration walkthrough, and the commissioned work-laptop
handoff requirement. It is a planning contract, not live deployment evidence.
