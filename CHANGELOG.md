# Changelog

All notable homelab automation changes are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

## [6.1.6] - 2026-09-02

Pre-release channel: `v6.1.6-beta` (Codex tab completion menu above prompt).

### Changed

- `shell-completion_one_off_tasks.bash` — render horizontal completion menu on the line
  **above** the prompt (save/restore cursor) instead of left of PS1; optional blank line
  before each prompt via `PROMPT_COMMAND` trial spacing.

## [6.1.5] - 2026-09-02

Pre-release channel: `v6.1.5-beta` (Codex tab completion in-place menu redraw).

### Changed

- `shell-completion_one_off_tasks.bash` — horizontal completion menu redraws in place on
  repeated Tab instead of stacking a new line each cycle; adds fzf-tab-completion for
  paths/flags after first word.

## [6.1.4] - 2026-09-02

Pre-release channel: `v6.1.4-beta` (Codex multi-terminal one-off trial).

### Added

- `docs/one_off_tasks/codex-multi-terminal-workflow/` — try-before-commit package for
  distributed homelab Codex terminals (`cx-deep`, `cx-desktop`, `cx-skills`,
  `cx-hvh01`, `cx-research`), role-specific instructions, and inline horizontal
  tab completion (`shell-completion_one_off_tasks.bash`).

## [6.1.3] - 2026-09-02

Pre-release channel: `v6.1.3-alpha` (pre-multi-agent ATDD coordination).

### Added

- `model-lane-acceptance/` project-owned acceptance YAML for gateway and Codex CLI
  lanes, with client-map, approved vs pending manifests, and run scripts wired to
  global-skills pytest harnesses.
- Global skill symlinks for homelab validation skills (codex-cli pytest, litellm
  lane pytest, local-ai-client validation pack).
- Draft multi-agent plan work (`00`–`02`) for acceptance-author vs implementer
  role boundaries and evaluator feedback on ATDD coordination wording.

### Changed

- ATDD developer-flow diagram and codex ATDD plan scaffolding in draft plan folder.
- Agent skills sync manifest refreshed after skills-cursor bridge updates.

## [6.1.2] - 2026-09-01

Pre-release channel: `v6.1.2-alpha` (Kilo Code homelab lanes).

### Added

- LiteLLM friendly client IDs for Kilo (`kilo-main`, `kilo-lite`, `kilo-autocomplete`,
  `kilo-fast`) and `kilo-lite` vLLM route on k3s-02.
- Kilo 14B AWQ testing lane on vLLM primary with 32k context for code-agent headroom.
- Brainstorm packets for Kilo GPU placement and structured LiteLLM client IDs.

### Changed

- Recovery and validation playbooks honor `kilo_testing_active` on k3s-02.
- Agent lane profiles and Continue IDE defaults aligned to structured model client IDs.


Pre-release channel: `v6.1.1-alpha` (partial stable closeout).

### Removed

- IIS (`Web-Server`) from Windows Server hypervisors — not used by this project;
  default `:80` site was misleading (for example `ollama-hvh01.hom.lab`).

### Changed

- IIS removal lives in `windows_base` only (no separate site/provision phase).
- Removed stale WinRM-only gate from `playbooks/windows_base.yml` so OpenSSH
  Windows hosts receive the full baseline.
- Canonical Langfuse platform data-plane vars (`langfuse_platform_external_*`);
  `fuzlang_*` retained as deprecated aliases only (`AGENTS.md` naming gate).

## [6.1.0] - 2026-08-27

### Fixed

- NVIDIA driver contract on `HOM-LAB-HVH-02` set to live `610.88` so GPU-P
  artifact publish matches `nvidia-smi` (Chocolatey package pin can lag).
- vLLM KV-cache recovery documented to prefer `--gpu-memory-utilization` only;
  do not trim model context unless the operator explicitly requests it.
