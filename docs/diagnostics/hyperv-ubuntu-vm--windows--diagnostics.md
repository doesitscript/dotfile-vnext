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
- filesystem attribute probes (`fsutil`, `compact`, `cipher`) because Hyper-V
  can still reject a disk that looks fixed in `Get-VHD`
- `Get-VMNetworkAdapter -VMName <vm> | Select-Object MacAddress, IPAddresses`
- `(Get-VM -VMName <vm>).VMIntegrationService` to inspect
  `Key-Value Pair Exchange` state when `IPAddresses` output looks wrong
- controller-side Azure datasource seed input:
  `ovf-env.xml` on a UDF-capable attached seed image

## Notes

- Current routed-subnet install shape:
  - Windows host gateway side:
    - `vEthernet (Guest)` on `192.168.137.1/24`
  - guest target address:
    - `192.168.137.10/24`
  - guest default gateway:
    - `192.168.137.1`
  - controller route:
    - `192.168.137.0/24` via `192.168.50.158`
- Current verification commands:
  - Windows host:
    - `Get-VM -Name server-225-ubuntu | Select-Object Name,State,Status,Uptime`
    - `Get-VMDvdDrive -VMName server-225-ubuntu`
    - `Test-Connection 192.168.137.10 -Count 1`
    - `Test-NetConnection -ComputerName 192.168.137.10 -Port 22`
    - `Get-NetNeighbor -IPAddress 192.168.137.10`
  - Mac/controller:
    - `route -n get 192.168.137.10`
    - `nc -vz -G 2 192.168.137.10 22`
    - `ssh -i ~/.ssh/id_ed25519_ansible -o IdentitiesOnly=yes ubuntu@192.168.137.10`
  - guest console:
    - `ip -br addr`
    - `ip route`
    - `systemctl is-active ssh`
    - `ss -ltnp | grep ':22'`
    - `sudo netplan get`
    - `networkctl status eth0`
    - `sudo journalctl -u systemd-networkd -b --no-pager | tail -n 200`
- Current interpretation rule:
  - do not treat the VMConnect tty screen as authoritative proof of failure by
    itself once the guest is installed
  - if the Windows host can ping `192.168.137.10` and `22/tcp` is open, the
    guest is alive even if VMConnect still shows old Subiquity/log output
  - the static-network change only affects the installed guest network config;
    it does not change getty/login behavior directly
- A converted Ubuntu cloud-image `.vhdx` can report `VhdType=Fixed` and still
  be rejected by Hyper-V with:
  `Virtual hard disk files must be uncompressed and unencrypted and must not be sparse`
- File-level attribute evidence matters as much as Hyper-V module output for
  this failure class.
- `Get-VMNetworkAdapter ... IPAddresses` is an integration-services/KVP-driven
  surface, not authoritative network truth by itself. Microsoft documents that
  this path depends on `Key-Value Pair Exchange` and guest-side `NetTCPIP` WMI
  support. Treat it as advisory and verify candidate addresses before
  publishing them.
- Host-side neighbor-table correlation by guest MAC is a stronger second source
  for the actual guest IPv4 on the local network than KVP-reported `IPAddresses`
  alone.
- Current pinned contradiction for `server-225-ubuntu`:
  - `Get-VHD` reports `VhdType=Fixed`
  - `fsutil sparse queryflag` reports `This file is set as sparse`
  - `compact /q` reports the file is compressed
  - `Get-Item` reports `Attributes = Archive, SparseFile, NotContentIndexed`
- Current guest-IP stabilization rule:
  - do not trust a Hyper-V-reported guest IP if it matches `host_ip` or
    `host_ipv6`
  - prefer a host-side `Get-NetNeighbor` match by guest MAC when available
  - record the guest adapter MAC and the full reported IP list for later
    analysis
  - verify the chosen address with a real network readiness probe before
    publishing it as `ansible_host`
- Azure VHD images should be treated as Azure-datasource guests, not as
  generic NoCloud guests:
  - Canonical documents that the Azure datasource expects an attached UDF CD
    containing `ovf-env.xml`
  - user-data should be delivered through that Azure datasource path instead of
    a NoCloud `CIDATA` seed ISO
  - when `Key-Value Pair Exchange` reports a protocol mismatch, treat
    `Get-VMNetworkAdapter ... IPAddresses` as especially untrustworthy
- Current first-boot SSH rule:
  - default to a minimal cloud-init payload that reuses the image's built-in
    OpenSSH/Python baseline
  - do not front-load package installation or forced DHCP churn until baseline
    SSH is proven
  - if SSH still fails, prefer guest/cloud-init evidence over adding more
    bootstrap steps blindly
- TODO:
  - explicitly test `Set-VMFirmware -VMName "server-225-ubuntu" -EnableSecureBoot Off`
    as a bounded follow-up even though the current VM does boot and receives a
    guest IP
  - rationale:
    - Generation 2 VMs enable Secure Boot by default
    - this repo currently keeps Secure Boot enabled with the
      `MicrosoftUEFICertificateAuthority` template
    - if guest console evidence suggests a kernel/init or early userspace
      problem rather than pure SSH bootstrap failure, Secure Boot should be
      re-tested before piling on more guest bootstrap changes
- On Wi-Fi-backed Windows hosts, a Hyper-V guest attached directly to an
  External switch is a weak DHCP path:
  - prefer an Internal switch for the guest
  - share the public Wi-Fi adapter to that Internal switch with ICS
  - keep using the External switch only for host-side consumers that still
    need it
- In that ICS/Internal-switch topology:
  - a guest IP like `192.168.137.63` is expected guest-network evidence
  - the Windows host should be able to reach that address directly
  - the Mac/controller should not be assumed to reach that private address
    directly without a separate access strategy
- Current routed-subnet evidence split that must be kept in mind:
  - the Windows host did reach/ping guest-private-subnet addresses during the
    Hyper-V Ubuntu experiments
  - the Mac/controller route is now validated toward `192.168.137.10`
  - the Mac/controller also proved `22/tcp` reachability to `192.168.137.10`
  - the remaining blocker after that milestone is SSH authentication, not
    guest-network reachability
- Current image/bootstrap pivot:
  - repeated Azure-image boots reached `cloud-init`, but the guest continued to
    fall back to Azure datasource / IMDS behavior instead of consuming local
    provisioning media as intended
  - do not keep rerunning that path blindly
  - Quick Create follow-up evidence:
    - the Canonical Hyper-V Quick Create image booted successfully into the
      Ubuntu desktop first-run configuration UI inside VMConnect
    - that proved Hyper-V-native bootability and usable console visibility
    - it also proved the image is a desktop/OOBE target, not a good unattended
      server bootstrap target for `server-225-ubuntu`
  - next image target:
    - official Ubuntu Server ISO on Hyper-V as the cleaner server-aligned
      installer path
    - keep autoinstall as the explicit follow-up, not as implied behavior
- first server-ISO installer milestone:
  - the ISO downloaded and verified successfully on `HOM-LAB-HVH-02`
  - the VM was recreated cleanly with the ISO attached as the DVD boot media
  - Hyper-V reported the VM `Operating normally` on switch `Guest`
  - no guest IP or SSH publication was attempted in this mode; this is an
    installer checkpoint, not a false claim of guest readiness
  - follow-up autoinstall milestone:
    - a second `cidata` seed ISO is now attached alongside the installer ISO
    - that means the installer media and the intended autoinstall config are
      both present on the VM
    - if the console still lands in the normal server installer welcome flow,
      the remaining missing piece is the bootloader/autoinstall handoff rather
      than missing seed media
- Residual operational note for roaming hosts:
  - moving the Windows host between networks may occasionally require adapter
    renewal or reset before the host and ICS path settle again
  - current soft-recovery commands:
    - `Clear-DnsClientCache`
    - `ipconfig /flushdns`
    - `ipconfig /release`
    - `ipconfig /renew`
- Interactive execution lessons and the failed `block_state_zero=off`
  experiment are captured in:
  [hyperv-ubuntu-vm--windows--lessons-learned.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--lessons-learned.md)
- Full layout note:
  [hyperv-network-layout--windows--wifi-ics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--wifi-ics.md)
- Current routed access-layer note:
  [hyperv-network-layout--windows--routed-private-subnet.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-network-layout--windows--routed-private-subnet.md)
