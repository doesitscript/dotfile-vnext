# Network Plus Cross-Repo Issue Set

This is the real current issue set used to exercise the multi-repo capability
added to `github-issue-workflow`.

## Source basis

Primary sources used:

- `doesitscript/network_plus` local repo context
- `doesitscript/dotfile-vnext` skill/framework context
- `workflows/ai-sessions/2026-03-26_170717_multipass-troubleshooting-debrief/`
- official GitHub docs for tasklists, sub-issues, and issue dependencies

Known gap:

- `/Users/joshc/develop/workflows/docs/intake/git_workflows_skill_feature_cross_repo_issues.md`
  is currently empty and was not used as authoritative guidance

## Repo roles

- `doesitscript/network_plus`
  `primary`
- `doesitscript/dotfile-vnext`
  `secondary`
- `doesitscript/workflows`
  `reference_only`

## Relationship mode

- `supporting_tracking`

## Issues

### Primary

- Repo: `doesitscript/network_plus`
- Title: `network_plus: define the app-ready local AI gateway stack baseline`
- Labels:
  - `type:feature`
  - `state:ready`
  - `scope:network-plus`
  - `coordination:cross-repo`
- URL: https://github.com/doesitscript/network_plus/issues/1

### Secondary

- Repo: `doesitscript/dotfile-vnext`
- Title: `codex-framework: support cross-repo issue sets for network_plus coordination`
- Labels:
  - `type:capability`
  - `state:ready`
  - `scope:codex-framework`
  - `coordination:cross-repo`
- URL: https://github.com/doesitscript/dotfile-vnext/issues/9

## Native GitHub tracking pattern used

- primary issue body contains a tasklist item referencing
  `doesitscript/dotfile-vnext#9`
- both issue bodies include explicit backlinks
- sub-issues and issue dependencies are documented as optional future patterns,
  not required for this v1 issue set
