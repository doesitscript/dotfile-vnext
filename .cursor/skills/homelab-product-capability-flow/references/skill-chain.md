# Skill chain — library → plan → Ansible → apply → NetBox

Ordered nested skills. Stop and plan only after Phase 1 evidence (or explicit deferral).

## Library / research

| Skill | Why |
| --- | --- |
| `hrl-library-index-entry` | Load HRL indexes before inventing placement/docs |
| `vendor-doc-collection` | Structured vendor capture; **default task-scoped**; full clone only if asked |
| `context7-intake-or-emulate` | Official docs packs without guessing env/compose APIs |
| `firecrawl-context7-crosscheck` | Reconcile scrapes vs Context7 |
| `library-entry-validate` | Gate incomplete library shape before “done” |
| `model-doc-pack-preflight` | When LiteLLM wiring/keys/lanes are in the goal |

## Ansible entry / implement

| Skill | Why |
| --- | --- |
| `homelab-ansible-first-entry` | Door before inventing SSH/compose one-offs |
| `ansible-knowledge-gate` | Module matrix (`docker_compose_v2`, vault, NetBox tags) |
| `tool-capability-intake` | New/extend `present\|absent` role for **CONTEXTS** |
| `homelab-ssh-alias-connect` | Guest pull/debug without inventing `user@ip` |
| `single-host-ansible-rollout` | Preview → apply → verify product playbook |
| `single-host-apply-and-receipt` | Receipt after live apply |

## SoT / modeling

| Skill | Why |
| --- | --- |
| `netbox-knowledge-gate` | Tags before CFs; seed tags; service on Compose VM |

## Process hygiene

| Skill | Why |
| --- | --- |
| `framework-change-receipt` | After AGENTS / `policy/` / `contracts/` moves |
| `project-capability-surface-audit` | Catch Langfuse platform contract vs policy vs inventory overlap |
| `operational-pattern-to-skill-extractor` | If this flow needs another narrower skill later |

## Operator prompts

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
