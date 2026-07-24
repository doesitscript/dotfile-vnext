# Human Escalation

Pause and surface a decision when:

- the install path is destructive or removes user-managed state
- switching lifecycle strategy has non-obvious undo cost
- multiple viable upstream assets exist and the tradeoff is real
- live rollout failures imply host drift or repo policy conflict

Do not escalate for normal read-only previews, syntax checks, or straightforward
retry-after-fix runs.
