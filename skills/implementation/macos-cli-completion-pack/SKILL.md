---
name: macos-cli-completion-pack
description: "Use when a repo-managed macOS CLI should add, repair, or standardize Bash completion wiring across the shared shell substrate and the owning role. Use for Gonzo, Dstl8, Stern, K9s, Kubectl, or similar completion install paths, loader expectations, and verification hooks."
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "macos-ansible-install-validator, interactive-shell-completion-proof, single-host-apply-and-receipt"
requires_summary: "Owning role; target command; upstream completion surface or generator"
title: MacOS CLI Completion Pack
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - macos
  - completion
  - tooling
related:
  - roles/common/bash_completion
  - roles/common/shell_config
  - roles/k8s_cli_tools
  - roles/gonzo_cli
  - roles/dstl8_cli
tags:
  - skill
  - ansible
  - macos
  - completion
---

# Skill: MacOS CLI Completion Pack

Standardize how repo-managed macOS CLIs install, load, document, and verify
Bash completion so each tool does not reinvent the substrate.

## When to use / not use

Use when a repo-managed CLI needs completion added, repaired, or brought into
the shared project pattern.

Do not use when the CLI does not expose a completion surface or when only
interactive proof is needed after the wiring is already correct.

## Inputs

- Owning role and playbook lane
- Target command name
- Upstream completion generator or published completion file

## Workflow

1. Inspect the nearest completion-owning role pattern first.
2. Generate or capture the completion body from the upstream CLI instead of pasting stale snippets by hand.
3. Converge the completion file into `common_bash_completion_directory` under the command's managed filename.
4. Ensure the owning playbook includes `common/shell_config` and `common/bash_completion` on the same execution lane as the tool role.
5. Add verify guidance to the role README and metadata so the completion path is part of the delivered contract.
6. Hand off to `macos-ansible-install-validator` for path, check-mode, and ownership validation.
7. Hand off to `interactive-shell-completion-proof` for real PTY proof.
8. Hand off to `single-host-apply-and-receipt` when the user asked to execute on `mac-dev`.

## Handoffs

- `macos-ansible-install-validator`
- `interactive-shell-completion-proof`
- `single-host-apply-and-receipt`

## Outputs

- Managed completion file path
- Shared loader expectation
- README and verification guidance aligned to the owning role

## Validation

- The completion file lives under the shared Homebrew completion directory
- The owning playbook includes the shared shell/completion substrate
- Interactive proof happens in a real PTY before success is declared

## Failure boundaries

- Stop when upstream exposes only a different shell family and no Bash surface exists
- Stop when the CLI emits unstable or empty completion output and the upstream behavior is the real blocker

## Prohibited behavior

- Loading per-tool completion from ad hoc dotfile edits when the repo owns the shell substrate
- Treating file presence as enough proof of working completion
- Copying a completion snippet from docs when the CLI can generate the authoritative body directly

## Progressive disclosure

- Operator escalation: `skills/_shared/human-escalation.md`
- Load `references/sources-and-precedence.md` when completion ownership is unclear.
- Load `references/related-artifacts.md` for current role and playbook patterns.
