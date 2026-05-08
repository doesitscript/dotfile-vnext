# Gemini Free-Tier Selection Guide

## Workload Mapping

- Infrastructure as code, WSL/Linux, shell, YAML, Ansible, Terraform, Kubernetes:
  Recommend one strong reasoning model and one fast default model.
- Higher-level programming:
  Recommend one deep-work model and one daily-driver model.
- MCP servers and agent/tool orchestration:
  Prefer fast models with good tool-use behavior; mention preview risk if applicable.
- Langfuse and eval pipelines:
  Prefer lighter models for bulk summarization, classification, trace tagging, and judge-style passes.
- LightLLM and RAG:
  Separate generation-model recommendations from embedding-model recommendations.

## Opinionated Framing

Use language like:

- "Use this as your deep-work model."
- "Use this as your default daily model."
- "Use this for cheap bulk work."
- "Use this for experiments, not your most stable path."
- "Use this as your embedding layer."

## Default Shortlist Pattern

Prefer this shape when the user wants a practical answer instead of a full catalog:

1. Strong reasoning model
2. Balanced default model
3. Cheap bulk-work model
4. Optional experimental preview model
5. Embedding model

## Opinionated Recommendation Section

After the main table, add a horizontal rule and then a separate section:

```markdown
---
## Opinionated Recommendation
```

Use this section to give concrete picks for the user's actual stack. Prefer entries like:

- Best Gemini model for Cursor
- Best Gemini model for MCP servers
- Best Gemini model for Langfuse evals
- Best Gemini model for LightLLM routing
- Best Gemini embedding model for RAG

Keep the tone decisive. Good examples:

- "If I were setting this up today, I'd use `...` in Cursor."
- "For MCP servers, I'd default to `...`."
- "For Langfuse evals, I'd use `...` because bulk scoring favors ..."
- "For LightLLM routing, I'd keep `...` as the quality route and `...` as the cheap route."

## Required Checks

Before finalizing recommendations, verify:

- The model is currently listed on the Gemini Developer API free tier.
- The model is not already deprecated for near-term shutdown.
- Any preview model is labeled as preview in the answer.

## Confidence Rule

If the user dislikes uncertainty, explicitly state:

- The exact date you verified the free-tier list.
- That free-tier status was confirmed against Google's current pricing page.
- That any remaining uncertainty is about preview-model stability, not whether the model is listed today.
