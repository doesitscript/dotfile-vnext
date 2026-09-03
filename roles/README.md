# Roles Organization

This repository organizes automation by capability-focused roles, then by operational modality and OS target where needed.

## Current Pattern

- `roles/common/*`
  - Shared verification/baseline behavior used across nodes.
- `roles/<node_group>/*`
  - Node-group specific capabilities (for example `dev_3090`, `server_225`, `network_server`).
- `roles/<capability>`
  - Cross-node capability roles adopted from previous repos (for example `git`, `hub`, `python`, `dotenv_bin`, `package_manager`).

## Role Naming Guardrail

- Prefer naming new roles for the capability they manage, not for the OS they
  happen to target first.
- Keep OS targeting inside `tasks/main.yml` with `mac.yml`, `ubuntu.yml`, and
  `windows.yml` dispatch when needed.
- Existing OS-suffixed roles in this repo are narrow compatibility exceptions,
  not the default pattern for new work.
- This guidance is meant to improve scalability and naming consistency over
  time, not to block good product- or domain-informed names from external docs,
  vendor guidance, or well-established architecture patterns.
- Example direction:
  `speech_central` is preferred over `speech_central_mac`.
  `remote_desktop` or another capability-focused name is preferred over a new
  role shaped like `remote_desktop_mac` unless the repo is intentionally
  preserving a narrow compatibility exception.

## Composition Guardrail

- When one user-facing operation needs multiple distinct capabilities, compose
  the capability-focused roles in a playbook instead of merging them into one
  larger role by default.
- Expose selective execution through meaningful playbook tags so operators can
  run the combined path or a single capability path without changing the role
  boundaries.
- Do not add wrapper roles by default when playbook composition already gives a
  clearer, more scalable control surface.

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
- When Homebrew source-builds or is weakly controllable, prefer a **pinned
  GitHub release binary** role pattern (example: `roles/gonzo_cli`,
  `roles/multiagents` for Bun). Keep version pins in
  `inventory/group_vars/all/*.yml` contracts and lifecycle in host_vars.

## CLI / tool capability settings ownership

For repo-managed developer CLIs, keep settings in the same places so scale-out
stays boring:

| Layer | What lives there | Example |
| --- | --- | --- |
| `inventory/group_vars/all/<tool>_tooling.yml` | Shared version contract | `multiagents_tooling.yml` |
| `inventory/host_vars/<host>.yaml` | Per-host `*_state: present\|absent` | `multiagents_state` on `mac-dev` |
| `roles/<capability>/` | Defaults, tasks, README, argument_specs | `roles/multiagents/` |
| `playbooks/deploy_development_nodes.yaml` | Composition + `--tags` | `--tags multiagents` |

Additional PowerShell-based package managers are planned and will be added later as separate, explicit tasks/roles (for example WinGet or PowerShell module flows) so behavior stays clear by operational modality.
