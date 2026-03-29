# Ansible Architect — Gate Definitions

Gates specific to this agent team. The framework rules
(`framework-partner-process.mdc`, `framework-mcp-and-tool-usage.mdc`) define
additional gates that also apply — this file covers agent-level gates only.

| Gate | Condition | Defined in |
|---|---|---|
| Observer lock-in | Observer MUST run against the final plan before the user accepts it. Non-negotiable. If skipped in Phase 1, fires in Phase 4. | `ansible-coordinator` Phase 4 |
| Research before finalization | If the topic is novel or under-researched, researcher MUST complete before the plan is locked. | `ansible-coordinator` Phase 1 |
| Change contract | Apply / Verify / Undo / Change class must all be statable before the final plan is presented. | `ansible-planner` Phase 5 |

Gate definitions live in the skill files. This file is an index only.
