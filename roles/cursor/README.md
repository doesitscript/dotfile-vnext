# Cursor Editor Role

Configures Cursor editor settings, Remote-SSH connectivity, project AI
agent/profile contracts, and idempotently merges LF + UTF-8-no-BOM file settings
into Cursor's settings.json.

## What This Role Does

### All Hosts (macOS, Ubuntu, Windows)
- **Merges LF + UTF-8 settings** into `settings.json` — prevents BOM and CRLF contamination in all files edited with Cursor (see [Settings](#settings) below)
- **Installs Cursor extensions** via CLI
- **Renders project AI agent/profile contracts** for Cursor and Codex-compatible clients from `inventory/group_vars/all/ai_agent_profiles.yml`

### macOS Hosts
- **Installs or upgrades Cursor IDE** via Homebrew cask `cursor`
- **Installs Cursor CLI** (`cursor-cli` cask; binary is **`cursor-agent`** at `/usr/local/bin/cursor-agent`, not `cursor-cli`) with version contract pinning and `brew pin`

### macOS and Ubuntu Hosts
1. **Sets EDITOR environment variable** to `cursor --wait` for use with git and other tools
2. **Deploys SSH config entries** to `~/.ssh/config.d/cursor_remote_hosts` for Cursor Remote-SSH connections

### Windows Hosts
- No OpenSSH or shell configuration. OpenSSH DefaultShell is owned by the **access_identity_windows** role (playbooks/access_windows.yaml). Use the access playbook to set PowerShell (or another shell) as the default.

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
- **Windows targets**: OpenSSH DefaultShell is configured by the access playbook (access_identity_windows).
  Use that role to set the default shell (e.g. PowerShell). Cursor does not modify OpenSSH.

---

## Dependencies

- `common/shell_config` — sets up the `.bashrc.d` pattern (include before `cursor`)

---

## Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `cursor_openai_extension_id` | `openai.chatgpt` | Extension ID used for the Codex/OpenAI Cursor extension |
| `cursor_openai_extension_version` | `{{ codex_tooling_version_contract.cursor_extension }}` | Optional pinned version for the Codex/OpenAI Cursor extension |
| `cursor_settings_enabled` | `true` | Set to `false` to skip settings.json merge for this node |
| `cursor_settings_path` | *(platform auto-detected)* | Full path to Cursor's settings.json |
| `cursor_settings_lf_utf8` | *(see defaults)* | Settings dict merged idempotently into settings.json |
| `cursor_extensions` | *(see defaults)* | List of extension IDs to install via CLI |
| `cursor_remote_ssh_hosts` | *(see defaults)* | List of SSH Host entries for Remote-SSH config |
| `cursor_cli_enabled` | `true` | Set to `false` to skip Cursor CLI (Homebrew `cursor-cli`) install |
| `cursor_cli_version` | `{{ codex_tooling_version_contract.cursor_cli }}` | Pinned CLI version; bump in inventory to trigger upgrade |
| `cursor_cli_cask_state` | `present` | `present` or `absent` (remove CLI) |
| `cursor_ai_agent_profiles_enabled` | `true` | Render project-scoped Cursor and Codex AI agent/profile contract files |

The default Codex/OpenAI extension entry is assembled as
`{{ cursor_openai_extension_id }}@{{ cursor_openai_extension_version }}` when a
version is provided, so the shared inventory contract can pin it without
rewriting the whole extension list.

Each item in `cursor_remote_ssh_hosts`:

```yaml
cursor_remote_ssh_hosts:
  - name: server-225-ubuntu       # SSH Host alias
    hostname: 192.168.137.10      # IP or hostname
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
| `cursor_install` | Cursor IDE Homebrew cask (macOS only) |
| `cursor_cli` | Cursor CLI Homebrew cask `cursor-cli` (macOS only) |
| `cursor_extensions` | Extension installation only |
| `cursor_settings` | settings.json LF/UTF-8 merge only |
| `cursor_ai_profiles` | Project AI agent/model-lane contract only |

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

# Cursor CLI only (mac-dev)
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml --limit mac-dev --tags cursor_cli

# AI agent/profile contract only (project-scoped Cursor + Codex files)
ansible-playbook playbooks/deploy_development_nodes.yaml -i inventory/inventory.yaml --limit mac-dev --tags cursor_ai_profiles

# Windows tasks only
ansible-playbook playbooks/deploy_shell_config.yaml --tags cursor_windows --limit hom-lab-ctl-hvh-02
```

---

## Files Deployed

| Target | Path | Purpose |
|--------|------|---------|
| Mac/Linux | `~/.bashrc.d/cursor.bash` | EDITOR variable and shell integration |
| Mac/Linux | `~/.ssh/config.d/cursor_remote_hosts` | Remote-SSH host definitions |
| Mac/Linux | `~/.ssh/config` | `Include config.d/*` added at top |
| All | `<platform settings.json path>` | LF + UTF-8-no-BOM settings (merged) |
| Project | `.cursor/ai-agent-profiles.json` | Machine-readable Cursor agent role and model-lane contract |
| Project | `.cursor/rules/framework-ai-agent-model-lanes.mdc` | Cursor rule that keeps agents on LiteLLM model lanes |
| Project | `.codex/ai-agent-profiles.json` | Machine-readable Codex-compatible copy of the same contract |
| Project | `.codex/AI_AGENT_PROFILES.md` | Human-readable Codex companion note |
