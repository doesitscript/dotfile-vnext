# Direnv Role

Installs and configures [direnv](https://direnv.net/), a tool that loads and unloads environment variables depending on the current directory.

## What This Role Does

1. **Installs direnv** via package manager (Homebrew on macOS, apt on Ubuntu)
2. **Configures bash hook** in `~/.bashrc.d/direnv.bash` (requires `common/shell_config` role)

## Dependencies

- `common/shell_config` - Sets up `.bashrc.d` pattern (include before `direnv`)

## Usage

```yaml
roles:
  - common/shell_config  # Must come first
  - direnv
```

## Configuration

After installation, create `.envrc` files in your project directories to automatically load environment variables when you `cd` into them.

## Gitignore

The following files should be in `.gitignore`:
- `.direnv/` - Direnv cache directory
- `.envrc` - Environment variable definitions (if they contain secrets)
