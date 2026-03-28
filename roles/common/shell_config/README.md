# Shell Configuration Role

Manages bash startup using a modular `.bashrc.d` pattern. This role:

1. Creates `~/.bashrc.d/` directory for modular shell configs
2. Ensures `~/.bash_profile` sources `~/.bashrc` (so login shells get the same config)
3. Ensures `.bashrc` sources all `~/.bashrc.d/*.bash` files
4. Deploys `path.bash` and `aliases.bash` into `.bashrc.d/`
5. Keeps shell startup modular and predictable across macOS and Linux

## Pattern (build order)

- **Login shells** (e.g. macOS Terminal): `~/.bash_profile` → sources `~/.bashrc` → sources `~/.bashrc.d/*.bash`
- **Interactive non-login**: `~/.bashrc` → sources `~/.bashrc.d/*.bash`
- Other roles (direnv, cursor, hub, etc.) add their own `*.bash` files into `~/.bashrc.d/`; no changes to `.bash_profile` or `.bashrc` needed
- Non-destructive: uses blockinfile so user customizations in `.bash_profile` and `.bashrc` are preserved
## Usage

Include this role early in playbooks (before other roles that deploy shell configs):

```yaml
roles:
  - common/shell_config
  - git
  - python
  - hub
```
