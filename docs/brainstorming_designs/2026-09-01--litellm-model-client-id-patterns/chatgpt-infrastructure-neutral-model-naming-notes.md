---
title: "ChatGPT — infrastructure-neutral LiteLLM model naming (ideas only)"
status: brainstorm
source: chatgpt
authority: advisory-only
---

# ChatGPT — infrastructure-neutral LiteLLM model naming

> **Disclaimer:** The content below is **ideas suggested by ChatGPT**, captured
> here for comparison with the homelab's partially implemented structured client
> IDs. It is **not** approved repo direction unless promoted through
> `docs/intake/` or `docs/plans/`.

---

## Task: Refactor LiteLLM Model Naming, Display Metadata, and Routing Conventions

Review the LiteLLM configuration changes you just implemented and refactor them to establish a clean distinction between:

1. Canonical/public model IDs
2. LiteLLM model groups / routing pools
3. Physical model deployments
4. Server/runtime identity
5. Human-friendly descriptive names
6. Access-control groups

Apply the conventions below consistently throughout the LiteLLM configuration and anywhere else in this project that references model IDs.

---

## 1. Correct the previous naming change

I previously asked you to restructure model IDs into something like:

`<model>-<server>-<friendly-name>`

Do **not** use that structure as the normal/public LiteLLM `model_name`.

That mixes three different concerns:

- logical model identity
- physical deployment location
- human-readable description

and would make future load balancing, failover, server migration, and OpenAI-compatible integrations unnecessarily difficult.

Instead, keep these concerns separate.

---

## 2. Canonical model/group IDs must be infrastructure-neutral

The `model_name` exposed by LiteLLM should normally describe the logical model or logical service, not the machine currently hosting it.

Preferred examples:

```yaml
model_name: qwen2.5-coder-32b
model_name: deepseek-r1-32b
model_name: gpt-4o
model_name: gpt-4o-mini
model_name: text-embedding-3-small
```

---

## 3. Open questions (not fully specified in the ChatGPT export)

The original ChatGPT thread also discussed (but did not finish in the saved
export):

- separating **display names** from `model_name` via `model_info` / UI metadata
- using **model groups** for load balancing without renaming clients when a host
  moves
- keeping **catalog `model_lane`** slugs stable for tracing while client IDs stay
  infrastructure-neutral

Treat those as follow-up research, not current homelab truth.
