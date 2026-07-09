
The live kernel driver file in use is:
C:\Windows\System32\DriverStore\FileRepository\nvmdsi.inf_amd64_e82263d194ad754a\nvlddmkm.sys
I also confirmed:
GPU: NVIDIA GeForce RTX 5090
Service: nvlddmkm
Published INF: oem18.inf
Original INF: nvmdsi.inf
Driver version: 32.0.15.8129
Related NVIDIA files/locations on the host:
C:\Windows\System32\nvapi64.dll
C:\Windows\System32\nvcuda.dll
C:\Program Files\NVIDIA Corporation\NVIDIA App
C:\Program Files\NVIDIA Corporation\NvContainer
C:\Program Files\NVIDIA Corporation\Installer2
C:\Program Files\NVIDIA Corporation\FrameViewSDK
C:\Program Files\NVIDIA Corporation\NvTelemetry

Important detail: on your system the display driver package is nvmdsi.inf, not nv_dispi.inf, so if we do any HostDriverStore-style copy work later, this is the folder we’d start from:
C:\Windows\System32\DriverStore\FileRepository\nvmdsi.inf_amd64_e82263d194ad754a



search GitHub for "dxgkrnl dkms";

there are a few maintained forks specifically for running GPU-P in full Hyper-V Linux VMs

######
Copy more than just those two. In that same nvmdsi.inf_amd64_... folder there should be several sibling files you'll want, typically including:

libcuda.so.1.1 (and you'll create the libcuda.so.1 / libcuda.so symlinks yourself)
libnvidia-ml.so.1
libnvidia-ptxjitcompiler.so.1 (CUDA needs this for JIT compilation)
nvidia-smi (yes, a Linux ELF binary lives in the Windows driver store — handy for verification)
possibly libnvcuvid, libnvidia-encode, libnvoptix, etc. depending on driver

Grab all the .so* files plus nvidia-smi rather than cherry-picking two.


Placement in the guest. Mirror the WSL convention so tools behave predictably:
bashsudo mkdir -p /usr/lib/wsl/lib
# copy files in, then:
cd /usr/lib/wsl/lib
sudo ln -s libcuda.so.1.1 libcuda.so.1
sudo ln -s libcuda.so.1 libcuda.so
echo /usr/lib/wsl/lib | sudo tee /etc/ld.so.conf.d/wsl.conf
sudo ldconfig
***


# Finalization:
After it loads and binds, you should see dxg in lsmod and /dev/dxg appear. That's your checkpoint before touching userspace.
