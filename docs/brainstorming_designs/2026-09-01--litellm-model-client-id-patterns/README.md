---
title: "LiteLLM model client ID patterns"
status: brainstorm
created: 2026-09-01
execution_status: packet-active
related_implementation:
  - roles/k3s_litellm_gateway/defaults/main/model_client_ids.yml
  - roles/k3s_litellm_gateway/README.md
related_plans:
  - docs/brainstorming_designs/2026-09-01--homelab-routing-layer-flint-openwrt/re-evaluate-models-and_distribution.partially-implemented.md
---

# LiteLLM model client ID patterns

Brainstorm packet comparing two naming directions for LiteLLM `model_name`
values and related display metadata.

## How to treat this material

- **Not** active repo truth beyond what is already merged in Ansible/LiteLLM.
- The **partially-implemented** file documents what is live on the gateway today.
- **Kilo GPU placement** (5090 primary, desktop fallback): see
  [re-evaluate-models-and_distribution.partially-implemented.md](../2026-09-01--homelab-routing-layer-flint-openwrt/re-evaluate-models-and_distribution.partially-implemented.md).
- The **ChatGPT notes** file is advisory only — ideas to evaluate, not approved
  direction.

## Packet contents

| File | Purpose | Execute marking |
| --- | --- | --- |
| [structured-client-model-ids.partially-implemented.md](structured-client-model-ids.partially-implemented.md) | Homelab structured client ID syntax (`@` / `~`) — **live on gateway** | `.partially-implemented.md` until promoted or superseded |
| [chatgpt-infrastructure-neutral-model-naming-notes.md](chatgpt-infrastructure-neutral-model-naming-notes.md) | ChatGPT-suggested infrastructure-neutral IDs | reference only; not executed |

## Execution marking (this packet)

- **`.partially-implemented.md`** — repo work started and deployed, but the
  brainstorm is not closed (docs/catalog convergence, legacy aliases, display
  metadata layer, or a future rename may remain).
- **`.executed.md`** — use when a brainstorm *plan* in this packet is fully
  carried out and verified (see parent [README.md](../README.md)).

Promoting to `docs/plans/` is separate from these suffixes.
