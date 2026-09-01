# probe_hyperv_network_adapters.ps1 — list physical/vEthernet adapters, VMSwitch bindings.
$ErrorActionPreference = 'Stop'

$adapters = Get-NetAdapter -IncludeHidden | Sort-Object Name | ForEach-Object {
    $ips = @(
        Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.IPAddress -notlike '169.254.*' } |
            ForEach-Object { "$($_.IPAddress)/$($_.PrefixLength) $($_.PrefixOrigin)" }
    )
    [PSCustomObject]@{
        Name                 = $_.Name
        InterfaceDescription = $_.InterfaceDescription
        Status               = $_.Status.ToString()
        MacAddress           = $_.MacAddress
        HardwareInterface    = $_.HardwareInterface
        IPv4                 = ($ips -join '; ')
    }
}

Write-Output '--- Adapters ---'
$adapters | Format-Table -AutoSize | Out-String -Width 300

Write-Output '--- VMSwitch ---'
Get-VMSwitch -ErrorAction SilentlyContinue | ForEach-Object {
    [PSCustomObject]@{
        Name                           = $_.Name
        SwitchType                     = $_.SwitchType.ToString()
        NetAdapterInterfaceDescription = $_.NetAdapterInterfaceDescription
        AllowManagementOS              = $_.AllowManagementOS
    }
} | Format-Table -AutoSize | Out-String -Width 300

Write-Output '--- External vNIC ---'
Get-NetAdapter | Where-Object { $_.Name -like 'vEthernet*' } | ForEach-Object {
    [PSCustomObject]@{
        Name                 = $_.Name
        Status               = $_.Status
        InterfaceDescription = $_.InterfaceDescription
        MacAddress           = $_.MacAddress
    }
} | Format-Table -AutoSize | Out-String -Width 300
