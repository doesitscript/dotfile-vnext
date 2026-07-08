# Agent Langfuse LangGraph Model Work

## Summary

This note is a repo-adapted planning sketch derived from Langfuse examples and
integration patterns. It is not the infrastructure source of truth.

Infrastructure authority in this repo is imposed by:

- NetBox for host, VM, IP, platform, role, and site facts
- repo naming/schema and playbook patterns for durable implementation shape
- current-state retrospectives when cookbook defaults conflict with live repo
  placement

That means external examples can inform the plan, but they do not override the
project's existing infrastructure model.

## Authority Note

Use this document as:

- a routing and integration sketch
- a product/dependency classification note
- a checklist of example families to adapt into this homelab

Do not use this document as:

- a deployment authority for host placement
- a replacement for NetBox truth
- a replacement for current repo playbook targeting
- a generic K3s/Helm topology to copy directly

Current repo authority sources for this slice:

- `AGENTS.md`
- `README.md`
- `docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md`

## Part 1 - Routing Intent

For this homelab, the value of the stack is still the same:

- reduce Claude costs
- run local models
- compare local vs. cloud outcomes
- build multi-agent coding workflows with observable routing decisions

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

Every one of those decisions should be logged into Langfuse so the routing
policy can be validated with real traces, costs, latency, and quality evidence.

Representative outcomes the platform should eventually support:

- "Ornith handled most Terraform tasks successfully."
- "Claude was only needed for a smaller escalation slice."
- "Average savings are measurable instead of guessed."

## Part 2 - Product Model

The high-level product pattern still makes sense:

```text
Cursor / VS Code / FastAPI clients
  |
LiteLLM gateway
  |- Claude
  |- OpenAI
  `- local models via vLLM
      |- Ornith
      |- Qwen Coder
      `- DeepSeek-compatible local/runtime path
          |
          v
       Langfuse
```

### Why this still fits

LiteLLM is the runtime gateway:

- OpenAI-compatible client surface
- provider abstraction
- model routing
- fallback handling
- budget and rate-limit controls

Langfuse is the engineering/observability layer:

- traces
- prompts
- token usage
- latency
- cost visibility
- evaluations
- feedback and prompt-version tracking

### Product normalization for this repo

- `Ornith` is a model, not a platform product
- `Qwen Coder` is a model, not a platform product
- `DeepSeek` is treated as a model/provider integration example
- `vLLM` is the model-serving layer for local models
- `Jupyter` is a client/workbench only

## Part 3 - Repo-Aligned Infrastructure Interpretation

### Core components

| Component | Purpose | Repo-aligned interpretation |
|-----------|---------|-----------------------------|
| LiteLLM | Runtime gateway/router | Gateway layer; current live path is repo-targeted on the GPU lane K3s surface |
| Langfuse | Observability, prompts, evals, experiments | Platform layer; current live path is concentrated on the GPU lane, even if some examples imply cleaner separation |
| vLLM | Local model serving | GPU-lane inference runtime for local models |
| Postgres | Langfuse database | Current repo path uses the external PostgreSQL surface on `hom-lab-ctl-dkr-02` |
| MinIO | Object storage | Example dependency pattern only; actual placement must follow repo-owned current state and role targeting |

### Important correction to sample deployment language

The original generic labels like `K3s (Helm)` are not sufficient source of
truth here.

Repo current-state evidence says:

- the storage lane is `hom-lab-ctl-hvh-01` with guests `dkr-01` and `k3s-01`
- the GPU lane is `hom-lab-ctl-hvh-02` with guests `dkr-02` and `k3s-02`
- the live automation path still concentrates Langfuse, LiteLLM, vLLM, and
  Jupyter on the GPU lane
- the active Langfuse database path is tied to the `dkr-02` Docker-side
  PostgreSQL surface

So this plan must adapt examples to the repo's actual lane/guest model instead
of assuming a fresh greenfield split.

### Repo-authoritative baseline

```text
Control / authority
- NetBox owns durable infrastructure facts and naming
- repo playbooks and roles own execution and convergence

Current live AI stack concentration
- hom-lab-ctl-hvh-02
  |- hom-lab-ctl-dkr-02: PostgreSQL, Loki, Grafana, NetBox, Semaphore
  `- hom-lab-ctl-k3s-02: Langfuse, LiteLLM, vLLM, Jupyter, Traefik

Storage lane context
- hom-lab-ctl-hvh-01
  |- hom-lab-ctl-dkr-01: Docker engine, no live Langfuse stack from current playbooks
  `- hom-lab-ctl-k3s-01: readiness stub / no active K3s workload path
```

### Clients and consumers

These are consumers of the stack, not infrastructure authority:

- Cursor
- VS Code
- FastAPI applications
- Jupyter workbench

### Cursor local-model interpretation

For this repo, Cursor local-model usage should be understood as:

- Cursor using its OpenAI-compatible provider settings path
- pointed at the repo-approved LiteLLM gateway endpoint
- with model selection tied to LiteLLM alias names, not informal plan labels

The repo-aligned target shape is:

- gateway authority host: `litellm.hom.lab`
- Cursor OpenAI-compatible API path: `http://litellm.hom.lab/v1`

This is a client-routing decision only. It does not change where `vLLM`,
LiteLLM, or Langfuse are deployed.

One remaining planning gap is still open:

- the exact Cursor-visible alias names for the local models need to be declared
  from the repo-managed LiteLLM layer and then reflected back into operator
  docs

### Local model examples behind vLLM

- Ornith
- Qwen Coder
- DeepSeek

Representative runtime surface:

- `http://vllm:8000/v1`

That endpoint shape is an integration example, not a host-placement decision.

## Initial Routing Policy

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

## Deployment Interpretation

The intended order of capability still makes sense, but deployment must follow
repo-owned patterns:

- [x] vLLM layer
- [x] Ornith model through vLLM
- [x] LiteLLM gateway layer
- [x] Langfuse observability layer
- [x] Connect LiteLLM -> Langfuse
- [x] Point Cursor and other clients at the repo-approved gateway path
- [x] Add additional local models as needed

## Outcome

The desired result remains:

- a single client-facing model gateway
- local-first model usage to reduce Claude spend
- observable routing, quality, and cost behavior through Langfuse

But the implementation path must remain subordinate to repo truth, NetBox
authority, and the existing homelab lane/guest model instead of to upstream
sample topology.
