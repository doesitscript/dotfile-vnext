```text
Implement Plan 21 for the LiteLLM model-lane pytest vNext work.

## Primary authority (read first, follow exactly)
1. /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-13--get-back-ansible-best-practice/plan-21_vnext_skill_draft.md
   - This is the requirements contract. Execute its ordered slices.
   - Hard rule: Python package owns the harness; skills stay thin SHIMs.
   - Any new/updated skill for this path MUST keep the `-draft` suffix until an explicit promote decision.

## Context / prior pass (transitional — do not expand as the long-term home)
2. /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-13--get-back-ansible-best-practice/plan-20_TDD_next_pass_prompt.md
3. /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-13--get-back-ansible-best-practice/plan-20_TDD_next_pass_executed_reviewed.md
4. /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-13--get-back-ansible-best-practice/TDD/test_model_lanes_vnext.py
5. /Users/joshc/develop/dotfile-vnext/docs/plans/2026-09-13--get-back-ansible-best-practice/TDD/README_vnext.md
6. /Users/joshc/develop/dotfile-vnext/.cursor/skills/homelab-litellm-model-lane-pytest-draft/SKILL.md

## Implementation home
7. /Users/joshc/develop/homelab-model-lane-pytest
   - Scaffold already exists (uv/just/Ruff/pytest). Grow the harness here.
   - README rule: skills consume this package; test logic does NOT live skill-local.

## Behavior baseline to match or exceed (import patterns; do not fork forever)
8. /Users/joshc/develop/global-skills/skills/validation/homelab-litellm-model-lane-pytest/

## Work split (do not violate)
| Layer | Owns |
| --- | --- |
| `homelab-model-lane-pytest` | client, YAML manifests, capabilities, receipts, tool harness, markers/profiles, unit + live tests |
| `homelab-litellm-model-lane-pytest-draft` (thin SHIM) | SKILL.md discovery, human evidence rules, vault/`bin/*-env` launch recipes, links to package commands — NO growing skill-local lib/ harness |
| `dotfile-vnext` | commissioned-model SSOT / eval subset intent, vault wrappers, plan receipt paste-backs — NOT a second harness |

## Start with
1. Read Plan 21 end-to-end (especially §0 architecture, §8 slices, §9 done-when).
2. Inspect the package scaffold and Plan 20 transitional suite.
3. Begin slice 1 onward in `homelab-model-lane-pytest` (harness spine → manifest/capabilities → human receipts → journeys → tools → targeting → SSOT invariant → thin SHIM skill update).
4. Prefer importing/adapting global-skill patterns into the package over rewriting semantics.
5. Do not claim parity/done without unit proof (`just test` without key) and pasted human receipts from a targeted live run into the plan folder.

## Out of scope unless asked
- Replacing the global skill overnight
- Deploying LiteLLM/vLLM/inventory route changes
- Promoting `-draft` → stable
- Expanding Plan 20 skill-local/plan-local tests as the permanent home
```
