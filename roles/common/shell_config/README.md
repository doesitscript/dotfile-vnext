# Shell Configuration Role

Manages `.bashrc` using a modular `.bashrc.d` pattern. This role:

1. Creates `~/.bashrc.d/` directory for modular shell configs
2. Ensures `.bashrc` sources all files in `.bashrc.d/`
3. Deploys common aliases and shell configurations
4. **WSL PATH management**: Ensures Linux binaries take precedence over Windows binaries

## Pattern

- Each capability role (git, python, hub, etc.) deploys its own `.bash` file to `~/.bashrc.d/`
- `.bashrc` automatically sources everything in `.bashrc.d/`
- Non-destructive: preserves user customizations in `.bashrc`
- **WSL-specific**: In WSL, Linux paths are prioritized over Windows paths to prevent conflicts

## WSL PATH Priority

When running in WSL, this role ensures:
- Linux binaries (e.g., `/usr/bin/hub`) are found before Windows binaries (e.g., `/mnt/c/Program Files/hub/hub.exe`)
- Windows paths are still available but come after Linux paths
- A warning is shown if a Windows binary is found when a Linux version should be used

## Usage

Include this role early in playbooks (before other roles that deploy shell configs):

```yaml
roles:
  - common/shell_config
  - git
  - python
  - hub
```
