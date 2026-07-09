---
deprecated: true
deprecating_reason: WSL scope reform 2026-05-28 — server paths must not use WSL
coordinator_review: pending
---

# Hyper-V Ubuntu VM Windows Lessons Learned

## Purpose

This note captures execution lessons from repeated `server-225-ubuntu` boot-disk
failures on `HOM-LAB-HVH-02` so future troubleshooting starts with the proven
evidence path instead of repeating weak retries.

## Evidence means collected output, not execution narration

For this troubleshooting class, evidence should mean:

- actual command output
- actual event or log output
- saved artifact contents
- source-backed findings

It should not mean:

- what we are about to try next
- a summary of intent
- speculation without concrete output

This mattered in the Hyper-V investigation because the useful turning points
came from exact probes such as `fsutil`, `compact`, `Get-Item`, `Get-VHD`,
`Start-VM`, and Windows log/event output, not from restating the plan.

## Use an interactive Windows SSH session for conversion experiments

When the question is "what exactly did the Windows host create?" prefer an
interactive OpenSSH session to the Windows host over a delayed batch of remote
commands.

Current working entrypoint:

```text
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no joshc@DESKTOP-VLLM -p 22
```

Why:

- it exposes the actual Windows PowerShell output as each step runs
- it makes it easier to test one conversion change at a time
- it avoids hiding the tool path or quoting differences behind an Ansible task
- it is the fastest way to confirm whether a newly generated VHDX is already bad
  before Hyper-V sees it

## Do not trust the conversion step without immediate probes

For this failure class, the VHDX must be probed immediately after conversion and
before `New-VM` or `Start-VM`.

Minimum probe set:

```powershell
fsutil sparse queryflag "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\<file>.vhdx"
compact "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\<file>.vhdx"
Get-Item "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\<file>.vhdx" |
  Format-List FullName,Attributes,Length,LastWriteTime
Get-VHD -Path "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\<file>.vhdx" |
  Format-List Path,VhdType,Size,FileSize
& "C:\Program Files\qemu\qemu-img.exe" info "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\<file>.vhdx"
```

Interpretation rule:

- `Get-VHD VhdType=Fixed` is not sufficient
- if `fsutil` says sparse, `compact` says compressed, or `Get-Item` shows
  `SparseFile`, the artifact is still not Hyper-V-safe

## Parent directory checks still matter, but they were not the blocker here

Check the parent directory too:

```powershell
compact "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu"
Get-Item "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu" |
  Format-List FullName,Attributes
```

Pinned result for this incident:

- the parent directory was not configured to compress new files
- the generated VHDX itself still came out sparse/compressed

That means parent-folder inheritance was worth testing, but it was not the root
cause in this case.

## Exact QEMU path matters in interactive troubleshooting

`qemu-img` was not on the Windows SSH session PATH.

Pinned working path:

```text
C:\Program Files\qemu\qemu-img.exe
```

If a future interactive run cannot find `qemu-img`, locate the real binary first
instead of assuming the Ansible PATH matches the SSH PATH.

## Experimental result: block_state_zero=off did not fix the artifact

Interactive test run on 2026-03-27:

```powershell
& "C:\Program Files\qemu\qemu-img.exe" convert -O vhdx `
  -o subformat=fixed,block_state_zero=off,size=40G `
  "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\noble-server-cloudimg-amd64.img" `
  "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu-bszoff.vhdx"
```

Observed result:

- `fsutil sparse queryflag` still reported `This file is set as sparse`
- `compact` still reported the file as compressed
- `Get-Item` still reported `Attributes : Archive, SparseFile, NotContentIndexed`
- `Get-VHD` still reported `VhdType : Fixed`
- `qemu-img info` still reported a `virtual size` of about `3.5 GiB` despite
  `size=40G`

Conclusion:

- `block_state_zero=off` did not fix the Hyper-V incompatibility
- the current QEMU-on-Windows conversion path remains the first thing to distrust

## Do not layer more workarounds onto the disproven QEMU path

Once the raw `.img -> qemu-img -> vhdx` path had already been disproven by
repeated artifact probes, the right move was replacement, not another tuning
layer on the same branch.

That means:

- do not keep adding conversion flags as the primary response
- do not normalize the bad path into looking acceptable
- move to a more native upstream artifact or host-native conversion path

Pinned replacement result:

- Canonical Azure VHD plus source normalization plus native `Convert-VHD`
  produced the first viable Hyper-V boot path

Broader framework lesson:

- see
  [deprecated-or-disproven-paths-must-be-replaced-not-extended.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/codex/deprecated-or-disproven-paths-must-be-replaced-not-extended.md)
  for the durable rule and the matching WSL `bash.exe -> wsl.exe` example

## Package-based converter experiments on Windows

Two interactive package-discovery paths were tested on `HOM-LAB-HVH-02`.

### Winget / Microsoft Store result

Interactive search:

```powershell
winget search "VM Image Converter"
```

Observed result:

- `winget` found `VM Image Converter` as Store ID `9MZ556R4BSF8`
- installation attempt failed in the SSH session with:
  `0x80070520 : A specified logon session does not exist`

Conclusion:

- the Store-backed path exists
- but it is not reliable from the current OpenSSH/PowerShell session shape

### Chocolatey / MVMC result

Interactive search:

```powershell
choco search "Microsoft Virtual Machine Converter"
```

Observed result:

- Chocolatey found `virtualmachineconverter 3.1.0.20180613`
- installation succeeded
- the install dropped:
  - `C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.psd1`
  - `C:\Program Files\Microsoft Virtual Machine Converter\MvmcCmdlet.dll`

Imported command surface:

- `ConvertTo-MvmcAzureVirtualHardDisk`
- `ConvertTo-MvmcP2V`
- `ConvertTo-MvmcP2VVirtualHardDisk`
- `ConvertTo-MvmcVirtualHardDisk`
- `ConvertTo-MvmcVirtualHardDiskOvf`
- plus related source/snapshot/connection helpers

Promising direct cmdlet:

```powershell
ConvertTo-MvmcVirtualHardDisk -SourceLiteralPath <path> -DestinationLiteralPath <path> -VhdType FixedHardDisk -VhdFormat Vhdx
```

Direct test against the Ubuntu cloud image:

```powershell
ConvertTo-MvmcVirtualHardDisk `
  -SourceLiteralPath "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\noble-server-cloudimg-amd64.img" `
  -DestinationLiteralPath "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu-mvmc.vhdx" `
  -VhdType FixedHardDisk `
  -VhdFormat Vhdx
```

Observed result:

- failed immediately with:
  `No suitable drive was found at path (...) noble-server-cloudimg-amd64.img`

Conclusion:

## Wi-Fi-backed External switching is a weak guest DHCP path

Repeated field reports and the current incident both point to the same shape:

- Windows host is uplinked through Wi-Fi
- Hyper-V guest is attached to an External switch
- Linux guest DHCP/IP behavior becomes unreliable or misleading

Pinned direction for this repo:

- keep the External switch available for existing host consumers when needed
- stop treating it as the preferred guest path on Wi-Fi-backed hosts
- create a dedicated Internal switch for the guest
- enable ICS from the public Wi-Fi adapter to the Internal switch adapter
- attach the Hyper-V Ubuntu guest to that Internal switch

Important host-specific nuance discovered on `HOM-LAB-HVH-02`:

- once the External Hyper-V switch already owned the active public network
  profile, the working ICS public connection was `vEthernet (External)`, not
  the raw `Wi-Fi` connection name
- attempting `Set-Ics -PublicConnectionName 'Wi-Fi' -PrivateConnectionName 'vEthernet (Guest)'`
  failed with COM `0x8000FFFF`
- `Set-Ics -PublicConnectionName 'vEthernet (External)' -PrivateConnectionName 'vEthernet (Guest)'`
  succeeded

Reference write-up that matched the observed behavior well:

- https://www.hurryupandwait.io/blog/running-an-ubuntu-guest-on-hyper-v-assigned-an-ip-via-dhcp-over-a-wifi-connection

Implementation note:

- the repo now treats Internal switch + ICS as the preferred Hyper-V Ubuntu
  path on `HOM-LAB-HVH-02`

- MVMC exposes real VHD/VHDX conversion cmdlets
- but this direct `.img -> .vhdx` path did not accept the Ubuntu cloud image as
  a valid source
- so MVMC is not a drop-in fix for the current artifact path

Cleanup result:

- the one-time `virtualmachineconverter` Chocolatey install was uninstalled
- `C:\Program Files\Microsoft Virtual Machine Converter` no longer exists after cleanup

## Alternative-resource result: Canonical Azure VHD was viable after source normalization

The first replacement-resource path that produced a Hyper-V-safe boot disk was
Canonical's published Azure VHD tarball for Ubuntu 24.04.

## Azure images should use the Azure datasource path, not NoCloud

Once the role pivoted to Canonical's Azure VHD image, continuing to feed the
guest with a NoCloud `CIDATA` seed became a design mismatch.

Pinned evidence from the live Hyper-V run:

- `Heartbeat` integration service reported `OK`
- `Key-Value Pair Exchange` reported `Enabled`
- `Key-Value Pair Exchange` also reported:
  `The protocol version of the component installed in the virtual machine does not match the version expected by the hosting system`
- `Get-VMNetworkAdapter ... IPAddresses` kept reporting the Windows host IPv4
  (`192.168.50.158`) as if it were the guest address
- host-side `Get-NetNeighbor` had no IPv4 entry for the guest MAC

Source-backed correction:

- Canonical/cloud-init documents that the Azure datasource expects an attached
  CD formatted in UDF containing `ovf-env.xml`
- user-data for Azure images should be delivered inside that Azure datasource
  path via `CustomData` or `UserData`

Conclusion:

- once the boot artifact is an Azure image, the controller seed path should be
  Azure-style `ovf-env.xml` on a UDF seed image
- treating the Azure image like a generic NoCloud guest is likely to produce
  misleading behavior and weaker first-boot control

Interactive retrieval and extraction:

```powershell
Invoke-WebRequest -UseBasicParsing `
  -Uri "https://cloud-images.ubuntu.com/releases/server/24.04/release/ubuntu-24.04-server-cloudimg-amd64-azure.vhd.tar.gz" `
  -OutFile "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\ubuntu-24.04-server-cloudimg-amd64-azure.vhd.tar.gz"

tar -xzf C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\ubuntu-24.04-server-cloudimg-amd64-azure.vhd.tar.gz -C C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu
```

Extracted source artifact:

```text
C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\livecd.ubuntu-cpc.azure.vhd
```

Pinned source findings before normalization:

- `Get-VHD` reported a fixed VHD
- `fsutil sparse queryflag` reported `This file is set as sparse`
- `compact` reported the file as compressed
- `Get-Item` reported `Attributes : Archive, SparseFile, NotContentIndexed`
- Hyper-V `Convert-VHD` refused to convert it while it was still sparse/compressed

What worked:

```powershell
fsutil sparse setflag "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\livecd.ubuntu-cpc.azure.vhd" 0

compact /u /f "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\livecd.ubuntu-cpc.azure.vhd"

Convert-VHD `
  -Path "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\livecd.ubuntu-cpc.azure.vhd" `
  -DestinationPath "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu-azure.vhdx" `
  -VHDType Fixed
```

Pinned probe results on the converted VHDX:

- `fsutil sparse queryflag` -> `This file is NOT set as sparse`
- `compact` -> `0 are compressed and 1 are not compressed`
- `Get-Item` -> `Attributes : Archive, NotContentIndexed`
- `Get-VHD` -> `VhdType : Fixed`
- `Get-VHD` -> `VhdFormat : VHDX`

Operational result:

- repointing the VM's SCSI disk to `server-225-ubuntu-azure.vhdx`
- then running `Start-VM -Name 'server-225-ubuntu'`
- successfully moved the VM to `State : Running`

Conclusion:

- a replacement upstream artifact can get us to the same Ubuntu boot target
- but on this host, even the replacement source VHD still needed sparse/compression
  normalization before Hyper-V-native conversion
- the minimal viable path is now:
  - published Azure VHD tarball
  - extract VHD
  - clear sparse flag
  - clear compression
  - native `Convert-VHD`
  - attach and boot

## Role-design implication

The durable fix should be in the lifecycle role, not as an after-the-fact manual
repair step.

Recommended role behavior:

1. if using the raw `.img` path, distrust it until immediate probes prove the
   artifact is Hyper-V-safe
2. explicitly consider a more native upstream source such as Canonical's Azure
   VHD before continuing to tune the raw-image conversion path
3. ensure the destination directory is not NTFS-compressed before conversion
4. probe the source artifact too when it came from an extracted or downloaded
   virtual disk, not just the final converted VHDX
5. immediately probe the new VHDX with `fsutil`, `compact`, `Get-Item`,
   `Get-VHD`, and `qemu-img info`
6. fail fast if the source or destination artifact is sparse/compressed or
   otherwise inconsistent
7. do not let Hyper-V attach or start against a known-bad disk artifact

## Troubleshooting step-back rule

When repeated fixes against the current artifact stop producing new evidence,
the next move should not automatically be "try harder on the same file."

Instead, step back and ask:

- is there another source image format for the same OS release?
- is there another upstream artifact that gets us to the same bootable end
  state?
- are we overfitting to the current stock path just because it was the first one
  tried?

For this incident, that means the troubleshooting path should explicitly
consider alternative Canonical artifacts such as:

- Azure VHD
- VMDK
- OVA

before assuming the raw `.img` conversion route is the only viable bootstrap
path.

## Related evidence

- [hyperv-ubuntu-vm--windows--diagnostics.md](/Users/joshc/develop/dotfile-vnext/docs/diagnostics/hyperv-ubuntu-vm--windows--diagnostics.md)
- [evidence--hyperv-live-runs.md](/Users/joshc/develop/dotfile-vnext/docs/plans/2026-03-27--server-225-hyperv-ubuntu-vm-replacing-multipass/evidence--hyperv-live-runs.md)
- [hyperv_ubuntu_vm_probe.json](/Users/joshc/develop/dotfile-vnext/artifacts/troubleshooting/hyperv_ubuntu_vm/HOM-LAB-HVH-02/20260327-123920/command_results/hyperv_ubuntu_vm_probe.json)
