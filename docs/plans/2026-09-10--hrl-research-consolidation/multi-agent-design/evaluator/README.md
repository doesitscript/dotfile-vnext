# Evaluator design enhancements

This folder supplements the mature evaluator skills and their evaluator-owned
artifact contract. It adds a review lens for task-specific expert knowledge.

Start with:

- [`enhancements/pre-activation-evaluator-note.md`](enhancements/pre-activation-evaluator-note.md)
- [`enhancements/knowledge-capability-review.md`](enhancements/knowledge-capability-review.md)

For the current planning-through-implementation iteration, also use the
[role operating contract](../orchestration/02-authority--who-to-call.md). The Evaluator checks
the changed implementation against the canonical plan, selected authority
profile, Expert recommendation or documented exception, and independent
acceptance evidence. It does not promote a recommendation into approval or
write the corresponding implementation fix.
