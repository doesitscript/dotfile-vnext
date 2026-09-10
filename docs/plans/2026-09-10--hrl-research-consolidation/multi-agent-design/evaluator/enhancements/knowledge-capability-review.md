# Enhancement — evaluate knowledge-capability use

## Intent

The Evaluator should be able to tell the difference between an implementation
that merely cites best practices and one that used the right authoritative
knowledge for the target task.

## Review rubric

| Check | Evidence expected | Send-back condition |
| --- | --- | --- |
| Capability selection | The task's uncertainty matches the selected capability. | Generic research was substituted for a known domain requirement. |
| Source availability | Configured, listed, and successfully invoked sources are distinguished. | A configured MCP or stale note is claimed as live evidence. |
| Decision traceability | Chosen/rejected patterns lead to concrete implementation surfaces. | The brief cannot explain why the implementation took its shape. |
| Fidelity or deviation | Receipt maps work to the brief or documents an evidence-backed change. | An implementation silently diverges from the researched contract. |
| Safety and proof | Preflight, apply, verification, and rollback boundaries are evidenced. | Playbook success is used in place of target-state proof. |
| Research escalation | Repeated unresolved blockers produced a targeted research request. | Blind correction cycles repeat. |

## Boundary preserved

The Evaluator may independently spot-check high-risk claims and request a new
research pass. It must not rewrite the implementation, author an implementer
receipt, or use a research brief as automatic sign-off.

## Output

Write findings into the normal evaluator-owned `feedback_*`, `waiting_*`, or
`ready_*` artifact. Do not introduce a parallel approval namespace.
