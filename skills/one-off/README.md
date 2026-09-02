# One-off lifecycle skills (reviewed)

Stable skill family for **try-before-commit** work under `docs/one_off_tasks/` and
its two end states: **promotion** to Ansible or **discard** with host cleanup.

| Skill | Role |
| --- | --- |
| `one-off-lifecycle` | **Router** — pick the correct phase skill |
| `one-off-trial-scaffold` | Start or extend a compliant one-off trial |
| `one-off-promotion` | Promote a trial into roles, playbooks, and a plan packet |
| `one-off-discard-cleanup` | Deprecate a trial without promotion |
| `one-off-promotion-verify` | Execute-complete verification after promotion |

Reference implementation: `docs/plans/2026-09-02--codex-multi-terminal-promotion/`.

Catalog aliases `draft-one-off-*` remain for older prompts.

Paired multi-agent implementer family: `skills/multi-agent/`.
