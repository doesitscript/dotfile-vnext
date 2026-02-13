# Hub Role

Install [hub](https://github.com/github/hub), extending Git with GitHub integration.

## What This Role Does

1. **Installs hub** via package manager (Homebrew on macOS, apt on Ubuntu)
2. **Deploys hub aliases** to `~/.bashrc.d/hub.bash` (requires `common/shell_config` role)

## Dependencies

- `common/shell_config` - Sets up `.bashrc.d` pattern (include before `hub`)

## Usage

```yaml
roles:
  - common/shell_config  # Must come first
  - hub
```

## Configuration

Set `hub_aliases_enabled: false` in host_vars/group_vars to disable hub aliases.
