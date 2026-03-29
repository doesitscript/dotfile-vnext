# Ansible Architect Team — Model Assignments

## Current Assignments

| Agent | Model | Reason |
|---|---|---|
| `ansible-coordinator` | `gemini-2.5-flash` | Dispatches and synthesizes — balanced, good tool use, 250 RPD workable |
| `ansible-planner` | `gemini-2.5-flash` | Structured planning output, Ansible pattern knowledge — Flash is sufficient |
| `ansible-researcher` | `gemini-2.5-pro` | Strongest reasoning for synthesizing docs and MCP tool output into grounded recommendations |
| `ansible-maturity-observer` | `gemini-2.5-flash-lite` | Narrow structured work, readonly, pattern match and tag — Lite is sufficient, 1000 RPD is generous |

---

## Honest Caveats

**Free tier rate limits will bite.**

| Model | Daily limit | What hits it first |
|---|---|---|
| `gemini-2.5-pro` | 100 RPD | The researcher. One heavy planning session with multiple novel topics could burn 5–10 calls. 100 RPD = roughly 10–20 research dispatches per day. |
| `gemini-2.5-flash` | 250 RPD | Coordinator + planner combined. A typical planning session uses 2–4 calls across both. Comfortable for moderate daily use, not for sustained heavy sessions. |
| `gemini-2.5-flash-lite` | 1000 RPD | Effectively unlimited for observer use. Not a concern. |

**Rate limits are per Google Cloud project, not per API key.** Multiple API keys in the same project share the same quota. Creating extra keys does not help.

**Cursor's Zero Data Retention policy does not apply when using a custom Gemini API key.** Your prompts follow Google's privacy policy instead of Cursor's. For planning sessions that include internal role names, inventory structure, or capability details, this is worth knowing.

**The `model:` frontmatter key in `.cursor/agents/` may or may not be the correct Cursor-native key for this field.** At the time of writing, Cursor's subagent spec was not fully documented. If the model dropdown in the UI does not reflect the frontmatter value, set it manually in the UI. The frontmatter is a best-effort implementation.

---

## Fallback Models

When a Gemini model is unavailable, hits its rate limit, or is not yet configured:

| Agent | Primary | Fallback |
|---|---|---|
| `ansible-coordinator` | `gemini-2.5-flash` | `claude-3-5-haiku` — fast, cheap, solid tool use |
| `ansible-planner` | `gemini-2.5-flash` | `claude-3-5-haiku` — same reasoning |
| `ansible-researcher` | `gemini-2.5-pro` | `claude-sonnet-4-5` — strong reasoning, the current default model in this repo's Cursor sessions |
| `ansible-maturity-observer` | `gemini-2.5-flash-lite` | `claude-3-5-haiku` — narrow structured work, Haiku handles it cleanly |

**Fallback rationale:** Claude Haiku is the dealer's choice for the three lighter agents — it is fast, cheap per token, and handles structured output and tool calls reliably. The researcher gets Claude Sonnet as fallback because research synthesis is the one job where the stronger model earns its cost. Sonnet is also what the main Cursor session already uses, so it requires no additional setup.

**To switch to fallback:** change the `model:` value in the relevant `.cursor/agents/*.md` file, or update it in the Cursor UI model dropdown.
