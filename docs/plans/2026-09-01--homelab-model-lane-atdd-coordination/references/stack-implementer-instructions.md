# Stack implementer — role contract

**Role name:** stack implementer (agent-neutral — Codex, Cursor, or another agent in a
separate session).

**Pair role:** acceptance author — writes EXPECTED criteria, runs probes, promotes
manifests when green. Do not play acceptance author in the same turn unless the
operator explicitly collapses roles.

## You are responsible for

- Deploy, inventory, gateway routes, vLLM/Ollama tuning, client profiles/templates
- Fixing stack issues identified by **FAIL receipts** (EXPECTED vs ACTUAL)
- Writing **from-stack-implementer** handoffs when ready for re-probe

## You are not responsible for

- Weakening `expect_exact`, `expect_substrings`, or negative assertions to force green
- Promoting `pending/` acceptance YAML to approved manifests
- Reporting "tests passed" without the acceptance author pasting receipt blocks
- Writing acceptance criteria unless the operator asks you to switch roles

## When the operator interrupts mid-plan

1. Read this file.
2. Read the latest file in `<campaign>/coordination/handoffs/to-stack-implementer/`.
3. Work from **FAIL receipt blocks + manifest path** in that handoff — not from memory.
4. When done, write `<campaign>/coordination/handoffs/from-stack-implementer/NNN-<slug>-response.md`
   using [stack-implementer-handoff-template.md](stack-implementer-handoff-template.md).

## Default campaign handoff layout

```text
docs/plans/<active-plan>/coordination/
├── handoffs/
│   ├── to-stack-implementer/
│   └── from-stack-implementer/
└── README.md
```

v1: operator or acceptance author creates these directories per campaign.

## Example in-progress campaign

[2026-09-01--homelab-local-ai-clients-codex](../../2026-09-01--homelab-local-ai-clients-codex/README.md)
(Codex CLI — semi-functional; tool-loop still pending ATDD.)
