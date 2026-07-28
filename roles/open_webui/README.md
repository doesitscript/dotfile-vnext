# open_webui

Compose Open WebUI as the human OpenAI-compatible client for LiteLLM.

**Targeting:** capability-selected (`ai-client-ui` via `classify_host`). Do not
use `hosts: HOM-LAB-HVH-02`.

**depends_on** (`policy/process_order.yml` + `meta/main.yml`):

- `classify_host` (Ansible role dependency when facts missing)
- LiteLLM gateway (`http://litellm.hom.lab/v1`)
- Docker engine on the ai-client-ui host

soft: HVH portproxy LAN publish; NetBox capability tags

| | |
| --- | --- |
| **Apply** | `ansible-playbook playbooks/deploy_open_webui.yaml` |
| **Verify** | container up; HTTP on host port; models via LiteLLM |
| **Undo** | `open_webui_state: absent` + re-run |
| **Change class** | idempotent Compose config |
