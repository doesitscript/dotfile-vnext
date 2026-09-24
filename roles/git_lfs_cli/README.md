# git_lfs_cli

Installs and manages Git LFS on macOS through Homebrew. The role verifies the
linked executable at `/opt/homebrew/bin/git-lfs`, which is included in the
managed VS Code GUI PATH.

## State interface

```yaml
git_lfs_cli_state: present | absent
```

## Variables

```yaml
git_lfs_cli_state: present
git_lfs_cli_homebrew_formula: git-lfs
git_lfs_cli_binary_path: /opt/homebrew/bin/git-lfs
git_lfs_cli_verify: true
```