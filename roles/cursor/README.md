# Cursor Editor Role

Configures Cursor editor settings, Remote-SSH connectivity, and the WSL bash wrapper for Windows OpenSSH.

## What This Role Does

### All Unix Hosts (macOS, Linux, WSL)
1. **Sets EDITOR environment variable** to `cursor --wait` for use with git and other tools
2. **Deploys SSH config entries** to `~/.ssh/config.d/cursor_remote_hosts` for Cursor Remote-SSH connections

### Windows Hosts
1. **Deploys `wsl-bash-wrapper.cmd`** to `C:\ProgramData\ssh\` — routes OpenSSH sessions into the WSL login shell
2. **Configures OpenSSH DefaultShell** registry keys so SSH connections (including Cursor Remote-SSH) drop into WSL bash instead of PowerShell

## Remote-SSH

The `anysphere.remote-ssh` extension must be installed in Cursor manually
(search "Remote SSH" in the Extensions panel — it's the Anysphere-published one).
This role handles the infrastructure side:

- **Mac controller**: SSH config entries are generated from `cursor_remote_ssh_hosts` so that
  `Cmd+Shift+P → Remote-SSH: Connect to Host` finds the target hosts automatically.
- **Windows targets**: The WSL bash wrapper and DefaultShell registry ensure that when Cursor
  connects over SSH, it lands in the WSL Linux environment (not PowerShell).

## Dependencies

- `common/shell_config` — sets up the `.bashrc.d` pattern (include before `cursor`)

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cursor_wsl_distro` | `Ubuntu-24.04` | WSL distro name used in the bash wrapper |
| `cursor_wsl_wrapper_path` | `C:\ProgramData\ssh\wsl-bash-wrapper.cmd` | Where the wrapper is deployed on Windows |
| `cursor_remote_ssh_hosts` | *(see defaults)* | List of SSH Host entries for Remote-SSH config |

Each item in `cursor_remote_ssh_hosts`:

```yaml
cursor_remote_ssh_hosts:
  - name: server-225-wsl          # SSH Host alias
    hostname: DESKTOP-VLLM        # IP or hostname
    user: joshc                   # SSH user
    port: 22                      # SSH port
    identity_file: ~/.ssh/id_ed25519_ansible  # Key path
```

## Usage

```yaml
roles:
  - common/shell_config   # Must come first
  - cursor
```

## Files Deployed

| Target | Path | Purpose |
|--------|------|---------|
| Mac/Linux | `~/.ssh/config.d/cursor_remote_hosts` | Remote-SSH host definitions |
| Mac/Linux | `~/.ssh/config` | `Include config.d/*` added at top |
| Windows | `C:\ProgramData\ssh\wsl-bash-wrapper.cmd` | OpenSSH → WSL routing |
| Windows | Registry `HKLM:\SOFTWARE\OpenSSH\DefaultShell` | Points to the wrapper |
