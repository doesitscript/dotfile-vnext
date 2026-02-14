# Cursor Editor Role

Configures Cursor editor settings and environment variables.

## What This Role Does

1. **Sets EDITOR environment variable** to `cursor --wait` for use with git and other tools
2. **Deploys configuration** to `~/.bashrc.d/cursor.bash` (requires `common/shell_config` role)

## Dependencies

- `common/shell_config` - Sets up `.bashrc.d` pattern (include before `cursor`)

## Usage

```yaml
roles:
  - common/shell_config  # Must come first
  - cursor
```

## Configuration

After installation, git and other tools will use Cursor as the editor:
- `git commit` (without `-m`) will open Cursor
- `crontab -e` will use Cursor
- Other tools that respect `$EDITOR` will use Cursor

## Future Extensions

This role can be extended to include:
- Cursor-specific settings
- Keyboard shortcuts
- Extension recommendations
- Workspace configurations
