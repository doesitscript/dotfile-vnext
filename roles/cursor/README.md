# Cursor Editor Role

Configures Cursor editor settings, Remote-SSH connectivity, the WSL bash wrapper for Windows OpenSSH, and idempotently merges LF + UTF-8-no-BOM file settings into Cursor's settings.json.

## What This Role Does

### All Hosts (macOS, Ubuntu, Windows)
- **Merges LF + UTF-8 settings** into `settings.json` — prevents BOM and CRLF contamination in all files edited with Cursor (see [Settings](#settings) below)
- **Installs Cursor extensions** via CLI

### macOS and Ubuntu Hosts
1. **Sets EDITOR environment variable** to `cursor --wait` for use with git and other tools
2. **Deploys SSH config entries** to `~/.ssh/config.d/cursor_remote_hosts` for Cursor Remote-SSH connections

### Windows Hosts
1. **Deploys `wsl-bash-wrapper.cmd`** to `C:\ProgramData\ssh\` — routes OpenSSH sessions into the WSL login shell
2. **Configures OpenSSH DefaultShell** registry keys so SSH connections (including Cursor Remote-SSH) drop into WSL bash instead of PowerShell

---

## Settings

Cursor inherits VS Code's settings.json format. Without explicit configuration, it defaults to the OS native line ending (CRLF on Windows), which contaminates source-controlled files with mixed line endings and may inject a UTF-8 BOM.

This role idempotently merges the following settings into Cursor's `settings.json`:

```json
{
  "files.eol": "\n",
  "files.encoding": "utf8",
  "files.insertFinalNewline": true,
  "files.trimFinalNewlines": true
}
```

**Merge strategy:** existing user values always win. Only keys not already present in the file are added. No user customizations are overwritten.

Settings path is resolved automatically per platform:

| Platform | Path |
|----------|------|
| macOS | `~/Library/Application Support/Cursor/User/settings.json` |
| Linux (Ubuntu) | `~/.config/Cursor/User/settings.json` |
| Windows | `%APPDATA%\Cursor\User\settings.json` |

---

## Remote-SSH

The `anysphere.remote-ssh` extension must be installed in Cursor manually
(search "Remote SSH" in the Extensions panel — it's the Anysphere-published one).
This role handles the infrastructure side:

- **Mac controller**: SSH config entries are generated from `cursor_remote_ssh_hosts` so that
  `Cmd+Shift+P → Remote-SSH: Connect to Host` finds the target hosts automatically.
- **Windows targets**: The WSL bash wrapper and DefaultShell registry ensure that when Cursor
  connects over SSH, it lands in the WSL Linux environment (not PowerShell).

---

## Dependencies

- `common/shell_config` — sets up the `.bashrc.d` pattern (include before `cursor`)

---

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cursor_settings_enabled` | `true` | Set to `false` to skip settings.json merge for this node |
| `cursor_settings_path` | *(platform auto-detected)* | Full path to Cursor's settings.json |
| `cursor_settings_lf_utf8` | *(see defaults)* | Settings dict merged idempotently into settings.json |
| `cursor_extensions` | *(see defaults)* | List of extension IDs to install via CLI |
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

---

## Tags

| Tag | What it runs |
|-----|-------------|
| `cursor` | Everything in this role |
| `cursor_unix` | macOS + Ubuntu tasks only |
| `cursor_windows` | Windows tasks only |
| `cursor_extensions` | Extension installation only |
| `cursor_settings` | settings.json LF/UTF-8 merge only |

---

## Usage

```yaml
roles:
  - common/shell_config   # Must come first
  - cursor
```

Selective execution examples:

```bash
# Settings merge only (all development nodes)
ansible-playbook playbooks/deploy_shell_config.yaml --tags cursor_settings

# Extensions update only
ansible-playbook playbooks/deploy_shell_config.yaml --tags cursor_extensions

# Windows tasks only
ansible-playbook playbooks/deploy_shell_config.yaml --tags cursor_windows --limit server-225-win
```

---

## Files Deployed

| Target | Path | Purpose |
|--------|------|---------|
| Mac/Linux | `~/.bashrc.d/cursor.bash` | EDITOR variable and shell integration |
| Mac/Linux | `~/.ssh/config.d/cursor_remote_hosts` | Remote-SSH host definitions |
| Mac/Linux | `~/.ssh/config` | `Include config.d/*` added at top |
| Windows | `C:\ProgramData\ssh\wsl-bash-wrapper.cmd` | OpenSSH → WSL routing |
| Windows | Registry `HKLM:\SOFTWARE\OpenSSH\DefaultShell` | Points to the wrapper |
| All | `<platform settings.json path>` | LF + UTF-8-no-BOM settings (merged) |
