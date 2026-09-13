# Smoke evidence decode (what the verification numbers mean)

These lines appear in intake status as shorthand for **live probes against LiteLLM**, not marketing scores.

**ATDD source of truth (user need + Given/When/Then + future Python):**
[`model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md`](../../../model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md)

---

## Human-facing situations (why these probes exist)

### Embed — `768 dims`

**What the user is doing:** In Continue, they use `@Codebase` / `@Docs` (or similar
retrieval) so the IDE can find *relevant* chunks of their repo without them
pasting files by hand.

**What has to work for that need to be met:** Every chunk Continue indexes must
become a real vector of the **same width** the client expects. For
`nomic-embed-text`, that width is **768**. If the gateway returns an error, an
empty list, or a different length, retrieval is broken even when chat still
works — `@Codebase` looks “empty” or nonsense.

**What the smoke proves:** Continue’s configured embed model id
(`nomic-embed-text`) reaches LiteLLM → Ollama and returns a
**768**-float embedding. That is the minimum end-to-end proof that **repo search
can index**; it is not a judgment of retrieval quality.

### Autocomplete — `FIM completions 200`

**What the user is doing:** They type in the editor and expect Tab / ghost-text
to fill the *middle* of the current edit (prefix above the cursor, suffix below).

**What has to work for that need to be met:** The autocomplete model must accept
a **fill-in-the-middle (FIM)** prompt on the **legacy completions** API
(`/v1/completions`), not only chat. Chat-only success does **not** prove Tab
complete. Failure modes the user feels: no suggestions, spinner forever, or
garbage inserted mid-function.

**Model contract:** Continue
`promptTemplates.autocomplete` uses `<|fim_prefix|>{{{prefix}}}<|fim_suffix|>{{{suffix}}}<|fim_middle|>`,
which matches Ollama `qwen2.5-coder:1.5b-base` Modelfile TEMPLATE
(`{{- if .Suffix }}…<|fim_*|>…`). See `roles/continue_ide/README.md`.

**What the smoke proves:** LiteLLM route for `qwen2.5-coder-1.5b-base-q8_0` accepts a
FIM-shaped prompt and returns **HTTP 200** with **non-empty** completion text.
That is the minimum end-to-end proof that **IDE autocomplete plumbing works**;
it is not a grade of suggestion quality (separate ATDD can require substrings
like `return`).

---

## `embed smoke 768 dims`

| Piece | Meaning |
| --- | --- |
| **embed smoke** | A test `POST` to LiteLLM `http://litellm.hom.lab/v1/embeddings` with model `nomic-embed-text` and a short sample string |
| **768 dims** | The response embedding vector had **length 768** (768 floating-point numbers). That is the expected output width for `nomic-embed-text` — it proves the gateway reached Ollama and returned a real embedding, not an empty or error body |

HTTP status for that call was **200**. If dims were 0 or status were 4xx/5xx, embed would be **fail**.

## `FIM completions 200`

| Piece | Meaning |
| --- | --- |
| **FIM** | Fill-in-the-middle — the autocomplete prompt shape Continue uses (`<\|fim_prefix\|>…<\|fim_suffix\|>…<\|fim_middle\|>`), aligned with Ollama `qwen2.5-coder:1.5b-base` TEMPLATE |
| **completions** | A test `POST` to LiteLLM `/v1/completions` (legacy completions API, not chat) with model `qwen2.5-coder-1.5b-base-q8_0` |
| **200** | HTTP **200 OK** — the autocomplete route accepted the FIM prompt and returned completion text (probe also recorded a non-zero `text_len`) |

So: **embed works end-to-end with the right vector size; autocomplete FIM works end-to-end through the gateway.** Neither number is a quality grade (not “768% good” or “200 points”).

## How to re-run (operator)

Use vault-backed Ansible `uri` calls (do not paste the master key into chat). Check:

1. `GET /v1/models` includes `nomic-embed-text` and `qwen2.5-coder-1.5b-base-q8_0`
2. `POST /v1/embeddings` → status 200, `len(data[0].embedding) == 768`
3. `POST /v1/completions` with FIM prompt → status 200, non-empty `choices[0].text`

**Harness today:** FIM journey already runs via approved
[`model-lane-acceptance/gateway/manifest.yml`](../../../model-lane-acceptance/gateway/manifest.yml)
(`./model-lane-acceptance/scripts/run-gateway-acceptance.sh -m llm_fim -v -s`).
Embed journey is specified in the ATDD doc above; Python `type: embed` is still a
harness gap in global-skills.
