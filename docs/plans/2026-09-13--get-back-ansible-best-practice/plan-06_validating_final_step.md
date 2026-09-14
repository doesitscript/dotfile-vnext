In the end validate these models  work:
qwen3-coder-30b-a3b
qwen2.5-coder-7b
qwen2.5-coder-1.5b-base-q8_0
qwen2.5-coder-14b
gpt-oss-20b
nomic-embed-text
ministral-3-8b

## Validation receipt

This list is the required acceptance target. A model is not marked “working”
from catalog presence alone; each applicable model needs runtime identity,
gateway route, and behavior evidence. Because the listed models share limited
GPU resources, validate them in separate sequential runs rather than requiring
simultaneous residency.

Required evidence per model:

1. Source/route identity resolves to the intended model and backend.
2. Runtime health and direct OpenAI-compatible request succeed.
3. LiteLLM route request succeeds with the intended client-facing ID.
4. Role-specific behavior succeeds: chat, edit/apply, FIM autocomplete,
   embedding/indexing, or tool calls as applicable.
5. A second convergence reports `changed=0` where the deployment target is
   available for idempotence testing.

Run from the repository root with the project wrapper:

```bash
cd /Users/joshc/develop/dotfile-vnext
bin/codex-env ansible-playbook playbooks/validate_ai_inference_stack_contracts.yaml \
  -i inventory/inventory.yaml --limit hom-lab-ctl-k3s-02
bin/codex-env ansible-lint roles/k3s_litellm_gateway \
  playbooks/deploy_litellm_gateway.yaml \
  playbooks/validate_ai_inference_stack_contracts.yaml
```

The validation receipt must show literal command output and distinguish source
validation, rendered configuration, live runtime, gateway, and client evidence.
Until those outputs are captured, this plan remains incomplete.

## Validation output captured 2026-09-13

The validation playbook was corrected to target `ai_inference_stack_nodes`;
before that correction, `--limit hom-lab-ctl-k3s-02` matched no hosts and
silently skipped the validation. After the correction, the literal result was:

```text
TASK [Validate current client lane vocabulary] *********************************
ok: [hom-lab-ctl-k3s-02] => (item=qwen3-coder-30b-a3b)
ok: [hom-lab-ctl-k3s-02] => (item=qwen2.5-coder-7b)
ok: [hom-lab-ctl-k3s-02] => (item=qwen2.5-coder-1.5b-base-q8_0)
ok: [hom-lab-ctl-k3s-02] => (item=qwen2.5-coder-14b)
ok: [hom-lab-ctl-k3s-02] => (item=gpt-oss-20b)
ok: [hom-lab-ctl-k3s-02] => (item=nomic-embed-text)
ok: [hom-lab-ctl-k3s-02] => (item=ministral-3-8b)

TASK [Validate complexity smart-router is disabled] ****************************
ok: [hom-lab-ctl-k3s-02]

PLAY RECAP *********************************************************************
hom-lab-ctl-k3s-02 : ok=4 changed=0 unreachable=0 failed=0 skipped=1 ignored=0
```

This proves the seven lane-contract entries and disabled complexity router are
present in source/inventory evaluation. It does not yet prove that all seven
weights are simultaneously resident or that every route has passed a live
role-specific request. Those remain sequential runtime/gateway/client tests.

## Live runtime and gateway/client round-trip output 2026-09-14

The requested non-role-specific checks were run sequentially. These checks
verified model identity/availability, LiteLLM route publication, and a minimal
OpenAI-compatible request/response. They deliberately did not test tool calls,
FIM quality, edit/apply quality, embedding indexing, or other role behavior.

Gateway model list contained the seven requested IDs:

```text
gpt-oss-20b
ministral-3-8b
nomic-embed-text
qwen2.5-coder-1.5b-base-q8_0
qwen2.5-coder-14b
qwen2.5-coder-7b
qwen3-coder-30b-a3b
```

Minimal chat round trips through `http://litellm.hom.lab/v1`:

```text
qwen3-coder-30b-a3b          HTTP 200  response model qwen3-coder-30b-a3b
qwen2.5-coder-7b             HTTP 200  response model qwen2.5-coder-7b
qwen2.5-coder-1.5b-base-q8_0 HTTP 200  response model qwen2.5-coder-1.5b-base-q8_0
qwen2.5-coder-14b            HTTP 200  response model qwen2.5-coder-14b
gpt-oss-20b                  HTTP 200  response model gpt-oss-20b
ministral-3-8b               HTTP 200  response model ministral-3-8b
nomic-embed-text             HTTP 200  embedding length 768
```

Backend runtime identity output:

```text
--- Ollama desktop identity ---
qwen2.5-coder:14b
qwen2.5-coder:7b
ministral-3:8b
gpt-oss:20b

--- Ollama HVH-01 identity ---
nomic-embed-text:latest
qwen2.5-coder:1.5b-base-q8_0

--- vLLM Kubernetes identity ---
vllm-primary-86495b66c8-qscs7  1/1 Running
cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit  max_model_len=32768
```

Runtime caveat captured literally: an older vLLM ReplicaSet pod,
`vllm-primary-9759b7dd-5qqhk`, was also present with
`0/1 UnexpectedAdmissionError`. The active serving pod was healthy and served
the expected identity, but stale ReplicaSet cleanup or investigation remains
required before claiming a completely clean runtime state.

## Excluded role-specific behavioral tests

The following were intentionally not run in this pass:

- Qwen3 tool-call generation and parser compatibility;
- Continue FIM/autocomplete completion quality and latency;
- edit/apply patch correctness on the 7B and 14B lanes;
- embedding indexing/retrieval quality, normalization, and vector-store
  compatibility;
- streaming/UI rendering in Continue, Cline, Codex, OpenCode, or Kilo;
- gpt-oss reasoning-mode behavior and Ministral agent/tool behavior;
- long-context overflow testing beyond the minimal request.

The seven models therefore pass live identity, gateway publication, and basic
client-compatible round-trip checks. They are not fully behaviorally qualified
until the role-specific tests above are run.

## Basic functional and context-budget smoke output 2026-09-14

These checks used the LiteLLM OpenAI-compatible endpoint with a small explicit
`max_tokens` value, followed by a 12,424-character prompt and
`max_tokens=64`. The larger prompt is a practical budget smoke, not a maximum
context boundary test. No `ContextWindowExceededError` or HTTP failure occurred.

### Basic request output

```text
MODEL: qwen3-coder-30b-a3b
HTTP: 200
RESPONSE_MODEL: qwen3-coder-30b-a3b
FINISH_REASON: stop
CONTENT: 'OK qwen3-coder-30b-a3b'
USAGE: {'completion_tokens': 14, 'prompt_tokens': 28, 'total_tokens': 42}

MODEL: qwen2.5-coder-7b
HTTP: 200
RESPONSE_MODEL: qwen2.5-coder-7b
FINISH_REASON: stop
CONTENT: 'OK qwen2.5-coder-7b'
USAGE: {'completion_tokens': 12, 'prompt_tokens': 47, 'total_tokens': 59}

MODEL: qwen2.5-coder-1.5b-base-q8_0
HTTP: 200
RESPONSE_MODEL: qwen2.5-coder-1.5b-base-q8_0
FINISH_REASON: stop
CONTENT: '\nOK'
USAGE: {'completion_tokens': 3, 'prompt_tokens': 25, 'total_tokens': 28}

MODEL: qwen2.5-coder-14b
HTTP: 200
RESPONSE_MODEL: qwen2.5-coder-14b
FINISH_REASON: stop
CONTENT: 'OK qwen2.5-coder-14b'
USAGE: {'completion_tokens': 13, 'prompt_tokens': 48, 'total_tokens': 61}

MODEL: gpt-oss-20b
HTTP: 200
RESPONSE_MODEL: gpt-oss-20b
FINISH_REASON: stop
CONTENT: ''
USAGE: {'completion_tokens': 32, 'prompt_tokens': 86, 'total_tokens': 118}

MODEL: ministral-3-8b
HTTP: 200
RESPONSE_MODEL: ministral-3-8b
FINISH_REASON: stop
CONTENT: 'OK ministral-3-8B-instruct-2512'
USAGE: {'completion_tokens': 16, 'prompt_tokens': 572, 'total_tokens': 588}

MODEL: nomic-embed-text
HTTP: 200
RESPONSE_MODEL: nomic-embed-text
EMBEDDING_LENGTH: 768
USAGE: {'completion_tokens': 0, 'prompt_tokens': 9, 'total_tokens': 9}
```

### Larger prompt / overflow smoke output

```text
MODEL: qwen3-coder-30b-a3b
HTTP: 200
FINISH_REASON: stop
CONTENT: 'OK'

MODEL: qwen2.5-coder-7b
HTTP: 200
FINISH_REASON: stop
CONTENT: 'OK'

MODEL: qwen2.5-coder-1.5b-base-q8_0
HTTP: 200
FINISH_REASON: stop
CONTENT: ''

MODEL: qwen2.5-coder-14b
HTTP: 200
FINISH_REASON: stop
CONTENT: 'OK'

MODEL: gpt-oss-20b
HTTP: 200
FINISH_REASON: stop
CONTENT: 'OK'

MODEL: ministral-3-8b
HTTP: 200
FINISH_REASON: stop
CONTENT: 'OK.'
```

Conclusion: all seven lanes passed the basic HTTP/response or embedding
endpoint smoke, and all five chat lanes handled the larger prompt without a
context overflow. The 1.5B empty larger-prompt content and gpt-oss empty short
smoke are findings for role-specific or client-parameter follow-up, not proof
of a context-window failure.

## TDD user-perspective smoke results 2026-09-14

The two findings were corrected in the test contract:

- `gpt-oss-20b` is tested as chat with `max_tokens=256`, allowing its normal
  response budget; it now returns non-empty text.
- `qwen2.5-coder-1.5b-base-q8_0` is tested as FIM autocomplete through
  `/v1/completions`, not as chat; it now returns inserted code.

The plan-local TDD implementation is in [`TDD/`](./TDD/). Its live output was:

```text
MODEL: qwen3-coder-30b-a3b
API: chat/completions HTTP 200
CONTENT: 'OK'
RESULT: PASS

MODEL: qwen2.5-coder-7b
API: chat/completions HTTP 200
CONTENT: 'OK.'
RESULT: PASS

MODEL: qwen2.5-coder-14b
API: chat/completions HTTP 200
CONTENT: 'OK'
RESULT: PASS

MODEL: gpt-oss-20b
API: chat/completions HTTP 200
CONTENT: 'OK'
RESULT: PASS

MODEL: ministral-3-8b
API: chat/completions HTTP 200
CONTENT: 'OK.'
RESULT: PASS

MODEL: qwen2.5-coder-1.5b-base-q8_0
API: completions (FIM) HTTP 200
CONTENT: 'print "ADDING %d + %d" % (a, b)\\n    return a + b\\n...'
RESULT: PASS

MODEL: nomic-embed-text
API: embeddings HTTP 200
EMBEDDING_LENGTH: 768
RESULT: PASS
```

All seven TDD smoke tests passed. These are basic user-perspective
connectivity/response tests; they do not prove semantic code quality, tool
calling, retrieval quality, latency, or UI rendering.

## Backend-variable naming migration receipt 2026-09-14

The gateway variable migration is complete for active implementation surfaces.
Client model IDs were intentionally preserved because they are stable external
client contracts; backend variables now identify the actual runtime/provider:

| Retired concern | Current backend variable family |
|---|---|
| Continue edit/apply | `ollama_desktop_7b` |
| Desktop implementation | `ollama_desktop_14b` |
| Autocomplete 1.5B | `ollama_hvh01_fim_1_5b` |
| Nomic embeddings | `ollama_hvh01_nomic` |
| Kilo fast fallback | `ollama_desktop_ministral` |
| GPT-OSS chat | `ollama_desktop_gpt_oss` |
| Local Continue route collection | `local_model_routes` |

Validation evidence:

- active `roles/`, `inventory/`, and `playbooks/` contain no retired
  client-oriented gateway variable names;
- production-profile `ansible-lint` passed with zero failures and warnings;
- both deployment and contract-validation playbooks passed syntax checks;
- LiteLLM gateway convergence on `hom-lab-ctl-k3s-02` completed `ok=32
  changed=0 failed=0`;
- live seven-lane contract validation completed `ok=4 changed=0 failed=0`;
- live TDD smoke tests passed for all seven lanes, including chat, FIM, and
  768-dimensional embeddings.

The old names remain only in historical assessment material, where they are
preserved as evidence of the input state rather than used by Ansible.
