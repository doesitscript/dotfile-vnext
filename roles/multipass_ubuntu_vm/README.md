# multipass_ubuntu_vm

Stateful role for a Multipass-backed Ubuntu VM on a Windows Hyper-V host.

## Status

Archived legacy reference. No longer wired into active playbooks.

The repo has abandoned Multipass as the target provisioning mechanism for
`server-225-ubuntu` and is moving to a Hyper-V-native Ubuntu VM built from an
Ubuntu cloud image. The legacy teardown has been completed and the active
Multipass playbook surfaces have been removed. This role is retained
temporarily only as a reference source while the Hyper-V-native replacement is
implemented.

## Purpose

- keep the public interface lifecycle-based: `present|absent`
- use cloud-init for Day-0 SSH bootstrap
- publish the guest as a real SSH target in inventory/controller config
- translate useful Linux bootstrap ideas from the older WSL path without
  carrying WSL-specific mechanics forward

Current practical use:

- reference the old lifecycle and cloud-init pattern during Hyper-V-native role
  implementation
- preserve the teardown logic that was used to retire the old capability

Tracked in GitHub issue [#4](https://github.com/doesitscript/dotfile-vnext/issues/4).

## Why this does not use the Ansible Multipass collection directly

The repo intake pointed at the `theko2fi.multipass` collection, and it is a
useful reference for the desired state model. But this implementation targets a
Windows Hyper-V host over WinRM, and the collection is not a clean fit for that
host surface. It also does not cover the bridged-network lifecycle we need.

So this role keeps the same high-level capability shape, but implements it
through `ansible.windows.win_powershell` with real Multipass state probes.

## Windows install path

The role installs Multipass on Windows from the official GitHub release MSI,
not the Chocolatey wrapper package. That is intentional: the Chocolatey package
currently hard-fails on Windows Server 2025 with an outdated Hyper-V OS check.

The VM lifecycle remains the public capability owned by this role. Installing
Multipass itself is treated as a supporting bootstrap dependency for that
capability, not as a separate user-facing lifecycle surface.

Official Multipass expectations on Windows are narrower than our host target:

- Canonical documents Windows support around Windows 10 Pro/Enterprise with
  either Hyper-V or VirtualBox available
- the Multipass MSI is an Administrator install step, but the docs do not say
  that Multipass enables Hyper-V, VirtualBox, or Windows optional features for
  you
- for Hyper-V on Windows, Multipass expects the host virtualization stack and
  networking model to already be in a usable state

In this repo, that means:

- this role installs and drives Multipass itself
- Hyper-V feature enablement remains a separate host prerequisite
- if Windows host virtualization or networking is broken, this role should
  surface that with diagnostics instead of guessing past it

## Logging and diagnostics

For Windows troubleshooting, the first places to check are:

- Event Viewer -> `Windows Logs/Application` filtered by source `Multipass`
- installer logs under `%TEMP%` such as `MSI*.LOG`
- Multipass GUI log:
  `%APPDATA%\com.canonical\Multipass GUI\multipass_gui.log`
- CLI health probes:
  - `multipass -vvv version`
  - `multipass -vvv networks`
- Host networking probes:
  - `Get-VMSwitch`
  - `Get-NetAdapter`
  - `Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty HypervisorPresent`
  - `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor`
  - `Get-WindowsFeature Hyper-V`

The role emits these diagnostic hints during execution and, when bridged
readiness is blocked, it also reports the current Hyper-V feature state,
Hyper-V switch state, adapter state, Multipass network probe output, and recent
Multipass event-log entries.

Repo-stored diagnostic reference:

- [docs/diagnostics/multipass--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/multipass--windows--diagnostics.md)

Important Windows nuance:

- for the daemon/service side, the official Multipass logging surface on
  Windows is Event Viewer, not a dedicated text log file
- if deeper service logging is needed, Multipass documents increasing daemon
  verbosity via the Windows service `ImagePath`

## What Multipass is actually checking on this host

The recent Multipass Windows event entries are useful because they show the
health checks Multipass is running before `multipass networks` fails.

So far, the event log shows Multipass invoking PowerShell feature probes such
as:

- `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V`
- `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor`

That is separate from the host-level hypervisor presence probe:

- `Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty HypervisorPresent`

So when the event log says Multipass is checking
`Microsoft-Hyper-V-Hypervisor`, it is referring to a PowerShell
`Get-WindowsOptionalFeature` probe, not a CIM query.

## What `The Hyper-V Hypervisor is disabled` means here

Treat that message as a Multipass backend failure string, not as proof of one
missing Windows feature.

The reason this role does not reduce it to "enable one more feature" is that
our host evidence has already shown cases where:

- `HypervisorPresent` is `true`
- `hypervisorlaunchtype` is `auto`
- Hyper-V optional/server features report enabled
- but `multipass networks` still fails

Canonical's own guidance for Windows Server is important here: Multipass on
Windows Server is not currently supported in the same way as Windows 10 because
the Windows Server Hyper-V networking surface does not provide the Windows 10
`Default Switch` Multipass expects.

So in this repo, the correct behavior is:

- keep collecting actual host evidence
- avoid assuming the failure string means one specific toggle is missing
- treat unsupported or conflicting host networking as a first-class possibility

## Lifecycle contract

Primary control point:

```yaml
multipass_ubuntu_vm_state: present | absent
```

The role treats the VM as one capability:

- `present` means the Multipass instance exists, is running, has Day-0 SSH
  bootstrap applied, and is published as an SSH target
- `absent` means the instance is deleted/purged and the role-owned metadata is
  removed

## Troubleshooting controls

This role is the first pilot for the repo troubleshooting-mode pattern.

Standard variables:

```yaml
ansible_troubleshooting_mode: false
debug_remote_output: false
debug_collect_component_evidence: false
```

Useful tags:

- `evidence`
- `debug_resources`
- `multipass_troubleshooting`
- `collect_troubleshooting`

Evidence ownership:

- `evidence`, `debug_resources`
  - live role-owned evidence emitted during apply/retry
- `multipass_troubleshooting`, `collect_troubleshooting`
  - saved artifact collection via `troubleshooting_collectors`
- collector surface tags:
  - `multipass_event_logs`
  - `multipass_probe_bundle`
  - `multipass_host_probes`
  - `multipass_installer_logs`
  - `multipass_gui_logs`

When troubleshooting mode or debug evidence collection is enabled, the role
will emit:

- Multipass network probe output
- a troubleshooting report with identified, collected, and missing evidence
  surfaces
- the full structured diagnostics block for the current failure

Optional artifact collection used to be available through the retired
Multipass-specific collector/playbook path. The collector entrypoint has now
been removed, but the historical artifacts remain under:

- `artifacts/troubleshooting/multipass_bridge_failure/<host>/<timestamp>/`

The artifact collector is support work only. It does not replace the
mandatory troubleshooting-mode report.

## Bootstrap vs reconcile

This role is explicit about immutable-ish inputs:

- cloud-init is treated as bootstrap-only
- bridge adapter changes are treated as recreate-worthy changes

The role stores a small metadata file on the Windows host so it can detect:

- cloud-init drift
- bridge adapter drift

If either changes on an existing VM, the role fails with guidance to recreate
the instance intentionally instead of pretending that Day-0 input can be fully
reconciled in place.

## What was translated from the old WSL path

WSL deprecation and safe removal tracked in GitHub issue [#7](https://github.com/doesitscript/dotfile-vnext/issues/7).

Useful pieces translated forward:

- controller SSH key bootstrap from the execution node
- Day-0 cloud-init file generation
- direct SSH publication back into inventory/controller config
- bridged-network prerequisite checks

Useful WSL logic that does **not** carry forward:

- `.wslconfig`
- `wsl.exe` install/reset logic
- `netsh portproxy`
- WSL keepalive behavior
- default-user/root tricks that are specific to WSL

For Multipass guests, the default `ubuntu` user is kept as the SSH/bootstrap
user. That is intentional and simpler for first-pass Multipass compatibility.

For bridged networking on Windows, keep the two layers separate:

- choose the physical adapter in `hyperv_config.adapter_name`
- let the Multipass bridge target follow `hyperv_config.switch_name`

That means the physical intent can stay something like `Wi-Fi`, while
Multipass itself receives the Hyper-V-visible network name such as `External`.
In normal repo use, `multipass_ubuntu_vm_bridge_adapter_name` should not need a
host override unless you intentionally want a different Multipass-visible switch
name than the one created by `hyperv_networking`.

## Research bookmark

This role intentionally preserves the key Windows Multipass research outcome so
future work does not have to rediscover it from scratch:

- official install: Administrator MSI, with Hyper-V or VirtualBox already
  usable on the host
- official Windows logging: Event Viewer `Multipass` source, installer logs in
  `%TEMP%`, GUI log in `%APPDATA%`
- current host blocker to watch closely: `multipass networks` can still report
  `The Hyper-V Hypervisor is disabled` even when Windows feature probes look
  healthy, which points to host compatibility/networking issues rather than a
  simple missing feature flag

## Example

There is no active example command anymore because the Multipass playbook
surfaces were retired after teardown. Keep this role as reference material
only while the Hyper-V-native replacement is implemented.
