# Open WebUI deploy — 2026-07-24

## What succeeded
- Role `open_webui` + playbook `deploy_open_webui.yaml`
- Classification gate: only `hom-lab-ctl-dkr-02` (`ai-client-ui`)
- Rendered `/srv/stacks/openwebui/{docker-compose.yml,.env}` and data dir

## What blocked then recovered
1. First pull: TLS handshake timeout to ghcr.io — retry succeeded.
2. Port 3000: already Grafana on dkr-02 — switched Open WebUI to **3080**.

## Current verify (2026-07-24)
- Image: `ghcr.io/open-webui/open-webui:v0.6.18`
- Compose project: `/srv/stacks/openwebui`
- Host port: **3080** → container 8080
- LiteLLM: `OPENAI_API_BASE_URL=http://litellm.hom.lab/v1`

## Related
- HVH-02 portproxy entry `openwebui`: `192.168.50.158:3080` → `192.168.137.10:3080`
  (inventory; converge via `configure_hyperv_windows_hosts.yaml`)
- UI guest: `http://192.168.137.10:3080` · LAN after portproxy: `http://192.168.50.158:3080`
- LiteLLM backend (not the UI): `http://litellm.hom.lab/v1`
- Policy: `ai-client-ui` / `policy/execution_roles.yml`
