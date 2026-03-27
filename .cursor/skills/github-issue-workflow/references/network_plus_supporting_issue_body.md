Overview:
Track the supporting `dotfile-vnext` framework/process work needed to coordinate
real cross-repo issue handling for `network_plus` and to preserve the supporting
repo context that informed the main product issue.

Why this issue lives here:
- `dotfile-vnext` owns the Codex framework and the `github-issue-workflow`
  skill that needs to support multi-repo issue sets
- the supporting issue belongs here because this repo owns the workflow and
  process behavior, not the main product stack itself

Primary issue link:
- https://github.com/doesitscript/network_plus/issues/1

Current state:
- the `github-issue-workflow` skill was originally shaped around single-repo
  issue drafting and creation
- the real current need is a primary issue in `doesitscript/network_plus` with a
  supporting issue in `doesitscript/dotfile-vnext`
- the debrief and follow-up records under `workflows/ai-sessions/` contain the
  strongest current cross-repo source material
- the dropped intake file at
  `/Users/joshc/develop/workflows/docs/intake/git_workflows_skill_feature_cross_repo_issues.md`
  is currently empty and should be treated as an input gap, not authoritative
  guidance

Local execution plan:
- upgrade `github-issue-workflow` to support explicit multi-repo issue sets with
  `primary`, `secondary`, and `reference_only` repo roles
- document GitHub-native relationship options such as cross-repo tasklist
  references, sub-issues, and issue dependencies without over-claiming current
  automation support
- create or refine the minimum labels needed in `network_plus` for the real
  primary issue
- create and cross-link the real `network_plus` primary issue and this
  supporting `dotfile-vnext` issue

Definition of done:
- the skill can draft or create a coordinated cross-repo issue set
- the real `network_plus` primary issue exists and links back to this supporting
  issue
- durable issue-set references exist under the skill so future sessions can
  reuse the pattern
- the empty intake file is noted as a gap and the real source basis is made
  explicit

Pick-up references:
- `.cursor/skills/github-issue-workflow/SKILL.md`
- `.cursor/skills/github-issue-workflow/capability.yml`
- `/Users/joshc/develop/workflows/ai-sessions/2026-03-26_170717_multipass-troubleshooting-debrief/output/debrief.md`
- `/Users/joshc/develop/workflows/ai-sessions/2026-03-26_170717_multipass-troubleshooting-debrief/output/followups.md`
- `/Users/joshc/develop/network_plus/README.txt`
- `/Users/joshc/develop/network_plus/litellm.config.yaml`
