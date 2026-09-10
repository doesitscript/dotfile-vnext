---
title: Continue local autocomplete — Jan and Ollama learnings
status: reference
authority: internal
retrieved_at: "2026-09-10"
applies_to:
  - continue
  - jan
  - ollama
related:
  - docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/
  - exports/work-laptop-ai-tools/DOCKER-MODEL-RUNNER.md
---

# Continue local autocomplete — Jan and Ollama learnings

Work-laptop Continue **does not deploy** Jan or Ollama autocomplete. Those
products are fine; this slice standardized on **Docker Model Runner** (1.5B)
plus LiteLLM edit/apply. Keep the recipes below for other Macs or future
experiments.

## Jan (OpenAI-compatible)

Verified on the work Mac earlier (then superseded for the packet default):

```yaml
  - name: "Qwen 2.5 Coder 1.5B (Jan Autocomplete)"
    provider: "openai"
    apiBase: "http://127.0.0.1:1337/v1"
    apiKey: "jan-local"
    model: "qwen2.5-coder-1.5b-q8_0.gguf"   # from GET /v1/models — not an Ollama tag
    roles:
      - "autocomplete"
    defaultCompletionOptions:
      contextLength: 8192
      maxTokens: 128
      temperature: 0.1
    autocompleteOptions:
      debounceDelay: 250
      maxPromptTokens: 6144
    useLegacyCompletionsEndpoint: true
    promptTemplates:
      autocomplete: "<|fim_prefix|>{{{prefix}}}<|fim_suffix|>{{{suffix}}}<|fim_middle|>"
```

Check: `curl --fail --silent http://127.0.0.1:1337/v1/models`

Failure mode: using `provider: ollama` or an Ollama-style tag against Jan →
HTTP 400 model not found.

## Ollama (local provider)

Earlier packet drafts used `provider: ollama` + tags like
`qwen2.5-coder:1.5b-base`. That works when Ollama is the runtime. It is the
wrong provider for Jan or DMR OpenAI endpoints. Prefer `provider: openai` +
the server’s real `/v1` model id when the backend is OpenAI-compatible.

## Work-laptop default (deployed)

See packet `host_vars/work-laptop.yaml` → `continue_ide_local_models`:

- Autocomplete: DMR `local/qwen2.5-coder-autocomplete:1.5b-q8_0` at
  `http://127.0.0.1:12434/engines/llama.cpp/v1`
- Edit/apply: LiteLLM `qwen2.5-coder-7b@desktop`
- Chat: LiteLLM `qwen2.5-coder-32b@k3s02-vllm`

DMR Ansible install remains disabled until commissioned.
