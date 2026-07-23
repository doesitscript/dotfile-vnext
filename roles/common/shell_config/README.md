# Shell Configuration Role

Manages bash startup using a modular `.bashrc.d` pattern. This role:

1. Creates `~/.bashrc.d/` directory for modular shell configs
2. Optionally manages the user's login shell on macOS
3. Ensures `~/.bash_profile` sources `~/.bashrc` (so login shells get the same config)
4. Ensures `.bashrc` sources all `~/.bashrc.d/*.bash` files
5. Deploys `path.bash` and `aliases.bash` into `.bashrc.d/`
6. Keeps shell startup modular and predictable across macOS and Linux

## Pattern (build order)

- **Login shells** (e.g. macOS Terminal): `~/.bash_profile` → sources `~/.bashrc` → sources `~/.bashrc.d/*.bash`
- **Interactive non-login**: `~/.bashrc` → sources `~/.bashrc.d/*.bash`
- Other roles (direnv, cursor, hub, etc.) add their own `*.bash` files into `~/.bashrc.d/`; no changes to `.bash_profile` or `.bashrc` needed
- Non-destructive: uses blockinfile so user customizations in `.bash_profile` and `.bashrc` are preserved

## Login shell management

When `shell_config_manage_login_shell: true` on macOS, the role:

- verifies the desired shell binary exists
- ensures the desired path is present in `/etc/shells`
- sets the current user's login shell to `shell_config_login_shell_path`

Useful variables:

- `shell_config_manage_login_shell`
- `shell_config_login_shell_path`
## Usage

Include this role early in playbooks (before other roles that deploy shell configs):

```yaml
roles:
  - common/shell_config
  - git
  - python
  - hub
```
