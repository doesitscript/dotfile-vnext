# dev-workstation-win intermittent download slowdown

Date captured: 2026-05-08

## Situation

`dev-workstation-win` had recently been offline, then came back online. The
reported issue was intermittent download throughput: downloads start around
`300+ Mbps` or `300+ MB/s`, then after a few minutes fall to roughly
`20-30`. Pausing and resuming the download temporarily restores the high speed,
then it slows again after a few minutes.

The active suspected download client during the session was Steam.

## Target

- Inventory host: `dev-workstation-win`
- Computer name: `DESKTOP-C1ACPUM`
- Repo inventory path: `inventory/host_vars/dev-workstation-win.yaml`
- Inventory-stored address at the time: `192.168.50.70`
- Live address discovered during this session: `192.168.50.132`
- Working remote path: WinRM / PS Remoting through Ansible
- SSH status: not available

The old inventory address was stale for this session. Name lookup and mDNS
showed `DESKTOP-C1ACPUM` at `192.168.50.132`, and WinRM worked only after
overriding `ansible_host`.

## Confirmed remote access

Working command shape:

```bash
bin/codex-env ansible -i inventory/inventory.yaml dev-workstation-win \
  -e ansible_host=192.168.50.132 \
  -m ansible.windows.win_shell \
  -a 'hostname; whoami; $PSVersionTable.PSVersion.ToString()'
```

Observed output:

```text
DESKTOP-C1ACPUM
desktop-c1acpum\joshc
5.1.19041.6456
```

`win_ping` also succeeded with the live address:

```text
dev-workstation-win | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

## Remote access checks performed

These checks were used to distinguish stale addressing, WinRM availability, and
SSH availability:

```bash
ping -c 2 192.168.50.70
nc -vz -w 3 192.168.50.70 22
nc -vz -w 3 192.168.50.70 5985
ssh -o BatchMode=yes -o ConnectTimeout=5 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  joshc@192.168.50.70 hostname
dscacheutil -q host -a name DESKTOP-C1ACPUM
smbutil lookup DESKTOP-C1ACPUM
dns-sd -G v4v6 DESKTOP-C1ACPUM.local
ping -c 2 192.168.50.132
ssh -o BatchMode=yes -o ConnectTimeout=5 \
  -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  joshc@192.168.50.132 hostname
```

Key results:

```text
smbutil lookup DESKTOP-C1ACPUM
Got response from 192.168.50.132
IP address of DESKTOP-C1ACPUM: 192.168.50.132
```

```text
ping 192.168.50.132
2 packets transmitted, 2 packets received, 0.0% packet loss
```

```text
ssh: connect to host 192.168.50.132 port 22: Operation timed out
```

Windows-side probe showed SSH was not configured or listening:

```text
"sshd_service": null
"sshd_processes": []
"sshd_tcp": []
"ssh_firewall": []
```

## Throughput troubleshooting checks performed

Read-only checks collected:

- active IPv4 address and interface
- network adapter model, status, link speed, MAC, and driver
- adapter power-management state
- Wi-Fi interface state through `netsh wlan show interfaces`
- Wi-Fi driver capabilities through `netsh wlan show drivers`
- TCP global settings through `netsh int tcp show global`
- TCP/IP statistics through `netstat -s`
- DNS servers and default route
- network profile category and connectivity
- disk volumes, free space, health, and physical disk inventory
- recent WLAN AutoConfig events
- recent NetworkProfile events
- recent System events related to networking, services, and disk/storage
- Steam-related services and processes
- a 45-second sampled view of Wi-Fi bytes, signal, link rate, and Steam process snapshot

## Important observed values

Network:

```text
Interface: Wi-Fi 3
Description: TP-Link Wi-Fi 6 PCIe Adapter
Status: Up
LinkSpeed: 1.7 Gbps
Driver: MediaTek 0.34.2.886, 2024-05-04
SSID: ASUS_5G-1
BSSID: a0:36:bc:e4:0c:44
Radio type: 802.11ac
Authentication: WPA3-Personal
Channel: 52
Receive rate: 1733.3 Mbps
Transmit rate: 1733.3 Mbps
Signal: 84-86%
```

Wi-Fi advanced settings of note:

```text
Power Saving: Auto
Preferred Band: No Preference
Transmit Power Level: Highest
5GHz channel bandwidth: Auto
802.11ax/ac/n/abg: 802.11ax
```

TCP/IP:

```text
Receive-Side Scaling State: enabled
Receive Window Auto-Tuning Level: normal
Receive Segment Coalescing State: enabled
TCP Segments Retransmitted: 7432
IPv4 Received Packets Discarded: 4093
IPv4 Received Address Errors: 1327
```

Storage:

```text
Disk 2: Intel Raid 0 Volume, RAID, SSD, Healthy, D:
Disk 1: ADATA SX8200PNP, NVMe, Healthy, boot/system, C:
Disk 0: T-FORCE TM8FFE512G, NVMe, Healthy, E:
```

At the time sampled, disk perf counters were idle:

```text
AvgDisksecPerWrite: 0
DiskWriteBytesPersec: 0
PercentDiskTime: 0
CurrentDiskQueueLength: 0
```

Steam/app state:

```text
steam.exe running
steamservice.exe running
multiple steamwebhelper.exe processes running
```

Recent System events included Steam service startup trouble:

```text
The Steam Client Service service failed to start due to the following error:
The service did not respond to the start or control request in a timely fashion.

A timeout was reached (90000 milliseconds) while waiting for the Steam Client
Service service to connect.
```

WLAN/network events showed connect/disconnect activity around the recovery
window, including:

```text
Network Disconnected: ASUS_5G-1
Network Connected: ASUS_5G-1
WLAN AutoConfig service has successfully connected to a wireless network.
```

Windows diagnostics also logged:

```text
Result of diagnosis: There may be problem
```

for wireless connectivity / adapter diagnosis, even though the live link later
looked strong.

## 45-second sampler result

The short sampler was not guaranteed to overlap the bad part of an active
download, but it did show a burst and then low traffic while link quality stayed
stable.

```text
rxMbps_min: 0
rxMbps_avg: 5.37
rxMbps_max: 204.1
signal_min: 84
signal_avg: 85.2
signal_max: 86
link_rx_rate_min: 1733.3
link_rx_rate_max: 1733.3
```

Assessment from this sample: during the sampled window, Wi-Fi signal and link
rate did not collapse. That made a pure RF/link-rate failure less likely, but
the sample did not prove what happens after the download has been running for a
few minutes.

## Change made

The user reported being told to try:

```text
Turned off disk caching and turned down the priority of Steam.exe(I believe) in task manager
```

Only the Steam priority change was applied.

Applied temporary process-priority change:

- `steam.exe` -> `BelowNormal`
- `steamwebhelper.exe` -> `BelowNormal`
- `steamservice.exe` was left unchanged

Observed before/after showed the priority class changed to `BelowNormal`
numeric value `16384` for `steam.exe` and the `steamwebhelper.exe` processes.

This change is not persistent. It lasts until Steam restarts.

## What was not changed

Disk write caching was not changed.

Reason: "turn off disk caching" can mean different things:

- Steam download/cache settings
- Windows disk-device write caching policy
- storage controller or vendor cache behavior

The dangerous version is the Windows disk-device policy. Changing that blindly
can reduce performance or change data-loss risk during power loss. The machine
has multiple storage devices, including an Intel RAID 0 volume and NVMe SSDs,
so the exact target matters.

Attempts to enumerate deeper disk/cache and Steam log state over WinRM hung on
slow file/device enumeration. Those local Ansible processes were killed from
the Mac controller rather than left running.

Stopped collectors:

- Steam log/library tailing command that read from `C:\Program Files (x86)\Steam`
- disk/cache device-property discovery command using `Get-PnpDeviceProperty`
- a simplified Steam library/log summary command that still hung

No repo files, inventory, Windows disk policy, Wi-Fi driver settings, firewall
settings, services, or Steam configuration files were changed.

## Current assessment

The best current read is that the issue is more likely Steam/client/disk
pipeline behavior than a Wi-Fi signal collapse:

- live Wi-Fi link rate stayed at `1733.3 Mbps`
- signal stayed around `84-86%`
- adapter packet error counters were `0` in the collected snapshot
- Steam was actively running
- Steam service had recent timeout errors
- pause/resume temporarily restoring speed is consistent with a download client
  bursting network, then throttling while writing/verifying/patching/decompressing

There was still enough WLAN reconnect history that Wi-Fi is not fully cleared.
It should be sampled during the bad window before ruling it out.

## Recommended next pickup

1. Keep using the live WinRM override unless inventory is updated:

   ```bash
   bin/codex-env ansible -i inventory/inventory.yaml dev-workstation-win \
     -e ansible_host=192.168.50.132 \
     -m ansible.windows.win_shell \
     -a 'hostname; netsh wlan show interfaces'
   ```

2. Have the user start or resume the Steam download.

3. Wait until it drops to `20-30`.

4. Run a longer sampler during the bad window. Capture:

   - Wi-Fi received bytes per second
   - Wi-Fi signal and negotiated rate
   - `Get-NetAdapterStatistics`
   - Steam process CPU
   - disk write bytes/sec
   - average disk write latency
   - disk queue length
   - active TCP connections by owning process
   - WLAN/network events during the same timestamp window

5. If disk write latency or queue spikes while network drops, focus on Steam
   install library location, decompression/patching, antivirus scanning, and
   disk/controller behavior.

6. If Wi-Fi signal or negotiated rate drops during the bad window, focus on
   MediaTek/TP-Link driver settings:

   - `Power Saving`: consider testing `Disabled`
   - `Preferred Band`: consider testing `5GHz`
   - router channel / DFS behavior, currently channel `52`
   - WPA3 compatibility with this adapter/driver
   - driver update or rollback for MediaTek `0.34.2.886`

7. If the user still wants disk write caching changed, first identify the Steam
   library disk and then make a narrow, reversible change. Do not apply a
   blanket device-level caching change across all disks.

## Useful future command snippets

Basic live check:

```bash
bin/codex-env ansible -i inventory/inventory.yaml dev-workstation-win \
  -e ansible_host=192.168.50.132 \
  -m ansible.windows.win_shell \
  -a 'hostname; netsh wlan show interfaces'
```

Steam priority again, if Steam has restarted:

```bash
bin/codex-env ansible -i inventory/inventory.yaml dev-workstation-win \
  -e ansible_host=192.168.50.132 \
  -m ansible.windows.win_shell \
  -a '$targets = Get-Process | Where-Object { $_.ProcessName -match "^steam$|steamwebhelper" }; foreach ($p in $targets) { try { $p.PriorityClass = "BelowNormal" } catch {} }; $targets | Select-Object ProcessName,Id,PriorityClass'
```

One-minute Wi-Fi rate sampler:

```bash
bin/codex-env ansible -i inventory/inventory.yaml dev-workstation-win \
  -e ansible_host=192.168.50.132 \
  -m ansible.windows.win_shell \
  -a '$samples=@(); for($i=0;$i -lt 60;$i++){ $wifi=Get-NetAdapterStatistics -Name "Wi-Fi 3"; $iface=(netsh wlan show interfaces | Out-String); $samples += [pscustomobject]@{ t=(Get-Date).ToString("HH:mm:ss"); rx=[int64]$wifi.ReceivedBytes; tx=[int64]$wifi.SentBytes; signal=if($iface -match "Signal\s+:\s+(\d+)%"){[int]$Matches[1]}else{$null}; rxRate=if($iface -match "Receive rate \(Mbps\)\s+:\s+([0-9.]+)"){[double]$Matches[1]}else{$null} }; Start-Sleep 1 }; $rates=@(); for($i=1;$i -lt $samples.Count;$i++){ $rates += [pscustomobject]@{ t=$samples[$i].t; rxMbps=[math]::Round((($samples[$i].rx-$samples[$i-1].rx)*8/1MB),2); signal=$samples[$i].signal; rxRate=$samples[$i].rxRate } }; $rates | ConvertTo-Json -Depth 4'
```
