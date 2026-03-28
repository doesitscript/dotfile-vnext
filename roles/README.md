# Roles Organization

This repository organizes automation by capability-focused roles, then by operational modality and OS target where needed.

## Current Pattern

- `roles/common/*`
  - Shared verification/baseline behavior used across nodes.
- `roles/<node_group>/*`
  - Node-group specific capabilities (for example `dev_3090`, `server_225`, `network_server`).
- `roles/<capability>`
  - Cross-node capability roles adopted from previous repos (for example `git`, `hub`, `python`, `dotenv_bin`, `package_manager`).

## OS Handling Convention

Inside role task entrypoints, OS task files are split by explicit target names used in this repo:

- `windows.yml` for Windows hosts (WinRM surfaces)
- `ubuntu.yml` for Ubuntu Linux hosts
- `mac.yml` for macOS hosts

Role `tasks/main.yml` files should import OS-specific task files using clear conditions, for example:

- `ansible_system == "Windows"`
- `ansible_distribution == "Ubuntu"`
- `ansible_system == "Darwin"`

## Package Manager Strategy

- Windows package management currently uses Chocolatey (`chocolatey.chocolatey.win_chocolatey`).
- Ubuntu package management uses `ansible.builtin.apt`.
- macOS package management uses Homebrew (`community.general.homebrew`).

Additional PowerShell-based package managers are planned and will be added later as separate, explicit tasks/roles (for example WinGet or PowerShell module flows) so behavior stays clear by operational modality.
