# GitHub-Native Relationship Guidance

This note records the GitHub-native relationship options that the
`github-issue-workflow` skill should understand for cross-repo issue work.

## Supporting / tracking relationship

Default for primary/secondary repo coordination:

- include backlinks in both issue bodies
- add a tasklist item in the primary issue body that references the secondary
  issue once that issue exists

Why:

- GitHub tasklists support cross-repo issue references
- referenced issues in tasklists get tracked-by behavior
- this gives a native relationship without forcing blocker semantics

## Parent / child relationship

Use only when the secondary issue is genuinely a child of the primary issue.

Recommended GitHub-native feature:

- sub-issues

GitHub supports adding existing issues from other repositories as sub-issues.

## Blocking relationship

Use only when one issue truly blocks another.

Recommended GitHub-native feature:

- issue dependencies

Do not use dependency language for ordinary supporting work.

## Practical v1 rule

For this repo's v1 skill behavior:

- use tasklist reference + backlinks by default
- recommend sub-issues for real parent/child work
- recommend issue dependencies for real blockers
- do not pretend the current `gh issue create` flow directly automates all
  native relationship types

## Sources

- GitHub Docs: About tasklists
  https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/about-tasklists
- GitHub Docs: Adding sub-issues
  https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues
- GitHub Docs: Creating issue dependencies
  https://docs.github.com/en/enterprise-cloud@latest/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies
