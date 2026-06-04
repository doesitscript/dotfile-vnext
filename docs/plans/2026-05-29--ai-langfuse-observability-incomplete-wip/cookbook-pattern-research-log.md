---
status: initial-review
reviewed_at: "2026-05-29"
source_plan: docs/plans/2026-05-29--ai-langfuse-observability-incomplete-wip/README.md
---

# Langfuse Cookbook Pattern Research Log

This log prevents cookbook ideas from becoming vague "later" notes. Each intake
pattern is reviewed against current Langfuse docs and routed.

| Pattern | Source checked | Disposition | Repo action / trajectory |
|---------|----------------|-------------|--------------------------|
| LiteLLM + Langfuse proxy integration | https://langfuse.com/integrations/gateways/litellm | implement-now | Use LiteLLM proxy callback/OTEL path; keep keys vault-backed; smoke via `litellm.hom.lab` once vLLM/LiteLLM pass. |
| Request metadata for trace grouping | https://langfuse.com/integrations/frameworks/litellm-sdk | implement-now | Prefer request body `metadata` for `agent_role`, `model_lane`, `routing_policy`, `context_class`; avoid relying on uncertain headers. |
| OpenAI-compatible tracing wrappers | https://langfuse.com/docs/observability/get-started | extract-knowledge | Client profile plan can use OpenAI-compatible SDK wrappers later; current slice keeps gateway-level tracing. |
| Nested traces / multi-step workflow | https://langfuse.com/docs/glossary | defer-with-trajectory | Langfuse has Agent and Agent Graph concepts; create future agent lineage plan after client profiles exist. |
| Prompt / version management | https://langfuse.com/docs/glossary | defer-with-trajectory | Track prompt management as future prompt API slice; not required for vLLM/LiteLLM bootstrap. |
| Tool-call observability | https://langfuse.com/docs/glossary | defer-with-trajectory | Use Span/Event/Tool observation concepts later for IDE shell/Ansible/tool calls. |
| Evaluation workflows | https://langfuse.com/docs/evaluation/evaluation-methods/llm-as-a-judge | defer-with-trajectory | Add future evaluation plan after stable traces exist; prefer observation-level evaluators for production monitoring. |
| Dataset / eval storage | https://langfuse.com/docs/evaluation/evaluation-methods/llm-as-a-judge | defer-with-trajectory | Future dataset/experiment slice; not part of current gateway/runtime bootstrap. |
| Multi-agent lineage | https://langfuse.com/guides/cookbook/example_langgraph_agents | extract-knowledge | Preserve graph/span lineage idea for planner/coder/reviewer flows; implement after IDE client profiles can emit metadata. |

## Implementation Guard

No cookbook-derived Ansible task may be added unless its row above is
`implement-now` or the target future plan is created and linked with
`moved_to_plan`.
