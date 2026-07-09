To get around this, you need to create 2 keys in Reg edit.

HKLM:\SOFTWARE\Policies\Microsoft\Windows\HyperV" -Name "RequireSecureDeviceAssignment" -Type DWORD -Value 0

HKLM:\SOFTWARE\Policies\Microsoft\Windows\HyperV" -Name "RequireSupportedDeviceAssignment" -Type DWORD -Value 0

I closed off MMC.exe from Task Manager before attempting to run the VM again.

Try to launch the VM again by running the following command in Powershell: Start-VM Server123

(Replace "Server123" with your recently created guest server name).

Your server should now boot up with no error. I installed drivers in the guest and tested by running a 4K youtube video, and watched the resource spike up on the host machine's task manager.

Notes:

• Make sure that you install GPU drivers on the host machine before doing any of the above.

• Make sure to install GPU drivers on the guest VM when after creation and booting into it.

• Normally, GPU resources are not visible in the guest VM.

• Check Device manager to make sure the GPU shows up and is enabled. If it isn't, you need to extract the drivers from the host machine and re-assign them to the VM. The link below should help: GPU Virtualization with Hyper-V – James' Personal Site (mu0.cc) , and possibly GPU Virtualization with Hyper-V – James' Personal Site (mu0.cc)


I'm not a very active user so getting back to comments may not be as quick as some would expect, but please do leave any issues, queries or observations in the comments so that other could potentially assist if I don't get back to you in time.

Please also feel free to start discussions on the comments, just try not to get off topic to make it easier for others to find answers for questions they may be looking for.
