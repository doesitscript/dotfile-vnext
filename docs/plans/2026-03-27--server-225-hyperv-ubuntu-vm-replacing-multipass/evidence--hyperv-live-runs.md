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
ansible-playbook playbooks/server_225_hyperv_ubuntu_vm.yaml -i inventory/inventory.yaml --limit 'execution_nodes,server-225-win'
```

Output excerpt:

```text
TASK [hyperv_networking : Create External VMSwitch with PowerShell when absent] ***
[WARNING]: Failed to cleanup running WinRM command, resources might still be in use on the target server
[ERROR]: Task failed: winrm connection error: HTTPConnectionPool(host='desktop-vllm', port=5985): Read timed out. (read timeout=30)
```

Follow-up evidence:

```text
server-225-win | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

```text
server-225-win | CHANGED | rc=0 >>
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
fatal: [server-225-win]: FAILED! => {
  "result": "qemu-img was not found after package installation"
}
```

Follow-up evidence:

```text
server-225-win | CHANGED | rc=0 >>
C:\Program Files\qemu\qemu-img.exe
```

## Disk Resize Failure With Hyper-V

Output excerpt:

```text
TASK [hyperv_ubuntu_vm : Resize VHDX to desired capacity] **********************
fatal: [server-225-win]: FAILED! => {
  "output": "Resize-VHD : Failed to resize the virtual disk... Virtual hard disk files must be uncompressed and unencrypted and must not be sparse. (0xC03A001A)."
}
```

## qemu-img Resize Failure

Output excerpt:

```text
TASK [hyperv_ubuntu_vm : Resize VHDX to desired capacity] **********************
fatal: [server-225-win]: FAILED! => {
  "output": "qemu-img.exe: Image format driver does not support resize"
}
```

## Current Hyper-V Boot Blocker

Live disk inspection:

```text
server-225-win | CHANGED | rc=0 >>
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
server-225-win | CHANGED | rc=0 >>
{"Path":"C:\\ProgramData\\Ansible\\hyperv_ubuntu_vm\\server-225-ubuntu\\server-225-ubuntu.vhdx","VhdType":2,"FileSize":5997854720,"Size":3758096384}
```

```text
server-225-win | CHANGED | rc=0 >>
This file is set as sparse
...
Of 1 files within 1 directories
1 are compressed and 0 are not compressed.
5,997,854,720 total bytes of data are stored in 1,919,877,120 bytes.
The compression ratio is 3.1 to 1.
```

After clearing compression and sparse flag:

```text
server-225-win | CHANGED | rc=0 >>
This file is NOT set as sparse
...
Of 1 files within 1 directories
0 are compressed and 1 are not compressed.
5,997,854,720 total bytes of data are stored in 5,997,854,720 bytes.
The compression ratio is 1.0 to 1.
```

Start attempt after that change:

```text
server-225-win | CHANGED | rc=0 >>
{"Name":"server-225-ubuntu","State":3}
Start-VM : 'server-225-ubuntu' failed to start.
Synthetic SCSI Controller ... Virtual hard disk files must be uncompressed and unencrypted and must not be sparse.
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
