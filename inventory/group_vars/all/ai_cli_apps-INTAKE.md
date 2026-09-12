# AI CLI apps intake — what feeds from this file

**Intake SSOT:** [`ai_cli_apps.yml`](./ai_cli_apps.yml)

- Commissioned LiteLLM `model@host` ids → `ai_cli_commissioned_models`
- Client role registry → `ai_cli_apps`
- Agent prompt snippet → `ai_cli_model_lane_intake.prompt_snippet`
- ASCII cog layout → [`ai_cli_apps-INFRA-COGS.md`](./ai_cli_apps-INFRA-COGS.md)

This file is the **client-facing commission list**. It does **not** pull weights
or open firewall ports by itself. Downstream pieces must stay aligned when you
add/change a commissioned id.

## Copy-paste agent prompt

From `ai_cli_model_lane_intake.prompt_snippet` in the YAML:

```text
Use skill continue-ide-model-lane-recommend with:
  roles: [chat, edit, apply, autocomplete, embed]
  free_infra: <hosts, GPUs, VRAM, runtimes>
  client: mac-dev Continue via LiteLLM
Then use skill homelab-ansible-first-entry to apply, then continue-ide-model-lane-verify.
```

## Dependents (what consumes this intake)

| Layer | Path / surface | How it uses this intake |
| --- | --- | --- |
| Continue IDE config | `roles/continue_ide/defaults/main.yml` + `mac-dev` host_vars | Maps roles (`chat`/`edit`/`apply`/`autocomplete`/`embed`) to commissioned ids; renders `~/.continue/config.yaml` |
| Cline / OpenCode / Kilo / Aider / Codex | sibling roles under `roles/*` | Should expose the same enabled catalog where the client supports multi-model lists |
| LiteLLM gateway routes | `roles/k3s_litellm_gateway/` + `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` | **Must** publish each enabled id on `GET /v1/models` or clients look empty |
| Ollama pulls | `roles/windows_ollama_runtime` + HVH-01 / desktop host_vars | Supplies backend tags (`qwen2.5-coder:*`, `nomic-embed-text`, …) behind those ids |
| vLLM primary | `roles/k3s_vllm_runtime` + k3s-02 | Backend for plain slug chat lanes (e.g. `qwen3.6-35b-a3b`; placement in notes, not `@k3s02-vllm`) |
| Model catalog | `inventory/group_vars/model_catalog/manifest.yml` | Durable lane status / research notes (heavier than this thin list) |
| Acceptance / ATDD | `model-lane-acceptance/` | Gateway + client maps that expect commissioned ids |
| Work-laptop packet | `exports/work-laptop-ai-tools/` | Mirrors commissioned defaults for the laptop export |
| Plan packet (worked example) | `docs/plans/2026-09-12-mac_and_model_recommend/` | Role cards, placement, smoke decode |

## Older models when upgrading (open question)

**Not a closed policy.** When a plan upgrades a role (example: Continue Edit
from `qwen2.5-coder-7b@desktop` to `qwen2.5-coder-14b@desktop`), agents must
**not** assume the older named entry should disappear from client catalogs.

- Catalog noise is not a problem yet; prefer **keep both** or demote roles /
  `enabled: false` with a comment over silent delete.
- Replacing a dual-role binding (edit+apply on 7B) with split bindings is fine;
  deleting the 7B **identity** from pickers is a separate, explicit choice.
- Durable note:
  [`docs/lessons-learned/continue/do-not-auto-retire-older-model-entries.md`](../../docs/lessons-learned/continue/do-not-auto-retire-older-model-entries.md)

## Change order (safe)

1. Research + place (`continue-ide-model-lane-recommend`)
2. Backend present (Ollama pull and/or vLLM serve)
3. LiteLLM route + client id
4. Add/enable row in `ai_cli_commissioned_models` (+ defaults keys)
5. Wire consuming roles (`continue_ide`, …)
6. Deploy `--tags ai_cli_apps` (and gateway/ollama as needed)
7. Verify (`continue-ide-model-lane-verify`)

Do **not** advertise a commissioned id in this YAML before the LiteLLM route
exists.

## Implementation status (2026-09-12)

- Parity gate: `bin/codex-env python model-lane-acceptance/scripts/check-ai-cli-model-parity.py` → **PASS**
- Client catalogs aligned: Continue / Cline / OpenCode / Kilo role defaults + work-laptop host_vars + Zed
- Live apply: `deploy_development_nodes.yaml --limit mac-dev --tags ai_cli_apps` → **ok**, Continue roles include edit 14B / apply 7B / autocomplete / embed
