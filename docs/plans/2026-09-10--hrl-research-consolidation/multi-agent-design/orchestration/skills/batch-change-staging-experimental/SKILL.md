---
name: batch-change-staging-experimental
description: "After research and On-site Expert refinement, classify stable separable source work into one isolated no-commit worktree batch, validate it, and prepare grouped Evaluator review. Do not use for live Apply or shared mutable work."
metadata:
  status: experimental
  scope: post-research-batch-staging
  workflow_id: evaluator-implementer-loop
  role: batch-stager
---

# Batch change staging — experimental

Run after the research/On-site Expert packet has made the technical direction
stable and before the normal Implementer/Evaluator loop. Group only source work
whose owners, target identity, and acceptance criteria are already known.

Reject from a batch: live Apply, destructive storage actions, approval,
unresolved design forks, two changes to the same mutable owner, or work that
needs a different target/authority decision. Record rejected work in the batch
brief for later serial handling.

Use `runtime/stage-batch-worktree.ts` with selected relative paths and a fresh
directory outside the source repository. It copies only the selected dirty
snapshot into a detached worktree, never commits, and writes `.batch-manifest.json`.
Run the relevant validation bundle there. A failed check is a `validation_failed`
candidate for grouped feedback—not a reason to touch the source worktree.

The Implementer owns synthesis of one staged change package. The Evaluator
reviews the complete staged diff and groups feedback by owner/file in one
artifact. One follow-up Implementer batch fixes the grouped feedback. No live
Apply occurs from the staging worktree.
