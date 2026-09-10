# Inbox process receipt — 2026-09-10b (inbox/config.yaml)

## Source

- Sibling commit `0559c19` — `chore(inbox): add corrected Continue configuration`
- File: `inbox/config.yaml` (live Continue MCP + local model config from work Mac)

## Evaluation → packet changes

| Finding in inbox config | Packet action |
| --- | --- |
| Active autocomplete = DMR 3B on `12434/engines/llama.cpp/v1` | `continue_ide_local_models` matches; Jan not default |
| llama.cpp `:8080` + DMR 1.5b present with empty roles | Kept as alternates |
| LM Studio embed `:1234` / `continue-nomic-embed` | Added |
| Ollama block commented/deprecated | Keep `continue_ide_ollama_local_models: []` |
| No edit/apply entries | **Keep** LiteLLM `qwen2.5-coder-7b@desktop` (prior inbox + validations) |
| AWS IaC `command: ""` | Fix → `/opt/homebrew/opt/uv/bin/uvx` via `aws_iac_mcp_command` |
| Morph PATH = huge GUI dump | Replace with `~/.npm-packages/bin:~/.local/bin:$PATH` |
| Absolute `/Users/a805120/Documents/develop/...` paths | Keep Ansible `playbook_dir` / `HOME` templates |
| MCP nvm-exec paths | Already fixed in prior pass |

## Moved

- `inbox/config.yaml` → `inbox/processed/2026-09-10-continue-config.yaml`
