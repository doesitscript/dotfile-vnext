# Multi-agent implementer skills

Stable skill family for the **implementer** role when another AI agent (or
automated evaluator) owns review, feedback, and sign-off.

| Skill | Role |
| --- | --- |
| **`multi-agent-implementer`** | **Entry point** — bootstrap in conversation; resolve plan folder; run the loop |
| `multi-agent-implementer-lifecycle` | Phase router (child) |
| `multi-agent-implementer-corrections` | Read evaluator output; apply repo fixes |
| `multi-agent-implementer-folder-watch` | Watch plan folder for new evaluator files only |
| `multi-agent-implementer-closeout` | Close loop after `ready_for_review_*` sign-off |

**Start here:**

```text
Use skill multi-agent-implementer on docs/plans/<slug>/
```

Omit the path when the agent is already inside the plan packet or only one
evaluator-active plan exists — the skill auto-detects via
`scripts/resolve_plan_dir.py`.

**Pattern meditation (required reading):**
`references/evaluator-implementer-partition.md`

Reference run: `docs/plans/2026-09-02--codex-multi-terminal-promotion/`.

Durable documentation:
`docs/codex_framework/multi-agent/workflow-packages/evaluator-implementer-loop/`.

Capability manifest: `skills/multi-agent/multi-agent-implementer/capability.yml`.

Paired one-off promotion skills: `skills/one-off/` (`one-off-promotion`,
`one-off-promotion-verify`).
