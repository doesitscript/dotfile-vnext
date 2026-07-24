---
name: deploy-dev-workstation-ollama-runtime
description: >-
  Use when applying the AMD desktop Ollama runtime playbook
  (deploy_dev_workstation_ollama_runtime.yaml) on dev-workstation-win, or when
  replacing ad-hoc ansible-playbook | tee /tmp/... with a project logs/runs
  capture. Prefer this over inventing /tmp log paths for desktop Ollama apply.
license: MIT
version: "0.1.0"
author: "dotfile-vnext"
compatibility: "Project skills for Codex/Cursor workflows"
modes: "agent, ask, plan, debug"
depends_on_skills: "homelab-ansible-first-entry, single-host-ansible-rollout, homelab-ssh-alias-connect"
requires_summary: "bin/codex-env; playbooks/deploy_dev_workstation_ollama_runtime.yaml; logs/runs/"
title: Deploy Dev Workstation Ollama Runtime
technology: ansible
document_type: skill
status: reviewed
authority: internal
source_type: internal
skill_scope: project
last_reviewed_at: "2026-07-24"
applies_to:
  - ansible
  - windows
  - ollama
related:
  - playbooks/deploy_dev_workstation_ollama_runtime.yaml
  - roles/windows_ollama_runtime/
  - roles/windows_artifact_download/
  - inventory/host_vars/dev-workstation-win.yaml
  - logs/README.md
tags:
  - skill
  - ansible
  - ollama
  - windows
  - rollout
---

# Skill: Deploy Dev Workstation Ollama Runtime

Replace ad-hoc `/tmp` tee applies of the desktop Ollama playbook with a durable
runner that always captures stdout/stderr under `logs/runs/`.

Source of truth: `skills/validation/deploy-dev-workstation-ollama-runtime/`.
Runtime discovery uses a managed symlink via `project-skill-runtime-bridge`.

## When to use / not use

**Use** when applying or re-applying:

- `playbooks/deploy_dev_workstation_ollama_runtime.yaml`
- limit `dev-workstation-win` (or `windows_amd_gpu_hosts`)

**Do not use** for HVH-01 Ollama, LiteLLM gateway apply, or Continue IDE alone.
Nest into `homelab-ansible-first-entry` first for novel install design; this
skill is the **execution surface** once that path is chosen.

## Hard stop — PROHIBITED

- `ansible-playbook ... | tee /tmp/desktop-*.log`
- Inventing a one-off temp playbook for desktop Ollama install
- Designing this skill only under `.cursor/skills/` (authority is `skills/`)
- Chocolatey as the Ollama install authority (deprecated in
  `windows_ollama_runtime`)

## Canonical command (replaces the /tmp tee)

From repo root:

```bash
bin/codex-env python \
  skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py
```

Defaults:

| Flag | Default |
| --- | --- |
| `--playbook` | `playbooks/deploy_dev_workstation_ollama_runtime.yaml` |
| `--limit` | `dev-workstation-win` |
| `--inventory` | `inventory/inventory.yaml` |
| `--verbosity` | `-vv` |
| log path | `logs/runs/<UTC>--deploy-dev-workstation-ollama-runtime.log` |

Useful variants:

```bash
# Read-only preview
bin/codex-env python \
  skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py \
  --check

# Skip model pull while proving installer only
bin/codex-env python \
  skills/validation/deploy-dev-workstation-ollama-runtime/scripts/apply_with_project_log.py \
  --extra-vars 'windows_ollama_runtime_models_present=[]'
```

The script prints `LOG_FILE=...` and `EXIT_CODE=...` when finished. Agents must
read that log (not invent a new `/tmp` path) for failure evidence.

## Workflow

1. Enter via `homelab-ansible-first-entry` if install method is still undecided.
2. Run the apply script above (live or `--check`).
3. On failure: inspect `LOG_FILE`, fix the smallest evidenced cause, re-run this
   skill (do not switch to `/tmp` tee).
4. After install success: verify `ollama.exe` and `/api/tags` via
   `homelab-ssh-alias-connect`.
5. Model pulls stay in this playbook when
   `windows_ollama_runtime_models_present` is set in host_vars.

## Outputs

- Live (or check-mode) ansible-playbook result
- Captured log under `logs/runs/` (gitignored)
- Printed `LOG_FILE` / `EXIT_CODE` lines for the agent to cite

## Nested skills

- `homelab-ansible-first-entry` — before inventing a new install approach
- `homelab-ssh-alias-connect` — host probes after apply
- `single-host-ansible-rollout` — broader preview/apply/verify receipt pattern

## Progressive disclosure

- Load `references/sources-and-precedence.md` for playbook and log authority.
- Load `references/related-artifacts.md` for command forms and surfaces.
