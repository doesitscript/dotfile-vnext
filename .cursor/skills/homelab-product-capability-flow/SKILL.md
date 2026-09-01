---
name: homelab-product-capability-flow
description: >-
  Use when adding or deploying a homelab product capability (Open WebUI, LiteLLM
  client, Compose stack) that needs HRL/library research before planning, then
  Ansible-first present|absent intake, classify/policy targeting, single-host
  apply, and optional NetBox tags. Use for Open WebUI Option A, companion UI,
  or policy + classify + product contract workflows. Do not use for one-off
  host debug without a new capability.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: >-
  hrl-library-index-entry, vendor-doc-collection, context7-intake-or-emulate,
  firecrawl-context7-crosscheck, library-entry-validate,
  homelab-ansible-first-entry, ansible-knowledge-gate, tool-capability-intake,
  homelab-ssh-alias-connect, single-host-ansible-rollout,
  single-host-apply-and-receipt, netbox-knowledge-gate,
  model-doc-pack-preflight, framework-change-receipt,
  project-capability-surface-audit
requires_summary: "Product/goal context; optional full-vendor-scrape flag"
title: Homelab Product Capability Flow
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - open-webui
  - litellm
  - policy
tags:
  - skill
  - open-webui
  - policy
  - classify
  - workflow
---

# Skill: Homelab Product Capability Flow

Orchestrates the **library → plan → Ansible capability → apply → NetBox** chain
used for Open WebUI Option A and similar product capabilities. Nested skills do
the work; this skill owns order and the policy/inventory mental model.

## Mental model (do not invert)

```text
policy/execution_roles.yml     = what ai-client-ui means + how to match
inventory host_vars            = facts about this host (classes, planes, state)
classify_host                  = computes labels/roles at runtime
open_webui_state: present      = commission this capability here
```

Lots of designators live in **policy**; inventory stays **thin** host truth +
commission flags. Do not invent `hosts: HOM-LAB-HVH-02`.

## When to use / not use

**Use** when adding or deploying a product that needs research before build
(Open WebUI, another OpenAI-compatible client, similar Compose/K3s product).

**Do not use** for pure debug of an already-commissioned stack, or for Windows
desktop Ollama alone (`deploy-dev-workstation-ollama-runtime`).

## Phase 0 — inputs

Capture from the user (or infer with high confidence):

| Input | Default |
| --- | --- |
| **Goal / CONTEXTS** | Required (e.g. `open_webui present\|absent on ai-client-ui`) |
| **Vendor scrape scope** | **Task-scoped** to what the goal needs |
| **Full vendor clone** | Only if user explicitly asks (“whole scrape”, “complete clone”) |

## Phase 1 — Library / research (before planning)

Run **in order**; do not start Option A / role planning until this phase yields
evidence or an explicit deferral.

1. **`hrl-library-index-entry`** — open HRL indexes + any existing product guide
   (e.g. `implementation-guides/open-webui/`).
2. **`vendor-doc-collection`** — default **scoped** to pages/concepts required by
   the goal. If user requested full clone, say so and widen the contract.
3. **`context7-intake-or-emulate`** — official SDK/env/compose docs (no guessing).
4. **`firecrawl-context7-crosscheck`** — reconcile scrapes vs Context7.
5. **`library-entry-validate`** — do not call library intake “done” until gate
   passes (or gaps are listed honestly).
6. If LiteLLM / model lanes are in the goal: **`model-doc-pack-preflight`**.

**Then** start planning (Apply / Verify / Undo / Change class).

## Phase 2 — Ansible entry / implement

1. **`homelab-ansible-first-entry`** — run `print_entry_doors.py`; pick door.
2. **`ansible-knowledge-gate`** — module matrix before shell.
3. **`tool-capability-intake`** — scaffold/extend `present|absent` role for
   **CONTEXTS** (e.g. `open_webui`).
4. Read **`policy/`** + run or cite **`classify_homelab_hosts`** before any new
   `hosts:` / placement (AGENTS.md Research §13).
5. **`homelab-ssh-alias-connect`** for guest debug (pull, logs) — never invent
   `user@ip`.

## Phase 3 — Apply / verify

1. **`single-host-ansible-rollout`** — preview → apply → verify the product
   playbook (e.g. `playbooks/deploy_open_webui.yaml`).
2. Prefer **no `--limit`** unless debugging; policy + `*_state` select hosts.
3. **`single-host-apply-and-receipt`** — durable receipt after live apply.

## Phase 4 — SoT / NetBox (when tags or services change)

1. **`netbox-knowledge-gate`** — **before** seeding capability tags or modeling
   the Compose service.
2. Prefer tags before new custom fields.

## Phase 5 — Process hygiene

1. **`framework-change-receipt`** after AGENTS / `policy/` / `contracts/` moves.
2. **`project-capability-surface-audit`** if Langfuse platform contract vs policy vs inventory
   overlap is suspected.
3. **`operational-pattern-to-skill-extractor`** only if this flow needs another
   narrower skill later.

## Reusable prompts

```text
Use skill homelab-product-capability-flow for <CONTEXTS>.
Library scrape: task-scoped | full vendor clone.
```

```text
Use skill hrl-library-index-entry then vendor-doc-collection for <product>
(task-scoped unless I say full clone), then plan before build.
```

```text
Use skill homelab-ansible-first-entry then tool-capability-intake to add <CONTEXTS>.
```

```text
Use skill single-host-ansible-rollout to preview/apply/verify playbooks/deploy_open_webui.yaml
```

```text
Use skill netbox-knowledge-gate before seeding capability tags.
```

## Open WebUI exemplar CONTEXTS

- Role: `open_webui` / `open_webui_state: present|absent`
- Playbook: `playbooks/deploy_open_webui.yaml`
- Match: `ai-client-ui` via `policy/execution_roles.yml` + `classify_host`
- Contract: `contracts/open-webui.yaml`
- Vault: `vault_open_webui_openai_api_key` in `vault/shared.vault.yml`

## References

- `references/mental-model.md`
- `references/skill-chain.md`
- `references/related-artifacts.md`
- `policy/README.md`
- `policy/process_order.yml`
