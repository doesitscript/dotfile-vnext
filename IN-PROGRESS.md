# IN-PROGRESS

This machine cannot complete the target runtime setup (Python/Linux shell based wrapper execution) reliably.
Complete the following on the target Mac.

## Work completed here

- Updated `bin/codex-env` to support automatic `.venv` bootstrap for:
  - `python*`
  - `pip*`
  - `ansible*`
- Added fallback dependency discovery:
  - `requirements.txt`
  - `scripts/requirements.txt`
- Updated docs:
  - `skills/README.md`
  - `docs/tool_access/README.md`

## Work intentionally not completed here

- Project runtime bridge verification should be confirmed on Mac.

## Finish on Mac

1. Verify wrapper bootstrap:
   - `bin/codex-env python -V`
2. Verify Ansible/venv path via wrapper:
   - `bin/codex-env ansible --version`
3. Refresh project runtime skill links:
   - `bin/codex-env python skills/implementation/project-skill-runtime-bridge/scripts/link_project_skills_to_cursor.py`
4. Optionally run project skill validations if you want a full health pass.

## Follow-up: post-brainstorm-skill evaluation loop

After creating a brainstorm-design skill, run these skills to find where reusable
skills can cut repeated instructions and framework token load:

- `generate-project-state-report` — Instruction Repetition Hotspots inventory
- `project-maturity-router` — skill replacements across Ansible/NetBox guidance
- `ansible-coordinator` — skill-first reduction map for Ansible process load
- `generate-mcp-briefing` — MCP/tool-selection prose that can become entry doors
- `create-skill` — scaffold 2–3 micro-skills from the highest-frequency findings

Detailed purpose, prompt examples, shared output contract, and token-reduction
levers:

- `docs/brainstorming_designs/2026-07-28--skill-instruction-reduction-patterns/`

## Linked brainstorm packet

- `docs/brainstorming_designs/2026-07-28--cross-repo-skill-evaluation-loop/`
