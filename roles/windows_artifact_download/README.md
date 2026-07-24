# windows_artifact_download

Reusable Windows role for large HTTP(S) artifact downloads.

Callers supply only an artifact contract (`id`, `url`, `destination`, checksum).
This role owns curl resume/retries/stall limits, optional Ansible async polling,
checksum verification, and atomic publish from `.partial` to the final path.

## Use for

- Installer binaries (e.g. `OllamaSetup.exe`)
- Driver packages, ZIPs, MSIs, firmware, standalone model files, tool archives

## Do not use for

- Application-native downloads such as `ollama pull` (manifest/layer aware)
- Package-manager installs when that is the chosen install authority

## Apply / Verify / Undo / Change class

- **Apply:** include this role with a complete `windows_artifact` contract
- **Verify:** destination exists and `win_stat` checksum matches contract
- **Undo:** remove destination / `.partial` (callers own product uninstall)
- **Change class:** idempotent config (safe re-run; resumes partials)

## Example caller (any large download)

```yaml
- name: Download pinned upstream installer
  ansible.builtin.include_role:
    name: windows_artifact_download
  vars:
    windows_artifact:
      id: "example-tool-1.2.3"
      url: "https://example.com/tool-1.2.3.exe"
      destination: 'C:\ProgramData\Ansible\artifacts\tool-1.2.3.exe'
      checksum:
        algorithm: sha256
        value: "abc123..."
```

The product role then installs/configures the published file
(`win_package`, extract, etc.). Keep download and install responsibilities separate.
