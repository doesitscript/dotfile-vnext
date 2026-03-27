# GitHub Issue Workflow Capability

This folder contains the portable skill logic for turning concrete
brainstorming, resumable work, or refined direction into durable GitHub issue
tracking.

It now also carries the repo-local pattern for multi-repo issue sets:

- one primary issue in the main product repo
- one or more secondary issues in supporting repos
- explicit repo-role mapping
- durable draft fallback when GitHub creation is blocked
- GitHub-native relationship guidance layered on top of body backlinks

The machine-readable source of truth for companion surfaces and ownership is
`capability.yml`.

## Owned Files

This capability currently owns or pairs with:

- `.cursor/skills/github-issue-workflow/SKILL.md`
- `.cursor/skills/github-issue-workflow/README.md`
- `.cursor/skills/github-issue-workflow/capability.yml`
- `.cursor/skills/github-issue-workflow/references/examples.md`
- `.cursor/skills/github-issue-workflow/references/github-native-relationship-guidance.md`
- `.cursor/skills/github-issue-workflow/references/multi_repo_issue_set_template.md`
- `.cursor/skills/github-issue-workflow/references/network_plus_cross_repo_issue_set.md`
- `.cursor/skills/github-issue-workflow/references/network_plus_primary_issue_body.md`
- `.cursor/skills/github-issue-workflow/references/network_plus_supporting_issue_body.md`
- `.cursor/rules/framework-github-issue-workflow.mdc`

## Multi-Repo Pattern

The v1 multi-repo default is:

- `primary`
  The issue in the main product or feature repo.
- `secondary`
  The issue in a supporting automation, framework, or process repo.
- `reference_only`
  Context repo or document source that informs the issue set but does not get
  its own issue by default.

For supporting/tracking relationships, prefer:

- backlinks in both issue bodies
- a tasklist reference in the primary issue body once the secondary issue exists

That gives a GitHub-native tracked relationship without forcing blocker
semantics or requiring deeper API automation.

## Update Rule

If an updated version of this skill is dropped into the repo, replace the files
listed in `owned_files` from the manifest unless the repo is intentionally
forking the workflow.

## Removal Rule

If this capability is removed, start from the same `owned_files` list so the
companion rule and references do not get left behind accidentally.
