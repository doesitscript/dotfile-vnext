# Continue Mac-local stack — example commands

Companion to the [brainstorm plan](continue-mac-local-model-plan.md).
Status: **provisional_example / pending_research**. These commands are reference
material, not an executed installation script. Verify model tags and variants
before running downloads. Pulls require network access and disk space; the
intended subsequent inference is local.

## Initial experiment candidates

The edited plan adds a 3B Base autocomplete comparison, keeps nomic and 7B edits,
and starts with reranking OFF. The explicit Base tag examples below require
availability checks; they were not included in the original command list.

Do not run `ollama pull` for this plan. The human-run scripts, and the
pattern copies in [examples/](examples/README.md), are:

- `exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-controller.sh`
- `exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`

Those scripts print `echo:huggingface` / `echo:ollama` first. Matching
`process:` blocks are the later mac-dev download and work-laptop import.
Add another CLI as its own echo+process pair above `SECTION: next-cli`.
Tags those imports create:

```text
qwen2.5-coder:1.5b-base
qwen2.5-coder:3b-base
nomic-embed-text
qwen2.5-coder:7b-instruct
```

## Inspection examples for a later experiment

```bash
ollama --version
ollama list
ollama ps
ollama show qwen2.5-coder:1.5b-base
ollama show qwen2.5-coder:3b-base
ollama show qwen2.5-coder:7b-instruct
```

Use inspection results alongside system memory and latency measurements; a
downloaded model list alone does not prove which model Continue actually uses.

## Original reranker command — deferred, unverified

Preserved exactly from the original proposal for next-iteration consideration.
Do not include it in the initial download batch. Confirm the model exists under
this name and that Continue can invoke it through a supported reranking API.

```bash
# Archived example: availability and Ollama reranking support unverified
ollama pull bge-reranker-large
```

No second reranker download is proposed initially. Consider `bge-reranker-base`
only if the large reranker improves retrieval enough to keep ranking but imposes
too much latency or memory use. `bge-m3` remains an archived research idea, not
an approved substitute or a command to run.

The original autocomplete config used `qwen2.5-coder:1.5b`; preserve that generic
identifier as history, but verify the Base variant intended by the later edits.
None of these commands writes Continue's configuration or proves role integration.
