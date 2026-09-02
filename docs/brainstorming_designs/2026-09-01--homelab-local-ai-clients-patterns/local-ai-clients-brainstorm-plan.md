---
title: Homelab local AI clients — Continue, OpenCode, Codex CLI
status: brainstorm
execution_status: not_started
created_at: 2026-09-01
agents:
  cursor_suffix: cursor-kilo
  codex_suffix: codex
related:
  - docs/brainstorming_designs/draft_vllm_considerations.md
  - docs/plans/2026-07-23--continue-model-lanes-desktop-hvh01-incomplete/
  - homelab-reference-library/implementation-guides/kilo-code/homelab-litellm-provider.md
gateway: http://litellm.hom.lab/v1
---

# Homelab local AI clients — brainstorm plan

## Goal

Two independently configured coding setups, each with **researched** models and
configs that fit existing homelab GPU/runtime lanes. Operator should need only
minimal steps after automation (Continue/OpenCode: config-complete; Codex CLI:
homelab profile switch).

**CLI use standard (both agents):** project chat, console work, refactors, skill
authoring — pick model tier appropriate to task complexity.

## Agent split

| Owner | Products | Config surface |
| --- | --- | --- |
| **Cursor** | [Continue](https://docs.continue.dev/) in Cursor + [OpenCode](https://opencode.ai/install) | Continue `config.yaml`; OpenCode project/global config per vendor docs |
| **Codex** | OpenAI Codex CLI | Homelab-fixed profile/template in repo; local model entries per Codex CLI docs |

Models **do not** need to match across agents. They will not run at the same time.

## Shared infrastructure (already live — verify, do not reinvent)

| Route (`model@host`) | Runtime | GPU | Role hint |
| --- | --- | --- | --- |
| `qwen2.5-coder-14b@k3s02-vllm` | vLLM AWQ | RTX 5090 (32 GB) | Quality chat/plan; **broken tool_calls** on vLLM hermes today |
| `ministral-3-8b@desktop` | Ollama | RX 9060 XT | Agent/tools fallback |
| `qwen2.5-coder-1.5b@hvh01` | Ollama | GTX 1060 | Fast/autocomplete |

Gateway: `http://litellm.hom.lab/v1` — client IDs in
`roles/k3s_litellm_gateway/defaults/main/model_client_ids.yml`.

**vLLM constraints** (`draft_vllm_considerations.md`):

- Prefer **FP8 > AWQ/GPTQ > BitsAndBytes**; avoid GGUF on vLLM (experimental).
- On 32 GB: `gpu-memory-utilization` ~**0.90**, not 95–100%.
- Do not “fix” context by arbitrary truncation — size model + `max-model-len` correctly.

## Research gate (mandatory — both agents)

Before pinning models or editing gateway/inventory:

1. **Context7** — product docs:
   - Continue: config schema, model roles, context limits
   - OpenCode: install + config (anchor: https://opencode.ai/install)
   - Codex CLI: profiles, model provider config, local OpenAI-compatible base URL
   - vLLM / LiteLLM as needed for route compatibility
2. **Local authority** — if HRL or repo docs already cover the slice, use them
   (e.g. Kilo investigation note, existing Continue plan).
3. **HRL output** — add/update `implementation-guides/` entries per product; no
   invented model IDs or `~friendly` suffixes in active config (use `model@host` only).
4. **Live probes** — chat + (where applicable) tool/completion smoke via
   `playbooks/validate_kilo_litellm_probes.yaml` pattern or product-specific probes.

**Prohibited:** training-memory defaults when Context7 or local SSOT exists.

## Cursor scope (`-cursor-kilo` plan)

### Continue

- Install extension if missing; configure via **repo-managed or documented**
  `config.yaml` (Continue docs: models, roles, `apiBase`, context/output caps).
- Route through **LiteLLM** (`litellm.hom.lab`), not raw vLLM/Ollama ports.
- Assign roles (chat, edit, apply, autocomplete) with researched model picks per GPU.
- Set explicit context/output limits aligned with vLLM `--max-model-len`.
- **Test:** edit/apply/chat against a real repo file; capture probe output in plan receipt.

### OpenCode

- Install per https://opencode.ai/install (anchor product; not OpenClaw).
- Project-level config for homelab LiteLLM provider + model list.
- Same CLI standard: chat, console, refactor, skills.
- **Test:** non-interactive or scripted smoke where OpenCode supports it.

### Model selection (Cursor-owned)

Research and pick Continue + OpenCode lanes independently. Reasonable targets:

- **5090 / vLLM:** next-gen coder with native tool parser (e.g. Qwen3-Coder + `qwen3_coder`) — research before deploy; do not restore 32B without matrix.
- **Desktop Ollama:** 8B-class tool-capable model (ministral or successor).
- **HVH-01:** 1.5B fast lane.

## Codex scope (`-codex` plan)

### Codex CLI homelab profile

- Add repo-owned **homelab profile template** (fixed `hom.lab` gateway, API key
  source from vault/env pattern used elsewhere).
- Document switch procedure (Codex-recommended profile mechanism — research Context7
  `/openai/codex` or current CLI docs).
- Wire `model@host` entries matching LiteLLM `/v1/models` (no invented lanes).
- Operator goal: switch to local models with **minimal** manual steps (profile select
  or env hook only).

### Model selection (Codex-owned)

Independent research pass; may differ from Continue/OpenCode picks.

## Promotion workflow

**Trigger:** user says execute / implement this brainstorm.

| Step | Action |
| --- | --- |
| 1 | Copy this file’s scope into two `docs/plans/2026-09-01--homelab-local-ai-clients-{cursor-kilo\|codex}/README.md` packets |
| 2 | Add plan frontmatter, Apply/Verify/Undo, diagram inventory per `docs/plans/README.md` |
| 3 | Leave brainstorm packet in place; link both plans from packet `README.md` |
| 4 | Implement only the agent’s half; cross-link sibling for shared infra changes |
| 5 | Run validation playbooks + product smoke tests before `lifecycle: implemented` |
| 6 | Rename brainstorm plan to `.partially-implemented.md` when first slice is live |

## Apply / Verify / Undo (high level)

| | |
| --- | --- |
| **Apply** | Cursor: Continue config + OpenCode install/config. Codex: CLI profile + docs. Shared: gateway routes only if research requires new models (Ansible playbooks). |
| **Verify** | LiteLLM model list; per-product chat/edit probe; context-limit request within configured caps; GPU util not pegged at 100%. |
| **Undo** | Revert config files / profile; `*_state: absent` only for new Ansible capabilities. |
| **Change class** | Config = idempotent; new model downloads = semi-manual/Ansible prefetch. |

## On Deck — user decisions to integrate

- [ ] Confirm OpenCode (opencode.ai) is the intended CLI — not OpenClaw.
- [ ] Approve promoted plan folder names (`…-cursor-kilo`, `…-codex`).
- [ ] Approve 5090 v2 model research target (Qwen3-Coder vs Qwen 3.6 27B) before any vLLM pin.

## Diagram Inventory

On promotion, add:

- Architecture: mac-dev → LiteLLM → {vLLM 5090, Ollama desktop, Ollama HVH-01}
- Routing: per-client config surfaces (Continue yaml, OpenCode config, Codex profile)
