# Mac Continue roles + lab Ollama placement (2026-09-12)

## Packet index

| Doc | Purpose |
| --- | --- |
| [plan.md](./plan.md) (this file) | Recommendation table + intake status |
| [smoke-evidence-decode.md](./smoke-evidence-decode.md) | Plain-language decode of embed/FIM smoke numbers + human need |
| ATDD embed+FIM | [`model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md`](../../../model-lane-acceptance/gateway/continue-embed-and-fim-atdd.md) |
| [continue-role-requirements.md](./continue-role-requirements.md) | What to look for for **every** Continue role |
| [model-role-fit.md](./model-role-fit.md) | How each recommended model matched role needs |
| [placement-selection.md](./placement-selection.md) | Why each model landed on which host |
| [skills-recommended.md](./skills-recommended.md) | Skills to streamline roles → infra → research → recommend → apply |
| Inventory intake SSOT | [`inventory/group_vars/all/ai_cli_apps.yml`](../../../inventory/group_vars/all/ai_cli_apps.yml) (`ai_cli_model_lane_intake`) |
| Intake dependents | [`ai_cli_apps-INTAKE.md`](../../../inventory/group_vars/all/ai_cli_apps-INTAKE.md) |
| Infra cogs (ASCII) | [`ai_cli_apps-INFRA-COGS.md`](../../../inventory/group_vars/all/ai_cli_apps-INFRA-COGS.md) |

Good context from the images — the Mac hosting nothing (given it overheats and has no real GPU, just Iris Pro integrated graphics) is the right call regardless. Here's my fresh take, with the leftover GTX 1060 box and the AMD card doing the actual work:

| Role | Model | Deploy to | Runtime | Why |
|---|---|---|---|---|
| **Autocomplete** | `qwen2.5-coder:1.5b-base` | **HOM-LAB-HVH-01** (GTX 1060 6GB) | Ollama | Autocomplete needs raw speed above all — sub-second latency per keystroke. Critically, this should be the **base** model, not Instruct: FIM (fill-in-the-middle) completion is a next-token-prediction task, not a chat task, and base models handle the FIM tokens more reliably. A 1.5B fits in ~1.5GB and leaves headroom on that card. |
| **Embed** | `nomic-embed-text` | **HOM-LAB-HVH-01** (GTX 1060 6GB) | Ollama | This is exactly the "run it somewhere else" move you were already thinking. Embedding models are tiny (~275MB) and don't need meaningful compute — nomic-embed-text is the standard pick here. Coexists fine on the 1060 next to the 1.5B autocomplete model (both together are still under 2GB). This takes the embedding workload off the Mac entirely, which is your actual goal. |
| **Edit** | `qwen2.5-coder:14b-instruct` | **dev-workstation-win** (RX 9060 XT 16GB) | Ollama | Upgrade from your current 7B. The 16GB card has room (14B runs ~9GB at Q4), and Edit benefits more from reasoning/quality than Apply does, since it's generating the actual code transformation. |
| **Apply** | `qwen2.5-coder:7b-instruct` (keep as-is) | **dev-workstation-win** (RX 9060 XT 16GB) | Ollama | Apply's job is narrower — mechanically merging a generated diff into a file — so it doesn't need the same reasoning depth as Edit. Your current 7B is already a sensible fit here; no need to change it. Running Edit (9GB) + Apply (4.5GB) together still fits comfortably under 16GB if both stay loaded. |

**Deliberately left untouched:** HOM-LAB-HVH-02 (the 5090/vLLM box) — that's already committed to the primary coder + generalist agent lanes from earlier in this conversation. Loading these small auxiliary roles onto it would just compete for VRAM against the models that matter most for actual coding work.

**Client routing:** Continue keeps `apiBase: http://litellm.hom.lab/v1`. Each role selects a different LiteLLM `model@host` id so backends land on HVH-01 vs desktop vs vLLM without Continue talking to three Ollama URLs directly. Detail: [placement-selection.md](./placement-selection.md).

---

## Intake status (executed)

| Obligation | Status | Evidence |
| --- | --- | --- |
| Pull Ollama tags via `windows_ollama_runtime` | pass | HVH-01: `1.5b-base`, `nomic-embed-text`; desktop: `7b`, `14b` |
| LiteLLM routes for Ollama backends | pass | `/v1/models` lists `1.5b@hvh01`, `14b@desktop`, `7b@desktop`, `nomic-embed-text@hvh01` |
| Continue mac-dev role assignment (add, no delete) | pass | `~/.continue/config.yaml` roles wired; chat/Gemini/gpt-oss kept |
| Live embed + FIM smoke | pass | See decode below / [smoke-evidence-decode.md](./smoke-evidence-decode.md) |
| Research run params (Context7 / Firecrawl) | done | below |
| Role guidance + model fit + placement docs | done | packet files above |
| Streamline skills scaffolded | done | [skills-recommended.md](./skills-recommended.md) |

### Smoke line in plain English

Recorded shorthand: `embeddings 768-dim; /v1/completions FIM 200`

- **768-dim** = embed probe returned a vector of length **768** (correct for nomic) over HTTP 200
- **FIM 200** = autocomplete FIM probe to `/v1/completions` returned HTTP **200 OK** with text

Full decode: [smoke-evidence-decode.md](./smoke-evidence-decode.md).

### Ollama ↔ LiteLLM

**Works for this lab.** Existing routes already use Ollama OpenAI `/v1` (`openai/` + `api_base …:11434/v1`) for chat/completions, and native `ollama/` for some desktop lanes. Embeddings use LiteLLM `ollama/nomic-embed-text` with `api_base` without `/v1`. Continue clients keep `apiBase: http://litellm.hom.lab/v1` and select backends via `model@host` ids.

### Recommended run parameters (research)

| Model | Runtime knobs | Continue / client |
| --- | --- | --- |
| `qwen2.5-coder:1.5b-base` | Ollama library tag (valid); HF `Qwen/Qwen2.5-Coder-1.5B`; small `num_ctx` (~4k) is enough for FIM | temp **0.0**, debounce **250**, maxPromptTokens **1024**, legacy completions + FIM template |
| `nomic-embed-text` | Ollama ≥ 0.1.26; `/api/embed` or OpenAI embeddings; ~137M | Continue role `embed` only |
| `qwen2.5-coder:14b` (instruct default) | Desktop `OLLAMA_CONTEXT_LENGTH=12000` already set | Edit: temp **0.2**, maxTokens **4096** |
| `qwen2.5-coder:7b` | Same desktop runtime | Apply: temp **0.2**, maxTokens **4096** |

Sources: Ollama Modelfile / embed API (Context7 `/websites/ollama`), ollama.com library tags + nomic page (Firecrawl), Continue autocomplete docs, LiteLLM Ollama + embeddings docs.

### Client id mapping

| Continue role | LiteLLM `model` | Backend |
| --- | --- | --- |
| autocomplete | `qwen2.5-coder-1.5b@hvh01` | Ollama `qwen2.5-coder:1.5b-base` @ HVH-01 |
| embed | `nomic-embed-text@hvh01` | Ollama `nomic-embed-text` @ HVH-01 |
| edit | `qwen2.5-coder-14b@desktop` | Ollama `qwen2.5-coder:14b` @ desktop |
| apply | `qwen2.5-coder-7b@desktop` | Ollama `qwen2.5-coder:7b` @ desktop |
| chat (unchanged) | `qwen3.6-35b-a3b` + Gemini / gpt-oss | existing |
