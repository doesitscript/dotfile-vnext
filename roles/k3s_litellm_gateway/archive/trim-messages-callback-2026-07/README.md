# Archived: LiteLLM trim_messages callback (2026-07)

**Status:** archived — not mounted on the live LiteLLM gateway.

**Live replacement:** Request Inspector callback in
`roles/k3s_litellm_gateway/templates/custom_callbacks.py.j2`
(observe-only; does **not** mutate messages).

## What this archive is

Snapshot of the combined pre-call hook that:

1. **Observed** Cursor `tools[]` token tax (breakdown logs + pod JSON dumps)
2. **Mutated** requests via `litellm.utils.trim_messages` + hard character cut
   when `model_info.trim_messages: true`

That mix lived under names like `trim_messages` even for pure logging. The
Request Inspector keeps/upgrades the observe half as the permanent product.
The mutate half is intentionally **out of the live path**.

## Why it existed

Local Ornith / vLLM primary is ~32k context. Cursor Agent injects large
builtin `tools[]` schemas (~26k tokens observed). Without trim, LiteLLM/vLLM
hit `ContextWindowExceededError` or mid-stream `finish_reason=length`
(Cursor Internal Server Error). See:

- `docs/diagnostics/litellm-context-window--k3s--diagnostics.md`
- `docs/lessons-learned/codex/local-llm-context-vs-always-on-framework-rules.md`

## Former live Ansible / inventory names

These belonged to the **mutate** path. They are documented here so operators
can revive the archive without guessing. Live role vars are now
`k3s_litellm_gateway_request_inspector_*`.

| Former live var | Purpose |
| --- | --- |
| `k3s_litellm_gateway_trim_messages_enabled` | Mount ConfigMap + register callback |
| `k3s_litellm_gateway_trim_messages_callback_configmap` | ConfigMap name (`litellm-callback-files`) |
| `k3s_litellm_gateway_trim_messages_callback_ref` | `custom_callbacks.proxy_handler_instance` |
| `k3s_litellm_gateway_trim_messages_max_input_tokens` | Input budget (24000) |
| `k3s_litellm_gateway_trim_messages_safety_tokens` | Safety headroom (2048) |
| `k3s_litellm_gateway_trim_messages_min_completion_tokens` | Preferred completion (4096) |
| `k3s_litellm_gateway_trim_messages_min_message_tokens` | Min chat reserve (2048) |
| `k3s_litellm_gateway_trim_messages_chars_per_token` | Hard-cut density (2.5) |
| `model_info.trim_messages: true\|false` | Per-alias opt-in to **mutate** |

## Naming pair (archive vs live)

| Concept | Archive (this folder) | Live gateway |
| --- | --- | --- |
| Callback job | trim_messages (+ incidental observe) | request inspector (observe only) |
| Ansible enable flag | `*_trim_messages_enabled` | `*_request_inspector_enabled` |
| Handler class | `MessageTrimHandler` | `RequestInspectorHandler` |
| Log prefix | `litellm trim_messages …` | `litellm request_inspector …` |

## How to revive mutate (emergency only)

1. Copy `custom_callbacks.py.j2` from this archive over the live template
   **or** mount this file as the ConfigMap data (temporary).
2. Restore the former `*_trim_messages_*` defaults/argspec/task wiring from git
   history if needed.
3. Redeploy `playbooks/deploy_litellm_gateway.yaml` so the subPath remounts.
4. Prefer fixing context budget (rules/tools/window) over permanent trim revival.

## Files

- `custom_callbacks.py.j2` — full archived template (Jinja still references
  former `k3s_litellm_gateway_trim_messages_*` defaults).
