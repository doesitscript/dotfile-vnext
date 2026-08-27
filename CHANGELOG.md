# Changelog

All notable homelab automation changes are documented here.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Removed

- IIS (`Web-Server`) from Windows Server hypervisors — not used by this project;
  default `:80` site was misleading (for example `ollama-hvh01.hom.lab`).

### Changed

- IIS removal lives in `windows_base` only (no separate site/provision phase).
- Removed stale WinRM-only gate from `playbooks/windows_base.yml` so OpenSSH
  Windows hosts receive the full baseline.

## [6.1.0] - 2026-08-27

### Fixed

- NVIDIA driver contract on `HOM-LAB-HVH-02` set to live `610.88` so GPU-P
  artifact publish matches `nvidia-smi` (Chocolatey package pin can lag).
- vLLM KV-cache recovery documented to prefer `--gpu-memory-utilization` only;
  do not trim model context unless the operator explicitly requests it.
