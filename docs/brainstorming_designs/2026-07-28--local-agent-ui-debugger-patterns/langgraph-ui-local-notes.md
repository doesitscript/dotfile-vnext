# LangGraph UI environment notes (UNVERIFIED)

**Important:** Everything in this note is unverified until we run and validate it
in the homelab environment.

## Objective (quick path)

Get a visual LangGraph debugging workflow running quickly for local development,
while preserving Langfuse as the observability backend.

## Candidate references to validate first

### 1) Official quickstart (start here)

- [Run a local LangGraph server](https://docs.langchain.com/oss/python/langgraph/local-server)

Expected workflow to verify:

```text
langgraph dev
API: http://127.0.0.1:2024
Studio: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:2024
```

### 2) Studio docs (debugger specifics)

- [LangGraph Studio documentation](https://docs.langchain.com/oss/python/langgraph/studio)

Topics to verify:

- Studio connection behavior
- `langgraph.json` expectations
- environment variables
- graph visualization + debugging behaviors

### 3) Local development lifecycle

- [Local development and testing guide](https://docs.langchain.com/langsmith/local-dev-testing)

Suggested lifecycle to verify:

```text
langgraph dev  -> rapid iteration
langgraph up   -> production-like validation
```

## Architecture interpretation to test

Potential current model (must verify):

```text
langgraph dev
    -> local server (localhost:2024)
    -> Studio UI served via smith.langchain.com/studio/?baseUrl=...
```

Implication to validate:

- agent code runs local
- state/runtime local
- UI may be cloud-hosted interface connecting to local base URL

## Langfuse-first stance (current project direction)

For this project family, keep:

- LangGraph for orchestration and local dev server
- LiteLLM for model gateway
- Langfuse for tracing/observability

Do not require by default:

- `LANGSMITH_API_KEY`
- `LANGSMITH_TRACING=true`

If Studio shows LangSmith run warnings, treat as expected unless we explicitly
choose LangSmith Cloud tracing.

## Validation checklist (before promoting to plan)

1. Confirm `just dev` / `uv run langgraph dev` loop works without LangSmith API.
2. Confirm Studio still connects to local base URL.
3. Confirm Langfuse receives traces for local runs.
4. Confirm `langgraph up` behavior and tradeoffs for homelab dev workflow.
5. Record any hard dependency on LangSmith Cloud UI login vs tracing.

## Follow-up experiment idea

If full local/no-cloud UI is a strict requirement, compare alternatives for
self-hosted visual debugging/orchestration UIs and rank by:

- self-hostability
- LangGraph compatibility
- LiteLLM compatibility
- Langfuse compatibility
- operational complexity
