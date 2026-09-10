# Docker Model Runner — preferred work-laptop local models

**Status (2026-09-09):** preferred direction.  
**Ansible automation:** **disabled / not priority** until explicitly commissioned.  
Do **not** implement a `present|absent` role or playbook apply for DMR until
the user asks. This packet only preserves config shape, examples, and a
redeploy recipe so a future role can be idempotent.

## Why this exists

The **HVH public-share → rsync → `~/models` → Ollama/LM Studio import** path
is **tentatively deprecated**. Prefer Docker Model Runner (DMR) on the work
Mac: pull models as OCI artifacts, serve OpenAI-compatible APIs locally, point
Continue (and peers) at that API.

Legacy share/rsync helpers remain under `helpers/work-mac-local-models/` for
history and emergency use. New work should not extend that pipeline.

## Authority surfaces

| Surface | Role |
| --- | --- |
| This file | Preferred-path contract + automation gate |
| `host_vars/work-laptop.yaml` | `work_laptop_docker_model_runner_*` flags + Continue local model intent |
| `helpers/docker-model-runner/examples/` | Compose + Continue snippets + redeploy checklist |
| `helpers/docker-model-runner/examples/save/` | Captured findings from rsync/LM Studio inbox |
| `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/` | Brainstorm; update status toward DMR |
| Legacy | `WORK-MAC-LOCAL-MODEL-ARRIVAL.md`, `helpers/work-mac-local-models/` |

## Config intent (from current host_vars)

Continue still declares local autocomplete / embed / edit / apply roles in
`continue_ide_ollama_local_models` (Ollama provider / tags). That block is the
**role intent** to preserve when moving to DMR:

| Continue role | Current model tag (provisional) | Future DMR note |
| --- | --- | --- |
| autocomplete | `qwen2.5-coder:1.5b-base` / `3b-base` | Map to a pulled DMR model id |
| embed | `nomic-embed-text` | Prefer a DMR embedding-capable model |
| edit / apply | `qwen2.5-coder:7b-instruct` | Map to DMR chat model |

DMR host API (typical Desktop):

```text
http://127.0.0.1:12434/engines/v1
```

**Work-laptop Continue (proven 2026-09-10 `inbox/config.yaml`):**

```text
http://127.0.0.1:12434/engines/llama.cpp/v1
```

with model ids like `local/qwen2.5-coder-autocomplete:3b-q8_0`. Prefer that
shape in `continue_ide_local_models` until DMR docs and the laptop disagree.

Continue uses `provider: openai` + that `apiBase` (same pattern as LM Studio
on `:1234/v1`). Exact model ids must come from the laptop `/models` response
or `docker model list` — do not invent Hub tags as selected.

## Automation gate (disabled)

```yaml
# host_vars/work-laptop.yaml — keep false until user commissions
work_laptop_docker_model_runner_enabled: false
work_laptop_docker_model_runner_automation: disabled
```

When automation is later commissioned, the role must implement Apply / Verify
/ Undo against the examples in `helpers/docker-model-runner/examples/` and
must remain idempotent (`docker model pull` / compose up of already-present
models should be no-op or converge, not re-download blindly every run).

## Human redeploy (idempotent recipe — no Ansible yet)

See `helpers/docker-model-runner/examples/redeploy-checklist.md`.

## Related deprecation

- `WORK-MAC-LOCAL-MODEL-ARRIVAL.md` — legacy arrival path
- Skills `work-laptop-model-public-download` / `work-laptop-model-runtime-import` — legacy echo helpers
- Deviation `smb-stable-mount-hvh01` — still valid if someone uses the legacy mount; not the preferred path

## Vendor docs

- https://docs.docker.com/ai/model-runner/
- https://docs.docker.com/ai/model-runner/get-started/
- https://docs.docker.com/ai/compose/models-and-compose/
- https://docs.docker.com/reference/cli/docker/model/
