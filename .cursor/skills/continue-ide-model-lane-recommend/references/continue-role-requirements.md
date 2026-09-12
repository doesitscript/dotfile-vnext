# Continue model roles — what to look for (all roles)

Continue assigns models via `roles` in `config.yaml`. Official role set
([Continue model roles](https://docs.continue.dev/customize/model-roles/00-intro),
[config reference](https://docs.continue.dev/reference)):

| Role | Used for | Status in Continue |
| --- | --- | --- |
| `chat` | Sidebar chat + Agent conversations | Active |
| `edit` | Inline / panel code transformation from an edit prompt | Active |
| `apply` | How a proposed change is merged into the file | Active |
| `autocomplete` | Tab / ghost-text FIM suggestions while typing | Active |
| `embed` | Vectors for `@Codebase` / `@Docs` retrieval | Active |
| `rerank` | Re-order retrieval hits by relevance | Active (optional) |
| `summarize` | Listed in schema | **Not currently used** by Continue |

Default if `roles` omitted: `[chat, edit, apply, summarize]` — always set roles
explicitly in this lab.

---

## Role requirement cards

### `chat`

**Job:** Answer questions, explain code, drive Agent tool loops when the chat
model is selected for Agent.

**Look for:**

- Strong instruction following and tool/function calling when Agent is in scope
- Enough context for multi-file discussion (lab primary often 32k+)
- Coding quality *and* honesty (avoid silent inventing of secrets/paths)
- Latency can be seconds; quality > sub-second speed

**Avoid:** Tiny FIM-only base models; embedding-only models.

**Smoke:** `POST /v1/chat/completions` with a short coding Q&A; optional tool-loop
acceptance suite.

---

### `edit`

**Job:** Generate the **code transformation** (rewrite / refactor / implement)
from an edit instruction + surrounding context.

**Look for:**

- Instruct / chat-tuned **code** models (not base FIM, not embed)
- Mid size often wins: enough reasoning to change structure correctly
- Stable formatting; low temperature (~0.1–0.3)
- Context window large enough for the selection + neighbors (often 8k–16k+)

**Avoid:** Autocomplete-only FIM models; pure embedding models; oversized models
that steal VRAM from primary chat if co-located poorly.

**Smoke:** Edit a small function via Continue Edit (or gateway chat with an edit
prompt); verify the patch is coherent.

---

### `apply`

**Job:** **Mechanically merge** a proposed change into the file (placement /
diff application), not invent a new design.

**Look for:**

- Smaller / faster instruct coder than Edit is OK
- High obedience to “apply this change here”; low creativity
- Low temperature; modest max tokens
- Can share a host with Edit if VRAM allows both resident

**Avoid:** Huge generalists; FIM base models; embeddings.

**Smoke:** Apply a known patch through Continue Apply; confirm merge without
rewriting unrelated code.

---

### `autocomplete`

**Job:** Predict the **middle** of code given prefix + suffix (FIM) as the user
types — sub-second preferred.

**Look for:**

- **FIM-trained** coder models; **base** often better than Instruct for raw FIM
  tokens (`<|fim_prefix|>` / `<|fim_suffix|>` / `<|fim_middle|>`)
- Small (0.5B–7B); Continue often cites Qwen2.5-Coder 1.5B / 7B
- Low temperature (often 0); short `maxTokens`; debounce ~250ms
- Prefer `/v1/completions` (legacy) + FIM template when using OpenAI-compatible
  gateways

**Avoid:** Large chat/Agent models; thinking models with thinking left on;
embedding models.

**Smoke:** `POST /v1/completions` with a FIM prompt → HTTP 200 + non-empty text.

---

### `embed`

**Job:** Turn code/docs chunks into **vectors** for semantic search (`@Codebase`,
`@Docs`).

**Look for:**

- Dedicated **embedding** models (e.g. `nomic-embed-text`), not chat LLMs
- Stable dimension width (nomic → **768**); document that in smokes
- Tiny VRAM/RAM; can co-reside with a small autocomplete model
- OpenAI-compatible `/v1/embeddings` or LiteLLM `ollama/<embed-model>`

**Avoid:** Chat/instruct LLMs used as fake embedders; FIM models.

**Smoke:** `POST /v1/embeddings` → HTTP 200 + `len(embedding) == expected_dims`
(e.g. 768 for nomic).

---

### `rerank`

**Job:** After vector retrieval, **re-score and reorder** chunks so the best
context reaches chat/edit.

**Look for:**

- Dedicated **reranker** models (Voyage rerank, Morph rerank, open zerank /
  bge-reranker family — verify Continue provider support first)
- Extra latency budget; only enable if retrieval quality measurably improves
- Lab stance from related brainstorms: start **OFF**, A/B later

**Avoid:** Using a chat model as a faux reranker without a supported API;
loading a large reranker on the same tiny GPU as FIM without measuring contention.

**Smoke:** Retrieval A/B with rerank on/off (relevance + latency), not just
`/v1/models` presence.

---

### `summarize`

**Job:** Schema allows it; Continue docs say it is **not currently used**.

**Look for:** Nothing to commission until Continue wires the role.

**Lab policy:** Do not invent inventory/LiteLLM lanes solely for `summarize`.

---

## Cross-role selection heuristics

| Pressure | Prefer |
| --- | --- |
| Typing latency | Small FIM on a dedicated/light GPU |
| Transformation quality | Mid instruct coder for Edit; smaller for Apply |
| Agent / deep chat | Large instruct + tools on best GPU (or cloud) |
| Repo search | Tiny embed (+ optional rerank later) |
| Client Mac with weak GPU | Offload all roles; Mac only holds Continue config |
| Single big GPU already on primary chat | Do **not** park auxiliary roles there unless idle |
