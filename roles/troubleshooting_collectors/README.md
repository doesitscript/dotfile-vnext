# troubleshooting_collectors

Optional artifact collectors for troubleshooting runs.

Purpose:

- keep mandatory troubleshooting-mode reporting in the normal role/playbook path
- provide an on-demand Ansible artifact-harvesting layer for failed or noisy
  investigations
- save artifacts under a controller-local, gitignored tree

Current collector task files:

- `multipass_windows.yml`

Default artifact root:

```yaml
troubleshooting_artifact_root: artifacts/troubleshooting
```

Current Multipass collector layout:

```text
artifacts/troubleshooting/
  multipass_bridge_failure/
    <host>/
      <timestamp>/
        event_logs/
        installer_logs/
        app_logs/
        probes/
```

Surface tags:

- `multipass_event_logs`
  - harvested Windows Event Viewer entries for `Multipass|Hyper-V|vmcompute|hns`
- `multipass_probe_bundle`
  - saved CLI + host probe bundle such as `multipass networks`, `Get-VMSwitch`,
    `Get-NetAdapter`, WinRM state, and `bcdedit`
- `multipass_host_probes`
  - alias tag for the host-facing subset of the probe bundle
- `multipass_installer_logs`
  - `%TEMP%` installer/MSI logs when present
- `multipass_gui_logs`
  - `%APPDATA%\\com.canonical\\Multipass GUI\\multipass_gui.log` when present
- `vmcompute_event_logs`
  - provider-focused `vmcompute` event entries saved separately
- `hns_event_logs`
  - provider-focused `hns` event entries saved separately

These tags are the collector-side mapping between:

- playbook/role resource
- output surface
- saved artifact location

If a surface is checked and absent, that should be reported as collected
absence, not as an unexamined missing surface.

This role is intentionally collector-oriented, not a long-term centralized
logging system.
