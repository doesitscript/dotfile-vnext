---
name: work-laptop-export-pack
description: "Use when the isolated work-laptop packet under exports/work-laptop-ai-tools should be synced into the sibling build-target repo and validated there. Use the archive branch only when the user explicitly asks for zip output or zip-based smoke proof."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "project-skill-runtime-bridge"
requires_summary: "exports/work-laptop-ai-tools/export-manifest.yml; sibling build-target repo checkout; ansible command for smoke verification"
title: Work Laptop Export Pack
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-09-02"
based_on_library: global-skills
based_on_library_version: "0.2.0"
library_contract_version: "2"
applies_to:
  - ansible
  - export
  - zip
  - macos
related:
  - exports/work-laptop-ai-tools/export-manifest.yml
  - exports/work-laptop-ai-tools/playbook.yaml
  - exports/work-laptop-ai-tools/inventory.yaml
  - skills/implementation/project-skill-runtime-bridge
tags:
  - skill
  - ansible
  - export
  - zip
  - sibling-repo
---

# Skill: Work Laptop Export Pack

Build and verify the isolated work-laptop export packet without pulling that
host into the repo's normal playbooks or inventories.

## When to use / not use

Use when the repo-owned packet under `exports/work-laptop-ai-tools` should be
synced into the generated sibling build-target repo and validated there.

Use the archive branch only when the user explicitly asks for zip output or
zip-based smoke proof.

Do not use when the task is to broaden the capability into main inventory lanes
or when only the packet role logic itself is changing.

## Inputs

- `exports/work-laptop-ai-tools/export-manifest.yml`
- sibling build-target repo checkout outside the source repo
- ansible command to use for local verification
- optional explicit archive path only when the archive branch is requested

## Workflow

1. Read the packet manifest and keep the slice limited to its explicit `include`
   list.
2. Validate the packet contract against the current repo work-laptop packet source surfaces:

```bash
bin/codex-env python \
  skills/implementation/work-laptop-export-pack/scripts/validate_export_contract.py
```

3. Sync the sibling build-target repo with:

```bash
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/sync_sibling_repo.py
```

4. Verify the sibling repo from outside the source repo with:

```bash
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --packet-dir /Users/joshc/develop/work-laptop-ai-tools \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

5. Build the optional archive with:

Only do this when the user explicitly requests the archive branch.

```bash
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/build_export_archive.py
```

6. When development still needs zip-based proof, unpack and verify from a
   non-repo location only when an explicit archive path is provided:

```bash
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --archive-path exports/work-laptop-ai-tools/dist/work-laptop-ai-tools.zip \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

7. Add `--apply` only when the external packet copy is being run on the real work
   laptop and a mutating apply is intended.
8. If the external proof path uses a non-default inventory, pass
   `--inventory-file <name>`.
9. Verify the preview commands run from the external `playbook_dir`, not the
   repo copy. When `--apply` is used, also verify the marker file proves the
   external `playbook_dir`.
10. Hand off to `project-skill-runtime-bridge` when the skill should be
   discoverable under `.cursor/skills`.

## Handoffs

- `project-skill-runtime-bridge`

## Outputs

- synced sibling build-target repo outside the source repo
- validation output showing the packet still matches repo work-laptop packet conventions
- command output proving external bootstrap preview plus external syntax,
  host, and task previews
- optional apply proof from the external packet when `--apply` is used on the
  real work laptop
- optional zip archive and archive-based smoke proof only when explicitly requested

## Validation

- The packet contract matches the current repo values for the work-laptop
  packet Python path, packet `.venv`, public `~/.local/bin` Ansible shims,
  and vendored bootstrap roles
- The sibling build-target repo contains only manifest-owned files
- The external packet copy lives outside the repo
- Preview proof uses the external bootstrap script and external playbook paths
- The marker file records the external `playbook_dir` when `--apply` is used
- Only manifest-owned packet files are included in the archive when the archive
  branch is explicitly requested

## Failure boundaries

- Stop when the manifest references missing files
- Stop when the sibling repo cannot be synced into an external git checkout
- Stop when the external packet copy fails its guarded local smoke run
- Stop when an explicitly requested archive path is missing or cannot be unpacked

## Prohibited behavior

- Expanding the archive scope beyond the manifest include list
- Syncing or extracting the smoke run back into this repo
- Treating repo-local playbook success as proof of sibling-repo success
- Building or validating the archive branch unless the user explicitly asked for it

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` for ownership and placement.
- Load `references/related-artifacts.md` for the packet files and helper scripts.
