---
id: continue-jan-local-openai
status: promoted
behavior_group: continue-local-models
title: Continue local autocomplete via DMR 1.5B (Jan/Ollama not deployed)
---

## Trigger

- Inbox Continue notes + `inbox/config.yaml`
- Prefer OpenAI-compatible local APIs; never `provider: ollama` for Jan/DMR ids

## Accommodation (work-laptop packet)

- **Default autocomplete:** Docker Model Runner 1.5B
  `apiBase: http://127.0.0.1:12434/engines/llama.cpp/v1`,
  model `local/qwen2.5-coder-autocomplete:1.5b-q8_0`
- Embed (optional): LM Studio `http://127.0.0.1:1234/v1` / `continue-nomic-embed`
- **Not deployed on work laptop:** Jan `:1337`, Ollama provider/tags, bare
  llama.cpp `:8080`, DMR 3B as default
- Jan/Ollama recipes retained in parent only:
  `docs/lessons-learned/continue/jan-and-ollama-local-autocomplete.md`
- Edit/apply: LiteLLM `qwen2.5-coder-7b@desktop`
- Chat: `qwen3-coder-30b-a3b~coder-primary`
- MCP: nvm-exec + Homebrew `uvx` for AWS IaC

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags continue
rg -n '1.5b-q8_0|provider: ollama|1337|qwen2.5-coder-7b@desktop' ~/.continue/config.yaml
```

## Generalize

| Peer | Action |
| --- | --- |
| Other OpenAI-compatible local servers | Same provider openai + real model id |
| Jan/Ollama on another Mac | Use parent lessons-learned doc — do not copy into this packet |
