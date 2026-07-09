# troubleshooting_collectors

Artifact collectors for troubleshooting runs. Part of the repo's mirror-tree
troubleshooting design.

## Mirror Tree Design

Every broken resource in this repo has (or should have) a corresponding
collector that mirrors its structure:

```
Original playbook                        Troubleshooting mirror
─────────────────────────────────────    ────────────────────────────────────────────────────
playbooks/hyperv_ubuntu_docker_vm        playbooks/troubleshoot/collect_hyperv_ubuntu_vm_artifacts.yaml
  └─ role: hyperv_ubuntu_vm               └─ role: troubleshooting_collectors
                                               tasks_from: hyperv_ubuntu_vm.yml
```

The collector runs FIRST when something breaks. Not after guessing. Not after
re-running the broken playbook. First.

## Two Entry Points

**1. In-playbook tag** (run alongside the normal lifecycle):
```bash
ansible-playbook playbooks/hyperv_ubuntu_docker_vm.yaml \
  -i inventory/inventory.yaml \
  --tags collect_hyperv
```
The `collect_hyperv` tag uses Ansible's `never` reserved tag — it is skipped
on normal runs and only fires when explicitly requested.

**2. Dedicated collector playbook** (standalone, no lifecycle side effects):
```bash
ansible-playbook playbooks/troubleshoot/collect_hyperv_ubuntu_vm_artifacts.yaml \
  -i inventory/inventory.yaml
```
Prefer this when the broken playbook itself may not complete far enough to
reach the tagged collector task.

## Hard Gate

You may not assess a failure without running a collector first.
"I ran the collector" is not sufficient — the content of the artifact files
is the evidence.

## Evidence-Quality Floor

- a collector is only useful if it preserves real output
- preferred contents: raw stdout/stderr, event log entries as JSON, service
  status, config file contents, CLI diagnostic output
- "I ran X" with no saved output is not collector-grade evidence

Current collector task files:

- `hyperv_ubuntu_vm.yml`
- `hyperv_ubuntu_gpu_p.yml`
- `windows_remote_access.yml`
- `dev_workstation_win_gpu.yml`

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
- [collect_hyperv_ubuntu_gpu_p_artifacts.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/troubleshoot/collect_hyperv_ubuntu_gpu_p_artifacts.yaml)
- [collect_windows_remote_access_artifacts.yaml](/Users/joshc/develop/dotfile-vnext/playbooks/troubleshoot/collect_windows_remote_access_artifacts.yaml)

Current Hyper-V Ubuntu troubleshooting note:

- [hyperv-ubuntu-vm--windows--lessons-learned.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--lessons-learned.md)

Current Windows remote-access troubleshooting notes:

- [winrm--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/winrm--windows--diagnostics.md)
- [openssh--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/openssh--windows--diagnostics.md)
- [windows-remote-access--local-run.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/windows-remote-access--local-run.md)
