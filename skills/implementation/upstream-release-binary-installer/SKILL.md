---
name: upstream-release-binary-installer
description: "Use when a repo-managed tool should install from a pinned upstream release binary instead of Homebrew, pip, or another package manager, especially on macOS where formulae may trigger long source builds. Use for release asset URL, checksum pinning, arch map, extraction path, or check-mode-safe binary install design."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "tool-usage-note-and-discoverability, single-host-ansible-rollout"
requires_summary: "Current upstream release metadata; target architecture facts"
title: Upstream Release Binary Installer
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
  - tooling
related:
  - roles/gonzo_cli
  - playbooks/deploy_development_nodes.yaml
tags:
  - skill
  - ansible
  - binary
  - releases
---

# Skill: Upstream Release Binary Installer

Prefer pinned upstream release binaries when package-manager installs are slow,
fragile, or operationally wrong for the host.

## When to use / not use

Use when Homebrew, pip, or another package-manager path causes long source
builds, broken dependencies, or a worse lifecycle than a pinned upstream asset.

Do not use when a stable first-party module or package-manager contract already
fits the repo and target host.

## Inputs

- Current upstream release metadata
- Target `ansible_architecture` and OS
- Desired install path and verification path

## Workflow

1. Fetch the current upstream release metadata and confirm the real latest version/date.
2. Identify the correct asset names, checksums, and architecture map.
3. Pin release version, archive filename, checksum, and install path in role defaults.
4. Keep the role check-mode-safe when directories or cached archives do not yet exist.
5. Prefer native platform extraction when Ansible archive helpers are incompatible.
6. Verify the final binary path directly after apply.
7. Hand off to `tool-usage-note-and-discoverability` for docs and to `single-host-ansible-rollout` for execution.

## Handoffs

- `tool-usage-note-and-discoverability`
- `single-host-ansible-rollout`

## Outputs

- Pinned release defaults
- Archive and checksum mapping
- Install/extract tasks
- Direct binary verification path

## Validation

- Asset names and checksums match upstream release metadata
- The chosen asset matches target architecture
- Check mode does not fail just because future directories are absent
- Live apply verifies the binary path directly

## Failure boundaries

- Stop when upstream assets are ambiguous or missing checksums
- Stop when architecture support is unclear

## Prohibited behavior

- Restarting a known-bad package-manager build after the user said to stop
- Using unpinned latest URLs without a version variable
- Pretending unarchive portability when the target extractor disagrees

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when ranking upstream release evidence.
- Load `references/related-artifacts.md` for expected role surfaces.
