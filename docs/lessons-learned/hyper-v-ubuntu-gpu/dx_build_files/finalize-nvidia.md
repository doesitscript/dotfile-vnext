That empty `/usr/lib/wsl/drivers` is exactly the missing piece, and it explains the failure precisely. Here's the mechanism:

When `nvidia-smi`/`libcuda` initialize, they go through `libdxcore` → `/dev/dxg` → host, and the **host replies with the Windows DriverStore path of the driver package** for the adapter (your `nvmdsi.inf_amd64_e82263d194ad754a` folder). libdxcore then translates that Windows path into a Linux one under `/usr/lib/wsl/drivers/<same folder name>/` and the runtime loads additional components from there. In WSL, that directory is a live 9p mount of `C:\Windows\System32\DriverStore\FileRepository` — that's why the host's WSL distro shows it populated. In your full VM there's no such mount, so the lookup dead-ends: the runtime is told "your driver bits are in folder X" and folder X doesn't exist.

So the fix is to recreate that path with real files:

```bash
sudo mkdir -p /usr/lib/wsl/drivers
```

Then copy the **entire** `nvmdsi.inf_amd64_e82263d194ad754a` folder from the host's DriverStore into it, so the guest ends up with:

```
/usr/lib/wsl/drivers/nvmdsi.inf_amd64_e82263d194ad754a/
├── libcuda.so.1.1
├── libnvidia-ml.so.1
├── nvidia-smi
└── ... (everything else in that folder)
```

Three things that matter here:

1. **The folder name must match exactly** — the host reports that specific directory name, so don't rename, shorten, or lowercase it. This also means when the host NVIDIA driver updates, the reported folder name changes (new hash suffix) and you'll need to copy the new folder in.
2. **Copy the whole folder, not just the .so files.** It's a few hundred MB, but the runtime may pull in pieces beyond the obvious ones, and disk is cheaper than another round of strace archaeology. You can prune later once it works.
3. **Case sensitivity** is a known gotcha on this path — libdxcore's translation of the Windows path can produce different casing than what you copied. If nvidia-smi still fails after the copy, run your strace again (`strace -f -e trace=openat ... | grep -i drivers`) and compare the exact path it attempts against what's on disk; a mismatched-case symlink fixes it.

Also check `/dev/dxg` permissions while you're in there — depending on the dxgkrnl-dkms udev setup it may be root-only, and nvidia-smi run as a normal user will fail differently. `ls -l /dev/dxg`; if it's `600 root:root`, test with sudo first, then add a udev rule for your user.

After the copy: rerun `nvidia-smi` (the one in the drivers folder or your `/opt/gpu-p/lib` copy — either should now resolve). If it prints the GPU, you're through the hard part and the remaining work is just CUDA toolkit installation, which is standard from there.
