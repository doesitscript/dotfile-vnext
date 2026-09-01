# Changelog

All notable homelab automation changes are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

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
