#  adapt teh follwoing to:

# the following two lines are meant to be adapted into answerable, to replace my current default shell which is currently set to wsl.exe
#  Add an additional block to especially create the registry item. Make a item potently, 
# Again adapt these, just as long as you achieve the same output, it's not necessary to try to mimic the exact behavior that the commands are written to do # I'm sure whenever you replace the current default shell behavior, to pay attention, the second line here is creating a new property on the first line. So make sure that you pick a resource that does the equivalent of these commands
# and this will likely be new into our resources to, the third line. So if I'm not mistaken you will need to have three resource blocks to adapt the following three lines
New-Item -Path 'HKLM:\SOFTWARE\OpenSSH' -Force | Out-Null #
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -PropertyType String -Force
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShellCommandOption -Value '-NoLogo -NoProfile -c' -PropertyType String -Force


# Replace the existing subsystem  that is configured in windows dir: C:\ProgramData\ssh\sshd_config
# also ensure the mac .ssh/config jinga by replacing the configuration in the mac's .ssh/config file, the block with thehost  alias: server-225-win-powershell-bysession
# remove  this line from there'Port 2223' 
Subsystem powershell C:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -sshs -NoLogo -NoProfile

# What does devices we will not be using multiplexing so change the following:
# Replace the related control setting *that are in windows blocks* so that they match the foling
ControlMaster no
ControlPath none