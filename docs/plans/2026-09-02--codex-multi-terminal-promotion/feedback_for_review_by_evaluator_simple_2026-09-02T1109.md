---
title: evaluator simple feedback
created_at: 2026-09-02T1109
author: evaluator-simple
status: partial
decision: not satisfactory
plan: 2026-09-02--codex-multi-terminal-promotion
---

# Evaluator feedback

Work is **not satisfactory yet**. Keep correcting.

## What improved

- The draft one-off skill family now passes the project validators:
  - `bin/codex-env python skills/scripts/validate_metadata.py` -> pass
  - `bin/codex-env python skills/scripts/validate_skills_catalog.py` -> pass
- The new project-local handoff target `complete-plan-lifecycle` now exists in
  the project skill source of truth and has `agents/openai.yaml`.
- The draft one-off skills now include the missing frontmatter fields and the
  source-authority reference for `single-host-ansible-rollout`.
- The new `draft-one-off-lifecycle` router is a good addition and addresses the
  earlier pack-resolution gap.

## Remaining open findings

### P1 stays open: real undo semantics are still wrong in live role behavior

Static bash contributions are still copied unconditionally by:

- `roles/common/shell_config/tasks/unix.yml:106-112`

and are still **not** removed by the owning roles' absent paths:

- `roles/fzf_tab_completion/tasks/absent.yml:1-20`
- `roles/codex_homelab_profiles/tasks/mac.yml:41-57`
- `roles/codex_homelab_profiles/tasks/multi_terminal.yml:1-43`

This means the promotion packet is still lying when it says role `absent`
states are enough to undo the capability.

### P2 stays open: the plan packet and role docs still publish false or incomplete commands

Still incorrect:

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:29-38`
- `roles/fzf_tab_completion/README.md:20-24`
- `roles/codex_homelab_profiles/README.md:27-32`

Problems:

- `Update behavior` still omits required integration tags
- `Apply` still omits `bash_completion`
- `Undo` still claims state toggles are sufficient
- role READMEs still expose the same bad removal contract

### P3 stays open: the plan still uses the short promotion map instead of the full disposition ledger

Still incomplete:

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:54-64`

The plan must enumerate the full archived one-off inventory with per-item
disposition, not just a short summary map.

### P4 stays open: the packet still does not separate contract from receipt

Still combined in one file:

- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md:66-99`

The receipt material is acceptable evidence, but the packet is still cleaner
and more future-proof if you split execution evidence into its own receipt file.

## Required next actions

1. Fix the actual removal behavior first.
   Either make static `bashrc.d` deployment state-aware, or add explicit delete
   tasks for the managed files so `absent` truly removes them.
2. After behavior is fixed, update the plan contract and both role READMEs.
3. Replace the short promotion map with the full disposition ledger.
4. Optionally split the execution receipt into a dedicated file once the
   contract is truthful.

## Re-check commands

Run these again after corrections:

```bash
bin/codex-env python skills/scripts/validate_metadata.py
bin/codex-env python skills/scripts/validate_skills_catalog.py
```

Then prove the plan-level correction with fresh source inspection of:

- `roles/common/shell_config/tasks/unix.yml`
- `roles/fzf_tab_completion/tasks/absent.yml`
- `roles/codex_homelab_profiles/tasks/mac.yml`
- `docs/plans/2026-09-02--codex-multi-terminal-promotion/README.md`
- `roles/fzf_tab_completion/README.md`
- `roles/codex_homelab_profiles/README.md`

## Satisfactory close condition

Do **not** create `ready_for_review_by_evaluator_<timestamp>.md` yet.

This work becomes satisfactory only when:

- the live undo behavior is actually correct
- the plan packet documents the true apply/undo contract
- the role READMEs agree with the code
- the plan uses the full disposition ledger
