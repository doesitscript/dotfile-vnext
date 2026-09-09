---
title: Continue Mac-local model stack and comparison experiments
status: brainstorm
execution_status: not_started
created_at: 2026-09-09
resource_selection_status: pending_research
---

# Continue Mac-local model stack

## Intent and provenance

First iteration is the **work laptop** only (MacBook Pro M3 Pro). This plan is
for getting models onto that Mac and pointing Continue at local Ollama. It is
not for installing or serving models on the controller Mac, except the
controller download into the public share.

Do not use `ollama pull`. That path sets runtime/library behavior we are not
using. The repeatable path is Hugging Face download on the controller, then
`ollama create` import on the work laptop. No `HF_HOME` or `OLLAMA_MODELS`
overrides.

Preserve the supplied proposal, with the later autocomplete and reranker edits
taking precedence. This entry does not certify its technical claims.

Model IDs below are **provisional_example** until the helper commands have been
run and `ollama list` matches the Continue `model` tags.

Human commands (you run these):

- Controller: `exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-controller.sh`
- Work laptop: `exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`

Share map: `exports/work-laptop-ai-tools/helpers/share_topology.md`.
`WORK_LAPTOP_PUBLIC_FOLDER` must be filled before the work-laptop script runs.

```text
controller Mac
  → hf download into \\HOM-LAB-HVH-01\public\models\huggingface
    (public root: apps, artifacts, driver-staging, models, studio; not HVH-02)
  → work laptop mount of that share
  → ollama create FROM <gguf>
  → continue_ide marked section continue-ollama-local
```

## Primary direction after edits

| Role | Proposed experiment | Decision rule |
| --- | --- | --- |
| Autocomplete | Qwen2.5-Coder-1.5B Base versus Qwen2.5-Coder-3B Base | Add the 3B candidate for an A/B test. Retain 1.5B if the extra latency is bothersome. |
| Embeddings (`embed`) | Keep `nomic-embed-text` | Hold the embedding model constant during comparisons. |
| Reranking (`rerank`) | Start OFF; compare with `bge-reranker-large` later | Make reranking demonstrate useful context improvements before retaining it. Do not initially download a second reranker. |
| Quick Edit (`edit` / `apply`) | Keep Qwen2.5-Coder-7B, with the original Instruct variant as the example | Evaluate targeted edits and applying changes separately. |

The supplied prediction is **3B autocomplete + nomic embeddings + no reranker +
7B Quick Edit** as a promising lightweight combination. This is a hypothesis,
not a benchmark result.

```text
Continue on the Mac
├── Autocomplete: select one for each test
│   ├── Qwen2.5-Coder-1.5B Base
│   └── Qwen2.5-Coder-3B Base — new comparison candidate
├── Embeddings: nomic-embed-text
├── Reranking
│   ├── OFF — baseline first
│   └── bge-reranker-large — subsequent comparison
└── Quick Edit / Apply: Qwen2.5-Coder-7B Instruct

Proposed runtime: Ollama locally; reranker integration pending research
```

## Role context from the original proposal

- **Autocomplete:** low-latency inline suggestions while typing.
- **Codebase embeddings:** build vector representations of repository content
  for retrieval. The supplied proposal calls the entry point `@Codebase`;
  confirm the installed Continue version's retrieval interface.
- **Search reranking:** score and reorder retrieved chunks before supplying
  context to a downstream model. The original “about 20 candidates, keep 3–5”
  numbers are illustrative, not established settings.
- **Quick inline edits and refactorings:** modify selected code. The supplied
  shortcut is `Cmd + I` / `Ctrl + I`; confirm IDE keybindings. Do not assume
  edit, apply, and repository retrieval are one identical workflow.

The original wording groups these as background tasks. Preserve the intended
local execution, but verify when each runs: indexing, retrieval-time ranking,
and user-triggered edits may have different execution paths. A reranker can only
affect an edit if that edit actually uses the retrieval path being tested.

## Experiment sequence

### 1. Establish the baseline and compare autocomplete

Keep nomic embeddings and the 7B edit candidate fixed, with reranking OFF.
Compare 1.5B Base against 3B Base on the same files, cursor positions, and prompts.
Confirm the exact Base model tags before downloading; the generic tags in the
original text do not establish which variant is installed.

Record warm and cold suggestion latency, useful suggestion acceptance, visible
typing interruptions, memory pressure, and swap. Choose 3B only if its quality
gain justifies the latency on this Mac; retaining 1.5B is an expected outcome.

### 2. Compare retrieval without and with the large reranker

Use the same repository snapshot, queries, embedding index, and downstream model:

1. **nomic embeddings → retrieved context → Qwen 7B; no reranker.**
2. **nomic embeddings → bge-reranker-large → Qwen 7B**, once a compatible
   reranking provider/API has been verified.
3. Only if step 2 is clearly better but too heavy, evaluate
   **bge-reranker-base** as a later alternative.

Record relevant chunks retrieved, final answer/edit correctness, added latency,
and memory pressure. Separately test highlighted-code edits that do not request
repository context, so their results are not incorrectly credited to reranking.
If ranking adds latency or memory without useful improvement, keep it OFF.

### 3. Record the result before promoting implementation

| Experiment | Quality / correctness | Cold / warm latency | Memory / swap | Decision |
| --- | --- | --- | --- | --- |
| 1.5B autocomplete | pending | pending | pending | pending |
| 3B autocomplete | pending | pending | pending | pending |
| Retrieval, reranking OFF | pending | pending | pending | pending |
| Retrieval, large reranker | pending | pending | pending | pending |
| Base reranker, conditional follow-up | pending | pending | pending | not initially scheduled |
| 7B edit and apply | pending | pending | pending | pending |

Record macOS, IDE, Continue and Ollama versions, total unified memory, exact model
tags/digests, quantization, context length, and other active workloads alongside
results. Compare battery use only under similar workloads and power conditions.

## Continue configuration

Work laptop only for this iteration. `roles/continue_ide` writes a marked
block `BEGIN ANSIBLE MANAGED: continue-ollama-local` from
`continue_ide_ollama_local_models` on `host_vars/work-laptop.yaml`. Chat and
MCP lanes are not replaced. The role does not download models. Run the helper
scripts first so the Ollama tags exist.

## Continue configuration sketch — pending research

The supplied destination is `~/.continue/config.yaml`; the original also mentioned
`config.json`. Verify the installed release's schema and migration behavior before
use. This YAML preserves the proposed role mapping, introduces the 3B comparison,
and leaves reranking out of the baseline. It is not a validated drop-in config.
Select one autocomplete entry for a test rather than assuming both are active.

```yaml
# provisional_example — validate schema, model tags, and role support first
name: Mac-Local Continue Setup
version: 0.0.1
schema: v1
models:
  - name: Qwen 2.5 Coder 7B (Local Edit)
    provider: ollama
    model: qwen2.5-coder:7b-instruct
    roles: [edit, apply]

  - name: Qwen 2.5 Coder 1.5B (Autocomplete Baseline)
    provider: ollama
    model: qwen2.5-coder:1.5b-base
    roles: [autocomplete]

  - name: Qwen 2.5 Coder 3B (Autocomplete Comparison)
    provider: ollama
    model: qwen2.5-coder:3b-base
    roles: [autocomplete]

  - name: Nomic Embed Text (Local Embeddings)
    provider: ollama
    model: nomic-embed-text
    roles: [embed]

# Baseline: no rerank model configured.
```

The Base-suffixed tags are created by
`continue-mac-local-work-laptop.sh` from the GGUF files downloaded by
`continue-mac-local-controller.sh`. They are not `ollama pull` tags.
Confirm whether any built-in/provider default still reranks
before labeling the baseline OFF. The original comment also mentioned small
chat, but its model roles included only `edit` and `apply`; if the retrieval
experiment needs chat, validate and explicitly configure that role.

## Superseded ideas and next-iteration considerations

| Original proposal | Current priority | Preserve for next iteration |
| --- | --- | --- |
| Use only Qwen2.5-Coder-1.5B for autocomplete | A/B test 1.5B Base and 3B Base | 1.5B remains the fallback if 3B slows suggestions too much. |
| Enable `bge-reranker-large` immediately | Start with reranking OFF | Compare large against OFF after baseline results and integration research. |
| Use `bge-m3` as a reranker alternative | No initial second reranker; consider base only conditionally | Research `bge-m3`'s model capabilities and API suitability separately; do not assume it is interchangeable with a reranker. |
| Configure Ollama directly as the rerank provider | Reranker provider path pending research | Preserve the original YAML below as an unverified integration idea. |
| About 2 GB for 1.5B, 300 MB for nomic, 600 MB for large reranker, 5 GB for 7B | Measure actual memory use | These are supplied estimates, not measured resident memory or a capacity budget. No 3B estimate was supplied. |
| Embedding and reranker models remain loaded together under 1 GB | No residency guarantee | Test concurrent loading with the actual models and runtime settings. |
| Ollama loads tiny models instantly without interrupting autocomplete | Measure cold loads and typing latency | Revisit scheduling and model residency only after contention measurements. |
| Autocomplete stays cached; 7B unloads after five idle minutes | Verify actual keep-alive settings | Test retention and eviction rather than treating the proposed timing as a guarantee. |
| Dynamic VRAM handling makes battery use low | Measure unified-memory pressure and battery impact on this Mac | Preserve power efficiency as a goal, not an observed benefit. |

Original reranker configuration, retained **only for next-iteration research**:

```yaml
# Archived provisional_example; not part of the baseline configuration
- name: BGE Reranker (Local Rerank)
  provider: ollama
  model: bge-reranker-large
  roles: [rerank]
```

Before promotion, verify Continue's supported providers per role, Ollama model
availability and reranking API compatibility, Base versus Instruct variants,
model licenses, and actual Mac capacity. Keep unresolved items pending rather
than treating a preserved example as a download or deployment decision.
