---
name: github-release-binary-intake
description: "Use when a macOS or cross-platform tool should install from a pinned GitHub release asset and the repo needs version, asset, checksum, and arch details captured before Ansible tasks are finalized. Use for latest release asset mapping, checksum file discovery, or darwin arm64/amd64 binary intake."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "tool-role-docs-pack, macos-ansible-install-validator, single-host-ansible-rollout"
requires_summary: "Current GitHub release metadata; target architecture facts"
title: GitHub Release Binary Intake
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-23"
applies_to:
  - ansible
  - macos
  - github
  - tooling
related:
  - roles/gonzo_cli
  - playbooks/deploy_development_nodes.yaml
tags:
  - skill
  - ansible
  - github
  - releases
---

# Skill: GitHub Release Binary Intake

Turn GitHub release metadata into a pinned, architecture-aware install contract.

## When to use / not use

Use when the repo should install from GitHub release assets instead of from
Homebrew or another package manager.

Do not use when the upstream source is not GitHub Releases or when live rollout
is the only remaining step.

## Inputs

- GitHub owner/repo
- Latest or requested release tag
- Target OS and architecture
- Desired install and verify paths

## Workflow

1. Confirm the true latest release or the explicit pinned tag.
2. Capture release date, version, asset names, and checksum surfaces.
3. Map target architectures to exact asset filenames instead of relying on string guesses in tasks.
4. Pin version, archive name, checksum, URL, and install path in role defaults.
5. Note ambiguity early when checksums are absent, split across files, or embedded in release notes.
6. Hand off to `macos-ansible-install-validator` for check-mode and extractor safety.
7. Hand off to `tool-role-docs-pack` for operator-facing links and docs.
8. Hand off to `single-host-ansible-rollout` for preview/apply/verify evidence.

## Handoffs

- `macos-ansible-install-validator`
- `tool-role-docs-pack`
- `single-host-ansible-rollout`

## Outputs

- Pinned release version and date
- Asset and checksum mapping
- Architecture map
- Install-path defaults ready for Ansible

## Validation

- Asset names come from current release metadata
- Checksums, when available, map to the chosen archive
- Architecture support is explicit

## Failure boundaries

- Stop when the repo or release does not publish a trustworthy asset/checksum surface
- Stop when multiple assets plausibly match the same architecture and no upstream cue resolves the tie

## Prohibited behavior

- Using a moving `latest` download URL without a pinned version variable
- Guessing asset names from memory
- Ignoring the release date when latest-vs-pinned matters

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking release evidence.
- Load `references/related-artifacts.md` for likely repo touch points.
- Helper script: `scripts/inspect_github_release.py`
