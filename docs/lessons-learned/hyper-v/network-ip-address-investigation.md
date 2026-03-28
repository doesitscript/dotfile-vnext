Researcher view:

Yes, there are less imposing steps first, and I think that’s the right order.

The static-IP commands I gave you were the stronger “validate the deterministic design” test. But before that, there’s a lighter DHCP-based recovery sequence that tests whether the current problem is just stale lease/state after the Hyper-V adapter transition.

Try these first in elevated PowerShell on `server-225-win`:

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
