# troubleshooting_collectors

Optional artifact collectors for troubleshooting runs.

Purpose:

- keep mandatory troubleshooting-mode reporting in the normal role/playbook path
- provide an on-demand Ansible artifact-harvesting layer for failed or noisy
  investigations
- save artifacts under a controller-local, gitignored tree

Evidence-quality floor:

- a collector is only useful if it preserves real output
- preferred contents are raw stdout/stderr, event-log entries, service status,
  CLI diagnostics, and structured probe results
- "I ran X" with no saved output is not collector-grade evidence

Troubleshooting-mode expectation:

- after repeated failure, the agent must identify output locations for the
  failing component
- if those surfaces are not already being harvested, wiring a narrow collector
  task file or dedicated troubleshoot playbook is part of the troubleshooting
  implementation path
- for Ansible retries, prefer `-vvv` as the default verbosity floor in
  addition to component-native logs and probes

Current collector task files:

- `hyperv_ubuntu_vm.yml`
- `windows_remote_access.yml`

Collector scoping pattern:

- collectors may expose grouped evidence scopes when a component has multiple
  logical layers of evidence
- default behavior should favor collecting all relevant groups for the current
  component
- narrower runs may override the group list when the operator is targeting a
  specific layer

Current Windows remote-access artifact groups:

- `control_surfaces`
  - WinRM/sshd services, listeners, configs, standard remote-access event logs,
    and direct firewall rules
- `network_path`
  - adapters, IPv4 bindings, and recent network-related System events
- `firewall_drop_path`
  - firewall profile policy, configured firewall logs, advanced-security
    channel events, and Security drop/audit events

Default artifact root:

```yaml
troubleshooting_artifact_root: artifacts/troubleshooting
```

The legacy Multipass collector was removed after the Multipass teardown work
completed. Historical artifacts under `artifacts/troubleshooting/` remain as
background evidence, but this role no longer exposes a live Multipass-specific
collector surface.

This role is intentionally collector-oriented, not a long-term centralized
logging system.

Current dedicated playbook entrypoint:

- [collect_hyperv_ubuntu_vm_artifacts.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/troubleshoot/collect_hyperv_ubuntu_vm_artifacts.yaml)
- [collect_windows_remote_access_artifacts.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/troubleshoot/collect_windows_remote_access_artifacts.yaml)

Current Hyper-V Ubuntu troubleshooting note:

- [hyperv-ubuntu-vm--windows--lessons-learned.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--lessons-learned.md)

Current Windows remote-access troubleshooting notes:

- [winrm--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/winrm--windows--diagnostics.md)
- [openssh--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/openssh--windows--diagnostics.md)
- [windows-remote-access--local-run.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/windows-remote-access--local-run.md)
