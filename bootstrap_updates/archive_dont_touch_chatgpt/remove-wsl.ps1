dism /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart

### Restartf
dism /online /cleanup-image /restorehealth
sfc /scannow

dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

sc query LxssManager
If it’s not present, stop — the feature install is still broken.

5. Install Ubuntu
Code
wsl --install -d Ubuntu


# wsl --uninstall removes:

# Distros

# Kernel

# User‑mode binaries

# But it does not remove or repair:

# Broken optional feature state

# Broken Hyper‑V Platform state

# Broken VHDMP storage filter

# Component store corruption

# Pending feature enable/disable

# Rollback leftovers


# #Why this works when everything else didn’t
# Because this sequence:

# Removes the broken feature state

# Repairs the component store

# Reinstalls the WSL user‑mode stack

# Reinstalls the virtualization platform

# Ensures LxssManager exists before distro install

# Ensures VHDMP is functional before VHDX creation

# It’s the only path that fixes the underlying cause instead of the 


w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:yes /update
net stop w32time
net start w32time
w32tm /resync /force

https://learn.microsoft.com/en-us/windows/wsl/install-manual
tasklist /svc /fi "imagename eq svchost.exe" | findstr LxssManager
