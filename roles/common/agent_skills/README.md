# Agent Skills

This role brings selected Cursor and Codex skills into repo ownership and links
the runtime home paths back to those tracked files.

`catalog.yml` is the machine-readable inventory for what is tracked here and
what is deliberately excluded.

## Classification

Use these categories when deciding whether a skill belongs here.

### Repo-Local Skills

Repo-local skills are part of this checkout's framework behavior. They live
under `.cursor/skills/`, are registered in `.cursor/skills/catalog.yml`, and
should use the repo skill pattern:

- `SKILL.md`
- `capability.yml` for new or materially changed skills
- optional `README.md`
- optional `references/`

Name repo-local skills by capability in kebab case, such as
`github-issue-workflow` or `generate-project-state-report`. Avoid runtime
prefixes unless the skill is truly runtime-specific.

### Personal-Portable Skills

Personal-portable skills are global operator skills that should survive a
machine rebuild but are not project behavior by themselves. This role tracks
them under `roles/common/agent_skills/files/` and links the expected home paths
to those repo-owned files.

Keep the installed skill directory names unchanged so Cursor and Codex discovery
continues to work. The classification is visible from the path:

- `files/cursor/skills-cursor/` for Cursor-managed global skills
- `files/cursor/skills/` for Cursor personal global skills
- `files/codex/skills/` for Codex personal global skills

Current imported personal-portable skills:

- Cursor managed global skills:
  - `babysit`
  - `canvas`
  - `create-hook`
  - `create-rule`
  - `create-skill`
  - `create-subagent`
  - `langfuse` (marketplace skill - tracing, prompting, and evaluation)
  - `migrate-to-skills`
  - `sdk`
  - `shell`
  - `split-to-prs`
  - `statusline`
  - `update-cli-config`
  - `update-cursor-settings`
- Cursor personal global skills:
  - _(none currently — `create-diagrams` promoted to `global-skills`)_
- Codex personal global skills:
  - `critical-naming-analysis`
  - `gemini-free-tier-model-chooser`

### Vendor-System Skills

Vendor-system skills are tool-managed or cache/vendor trees. Do not copy them
into this role as source-of-truth content.

Currently excluded:

- `~/.codex/skills/.system`
- `~/.codex/vendor_imports/skills`

Those trees can be re-created by the owning toolchain and may change outside
this repo's lifecycle.

## Link Strategy

The role follows the existing repo-owned symlink model used by the git role for
`~/.gitignore_global`.

Managed links:

- `~/.cursor/skills-cursor` ->
  `roles/common/agent_skills/files/cursor/skills-cursor`
- `~/.cursor/skills` ->
  `roles/common/agent_skills/files/cursor/skills`
- `~/.codex/skills/gemini-free-tier-model-chooser` ->
  `roles/common/agent_skills/files/codex/skills/gemini-free-tier-model-chooser`
- `~/.codex/skills/critical-naming-analysis` ->
  `roles/common/agent_skills/files/codex/skills/critical-naming-analysis`

Codex gets an individual skill link instead of replacing all of
`~/.codex/skills` so the tool-managed `.system` directory remains outside repo
ownership.

## Lifecycle

`agent_skills_manage` defaults to true on macOS and false elsewhere. That keeps
the broad development-node playbook from creating personal Cursor/Codex links on
Linux companions unless a host explicitly opts in.

`agent_skills_state: present` creates the links. If an unmanaged destination
already exists, the role moves it aside with a timestamped
`.before-agent-skills-link-*` suffix before creating the link.

`agent_skills_state: absent` removes only symlinks managed by this role. It does
not delete repo-owned skill sources and does not restore backup directories
automatically.
