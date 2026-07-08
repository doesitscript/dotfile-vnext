# Agent Langfuse LangGraph Model Work

## Part 1

We are deploying an adapted version of this approach.

For your homelab, I'd actually lean into this.

### Goals

- Reduce Claude costs
- Run local models
- Compare local vs. cloud
- Build multi-agent coding workflows

### Suggested routing policy

```text
Terraform edits?
  -> Ornith

Need AWS architecture?
  -> Ornith

Confidence low?
  -> Claude

Failed tests?
  -> Claude

Large design discussion?
  -> Claude
```

Every one of those decisions gets logged into Langfuse. Over time, you'll have
real data showing things like:

- "Ornith handled 82% of Terraform tasks successfully."
- "Claude was only needed for 18%."
- "Average savings: $X/month."

That's much more valuable than guessing.

## Part 2

We are deploying an adapted version of this too.

One thing I think would fit your platform extremely well: I would still put
LiteLLM in front of your models.

### High-level flow

```text
Cursor
  |
FastAPI
  |
LiteLLM
  |- Claude
  |- Ornith
  |- Qwen
  |- DeepSeek
  `- local vLLM
      |
      v
   Langfuse
```

### Why

LiteLLM is excellent at the runtime concerns: OpenAI-compatible API, provider
abstraction, retries, fallbacks, load balancing, budgets, and routing.

Langfuse is excellent at the engineering concerns: observability, prompt
management, evaluations, experiments, and understanding whether your routing
strategy is actually working.

## Part 3

Guidance on how to implement the above.

Set up both so that I can access both from within my IDE as different models.
That is how they are configured in Cursor, I believe.

### Core components

| Component | Purpose | Deploy |
|-----------|---------|--------|
| LiteLLM | Runtime gateway/router | K3s (Helm) |
| Langfuse | Observability, prompts, evals, experiments | K3s (Helm) |
| vLLM | Local model serving | GPU VM(s) |
| Postgres | Langfuse database | K3s |
| MinIO | Object storage | Already on your storage server |

### Local model examples behind vLLM

- Ornith
- Qwen Coder
- DeepSeek

Provides:

- `http://vllm:8000/v1`

### LiteLLM role

LiteLLM provides one endpoint for everything.

```text
Cursor
  |
  v
LiteLLM
  |- Claude
  |- OpenAI
  |- Ornith (vLLM)
  `- Qwen (vLLM)
```

Responsibilities:

- Model routing
- Fallbacks
- Load balancing
- Provider abstraction
- Budget/rate limits
- One OpenAI-compatible API

### Langfuse role

Langfuse is connected to LiteLLM and your apps.

It collects:

- Traces
- Prompts
- Token usage
- Latency
- Costs
- Evaluations
- User feedback
- Prompt versions

> You may need to alter this and other parts, because I do want two models set
> up in my IDE, and I don't know if this exactly represents what I need for my
> IDE.

## Target architecture

```text
Clients
- Cursor
- VS Code
- Jupyter
- FastAPI

          |
          v
       LiteLLM
          |
          |- Claude
          |- OpenAI
          `- vLLM
              |
              +-- Ornith
              `-- Qwen Coder

          |
          v
       Langfuse
          |
   Postgres + MinIO
```

### Kubernetes deployments

```text
ai-platform/
|- litellm/
|- langfuse/
|- postgres/
|- ingress/
`- monitoring/
```

### GPU server

```text
gpu-services/
`- vllm
   |- ornith
   |- qwen
   `- deepseek
```

## Initial routing policy

| Task | Model |
|------|-------|
| Chat | Ornith |
| Coding | Ornith |
| Terraform | Ornith |
| Ansible | Ornith |
| AWS docs | Ornith |
| Architecture | Claude |
| Final review | Claude |
| Failed local attempt | Claude |

## Deployment order

- [x] vLLM
- [x] Ornith model
- [x] LiteLLM
- [x] Langfuse
- [x] Connect LiteLLM -> Langfuse
- [x] Point Cursor to LiteLLM
- [x] Add additional local models as needed

## Outcome

This gives you a single endpoint for all clients, local-first model usage to
reduce Claude costs, and complete visibility into performance, quality, and
spending through Langfuse.
