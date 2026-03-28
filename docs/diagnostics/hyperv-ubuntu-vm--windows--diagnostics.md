# Hyper-V Ubuntu VM Windows Diagnostic Sources

## Logging Locations

- Event Viewer -> `Applications and Services Logs/Microsoft/Windows/Hyper-V-VMMS/Admin`
- Event Viewer -> `Applications and Services Logs/Microsoft/Windows/Hyper-V-Worker/Admin`
- Hyper-V VM configuration and attached artifact directory under:
  `C:\ProgramData\Ansible\hyperv_ubuntu_vm\<vm-name>\`
- Boot disk path for the current server-225 replacement:
  `C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu.vhdx`
- Controller-side play and evidence wiring:
  `/Users/joshc/develop/dotfile-vnext/roles/hyperv_ubuntu_vm/tasks/present.yml`
- Controller-side durable evidence artifact:
  `/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/evidence--hyperv-live-runs.md`

## Diagnostic Commands

- `Get-VM -Name <vm>`
- `Get-VMHardDiskDrive -VMName <vm>`
- `Get-VMDvdDrive -VMName <vm>`
- `Get-VMFirmware -VMName <vm>`
- `Get-VHD -Path <vhdx>`
- `fsutil sparse queryflag <vhdx>`
- `compact /q <vhdx>`
- `cipher /c <vhdx>`
- `Get-Item <vhdx> | Select-Object FullName, Length, Attributes`
- `qemu-img info <vhdx>`
- `Get-VMNetworkAdapter -VMName <vm> | Select-Object SwitchName, IPAddresses`

## Event / Channel Sources

- `Microsoft-Windows-Hyper-V-VMMS/Admin`
- `Microsoft-Windows-Hyper-V-Worker/Admin`

These channels are the first place to look when Hyper-V accepts VM creation but
rejects the boot disk or fails the VM start path.

## Vendor / Tooling Diagnostics

- Hyper-V cmdlet output from `Start-VM`, `Get-VHD`, and `Get-VMHardDiskDrive`
- `qemu-img info` on the resulting `.vhdx`
- filesystem attribute probes (`fsutil`, `compact`, `cipher`) because Hyper-V
  can still reject a disk that looks fixed in `Get-VHD`

## Notes

- A converted Ubuntu cloud-image `.vhdx` can report `VhdType=Fixed` and still
  be rejected by Hyper-V with:
  `Virtual hard disk files must be uncompressed and unencrypted and must not be sparse`
- File-level attribute evidence matters as much as Hyper-V module output for
  this failure class.
- Current pinned contradiction for `server-225-ubuntu`:
  - `Get-VHD` reports `VhdType=Fixed`
  - `fsutil sparse queryflag` reports `This file is set as sparse`
  - `compact /q` reports the file is compressed
  - `Get-Item` reports `Attributes = Archive, SparseFile, NotContentIndexed`
- Interactive execution lessons and the failed `block_state_zero=off`
  experiment are captured in:
  [hyperv-ubuntu-vm--windows--lessons-learned.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--lessons-learned.md)
