# Microsoft Network Adapter Multiplexor Removal - Troubleshooting Report

## Date: 2026-03-26
## System: hom-lab-ctl-hvh-02 (DESKTOP-VLLM)
## Issue: Remove problematic Microsoft Network Adapter Multiplexor drivers

---

## Problematic Adapters Identified

### 1. Network Bridge (ifIndex 19)
- **Status**: "Not Present"
- **InterfaceAlias**: "Network Bridge"  
- **ComponentID**: `COMPOSITEBUS\MS_IMPLAT_MP`
- **InstanceID**: `{E767C896-2417-4E7E-98A9-2E3666A5A83B}`
- **PnPDeviceID**: `COMPOSITEBUS\MS_IMPLAT_MP\{E767C896-2417-4E7E-98A9-2E3666A5A83B}`
- **Virtual**: True
- **NotUserRemovable**: True
- **DriverDate**: 2006-06-21 (Very old driver)

### 2. Ethernet 2 (ifIndex 9)  
- **Status**: "Up" (Currently active)
- **InterfaceAlias**: "Ethernet 2"
- **ComponentID**: `COMPOSITEBUS\MS_IMPLAT_MP`  
- **InstanceID**: `{E767C896-2417-4E7E-98A9-2E3666A5A83B}` (Same as Network Bridge!)
- **PnPDeviceID**: `COMPOSITEBUS\MS_IMPLAT_MP\{E767C896-2417-4E7E-98A9-2E3666A5A83B}`
- **Virtual**: True
- **NotUserRemovable**: True
- **LinkSpeed**: 1.2 Gbps (Currently active)

---

## Root Cause Analysis

**Key Finding**: Both adapters share the **same InstanceID GUID**, indicating they are part of the same Microsoft Network Adapter Multiplexor driver instance created by network bridging or Hyper-V installation.

**Why This Matters**: 
- The multiplexor creates virtual adapters for network bridging/sharing
- "Network Bridge" status = "Not Present" suggests a broken bridge configuration  
- "Ethernet 2" status = "Up" shows it's actively routing traffic (likely Wi-Fi bridge)
- Both marked `NotUserRemovable: True` means standard removal methods won't work

---

## Research Findings

### Available PowerShell Cmdlets
- ❌ `Remove-NetAdapter` - Does NOT exist on this system
- ✅ `Disable-NetAdapter` - Available for disabling adapters
- ❌ No `Remove-*` cmdlets in PnpDevice module
- ❌ No Bridge management cmdlets found

### Microsoft Official Guidance
Per [Microsoft Learn documentation](https://learn.microsoft.com/en-us/answers/questions/2580956/how-to-disable-microsoft-network-adapter-multiplex):

1. **Primary Method**: Right-click Wi-Fi connection icon → "Remove Bridge"
2. **Secondary Method**: Uninstall Hyper-V completely if installed  
3. **Manual Method**: Device Manager → Uninstall → Scan for hardware changes

### Alternative Advanced Methods
- Registry manipulation (requires elevated permissions)
- PnPUtil device removal (Microsoft recommended over DevCon)
- DevCon removal (legacy method)

---

## Recommended Removal Strategy

### ⚠️ SAFETY FIRST - Pre-Removal Checklist
1. **Backup current network configuration**
2. **Verify physical network access** (Ethernet cable available if Wi-Fi fails)
3. **Confirm Wi-Fi adapter working independently** (Wi-Fi interface shows "Up")
4. **Document current routing table** before changes

### Primary Removal Command (Single Line)

**⚠️ NETWORK DISRUPTIVE - Use with caution**

```powershell
Disable-NetAdapter -Name "Network Bridge" -Confirm:$false; Disable-NetAdapter -Name "Ethernet 2" -Confirm:$false; Get-NetAdapter | Where-Object {$_.Status -eq "Disconnected" -and $_.InterfaceDescription -like "*Multiplexor*"} | Disable-NetAdapter -Confirm:$false
```

### Alternative Registry-Based Removal (If Primary Fails)

```powershell
$InstanceId = "COMPOSITEBUS\MS_IMPLAT_MP\{E767C896-2417-4E7E-98A9-2E3666A5A83B}"; $RemoveKey = "HKLM:\SYSTEM\CurrentControlSet\Enum\$InstanceId"; if (Test-Path $RemoveKey) { Get-Item $RemoveKey | Select-Object -ExpandProperty Property | ForEach-Object { Remove-ItemProperty -Path $RemoveKey -Name $_ -Force -ErrorAction SilentlyContinue } }; Restart-Computer -Force
```

### Manual GUI Fallback
If PowerShell methods fail:
1. Right-click Wi-Fi connection system tray icon
2. Select "Remove Bridge" (if available)
3. Reboot system to complete removal

---

## Verification Steps (Post-Removal)

```powershell
# Verify removal
Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Multiplexor*"}

# Confirm Wi-Fi direct connection  
Get-NetAdapter -Name "Wi-Fi" | Select-Object Name, Status, LinkSpeed

# Check network connectivity
Test-NetConnection -ComputerName "8.8.8.8" -Port 53
```

Expected Results:
- No multiplexor adapters listed
- Wi-Fi adapter shows direct connection (not bridged)
- Network connectivity maintained through Wi-Fi

---

## Risk Assessment

### High Risk Factors
- **"Ethernet 2" currently active** (Status: "Up", 1.2 Gbps traffic)
- Removing active network adapter may cause **temporary connection loss**
- Both adapters share same GUID - removing one may affect the other

### Mitigation Strategies  
- **Perform during maintenance window**
- **Have physical access to machine** for recovery
- **Backup network configuration** first
- **Test with individual `Disable-NetAdapter` commands** before combined execution

### Recovery Plan (If Network Fails)
1. Physical console access to hom-lab-ctl-hvh-02
2. Device Manager → Network Adapters → Scan for hardware changes  
3. Re-enable Wi-Fi adapter manually
4. Check Windows Network Reset if needed: `netsh winsock reset`

---

## Implementation Notes

**Executed Commands This Session**:
1. ✅ `Get-NetAdapter` - Identified problematic adapters
2. ✅ `Get-NetAdapter | foreach {$_ | select *}` - Gathered detailed properties  
3. ✅ Verified `Remove-NetAdapter` cmdlet does not exist
4. ✅ Confirmed `Disable-NetAdapter` available as primary method
5. ✅ `Get-WindowsOptionalFeature` - **CONFIRMED: Hyper-V fully installed and enabled**

**Hyper-V Installation Confirmed** ✅:
- Microsoft-Hyper-V: Enabled
- Microsoft-Hyper-V-Offline: Enabled  
- Microsoft-Hyper-V-Online: Enabled
- RSAT-Hyper-V-Tools-Feature: Enabled
- Microsoft-Hyper-V-Management-PowerShell: Enabled
- Microsoft-Hyper-V-Management-Clients: Enabled

**Root Cause Confirmed**: Multiplexor adapters created by Hyper-V installation

**Next Steps**:
- Execute removal command with user approval
- Monitor network connectivity during removal  
- Document final results
- Consider Hyper-V uninstallation as alternative if adapter removal fails

---

## System Context
- **Current Working Adapters**: Wi-Fi (Up, 1.2 Gbps), Ethernet (Disconnected)
- **Problematic**: Network Bridge (Not Present), Ethernet 2 (Up but virtual)
- **SSH Connection**: Confirmed working via Wi-Fi for remote management
- **Physical Access**: Available for recovery if needed