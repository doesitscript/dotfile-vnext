# Multipass Windows Diagnostic Sources

Historical note:

- Multipass is no longer the active implementation direction for
  `server-225-ubuntu`
- keep this file only as historical troubleshooting context for old evidence or
  teardown work

## Logging Locations

- Event Viewer -> `Windows Logs/Application` filtered by source `Multipass`
- installer logs under `%TEMP%` such as `MSI*.LOG`
- GUI log:
  `%APPDATA%\com.canonical\Multipass GUI\multipass_gui.log`

## Diagnostic Commands

- `multipass version`
- `multipass -vvv version`
- `multipass networks`
- `multipass -vvv networks`
- `Get-CimInstance Win32_ComputerSystem | Select-Object -ExpandProperty HypervisorPresent`
- `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V`
- `Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Hypervisor`
- `Get-WindowsFeature Hyper-V`
- `Get-VMSwitch`
- `Get-NetAdapter`
- `bcdedit /enum {current}`

## Event / Channel Sources

- Windows Event Viewer provider/source `Multipass`
- On this host, provider-based event queries were more useful than
  `Get-WinEvent -ListLog *Multipass*`, which returned no dedicated log channel

## Vendor / Tooling Diagnostics

- Multipass daemon verbosity can be increased by updating the Windows service
  `ImagePath` to include `--verbosity debug`
- `multipass -vvv networks` is the most useful first CLI probe on this host
  because it shows the Hyper-V health-check commands Multipass is running

## Notes

- Multipass on Windows installs itself via MSI but is not documented as enabling
  Hyper-V or repairing Windows virtualization prerequisites for you
- The current host has shown a failure mode where:
  - `HypervisorPresent` is `True`
  - `hypervisorlaunchtype` is `Auto`
  - Hyper-V features report enabled
  - but `multipass networks` still fails with
    `The Hyper-V Hypervisor is disabled`
- On this host, `Get-NetAdapter` has also shown lingering bridge/multiplexor
  artifacts while `Get-VMSwitch` returned no visible Hyper-V switch
