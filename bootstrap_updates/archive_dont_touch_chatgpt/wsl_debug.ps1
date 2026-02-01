systeminfo | findstr /i hyper
Hyper-V Requirements:          A hypervisor has been detected. Features required for Hyper-V will not be displayed.


# Shutdown WSL
wsl --shutdown

# Stop WSL service (if it exists)
$wslService = Get-Service | Where-Object { $_.Name -like "*wsl*" -or $_.Name -like "*lxss*" -or $_.DisplayName -like "*Linux*Subsystem*" }
if ($wslService) {
    Stop-Service -Name $wslService.Name -Force -ErrorAction SilentlyContinue
}

# Remove all VHDX files from WSL directory
Remove-Item -Path "$env:LOCALAPPDATA\wsl\*.vhdx" -Force -ErrorAction SilentlyContinue

# Remove ext4.vhdx files recursively
Get-ChildItem -Path "$env:LOCALAPPDATA\wsl" -Recurse -Filter "ext4.vhdx" -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

wsl.exe --list --online
wsl.exe --list --verbose








##
Get-ComputerInfo | Select-Object HyperVRequirementVirtualizationFirmwareEnabled

HyperVRequirementVirtualizationFirmwareEnabled
----------------------------------------------
                                          True

                                          systeminfo.exe | Select-String "Virtualization Enabled In Firmware"

                                          Virtualization Enabled In Firmware: Yes      

                                          wsl.exe --list --verbose
                                          Get-WindowsOptionalFeature -Online | Where-Object { $_.State -eq "Enabled" -and $_.FeatureName -like "*Virtual*" }
                                          #Manual:
                                          Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

                                          Get-Service LxssManager              


                                          ###


#####
        wsl.exe --install --no-distribution

        Installing Windows optional component: VirtualMachinePlatform

        Deployment Image Servicing and Management tool
        Version: 10.0.26100.5074
        
        Image Version: 10.0.26100.32230
        
        Enabling feature(s)
        [==========================100.0%==========================] 
        The operation completed successfully.
        The requested operation is successful. Changes will not be effective until the system is rebooted.

        wsl --status
        Default Distribution: Ubuntu
        Default Version: 2
        WSL1 is not supported with your current machine configuration.
        Please enable the "Windows Subsystem for Linux" optional component to use WSL1.

        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux 
        
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
WARNING: Restart is suppressed because NoRestart is specified.


Path          :
Online        : True
RestartNeeded : True