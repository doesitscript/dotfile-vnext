---
deprecated: true
deprecating_reason: WSL scope reform 2026-05-28 — server paths must not use WSL
coordinator_review: pending
---

Here’s the straight, no‑nonsense truth: you’re reinventing the wheel because Hyper‑V + a raw Ubuntu ISO gives you zero automation primitives by default.  
Canonical does provide a fully automated path — but it’s not obvious, and Hyper‑V doesn’t expose it cleanly unless you know where to look.

Let me give you the landscape so you can stop fighting bootloaders and start deploying deterministic, headless Ubuntu VMs like a grown‑up cloud provider.

🧩 The Three Real Paths (and which one you actually want)
1️⃣ Use Canonical’s “Autoinstall” (cloud-init for bare metal/VMs)
This is the real answer.
This is what MAAS, Proxmox, VMware, and cloud providers use under the hood.

Ubuntu Server ISOs already contain:

cloud-init

the autoinstall subsystem

a fully noninteractive installer

support for injecting user-data + meta-data

support for preseed-like automation

support for SSH keys, packages, users, Docker install, etc.

You do NOT need a GUI. You do NOT need to click anything.

How it works
You provide two files:

Code
user-data
meta-data
Then you boot the ISO with a kernel parameter:

Code
autoinstall ds=nocloud-net;s=http://<your-host>/seed/
Or attach a virtual floppy/ISO containing:

Code
/nocloud/user-data
/nocloud/meta-data
Hyper‑V supports attaching a tiny ISO or VFD — that’s all you need.

What this gives you
Fully automated install

SSH ready on first boot

Users created

Packages installed

Docker installed

No GUI

No prompts

No bootloader weirdness

No rediscovering manual steps

This is the canonical, supported, future‑proof method.

2️⃣ Use a Prebuilt Cloud Image (the “cloud-init ready” QCOW/VHDX)
Canonical publishes official Ubuntu cloud images that:

boot instantly

already have cloud-init

skip the installer entirely

accept user-data on first boot

are designed for headless automation

You convert the QCOW2 → VHDX and attach it to a Hyper‑V VM.

This is how Azure, AWS, and OpenStack do it.

Pros
Fastest

No installer

No bootloader updates

Perfect for automation

Cons
Requires converting the disk

Slightly more setup on Windows

3️⃣ Vagrant + Hyper‑V
This is the “developer convenience” path.

Vagrant boxes:

already have SSH

already have cloud-init or provisioning hooks

already have sane defaults

already have Hyper‑V integration

But:

You’re limited to whatever boxes exist

You’re not learning the real automation path

It’s not as deterministic as autoinstall

This is fine for quick throwaway VMs, not for long‑term reproducible infra.

🧠 Which one makes sense for you?
Given your goals:

deterministic

audit-safe

no GUI

SSH ready

Docker ready

Hyper‑V automation

Cursor/Ansible integration

no rediscovery of manual steps

Option 1 (Canonical Autoinstall) is the correct path.  
It aligns with your entire philosophy: declarative, reproducible, zero-interaction, machine-friendly.

It also integrates perfectly with:

Ansible

Terraform

Packer

Hyper‑V automation scripts

NetBox-driven inventory

And it eliminates the “installer is updating the bootloader” nonsense you’re seeing right now.

🛠️ What your workflow should look like
Step 1 — Create a seed ISO
Inside a folder:

Code
/nocloud/user-data
/nocloud/meta-data
user-data contains:

SSH keys

users

packages

Docker install

systemd units

first-boot scripts

meta-data can be empty.

Generate a tiny ISO:

Code
genisoimage -output seed.iso -volid cidata -joliet -rock nocloud/
Step 2 — Boot the Ubuntu ISO with the seed ISO attached
Hyper‑V VM:

DVD 1 → Ubuntu ISO

DVD 2 → seed.iso

Ubuntu sees the NoCloud datasource → autoinstall runs → done.

Step 3 — VM boots into a fully configured, Docker-ready Ubuntu
No GUI.
No prompts.
No rediscovery.
No manual steps.

🧨 Why your current approach feels chaotic
Because the Ubuntu installer is not designed to be automated unless you explicitly activate autoinstall.
Without that, it behaves like a desktop installer:

interactive

slow

updates bootloader

asks questions

expects a human

You’re fighting the wrong layer.

If you want, I can generate:
a complete autoinstall user-data for:

SSH

Docker

cloud-init first boot

system hardening

a Hyper‑V PowerShell script that:

creates the VM

attaches the ISOs

sets CPU/RAM

sets network

boots into autoinstall

a deterministic directory structure for your automation repo

a Cursor agent prompt that enforces this workflow

Just tell me which piece you want next.

'Then you boot the ISO with a kernel parameter:

Code
autoinstall ds=nocloud-net;s=http://<your-host>/seed/' how do you provide this?
Great question — this is the part Canonical never explains clearly, and it’s exactly where most people get stuck.
How do you actually provide that kernel parameter to the Ubuntu ISO when booting under Hyper‑V?

There are three practical ways to do it, and only one of them is clean and repeatable.

Let me walk you through them in order of “works but painful” → “the correct, deterministic way.”

🟥 1. Editing the GRUB command line manually (works, but defeats automation)
When the ISO boots and you see:

Code
Try or Install Ubuntu Server
You can press e to edit the GRUB entry, then append:

Code
autoinstall ds=nocloud-net;s=http://<your-host>/seed/
But:

this requires a console

this requires a human

this is not deterministic

this breaks your automation goals

You should not use this method.

🟧 2. Rebuilding the ISO with the kernel parameter baked in (possible, but annoying)
You can unpack the ISO, modify grub.cfg, and rebuild it.

But:

it’s fragile

it’s slow

it’s unnecessary

it’s not how Canonical expects you to do it

This is only used by people building custom distros.

🟩 3. The correct method: attach a NoCloud seed ISO and let Ubuntu detect it automatically
This is the method cloud providers use.
This is the method Canonical documents (poorly).
This is the method that requires no kernel parameters at all.

Why?
Because Ubuntu’s autoinstall subsystem automatically activates when it detects a NoCloud datasource.

If you attach a second ISO containing:

Code
/nocloud/user-data
/nocloud/meta-data
Ubuntu sees it → cloud-init sees it → autoinstall runs → no kernel args required.

This is the clean, deterministic, automation-friendly method.
🟩 How to do it (the real workflow)
Step 1 — Create your seed directory
Code
seed/
  nocloud/
    user-data
    meta-data
meta-data can be empty:

Code
instance-id: ubuntu-autoinstall
Step 2 — Build the seed ISO
On Linux or WSL:

Code
genisoimage -output seed.iso -volid cidata -joliet -rock seed/
This produces a tiny ISO (~5 KB).

Step 3 — Attach both ISOs to the Hyper‑V VM
DVD Drive 1 → Ubuntu Server ISO

DVD Drive 2 → seed.iso

Step 4 — Boot the VM
Ubuntu sees the NoCloud datasource → autoinstall triggers → fully automated install.

No kernel parameters.
No GRUB editing.
No GUI.
No prompts.
No rediscovery of manual steps.

🟦 If you really want to use the kernel parameter
Hyper‑V does not expose a native way to pass kernel args like QEMU does.

So your only options are:

Option A — Manually edit GRUB at boot
(press e, append the line)

Option B — Rebuild the ISO with the parameter baked into grub.cfg
(annoying, fragile)

Option C — Use a PXE boot environment
(overkill for a homelab)

This is why everyone uses the seed ISO method.

🧠 TL;DR
You don’t need kernel parameters at all.
Just attach a NoCloud seed ISO and Ubuntu will autoinstall automatically.

If you want, I can generate:

a complete user-data for your exact needs

a PowerShell script that creates the VM, attaches both ISOs, and boots it

a deterministic directory layout for your automation repo

Just tell me what you want next.

do it allif possible in the next response. all please
See my thinking
Got you—let’s make this a single, deterministic pattern you can reuse forever.

Directory layout for your automation repo
Use something like:

text
ubuntu-autoinstall/
  iso/
    ubuntu-24.04-live-server-amd64.iso
    seed.iso
  seed/
    nocloud/
      user-data
      meta-data
  hyperv/
    New-UbuntuVM.ps1
  docs/
    README.md
iso/: Canonical ISO + generated seed.iso.

seed/nocloud/: cloud-init autoinstall config.

hyperv/: PowerShell automation.

docs/: any notes, version pins, etc.

user-data — fully automated, headless Ubuntu + SSH + Docker
Path: seed/nocloud/user-data

yaml
#cloud-config
autoinstall:
  version: 1
  locale: en_US
  keyboard:
    layout: us
    variant: ''
  identity:
    hostname: ubuntu-autoinstall
    username: josh
    # Replace this with a hashed password if you want password login enabled
    # mkpasswd --method=SHA-512
    password: "$6$rounds=4096$REPLACE_WITH_HASH$REPLACE_WITH_HASH_MATERIAL"
  ssh:
    install-server: true
    authorized-keys:
      - "ssh-ed25519 AAAA...REPLACE_WITH_YOUR_KEY... josh@host"
    allow-pw: false
  storage:
    layout:
      name: lvm
  packages:
    - git
    - curl
    - htop
    - ca-certificates
    - apt-transport-https
    - software-properties-common
  late-commands:
    # Enable SSH passwordless sudo for the primary user
    - curtin in-target --target=/target -- /usr/bin/bash -c "echo 'josh ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/90-josh-nopasswd && chmod 440 /etc/sudoers.d/90-josh-nopasswd"

    # Install Docker using official convenience script
    - curtin in-target --target=/target -- /usr/bin/bash -c "curl -fsSL https://get.docker.com | sh"

    # Add user to docker group
    - curtin in-target --target=/target -- /usr/bin/bash -c "usermod -aG docker josh"

    # Optional: create a marker file for audit/debug
    - curtin in-target --target=/target -- /usr/bin/bash -c "echo 'autoinstall complete: $(date -Iseconds)' >/var/log/autoinstall-complete"

  user-data:
    disable_root: true
    timezone: America/Chicago
    package_update: true
    package_upgrade: true
    final_message: "Ubuntu autoinstall complete. System ready."

  # No interactive questions
  interactive-sections: []
Edit these before use:

hostname: set per-VM or pattern.

username: your primary user.

password: either:

real SHA-512 hash, or

remove password and rely on SSH key only.

authorized-keys: your real SSH public key.

meta-data — minimal but required
Path: seed/nocloud/meta-data

yaml
instance-id: ubuntu-autoinstall-01
local-hostname: ubuntu-autoinstall
You can vary instance-id per VM if you want.

Build the NoCloud seed ISO
From the ubuntu-autoinstall/ root (on Linux or WSL):

bash
mkdir -p seed/nocloud

# (Put user-data and meta-data in seed/nocloud first)

genisoimage \
  -output iso/seed.iso \
  -volid cidata \
  -joliet -rock \
  seed/
Output: iso/seed.iso

Volume label cidata is what cloud-init expects.

Hyper‑V PowerShell script — create VM, attach ISOs, boot
Path: hyperv/New-UbuntuVM.ps1

powershell
param(
    [string]$VmName = "ubuntu-autoinstall-01",
    [int]$MemoryMB = 4096,
    [int]$VCPUs = 2,
    [string]$VhdPath = "C:\HyperV\Disks\ubuntu-autoinstall-01.vhdx",
    [string]$SwitchName = "Default Switch",
    [string]$IsoUbuntu = "C:\repos\ubuntu-autoinstall\iso\ubuntu-24.04-live-server-amd64.iso",
    [string]$IsoSeed = "C:\repos\ubuntu-autoinstall\iso\seed.iso"
)

# Create VHD folder if needed
$diskDir = Split-Path $VhdPath
if (-not (Test-Path $diskDir)) {
    New-Item -ItemType Directory -Path $diskDir | Out-Null
}

Write-Host "Creating VHDX at $VhdPath..."
New-VHD -Path $VhdPath -SizeBytes 40GB -Dynamic | Out-Null

Write-Host "Creating VM $VmName..."
New-VM -Name $VmName `
       -MemoryStartupBytes (${MemoryMB}MB) `
       -Generation 2 `
       -NewVHDPath $VhdPath `
       -NewVHDSizeBytes 40GB `
       -SwitchName $SwitchName | Out-Null

Write-Host "Configuring CPU..."
Set-VMProcessor -VMName $VmName -Count $VCPUs

Write-Host "Adding Ubuntu ISO..."
Add-VMDvdDrive -VMName $VmName -Path $IsoUbuntu | Out-Null

Write-Host "Adding seed ISO..."
Add-VMDvdDrive -VMName $VmName -Path $IsoSeed | Out-Null

Write-Host "Setting boot order (DVD first)..."
$vm = Get-VM -Name $VmName
$dvdDrives = Get-VMDvdDrive -VMName $VmName
Set-VMFirmware -VMName $VmName -FirstBootDevice $dvdDrives[0]

Write-Host "Starting VM..."
Start-VM -Name $VmName

Write-Host "VM $VmName started. Autoinstall should run non-interactively."
Adjust paths:

$IsoUbuntu: path to Canonical ISO.

$IsoSeed: path to seed.iso.

$VhdPath: where you want the VM disk.

Run it:

powershell
cd C:\repos\ubuntu-autoinstall\hyperv
.\New-UbuntuVM.ps1 -VmName "ubuntu-autoinstall-01"
What you should see
VM boots from Ubuntu ISO.

Ubuntu detects cidata (seed.iso) as NoCloud datasource.

Autoinstall runs with no prompts.

System reboots into installed Ubuntu.

You can SSH in:

bash
ssh josh@<vm-ip>
Using the SSH key you put in user-data.
