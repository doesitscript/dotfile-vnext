# Product contracts (intentional)

This directory is for **per-product** desired-state contracts — not a single
branded monolith.

| Path | Authority |
| --- | --- |
| `policy/` | Executable capability vocabulary + `depends_on` order |
| `inventory/` | Who/what is commissioned (`*_state`, host classes) |
| `contracts/<product>.yaml` | Product intent: endpoints, wiring, role ownership, depends_on |
| `contracts/fuzlang.contract.yaml` | **Legacy archive only** — do not grow; do not cite as SSOT |

**Do not call Langfuse or its backing services "fuzlang".** Use `langfuse_platform_*`
variables from `inventory/group_vars/all/langfuse_platform_external_services.yml`.

## Mental model

```text
policy/execution_roles.yml     = “what ai-client-ui means + how to match”
inventory host_vars            = “facts about this host” (classes, planes, state)
classify_host                  = computes labels/roles at runtime
open_webui_state: present      = “commission this capability here”
```

Lots of designators in **policy**; inventory stays relatively thin. Orchestration
skill: `homelab-product-capability-flow`.

## Rules

1. Prefer a new `contracts/<product>.yaml` over editing `fuzlang.contract.yaml`.
2. Contracts are **pattern guidance**, not inventory SSOT. Runtime truth stays in
   inventory + roles.
3. Salvaged 2026-07 promoted patterns live under `policy/` (see
   `policy/README.md`). Do not duplicate them back into fuzlang.
4. YAML comments (`#`) are fine for examples. Active keys are real YAML the
   repo can cite; commented blocks are copy-paste templates.

## Starter products

- [`open-webui.yaml`](open-webui.yaml) — OpenAI-compatible UI → LiteLLM
- [`litellm.yaml`](litellm.yaml) — gateway / model lanes
- [`../model-lane-acceptance/`](../model-lane-acceptance/README.md) — ATDD acceptance YAML + client map (executable probes via global-skills harness)

Add more only when a product has durable cross-cutting intent
(e.g. `langfuse.yaml`, `langgraph.yaml`) — not for every Ansible role.
