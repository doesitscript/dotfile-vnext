---
id: continue-jan-local-openai
status: promoted
behavior_group: continue-local-models
title: Continue sole autocomplete via LiteLLM Q8_0 (DMR catalog alternate)
---

## Trigger

- Inbox Continue notes + `inbox/config.yaml`
- Prefer OpenAI-compatible local APIs; never `provider: ollama` for Jan/DMR ids
- Inbox 2026-09-12: dual autocomplete (gateway Q8_0 + DMR) broke Tab-complete

## Accommodation (work-laptop packet)

- **Sole autocomplete role:** LiteLLM `qwen2.5-coder-1.5b-base-q8_0` (HVH-01
  Ollama GGUF FIM via gateway). Exactly one model may own `autocomplete`.
- **DMR catalog alternate (no role):** kept in `continue_ide_local_models` as
  `local/qwen2.5-coder-autocomplete:1.5b-q8_0` with `roles: []` so Ansible
  renders `roles: []` (not a YAML null).
- Embed (optional): LM Studio `http://127.0.0.1:1234/v1` / `continue-nomic-embed`
- **Not deployed on work laptop:** Jan `:1337`, Ollama provider/tags, bare
  llama.cpp `:8080`, DMR as default autocomplete
- Jan/Ollama recipes retained in parent only:
  `docs/lessons-learned/continue/jan-and-ollama-local-autocomplete.md`
- Edit/apply: LiteLLM `qwen2.5-coder-14b` / `qwen2.5-coder-7b`
- Chat: `qwen3-coder-30b-a3b`
- MCP: nvm-exec + Homebrew `uvx` for AWS IaC

## Re-apply

```bash
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags continue
python3 - <<'PY'
import yaml
from pathlib import Path
cfg = yaml.safe_load(Path.home().joinpath(".continue/config.yaml").read_text())
owners = [m.get("model") for m in cfg.get("models", []) if "autocomplete" in (m.get("roles") or [])]
assert owners == ["qwen2.5-coder-1.5b-base-q8_0"], owners
print("ok sole autocomplete:", owners[0])
PY
```

## Generalize

| Peer | Action |
| --- | --- |
| Other OpenAI-compatible local servers | Same provider openai + real model id |
| Jan/Ollama on another Mac | Use parent lessons-learned doc — do not copy into this packet |
