# Continue embed + FIM — ATDD (user need → acceptance → Python later)

Project acceptance criteria for the **two Continue auxiliary lanes** verified
in plan `2026-09-12-mac_and_model_recommend`:

| Lane | Continue role | Client id | Live smoke shorthand |
| --- | --- | --- | --- |
| Embed | `embed` | `nomic-embed-text` | `embed smoke 768 dims` |
| Autocomplete | `autocomplete` | `qwen2.5-coder-1.5b-base-q8_0` | `FIM completions 200` |

Plain-language decode:
[`docs/plans/2026-09-12-mac_and_model_recommend/smoke-evidence-decode.md`](../../docs/plans/2026-09-12-mac_and_model_recommend/smoke-evidence-decode.md)

Harness (global-skills): `homelab-litellm-model-lane-pytest`  
Approved FIM journey already in [`manifest.yml`](./manifest.yml).  
Embed journey: **specified here**; executable Python is a **documented gap**
until the harness grows `type: embed`.

---

## 1. Embed — `@Codebase` can index through LiteLLM

### Human situation (capability meets need)

Josh uses Continue on the Mac. The Mac should **not** run local embed models.
When he uses `@Codebase` / `@Docs`, Continue must call LiteLLM
`nomic-embed-text`, get real vectors, and build a usable index. If that
path is down, chat may still work while **repo-aware context feels broken**.

### User story

> As a developer using Continue `@Codebase`, I need the configured embed model
> to return a stable nomic vector (768 dims) through LiteLLM so indexing and
> retrieval can run without hosting embedders on the Mac.

### Acceptance (Given / When / Then)

| Step | Spec |
| --- | --- |
| **Given** | LiteLLM publishes `nomic-embed-text`; HVH-01 Ollama has tag `nomic-embed-text`; Continue `roles: [embed]` points at that id; `apiBase` is `http://litellm.hom.lab/v1` |
| **When** | Client (or probe) `POST /v1/embeddings` with `{"model":"nomic-embed-text","input":"homelab continue embed smoke"}` and a valid gateway key |
| **Then** | HTTP **200**; `data[0].embedding` is a non-empty list; **`len(embedding) == 768`** |

### Pass / fail meaning

| Result | User-facing meaning |
| --- | --- |
| PASS (200 + 768) | Minimum plumbing for `@Codebase` indexing works end-to-end |
| FAIL (4xx/5xx) | Gateway/auth/route/backend down — retrieval cannot run |
| FAIL (200 but dims ≠ 768) | Wrong model or broken response shape — client will mis-index |

### Proposed YAML (for harness when `type: embed` exists)

```yaml
# File target: model-lane-acceptance/gateway/pending/continue-embed-nomic-hvh01.yml
# Do not merge into manifest.yml until global-skills supports type: embed.

x-embed-nomic-768: &embed_nomic_768
  id: codebase-embed-nomic-768
  title: "Can @Codebase get a real 768-dim vector through LiteLLM?"
  user_story: >-
    You ask Continue to index or search the repo. The embed model must return
    a nomic-width vector (768 floats) so retrieval is not empty or mismatched.
  group: embed
  type: embed
  requires_capabilities: [embed]
  user: "homelab continue embed smoke"
  embedding:
    endpoint: embeddings
    input: "homelab continue embed smoke"
  expect_dims: 768
  http_status: 200

lanes:
  - id: nomic-embed-text
    label: "HVH-01 Ollama nomic-embed-text — Continue embed / @Codebase"
    capabilities: [embed]
    usage:
      - <<: *embed_nomic_768
```

Same content is staged (commented + non-executable note) in
[`pending/continue-embed-nomic-hvh01.yml`](./pending/continue-embed-nomic-hvh01.yml).

### Future Python assertions (global-skills)

Extend `homelab-litellm-model-lane-pytest`:

1. `LiteLLMLaneClient.embeddings(model, input) -> EmbeddingResult(status, dims, vector, raw)`
2. `UsageScenario.type == "embed"` + fields `expect_dims`, `embedding.input`
3. `KNOWN_CAPABILITIES` / `DEFAULT_REQUIRES_BY_TYPE` include `embed`
4. `TestLlmEmbed` filter: `s.type == "embed"` (or `s.group == "embed"`)
5. Receipt EXPECTED line: `HTTP 200; embedding dims == 768`
6. Receipt ACTUAL line: `HTTP {status}; dims={n}; matched={ok}`

Pseudocode:

```python
def _assert_embed(lane, scenario, result, receipt_store):
    expected_status = scenario.http_status  # 200
    expected_dims = scenario.expect_dims    # 768
    ok = (
        result.status == expected_status
        and result.dims == expected_dims
        and result.dims > 0
    )
    # record UsageReceipt with title/user_story; pytest.fail(receipt.render()) if not ok
```

Until that lands, operators re-run the Ansible/`uri` probe documented in
`smoke-evidence-decode.md` and treat this file as the contract.

---

## 2. Autocomplete — Tab/ghost-text FIM through LiteLLM

### Human situation (capability meets need)

Josh types in the editor. Continue should suggest the **middle** of the current
edit (prefix + suffix), quickly, from a small FIM model — not from the
5090 chat model and not via `/v1/chat/completions` alone. If FIM fails, he loses
**inline completion** even when sidebar chat is fine.

**Why this model:** Autocomplete is **FIM-first**. Live Ollama
`qwen2.5-coder:1.5b-base-q8_0` (`ollama show`) includes a Modelfile TEMPLATE that
emits the same tokens Continue uses when a suffix is present:

```text
{{- if .Suffix }}<|fim_prefix|>{{ .Prompt }}<|fim_suffix|>{{ .Suffix }}<|fim_middle|>{{ else }}{{ .Prompt }}{{ end }}
```

Continue config (rendered) must keep:

```yaml
promptTemplates:
  autocomplete: "<|fim_prefix|>{{{prefix}}}<|fim_suffix|>{{{suffix}}}<|fim_middle|>"
```

plus `useLegacyCompletionsEndpoint: true` so requests hit `/v1/completions`.
Role README: `roles/continue_ide/README.md` → Autocomplete role — FIM.

**Other FIM candidates (not commissioned):** `granite-code:8b` /
`granite-code:8b-base`; StarCoder2 (`starcoder2:3b` or `:7b`, prefer non-instruct).
If tried later: verify `ollama show` FIM TEMPLATE + LiteLLM
`POST /v1/completions` smoke before Continue commission — chat success ≠ FIM.

### User story

> As a developer typing in the editor, I need Continue autocomplete to complete
> fill-in-the-middle prompts through LiteLLM so Tab/ghost-text suggestions
> actually appear.

### Acceptance (Given / When / Then)

| Step | Spec |
| --- | --- |
| **Given** | LiteLLM publishes `qwen2.5-coder-1.5b-base-q8_0` backed by Ollama `qwen2.5-coder:1.5b-base-q8_0`; Continue autocomplete enabled with that model id and FIM `promptTemplates` matching the Ollama TEMPLATE |
| **When** | Client (or probe) `POST /v1/completions` with a FIM prompt using `<|fim_prefix|>` / `<|fim_suffix|>` / `<|fim_middle|>` |
| **Then** | HTTP **200**; `choices[0].text` is **non-empty** (ops smoke). Quality ATDD may also require substrings such as `return` for a `def add` body |

### Pass / fail meaning

| Result | User-facing meaning |
| --- | --- |
| PASS (200 + text) | Minimum plumbing for Tab-complete works end-to-end |
| FAIL | Autocomplete route broken — user sees no/failed ghost text |

### Executable YAML today

Already approved in [`manifest.yml`](./manifest.yml) as `autocomplete-add-fim`
on lane `qwen2.5-coder-1.5b-base-q8_0` (`type: fim`). Run:

```bash
./model-lane-acceptance/scripts/run-gateway-acceptance.sh -m llm_fim -v -s
```

Ops smoke (HTTP 200 + non-empty only) matches plan intake; the approved journey
adds a soft quality check (`expect_substrings: [return]`).

### Python today

Implemented in global-skills `tests/test_model_lanes.py` → `TestLlmFim` /
`_assert_fim` via `LiteLLMLaneClient.fim_completion`. No new project Python
required for FIM.

---

## 3. Mapping to client-map

| Continue role | Lane | Acceptance surface | Status |
| --- | --- | --- | --- |
| `autocomplete` | `qwen2.5-coder-1.5b-base-q8_0` | `gateway/manifest.yml` (FIM) | approved / runnable |
| `embed` | `nomic-embed-text` | this doc + `pending/continue-embed-nomic-hvh01.yml` | contract written; harness gap |

---

## 4. Promotion rule

1. Keep embed pending until global-skills supports `type: embed` **and** a live
   receipt shows PASS with dims=768.
2. Do not treat chat ping-pong on the 1.5B lane as proof of autocomplete.
3. Do not treat `/v1/models` listing alone as proof of embed or FIM.
