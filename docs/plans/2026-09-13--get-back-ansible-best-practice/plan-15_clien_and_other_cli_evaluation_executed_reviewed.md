Yes — your instinct is right. The Cline change was a **good local fix**, but the **scalable** pattern is not “special-case Cline forever.” It’s already half-built in your SSOT.

## What actually broke

Not “enabled when it shouldn’t be” in the global sense.

`qwen2.5-coder-1.5b-base-q8_0` is correctly `enabled: true` for **Continue FIM**. The bug was: **Cline treated every enabled commissioned model as an agent/chat picker entry**, then sent **tools** to a FIM-only lane.

So:

| Lever | Would it have fixed this alone? |
| --- | --- |
| Global `enabled: false` on 1.5B | No — breaks Continue autocomplete |
| Client-aware role filter (`chat`/`edit`/`apply` only) | Yes — what they did |
| Filter on `tools` capability for agent clients | Also important for Cline-like UIs |

## Scalable standard (Ansible-shaped)

You already have the data model pieces in `ai_cli_apps.yml`:

- per-model: `enabled`, `labels: [chat|edit|apply|autocomplete|embed|tools|…]`
- per-client registry: `ai_cli_apps` with `continue_ide`, `cline_ide`, …

What’s missing as a **shared contract** is something like:

```yaml
# conceptual — not claiming this exists yet as one var
ai_cli_client_model_contracts:
  continue_ide:
    accept_roles: [chat, edit, apply, autocomplete, embed]
  cline_ide:
    accept_roles: [chat, edit, apply]
    require_any_labels: [tools]   # optional stricter gate for agent mode
  kilo / codex / opencode:
    accept_roles: [chat, edit, apply]  # same family as Cline
```

Then **every** client renderer does the same thing:

1. Take `ai_cli_commissioned_models`
2. Keep `enabled: true` (or `present`)
3. Keep rows whose `labels` intersect that client’s `accept_roles`
4. Optionally require `tools` for agent CLIs
5. Assert default model ∈ filtered set

That’s the standard fix: **one SSOT + per-client capability contract + shared filter semantics**, not a one-off Cline hardcode — though the Cline task already implements the *shape* of step 3 (`intersect(['chat','edit','apply'])`).

Continue is the counterexample that proves you need **role-aware** filters, not a single global enable list: it *should* see FIM/embed; Cline should not.

## How this maps to “enable/disable”

Use Ansible lifecycle language carefully:

- **Model commissioned globally:** `enabled: true|false` on the SSOT row (you already have this).
- **Weights on disk:** download `present|absent` (separate).
- **Exposed to a given client:** not a second global boolean — **client accept_roles / require tools** (or sparse `clients: { cline: false }` overrides only when needed).

“Disable for Cline” by flipping global `enabled` is the wrong layer.

## Report lens on what they applied

From plan-13:

| Where | What |
| --- | --- |
| `roles/cline_ide/tasks/mac.yml` | Filter SSOT to labels intersecting `chat`/`edit`/`apply`; assert default ∈ catalog |
| `models.json.j2` | Unchanged logic; receives already-filtered list |
| Live `~/.cline/.../models.json` | Dropped FIM + embed |

**Reusable idea:** label-based role filter.
**Not yet scalable:** the accept-set lives only inside Cline’s task. Codex/Kilo/OpenCode/Aider could hit the same class of bug if they dump the full enabled SSOT into an agent picker.

## Residual risk (worth knowing)

Even after the FIM fix, Cline still gets chat/edit/apply rows that may **lack** `tools` in labels (e.g. 7B/14B, some Gemini). If the second error you saw was tool-related on a chat model, the next standard gate is: **agent clients require `tools` (or an explicit `agent: true`)**, not only “not FIM.”

## Bottom line

- Plan-13 fix: correct for Cline, high chance the **same filter pattern** applies to other agent-style clients.
- Your proposed standard: yes — **SSOT labels + per-client accepted roles (+ tools for agents)**, expressed once and reused by each role’s renderer.
- Don’t use global enable/disable to hide FIM from Cline; keep FIM enabled for Continue and filter by client capability.

I’m in Ask mode, so I can’t implement that shared contract — switch to Agent if you want it extracted from the Cline hardcode into inventory + shared by Continue/Cline/others.
