# GitHub Issue Workflow Capability

This folder contains the portable skill logic for turning concrete
brainstorming, resumable work, or refined direction into durable GitHub issue
tracking.

The machine-readable source of truth for companion surfaces and ownership is
`capability.yml`.

## Owned Files

This capability currently owns or pairs with:

- `.cursor/skills/github-issue-workflow/SKILL.md`
- `.cursor/skills/github-issue-workflow/README.md`
- `.cursor/skills/github-issue-workflow/capability.yml`
- `.cursor/skills/github-issue-workflow/references/examples.md`
- `.cursor/rules/framework-github-issue-workflow.mdc`

## Update Rule

If an updated version of this skill is dropped into the repo, replace the files
listed in `owned_files` from the manifest unless the repo is intentionally
forking the workflow.

## Removal Rule

If this capability is removed, start from the same `owned_files` list so the
companion rule and references do not get left behind accidentally.
