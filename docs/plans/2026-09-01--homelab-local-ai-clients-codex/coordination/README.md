# ATDD coordination — Codex CLI campaign

File-based handoffs between **acceptance author** and **stack implementer** for this
plan. v1 pseudo-infra: markdown files in `handoffs/` subdirs.

## Role contracts (authoritative)

| Doc | Path |
| --- | --- |
| Stack implementer instructions | [ATDD coordination plan — stack implementer instructions](../../2026-09-01--homelab-model-lane-atdd-coordination/references/stack-implementer-instructions.md) |
| Handoff templates | [stack-implementer-handoff-template.md](../../2026-09-01--homelab-model-lane-atdd-coordination/references/stack-implementer-handoff-template.md) |
| Intake request | [stack-implementer-intake-request.md](../../2026-09-01--homelab-model-lane-atdd-coordination/references/stack-implementer-intake-request.md) |

## Handoff dirs

```text
coordination/handoffs/
├── to-stack-implementer/     ← acceptance author writes FAIL evidence here
└── from-stack-implementer/   ← stack implementer writes fix summary + re-probe cmd
```

When the global skill `homelab-model-lane-atdd-coordinator` exists, it will point
here for this campaign by default.

## Acceptance specs

Project manifests: [`model-lane-acceptance/`](../../../../model-lane-acceptance/README.md)

Run probes:

```bash
./model-lane-acceptance/scripts/run-gateway-acceptance.sh -v -s
./model-lane-acceptance/scripts/run-codex-acceptance.sh pending/tool-loop.yml -v -s
```
