---
name: work-laptop-export-pack
description: "Use when the isolated work-laptop export packet under exports/work-laptop-ai-tools should be sliced into a zip, unpacked outside the repo, and smoke-tested from the extracted copy. Use for build the work-laptop export zip, round-trip this packet outside the repo, or verify the extracted hello-world packet still runs."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "project-skill-runtime-bridge"
requires_summary: "exports/work-laptop-ai-tools/export-manifest.yml; external extraction destination; ansible command for smoke verification"
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
---

# Skill: Work Laptop Export Pack

Build and verify the isolated work-laptop export packet without pulling that
host into the repo's normal playbooks or inventories.

## When to use / not use

Use when the repo-owned packet under `exports/work-laptop-ai-tools` should be
packaged as a portable zip for the work laptop, or when the extracted packet
needs an external smoke proof during development.

Do not use when the task is to broaden the capability into main inventory lanes
or when only the packet role logic itself is changing.

## Inputs

- `exports/work-laptop-ai-tools/export-manifest.yml`
- external destination root for extracted smoke runs
- ansible command to use for local verification

## Workflow

1. Read the packet manifest and keep the slice limited to its explicit `include`
   list.
2. Build the archive with:

```bash
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/build_export_archive.py
```

3. When development still needs an external proof run, unpack and verify from a
   non-repo location with:

```bash
bin/codex-env python skills/implementation/work-laptop-export-pack/scripts/roundtrip_smoke.py \
  --ansible-command "$PWD/bin/codex-env ansible-playbook"
```

4. If the extracted proof path uses a non-default inventory, pass
   `--inventory-file <name>`.
5. Verify the extracted playbook runs from its unpacked `playbook_dir`, not the
   repo copy.
6. Hand off to `project-skill-runtime-bridge` when the skill should be
   discoverable under `.cursor/skills`.

## Handoffs

- `project-skill-runtime-bridge`

## Outputs

- zip archive rooted at `work-laptop-ai-tools/`
- extracted smoke-run folder outside the repo
- command output proving syntax, host, task, and apply success from the
  extracted packet

## Validation

- Only manifest-owned packet files are included in the archive
- The extracted packet lives outside the repo
- The marker file records the extracted `playbook_dir`

## Failure boundaries

- Stop when the manifest references missing files
- Stop when the archive cannot be unpacked into an external destination
- Stop when the extracted packet fails its guarded local smoke run

## Prohibited behavior

- Expanding the archive scope beyond the manifest include list
- Extracting the smoke run back into this repo
- Treating repo-local playbook success as proof of extracted-packet success

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` for ownership and placement.
- Load `references/related-artifacts.md` for the packet files and helper scripts.
