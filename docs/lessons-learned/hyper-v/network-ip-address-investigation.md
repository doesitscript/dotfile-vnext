Researcher view:

Yes, there are less imposing steps first, and I think that’s the right order.

The static-IP commands I gave you were the stronger “validate the deterministic design” test. But before that, there’s a lighter DHCP-based recovery sequence that tests whether the current problem is just stale lease/state after the Hyper-V adapter transition.

Try these first in elevated PowerShell on `HOM-LAB-HVH-02`:

```powershell
Start-Transcript -Path "$env:USERPROFILE\Desktop\hyperv-host-network-dhcp-refresh.txt" -Force

$switchName = 'External'
$mgmtAlias  = "vEthernet ($switchName)"

'=== DISCOVERY BEFORE REFRESH ==='
Get-VMSwitch -Name $switchName | Format-List Name,SwitchType,NetAdapterInterfaceDescription
Get-NetAdapter | Sort-Object Name | Format-Table Name,InterfaceDescription,Status,MacAddress -Auto
Get-NetIPAddress -AddressFamily IPv4 | Sort-Object InterfaceAlias | Format-Table InterfaceAlias,IPAddress,PrefixLength,PrefixOrigin,SuffixOrigin -Auto
Get-NetIPConfiguration -InterfaceAlias $mgmtAlias | Format-List
ipconfig /all

'=== DHCP / CACHE REFRESH ==='
Clear-DnsClientCache
ipconfig /flushdns
ipconfig /release
ipconfig /renew

'=== OPTIONAL ADAPTER BOUNCE IF STILL WRONG ==='
Disable-NetAdapter -Name $mgmtAlias -Confirm:$false
Start-Sleep -Seconds 5
Enable-NetAdapter -Name $mgmtAlias -Confirm:$false
Start-Sleep -Seconds 10
ipconfig /renew

'=== VERIFY AFTER REFRESH ==='
Get-NetIPAddress -AddressFamily IPv4 | Sort-Object InterfaceAlias | Format-Table InterfaceAlias,IPAddress,PrefixLength,PrefixOrigin,SuffixOrigin -Auto
Get-NetIPConfiguration -InterfaceAlias $mgmtAlias | Format-List
Test-Connection 192.168.50.1 -Count 2
Test-NetConnection -ComputerName localhost -Port 22
Test-NetConnection -ComputerName localhost -Port 5985
ipconfig /all

Stop-Transcript
```

What this is testing:
- whether Windows just needs to rebind DHCP on the management OS adapter after the Hyper-V switch change
- whether DNS/lease state is stale
- whether an adapter bounce causes the router reservation to be honored again

If you want an even more conservative sequence, stop after:

```powershell
Clear-DnsClientCache
ipconfig /flushdns
ipconfig /release
ipconfig /renew
```

and check whether it returns to `.158`.

So the order I’d recommend is:

1. DHCP refresh only
2. if still wrong, adapter bounce + renew
3. if still wrong, then the stronger static-IP test

Planner/Steward view:

That lines up with a mature implementation path too:

- first possible repo feature:
  - `management_os_network_state: dhcp`
  - but explicitly renew/verify after Hyper-V switch creation
- second stronger option:
  - `management_os_network_state: static`

So yes, the lighter commands are worth trying first, and they’re a better first validation step if you want to avoid jumping straight to static configuration.

Outcomes:

The first implementation path in the repo should stay conservative:

1. Before risky Hyper-V feature or external-switch changes, stage a temporary
   boot-triggered recovery task on the Windows host.
2. On the next boot, run the proven soft DHCP refresh sequence:
   - `Clear-DnsClientCache`
   - `ipconfig /flushdns`
   - `ipconfig /release`
   - `ipconfig /renew`
3. Use the host's expected management IP (`host_ip`) as the recovery success
   target.
4. Let the task unregister itself after the boot attempt, then let the role
   remove any remaining helper artifacts after reconnection.

This is the preferred first try before introducing static IP management for the
Hyper-V management OS.

Follow-up direction:

- The DHCP refresh task stays useful for recovering the Windows host control
  plane after risky Hyper-V changes.
- But for the Ubuntu guest itself on Wi-Fi-backed hosts, the better topology is
  to avoid the External-switch guest DHCP path entirely.
- The next implementation path is:
  1. keep the External switch available for existing host consumers
  2. create a separate Internal Hyper-V switch for the guest
  3. enable ICS from the public Wi-Fi adapter to that Internal switch adapter
  4. attach the Hyper-V Ubuntu guest to the Internal switch

This direction came from repeated field reports that Linux guest DHCP over a
Wi-Fi-backed External Hyper-V switch is unreliable, including:

- https://www.hurryupandwait.io/blog/running-an-ubuntu-guest-on-hyper-v-assigned-an-ip-via-dhcp-over-a-wifi-connection
