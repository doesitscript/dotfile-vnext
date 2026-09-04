---
id: litellm-key-ide-clients
status: promoted
behavior_group: litellm-client-keys
title: Continue/Cline empty UI without LiteLLM vault key
---

## Trigger

- Continue configuration looked empty on the work laptop.
- Placeholder `REPLACE_WITH_LITELLM_KEY` / missing vault key.

## Accommodation

- `continue_ide_require_api_key` / `cline_ide_require_api_key: true` — fail loud.
- Hydrate `vault_k3s_litellm_gateway_master_key`; never ship placeholder as “configured”.

## Re-apply

```bash
# After vault drop on laptop:
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file --tags continue,cline
grep -E 'apiKey:|models:' ~/.continue/config.yaml | head
```

## Generalize

| Peer | Same risk? | Action |
| --- | --- | --- |
| Zed openai.env | yes | same vault key |
| New OpenAI-compatible IDE | yes | require key assert + vault hydrate |
