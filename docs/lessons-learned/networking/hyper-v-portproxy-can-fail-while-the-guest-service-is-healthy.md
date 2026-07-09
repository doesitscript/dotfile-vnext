# Hyper-V Portproxy Can Fail While The Guest Service Is Healthy

## Problem

NetBox looked down from the LAN at `http://192.168.50.158:8000/`, but the real
failure was not NetBox itself.

The broken layer was the Windows `netsh interface portproxy` publish path on
`HOM-LAB-HVH-02`.

## What was happening

- `server-225-ubuntu` was up
- NetBox on the Ubuntu VM was healthy
- the Windows host could reach the Ubuntu guest directly on
  `192.168.137.10:8000`
- but the LAN-published address `192.168.50.158:8000` was not accepting
  connections
- the same problem also affected other published ports like `3001`, `3100`,
  `30000`, and `30400`

This means:

- app healthy
- guest network healthy
- Windows host to guest path healthy
- LAN publish layer unhealthy

## Three ways to check it

### 1. Check from the controller/Mac

Probe the LAN-published NetBox URL directly:

```bash
curl -sS -o /tmp/netbox.out -w 'http_code=%{http_code} connect=%{time_connect} total=%{time_total}\n' --max-time 5 http://192.168.50.158:8000/api/status/ && cat /tmp/netbox.out
```

This answers:

- can the published LAN path be reached from the controller?

### 2. Check locally on the Ubuntu VM

Probe NetBox on the VM itself:

```bash
bin/codex-env ansible server-225-ubuntu -i inventory/inventory.yaml -m ansible.builtin.shell -a "curl -sS -o /tmp/netbox_status.out -w 'http_code=%{http_code} total=%{time_total}\n' http://127.0.0.1:8000/api/status/ && cat /tmp/netbox_status.out"
```

This answers:

- is NetBox itself healthy on the VM?

### 3. Check from the Windows Hyper-V host

Probe both the direct guest path and the LAN-published path from
`HOM-LAB-HVH-02`:

```bash
bin/codex-env ansible HOM-LAB-HVH-02 -i inventory/inventory.yaml -m ansible.windows.win_shell -a "try { \$r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 http://192.168.137.10:8000/api/status/; Write-Output ('guest_status=' + [int]\$r.StatusCode); Write-Output \$r.Content } catch { Write-Output \$_.Exception.Message; exit 1 }"

bin/codex-env ansible HOM-LAB-HVH-02 -i inventory/inventory.yaml -m ansible.windows.win_shell -a "try { \$r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 http://192.168.50.158:8000/api/status/; Write-Output ('lan_status=' + [int]\$r.StatusCode); Write-Output \$r.Content } catch { Write-Output \$_.Exception.Message; exit 1 }"

bin/codex-env ansible HOM-LAB-HVH-02 -i inventory/inventory.yaml -m ansible.windows.win_shell -a "Test-NetConnection 192.168.137.10 -Port 8000 -InformationLevel Detailed | Select-Object ComputerName,RemotePort,TcpTestSucceeded,InterfaceAlias,SourceAddress | Format-List"
```

This answers:

- can Windows reach the guest directly?
- can Windows reach its own published LAN address?
- is the failure in the guest service, or only in the publish layer?

## Useful clue

The configured rules can still exist even when the publish path is not actually
working:

```bash
bin/codex-env ansible HOM-LAB-HVH-02 -i inventory/inventory.yaml -m ansible.windows.win_shell -a "netsh interface portproxy show all"
```

So do not stop at "the rules are present." Verify reachability too.

## Fix

Restart the Windows `IP Helper` service:

```bash
bin/codex-env ansible HOM-LAB-HVH-02 -i inventory/inventory.yaml -m ansible.windows.win_service -a "name=iphlpsvc state=restarted start_mode=auto"
```

After that, re-run the three checks above.

## Why the troubleshooting appeared hung

The restart was launched against the Windows host over:

- Ansible `ssh`
- with `powershell.exe` as the remote shell

During the `iphlpsvc` restart, the controller-side command appeared stuck.
After the user interrupted that waiting session, follow-up probes showed the
service restart had completed and the published NetBox path was working again.

Treat this as a real operational caveat:

- restarting `iphlpsvc` may disrupt or stall the active remote session long
  enough to make the troubleshooting run look hung
- a hung controller-side wait does not necessarily mean the restart failed
- verify from fresh probes before assuming the fix did not apply

## Repo ownership

The published guest port surface for this host lives here:

- `inventory/host_vars/HOM-LAB-HVH-02.yaml`

The repo-managed implementation path for those rules lives here:

- `roles/hyperv_networking/tasks/routed_private_subnet.yml`
- `playbooks/configure_hyperv_windows_hosts.yaml`

If this problem repeats often, prefer the repo-managed Hyper-V networking path
over ad hoc manual `netsh` edits.
