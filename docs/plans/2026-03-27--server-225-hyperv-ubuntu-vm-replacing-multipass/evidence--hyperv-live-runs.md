# Evidence — Hyper-V Live Runs

This file records the actual command outputs from the first implementation pass
of the Hyper-V-native Ubuntu VM replacement.

## Local Verification

Command:

```bash
ansible-playbook --syntax-check playbooks/server_225_hyperv_ubuntu_vm.yaml -i inventory/inventory.yaml
```

Output:

```text
playbook: playbooks/server_225_hyperv_ubuntu_vm.yaml
```

Command:

```bash
ansible-lint roles/hyperv_ubuntu_vm playbooks/server_225_hyperv_ubuntu_vm.yaml
```

Output:

```text
Passed: 0 failure(s), 1 warning(s) in 16 files processed of 17 encountered.
jinja[spacing]: Jinja2 spacing could be improved: {{ lookup('env','HOME') }}/.ssh -> {{ lookup('env', 'HOME') }}/.ssh (warning)
roles/access_identity_controller/defaults/main.yml:3:21 Jinja2 template rewrite recommendation: `{{ lookup('env', 'HOME') }}/.ssh`.
```

## First Live Failure — Hyper-V External Switch Create

Command:

```bash
ansible-playbook playbooks/server_225_hyperv_ubuntu_vm.yaml -i inventory/inventory.yaml --limit 'execution_nodes,hom-lab-ctl-hvh-02'
```

Output excerpt:

```text
TASK [hyperv_networking : Create External VMSwitch with PowerShell when absent] ***
[WARNING]: Failed to cleanup running WinRM command, resources might still be in use on the target server
[ERROR]: Task failed: winrm connection error: HTTPConnectionPool(host='desktop-vllm', port=5985): Read timed out. (read timeout=30)
```

Follow-up evidence:

```text
hom-lab-ctl-hvh-02 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
{"Name":"External","SwitchType":2,"NetAdapterInterfaceDescription":"RZ608 Wi-Fi 6E 80MHz"}
```

## Controller Seed ISO Failure

Output excerpt:

```text
TASK [hyperv_ubuntu_vm : Build NoCloud seed ISO for Hyper-V Ubuntu VM on controller] ***
[ERROR]: Task failed: Module failed: Failed to add file /Users/joshc/.local/state/dotfile-vnext/hyperv_ubuntu_vm/server-225-ubuntu/user-data to ISO file due to ISO9660 filenames must consist of characters A-Z, 0-9, and _
```

## qemu-img Path Resolution Failure

Output excerpt:

```text
TASK [hyperv_ubuntu_vm : Resolve qemu-img command path on Windows host] ********
fatal: [hom-lab-ctl-hvh-02]: FAILED! => {
  "result": "qemu-img was not found after package installation"
}
```

Follow-up evidence:

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
C:\Program Files\qemu\qemu-img.exe
```

## Disk Resize Failure With Hyper-V

Output excerpt:

```text
TASK [hyperv_ubuntu_vm : Resize VHDX to desired capacity] **********************
fatal: [hom-lab-ctl-hvh-02]: FAILED! => {
  "output": "Resize-VHD : Failed to resize the virtual disk... Virtual hard disk files must be uncompressed and unencrypted and must not be sparse. (0xC03A001A)."
}
```

## qemu-img Resize Failure

Output excerpt:

```text
TASK [hyperv_ubuntu_vm : Resize VHDX to desired capacity] **********************
fatal: [hom-lab-ctl-hvh-02]: FAILED! => {
  "output": "qemu-img.exe: Image format driver does not support resize"
}
```

## Current Hyper-V Boot Blocker

Output locations collected in the current troubleshooting pass:

- Controller role wiring:
  `/Users/joshc/develop/dotfile-vnext/roles/hyperv_ubuntu_vm/tasks/present.yml`
- Windows Hyper-V event channels:
  `Microsoft-Windows-Hyper-V-Worker/Admin`
  `Microsoft-Windows-Hyper-V-VMMS/Admin`
- Windows artifact root:
  `C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\`
- Windows boot disk:
  `C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu.vhdx`

Live disk inspection:

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
image: C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu.vhdx
file format: vhdx
virtual size: 3.5 GiB (3758096384 bytes)
disk size: 1.79 GiB
cluster_size: 16777216
Child node '/file':
    filename: C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu.vhdx
    protocol type: file
    file length: 5.59 GiB (5997854720 bytes)
    disk size: 1.79 GiB
```

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
{"Path":"C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx","VhdType":2,"FileSize":5997854720,"Size":3758096384}
```

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
This file is set as sparse
...
Of 1 files within 1 directories
1 are compressed and 0 are not compressed.
5,997,854,720 total bytes of data are stored in 1,919,877,120 bytes.
The compression ratio is 3.1 to 1.
```

Troubleshooting probe captured through Ansible shell path with WinRM-safe env:

```text

## Multipass Cleanup Blocker

Current cleanup blocker output from the controller:

```text
$ ssh -o ConnectTimeout=5 joshc@DESKTOP-VLLM -p 22 exit
ssh: connect to host DESKTOP-VLLM port 22: Host is down
```

```text
$ nc -vz -G 2 DESKTOP-VLLM 5985
nc: connectx to DESKTOP-VLLM port 5985 (tcp) failed: Host is down
```

```text
$ arp -an | rg 192.168.50.158
? (192.168.50.158) at (incomplete) on en0 ifscope [ethernet]
```

Assessment:

- repo-side Multipass implementation can be removed independently
- host-side Multipass teardown is blocked until `hom-lab-ctl-hvh-02` comes back on
  the network
TASK [Probe Hyper-V Ubuntu boot disk evidence] *********************************
changed: [hom-lab-ctl-hvh-02] => {
  "result": {
    "exists": true,
    "get_vhd": {
      "Path": "C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx",
      "VhdType": "Fixed",
      "FileSize": 5997854720,
      "Size": 3758096384
    },
    "sparse": "This file is set as sparse",
    "compact": "Listing C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\\n...\n1 are compressed and 0 are not compressed.\n5,997,854,720 total bytes of data are stored in 1,919,877,120 bytes.\nThe compression ratio is 3.1 to 1.",
    "cipher": "Listing C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\\nNew files added to this directory will not be encrypted.\n\nU server-225-ubuntu.vhdx",
    "item": {
      "FullName": "C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx",
      "Length": 5997854720,
      "Attributes": "Archive, SparseFile, NotContentIndexed"
    },
    "qemu_img_info": "image: C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx\nfile format: vhdx\nvirtual size: 3.5 GiB (3758096384 bytes)\ndisk size: 1.79 GiB\ncluster_size: 16777216\nChild node '/file':\n    filename: C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx\n    protocol type: file\n    file length: 5.59 GiB (5997854720 bytes)\n    disk size: 1.79 GiB"
  }
}
```

This is the current contradiction to design around:

- `Get-VHD` reports a fixed disk
- NTFS/file probes still show the file as sparse and compressed
- Hyper-V Worker/Admin rejects the same file at power-on

After clearing compression and sparse flag:

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
This file is NOT set as sparse
...
Of 1 files within 1 directories
0 are compressed and 1 are not compressed.
5,997,854,720 total bytes of data are stored in 5,997,854,720 bytes.
The compression ratio is 1.0 to 1.
```

Start attempt after that change:

```text
hom-lab-ctl-hvh-02 | CHANGED | rc=0 >>
{"Name":"server-225-ubuntu","State":3}
Start-VM : 'server-225-ubuntu' failed to start.
Synthetic SCSI Controller ... Virtual hard disk files must be uncompressed and unencrypted and must not be sparse.
```

Current Hyper-V event output captured from the role-owned failure diagnostics:

```text
'server-225-ubuntu' Synthetic SCSI Controller ... Failed to Power on with Error
'The requested operation could not be completed due to a virtual disk system limitation.
Virtual hard disk files must be uncompressed and unencrypted and must not be sparse.' (0xC03A001A).
```

```text
'server-225-ubuntu': Attachment
'C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx (Lun 0)'
failed to open because of error:
'The requested operation could not be completed due to a virtual disk system limitation.
Virtual hard disk files must be uncompressed and unencrypted and must not be sparse.' (7864368).
```

## MCP / WinRM Crash Side Note

The MCP Ansible worker path is still not a trustworthy evidence surface for
WinRM collection on this controller. Current pinned outputs:

```text
[ERROR]: A worker was found in a dead state
```

Local crash report path:

`/Users/joshc/Library/Logs/DiagnosticReports/Python-2026-03-27-112818.ips`

Crash excerpt:

```text
responsibleProc : "Cursor"
CoreFoundation: "*** multi-threaded process forked ***"
libsystem_c.dylib: "crashed on child side of fork pre-exec"
symbol: "SCDynamicStoreCopyProxiesWithOptions"
```

## Interactive Replacement-Resource Success — Canonical Azure VHD

Interactive Windows SSH session entrypoint:

```text
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no joshc@DESKTOP-VLLM -p 22
```

Downloaded replacement source:

```text
C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\ubuntu-24.04-server-cloudimg-amd64-azure.vhd.tar.gz
```

Extracted source artifact:

```text
C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\livecd.ubuntu-cpc.azure.vhd
```

Source probe before normalization:

```text
Get-VHD:
VhdType   : Fixed
VhdFormat : VHD
Size      : 32213303296
FileSize  : 32213303808
```

```text
fsutil sparse queryflag ...livecd.ubuntu-cpc.azure.vhd
This file is set as sparse
```

```text
compact ...livecd.ubuntu-cpc.azure.vhd
32213303808 : 1935867904 = 16.6 to 1 d livecd.ubuntu-cpc.azure.vhd
1 are compressed and 0 are not compressed.
```

```text
Get-Item ...livecd.ubuntu-cpc.azure.vhd
Attributes : Archive, SparseFile, NotContentIndexed
Length     : 32213303808
```

Failed native conversion before normalization:

```text
Convert-VHD : Failed to convert the virtual disk.
... Virtual hard disk files must be uncompressed and unencrypted and must not be sparse. (0xC03A001A).
```

Interactive normalization that changed the source artifact:

```text
fsutil sparse setflag C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\livecd.ubuntu-cpc.azure.vhd 0
```

```text
fsutil sparse queryflag ...livecd.ubuntu-cpc.azure.vhd
This file is NOT set as sparse
```

```text
compact /u /f ...livecd.ubuntu-cpc.azure.vhd
livecd.ubuntu-cpc.azure.vhd [OK]
```

```text
compact ...livecd.ubuntu-cpc.azure.vhd
32213303808 : 32213303808 = 1.0 to 1   livecd.ubuntu-cpc.azure.vhd
0 are compressed and 1 are not compressed.
```

```text
Get-Item ...livecd.ubuntu-cpc.azure.vhd
Attributes : Archive, NotContentIndexed
Length     : 32213303808
```

Successful native conversion after normalization:

```text
Convert-VHD -Path ...livecd.ubuntu-cpc.azure.vhd -DestinationPath ...server-225-ubuntu-azure.vhdx -VHDType Fixed
```

Probe of the converted replacement VHDX:

```text
fsutil sparse queryflag ...server-225-ubuntu-azure.vhdx
This file is NOT set as sparse
```

```text
compact ...server-225-ubuntu-azure.vhdx
32250003456 : 32250003456 = 1.0 to 1   server-225-ubuntu-azure.vhdx
0 are compressed and 1 are not compressed.
```

```text
Get-Item ...server-225-ubuntu-azure.vhdx
Attributes : Archive, NotContentIndexed
Length     : 32250003456
```

```text
Get-VHD ...server-225-ubuntu-azure.vhdx
VhdType   : Fixed
VhdFormat : VHDX
Size      : 32213303296
FileSize  : 32250003456
```

VM repoint and boot result:

```text
Get-VMHardDiskDrive -VMName 'server-225-ubuntu'
Path               : C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu.vhdx
ControllerType     : SCSI
ControllerNumber   : 0
ControllerLocation : 0
```

```text
Set-VMHardDiskDrive -VMName 'server-225-ubuntu' -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0 -Path 'C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu-azure.vhdx'
Start-VM -Name 'server-225-ubuntu'
```

```text
Get-VM -Name 'server-225-ubuntu'
Name   : server-225-ubuntu
State  : Running
Status : Operating normally
```

## Framework-Relevant Note

No real subagent handoff was used in this run.

Relevant repo evidence:

```text
The current official Codex role mapping for this repo is:
- `default` -> `Planner / Steward` in the primary thread
- `explorer` -> `Researcher`
- `worker` -> `Executor`

True multi-agent delegation still needs runtime evidence. Configuration alone is
not proof that separate agent threads are being used automatically.
```

Sources:

- `docs/codex_framework/partner_process.md`
- `docs/plans/2026-03-27--subagents-v1/README.md`

## Interactive Windows SSH Experiment: `block_state_zero=off`

Interactive entrypoint used:

```text
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no joshc@DESKTOP-VLLM -p 22
```

Pinned QEMU binary path on the Windows host:

```text
C:\Program Files\qemu\qemu-img.exe
```

Experimental conversion command:

```text
& "C:\Program Files\qemu\qemu-img.exe" convert -O vhdx -o subformat=fixed,block_state_zero=off,size=40G `
  "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\noble-server-cloudimg-amd64.img" `
  "C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu-bszoff.vhdx"
```

Immediate probes on the newly generated file:

```text
fsutil sparse queryflag ...server-225-ubuntu-bszoff.vhdx
This file is set as sparse
```

```text
compact ...server-225-ubuntu-bszoff.vhdx
3766484992 : 1918828544 = 2.0 to 1 d server-225-ubuntu-bszoff.vhdx
1 are compressed and 0 are not compressed.
```

```text
Get-Item ...server-225-ubuntu-bszoff.vhdx | Format-List FullName,Attributes,Length,LastWriteTime
Attributes    : Archive, SparseFile, NotContentIndexed
Length        : 3766484992
```

```text
Get-VHD -Path ...server-225-ubuntu-bszoff.vhdx | Format-List Path,VhdType,Size,FileSize
VhdType  : Fixed
Size     : 3758096384
FileSize : 3766484992
```

```text
qemu-img info ...server-225-ubuntu-bszoff.vhdx
file format: vhdx
virtual size: 3.5 GiB (3758096384 bytes)
file length: 3.51 GiB (3766484992 bytes)
```

Parent directory state during the same interactive session:

```text
compact C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu
New files added to this directory will not be compressed.
0 are compressed and 1 are not compressed.
```

```text
Get-Item C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu | Format-List FullName,Attributes
Attributes : Directory, NotContentIndexed
```

Start attempt after the experimental conversion:

```text
Start-VM -Name 'server-225-ubuntu'
Start-VM : 'server-225-ubuntu' failed to start.
Synthetic SCSI Controller ... Virtual hard disk files must be uncompressed and unencrypted and must not be sparse.
Attachment 'C:\ProgramData\Ansible\hyperv_ubuntu_vm\server-225-ubuntu\server-225-ubuntu.vhdx (Lun 0)' failed to open ...
```

Current conclusion from this experiment:

- `block_state_zero=off` did not fix the Hyper-V incompatibility
- the freshly converted file still came out sparse/compressed
- the parent directory was not configured to compress new files
- the QEMU-on-Windows conversion path remains the first artifact-creation step to distrust
