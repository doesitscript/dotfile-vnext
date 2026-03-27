# Skill Template

Use this template when creating a new repo-local skill or when upgrading an
older skill to the manifest-backed pattern.

## Files

- `SKILL.md`
  Portable workflow logic.
- `capability.yml`
  Machine-readable manifest.
- `README.md`
  Human-facing ownership/update/remove note.
- `references/examples.md`
  Optional examples when they materially help usage.

## Required Manifest Fields

- `name`
- `family`
- `kind`
- `portable`
- `summary`
- `capabilities`
- `suggested_roles`
- `trigger_style`
- `skill_file`
- `owned_files`
- `update_behavior`
- `removal_behavior`

## Pattern

Keep the split clean:

- `SKILL.md` explains the portable workflow
- `capability.yml` makes discovery easy for agents
- companion rule files stay outside the skill folder but are listed in
  `owned_files` when the skill owns or depends on them
- framework docs explain the larger capability family

## Update And Removal Rule

For manifest-backed skills:

- dropping in an updated version should replace the files listed in
  `owned_files`
- removing the skill should start from `owned_files`

That rule should be true without rereading the whole repo.
