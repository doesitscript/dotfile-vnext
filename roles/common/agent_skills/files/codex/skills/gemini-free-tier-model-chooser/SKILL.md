---
name: gemini-free-tier-model-chooser
description: Recommend current Google Gemini Developer API free-tier models for a user's real workload and explain when to use each one. Use when Codex needs to compare Gemini models, shortlist free-tier options, suggest models for coding, infrastructure, MCP servers, Langfuse, LightLLM, RAG, or Cursor, or explain how to enable Gemini in Cursor.
---

# Gemini Free-Tier Model Chooser

Verify current free-tier availability before recommending anything. Gemini model availability, preview status, and deprecations change often.

## Workflow

1. Re-check Google's current Gemini Developer API pricing page to confirm which models are on the free tier.
2. Re-check Google's current Gemini models page to confirm positioning, capabilities, and any deprecation or preview status.
3. If the user asks about Cursor setup, re-check Cursor's current API-key/model-provider docs.
4. Tailor recommendations to the user's actual workload instead of listing every free-tier model.
5. Prefer 3-5 recommendations unless the user explicitly wants a complete catalog.

## How To Tailor Recommendations

- For hard coding, debugging, architecture, or long-context reasoning, bias toward the strongest reasoning model on the current free tier.
- For daily engineering work, shell/YAML/Python/TypeScript, and tool-using agents, bias toward the best balanced fast model.
- For high-volume background tasks, summarization, classification, formatting, and trace labeling, bias toward the lightest low-cost model on the free tier.
- For RAG or semantic search, include embedding models separately from chat/completion models.
- For preview models, call out stability risk clearly.
- For deprecated models, do not recommend them for new work unless the user explicitly asks for legacy compatibility.

## Output Shape

Default to a markdown table with these columns:

| Model | Best for | Why it fits | Caveat |
|---|---|---|---|

After the table, add:

- A clearly separated section using a horizontal rule: `---`
- A `## Opinionated Recommendation` section with concrete picks for the user's actual setup.
- In that section, prefer short bullets or a compact table covering the user's real categories, such as Cursor, MCP servers, Langfuse evals, and LightLLM routing.
- Make this section direct and decisive. Do not hedge unless the source docs genuinely force uncertainty.
- A short "Avoid for new work" section if any free-tier models are deprecated or near shutdown.
- If asked, add Cursor enablement steps.

## Cursor Setup

When the user asks how to enable Gemini in Cursor:

1. Tell them to create or copy a Gemini API key from Google AI Studio.
2. Tell them to open Cursor Settings, then Models.
3. Tell them to paste the Google/Gemini API key in the provider section and click Verify.
4. Tell them to select the Gemini model in Cursor's model picker.
5. Mention any current Cursor limitations from the docs, especially if custom API keys do not apply to all Cursor features.

## Reference

Load [selection-guide.md](./references/selection-guide.md) when you need workload mapping, wording patterns, or an opinionated shortlist structure.
