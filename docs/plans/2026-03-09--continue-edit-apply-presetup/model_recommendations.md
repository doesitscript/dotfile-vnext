# Model recommendations — Continue edit / apply

Plan: `docs/plans/2026-03-09--continue-edit-apply-presetup`  
Validated: 2026-09-10 (controller Mac → LiteLLM NodePort `:30400`)

## Recommendation

Use **`qwen2.5-coder-7b@desktop`** for **both** Continue **edit** and **apply**.

| Field | Value |
| --- | --- |
| LiteLLM client id | `qwen2.5-coder-7b@desktop` |
| Ollama tag on host | `qwen2.5-coder:7b` |
| Runtime host | `dev-workstation-win` (RX 9060 XT, Ollama/Vulkan) |
| Publish path | LiteLLM → `http://ollama-desktop.hom.lab:11434/v1` |
| Continue roles | `edit`, `apply` (one model entry) |
| Suggested completion options | `contextLength: 32768`, `maxTokens: 4096`, `temperature: 0.2` |

**Do not** point Continue edit/apply at `qwen2.5-coder-32b@k3s02-vllm`. That is
the **chat** lane on the 5090 vLLM runtime. It can pass the same micro-prompts
quickly, but it is the wrong placement for frequent inline edit/apply (and it
competes with chat load on the primary GPU).

## Why this works (Continue roles)

| Role | Job | Fit of 7B coder |
| --- | --- | --- |
| **edit** | Generate revised code from a selection + instruction | Strong — returns typed Hello edit in ~6s on this desktop path |
| **apply** | Produce a precise final file body from original+new | Strong — same model, ~6s; Continue prefers smaller/faster than chat |

Continue docs prefer Morph/Relace for specialized apply speed. This lab stays
self-hosted: Ollama on the desktop, published through LiteLLM.

## Live metrics (fresh `validations/run_all.py`)

Suite: `summary.ok = true` (all four scripts exit 0). Wall-clock below is
end-to-end via LiteLLM with `attempts=1` (no controller bind-retry inflation).

### Edit role (Continue-style prompt)

| Model | Pass | Latency (s) | Completion tokens |
| --- | --- | ---: | ---: |
| **`qwen2.5-coder-7b@desktop`** | yes | **6.69** | 23 |
| `ministral-3-8b@desktop` | yes | 11.79 | 109 |
| `qwen2.5-coder-14b@desktop` | yes | 11.75 | 23 |

### Apply role (Continue-style prompt)

| Model | Pass | Latency (s) | Completion tokens |
| --- | --- | ---: | ---: |
| **`qwen2.5-coder-7b@desktop`** | yes | **6.12** | 23 |
| `ministral-3-8b@desktop` | yes | 10.53 | 23 |
| `qwen2.5-coder-14b@desktop` | yes | 16.85 | 23 |

### Dual-pass desktop ranking (`compare_candidates.py`)

| Rank | Model | Edit (s) | Apply (s) | Combined (s) |
| ---: | --- | ---: | ---: | ---: |
| 1 | **`qwen2.5-coder-7b@desktop`** | 6.08 | 6.05 | **12.13** |
| 2 | `ministral-3-8b@desktop` | 11.81 | 10.06 | 21.87 |
| 3 | `qwen2.5-coder-14b@desktop` | 16.80 | 16.82 | 33.62 |

Chat contrast only (not a desktop edit/apply pick):
`qwen2.5-coder-32b@k3s02-vllm` edit **1.08s** / apply **0.58s** on these tiny
prompts — faster raw, wrong lane for Continue edit/apply policy.

### Metric targets used by the scripts

| Role | Warn above | Fail above | Functional check |
| --- | ---: | ---: | --- |
| edit | 8s | 25s | Typed `greet` + Hello / f-string style output |
| apply | 5s warn / 15s fail (script classes) | Precise final `def greet(...)-> str` body |

Selected 7B sits in the **fast** edit band (~6s) and near the apply warn line
(~6s). That is acceptable for desktop Ollama through LiteLLM on this hardware.

## Candidates (decision table)

| Model | Decision | Notes |
| --- | --- | --- |
| `qwen2.5-coder-7b@desktop` | **Selected** | Fastest desktop dual-pass; already Continue edit/apply |
| `ministral-3-8b@desktop` | Fallback | Passes both; slower; keep for Kilo-style fallback, not primary edit |
| `qwen2.5-coder-14b@desktop` | Keep off hot path | Passes; ~2.8× slower combined; Codex/implement lane |
| `qwen2.5-coder-32b@k3s02-vllm` | Chat only | vLLM 5090; not Continue edit/apply |

LiteLLM `GET /v1/models` publishes all three `@desktop` ids (see
`validations/results/models_present.json`).

## Repo wiring — already implemented (no mutate this turn)

Reuse existing inventory / roles; nothing new was commissioned:

| Surface | Setting |
| --- | --- |
| `roles/continue_ide/defaults/main.yml` | Edit entry → `qwen2.5-coder-7b@desktop`, roles `[edit, apply]` |
| `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` | `k3s_litellm_gateway_continue_edit_*` → desktop Ollama 7B |
| `inventory/host_vars/dev-workstation-win.yaml` | `qwen2.5-coder:7b` in `windows_ollama_runtime_models_present` |
| `inventory/group_vars/continue_ide_hosts/main.yml` | Research matrix lists same edit_apply client id |

**Apply / Verify / Undo / Change class** (if re-asserting config later):

- Apply: `ansible-playbook playbooks/deploy_continue_ide.yaml --limit <continue_host>`
- Verify: `cd …/validations && python3 run_all.py`
- Undo: point Continue edit/apply model away or `continue_ide_state=absent`
- Change class: idempotent config (no new model download required)

## How to re-validate

```bash
cd docs/plans/2026-03-09--continue-edit-apply-presetup/validations
export LITELLM_GATEWAY_ROOT=http://litellm.hom.lab:30400
export LITELLM_CURL_INTERFACE=en0   # required on this controller when binds flap
python3 run_all.py
```

Artifacts: `validations/results/{models_present,edit_role,apply_role,candidate_comparison,summary}.json`.

## Note on controller bind errors

Earlier failed runs showed `curl: (45) bind … errno 49` (ephemeral-port /
source-bind exhaustion on the Mac controller). That is a **client network
condition**, not a model failure. Fresh suite used `attempts=1` throughout.
