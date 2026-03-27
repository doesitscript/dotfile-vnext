# Git Command Approvals For Codex

This note exists because Git index-writing commands can be blocked by the
Codex execution sandbox even when ordinary repo edits are allowed.

## Why this happens

The sandbox is the execution boundary around the Codex session, not a repo
setting inside this project. Repo docs and rules can tell Codex what it should
do, but they cannot directly change the platform-level approval list that
controls restricted shell execution.

In practice, this means:

- normal file edits in the workspace can work
- some Git reads can work
- `git add` may work
- but index-writing commands like `git restore --staged`, `git reset`, or
  `git commit` can still be blocked until the platform approval layer allows
  them

## Durable repo rule

The repo guidance now treats non-destructive Git housekeeping as normal
execution. Codex should not keep asking about safe Git staging/commit work.
Only destructive or history-rewriting Git actions should be treated as special.

## Commands to approve when Git is blocked

If Codex cannot complete staging/commit work because of sandbox approval, these
are the main commands to allow:

- `git restore --staged`
  - for unstaging generated files without deleting them
- `git reset`
  - for clearing the staging area without changing the working tree
- `git commit`
  - for writing grouped commits

Additional Git commands can be added here if the platform blocks them in future
work.

## Current known-good low-risk Git workflow

These are the operations Codex commonly needs during normal repo work:

- `git status`
- `git diff`
- `git diff --cached`
- `git add`
- `git restore --staged`
- `git reset`
- `git commit`

## What to update when this comes up again

If another Git command is blocked by the platform but should be treated as
normal repo work:

1. add it to this document
2. keep the repo guidance aligned with that expectation
3. prefer broad enough approvals to avoid repeated interruption, but avoid
   destructive Git prefixes
