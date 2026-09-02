# Execution receipt — homelab model-lane ATDD coordination

**Date:** 2026-09-02  
**Scope:** Phase 1–2 per [execution-plan.md](execution-plan.md)  
**Out of scope:** Live multi-agent coordination in same session

## Created (global-skills)

| Artifact | Path |
| --- | --- |
| Coordinator skill | `skills/validation/homelab-model-lane-atdd-coordinator/SKILL.md` |
| Agent interface | `.../agents/openai.yaml` |
| Coordinator checklist | `.../references/coordinator-checklist.md` |
| Handoff template | `.../references/stack-implementer-handoff-template.md` |
| Stack implementer instructions | `.../references/stack-implementer-instructions.md` |
| Stack implementer intake request | `.../references/stack-implementer-intake-request.md` |
| Path helper script | `.../scripts/print_campaign_paths.py` |
| Catalog entry | `skills/catalog.yaml` → `homelab-model-lane-atdd-coordinator` |

## Updated

| Artifact | Change |
| --- | --- |
| `homelab-local-ai-client-validation-pack/SKILL.md` | ATDD row points to coordinator (removed "Future") |
| This plan README | Checklist `[x]`; `lifecycle: implemented` |
| [execution-plan.md](execution-plan.md) | Obligations O-01–O-06 marked done |

## Verification evidence

### V-1 — Catalog metadata

```text
$ bin/gs-env scripts/validate_skills_catalog.py
skills catalog validation ok
```

### V-2 — SKILL.md links

Coordinator SKILL.md references resolve to:

- dotfile-vnext `model-lane-acceptance/`
- Plan `docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/diagrams/atdd-developer-flow.md`
- Plan `examples/stack-implementer-intake-client-model-map.example.md`
- Plan `references/acceptance-artifacts-layout.md`

### V-3 — Dry-run diff (example intake map vs `client-map.yml`)

**Source map:** [examples/stack-implementer-intake-client-model-map.example.md](examples/stack-implementer-intake-client-model-map.example.md)  
**SSOT:** `model-lane-acceptance/client-map.yml`

| Client / row | Intake map | client-map.yml | Acceptance author action |
| --- | --- | --- | --- |
| Continue chat_quality | `qwen2.5-coder-32b@k3s02-vllm` selected | `approved` | No new pending YAML |
| Continue edit_apply | `qwen2.5-coder-7b@desktop` | `approved` | No new pending YAML |
| Continue autocomplete_fim | `qwen2.5-coder-1.5b@hvh01` | `approved` | No new pending YAML |
| Kilo agent_tools | (not in example intake) | `ministral-3-8b@desktop` approved | Out of scope for Codex intake; already mapped |
| Codex deep | 32b@k3s02, reasoning approved; tool loop not | `approved`, notes tool-loop pending | Keep `codex/pending/tool-loop.yml`; do not promote tool loop |
| Codex fast / tools / hom-lab | experimental | experimental | Author/extend pending acceptance before promotion |
| OpenCode edit | (not in example intake) | `qwen2.5-coder-7b@desktop` approved | No action from Codex intake |
| Shared 5090 32B | boundary documented | implicit via shared lane | Include in FAIL handoffs when tool-loop conflicts with chat load |

**Diff summary:** Example Codex intake aligns with existing `client-map.yml`. Remaining ATDD work is **codex tool-loop pending** and **experimental profile promotion** — not map drift.

### V-4 — No harness duplication

Coordinator skill contains references + path script only; pytest execution delegated to `homelab-litellm-model-lane-pytest` and `homelab-codex-cli-model-pytest`.

### V-5 — Optional gateway smoke

**Skipped** this execute slice (optional per execution plan). Run when operator wants live receipts:

```bash
cd /Users/joshc/develop/dotfile-vnext
./model-lane-acceptance/scripts/run-gateway-acceptance.sh -m smoke -v -s
```

### Path helper smoke

```text
$ print_campaign_paths.py --project-root dotfile-vnext --campaign docs/plans/2026-09-01--homelab-local-ai-clients-codex
project_root: /Users/joshc/develop/dotfile-vnext
client_map: .../model-lane-acceptance/client-map.yml
handoffs_to_stack_implementer: .../coordination/handoffs/to-stack-implementer
```

## Obligation receipt

| ID | Status |
| --- | --- |
| O-01 | done |
| O-02 | done |
| O-03 | done |
| O-04 | done |
| O-05 | done |
| O-06 | done |
| O-07 | deferred (multi-day layout) |

## Next operator actions

1. **Cold ATDD campaign:** invoke skill `homelab-model-lane-atdd-coordinator` with client-model map path.
2. **Codex tool-loop:** acceptance author runs `run-codex-acceptance.sh pending/tool-loop.yml -v -s`; on FAIL handoff to stack implementer.
3. **Optional:** gateway smoke (V-5) when live lane proof is needed.
