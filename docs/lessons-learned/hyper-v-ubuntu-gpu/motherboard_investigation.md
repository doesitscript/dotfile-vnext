# Motherboard investigation — GPU-P / SR-IOV on HOM-LAB-HVH-02

Evidence collected from the Windows host (`HOM-LAB-HVH-02`).

## Get-VMPartitionableGpu

Command:

```powershell
Get-VMPartitionableGpu
```

Returned the RTX 5090 correctly. Windows sees the GPU as partitionable.

```text
Name: \\?\PCI#VEN_10DE&DEV_2B85...GPUPARAV
ValidPartitionCounts: 32
PartitionCount: 32
TotalVRAM: 1000000000
AvailableVRAM: 1000000000
```

## IovSupportReasons

Exact messages reported by the platform:

```text
To use SR-IOV on this system, the system BIOS must be updated to allow Windows to control PCI Express. Contact your system manufacturer for an update.

SR-IOV cannot be used on this system as the PCI Express hardware does not support Access Control Services (ACS) at any root port. Contact your system vendor for further information.
```

## Hardware / platform

| Component | Value |
| --- | --- |
| CPU | AMD Ryzen 9 5900X 12-Core Processor |
| Motherboard | ASUSTeK COMPUTER INC. ROG STRIX X570-E GAMING WIFI II |
| BIOS | 5044 |
| OS | Windows Server 2025 Standard Evaluation, build 26100 |
| NVIDIA GPU | NVIDIA GeForce RTX 5090 |
| NVIDIA driver | 32.0.15.8129 (581.29 branch) |

## Hyper-V event evidence

Matches prior observations:

- With no GPU partition adapter, `hom-lab-ctl-k3s-02` starts normally.
- With the adapter attached, Hyper-V logs:
  - `12006`: `GPU Partition: Failed to finish reserving resources ... (0x800705AA)`
  - `12030`: VM failed to start

## Assessment

- `Get-VMPartitionableGpu` succeeding means this is not "Windows can't see the GPU" and not the simple "wrong NVIDIA driver family" class of failure.
- The first `IovSupportReason` still leaves room for a BIOS setting or update issue.
- The second reason is the heavier clue: `no ACS at any root port` points toward a platform / motherboard PCIe capability limit rather than MMIO sizing, guest Ubuntu setup, or K3s config.
- Treat the missing capability as host-platform SR-IOV/ACS support on `HOM-LAB-HVH-02`, not the Linux guest.

## Next host-side investigation

1. Work through [BIOS settings to verify](#bios-settings-to-verify) at the end of this document.
2. Confirm the 5090 is in **PCIEX16_1** (CPU-attached primary x16), not a chipset slot.
3. Determine whether this X570 board exposes ACS in a way Hyper-V accepts for GPU-P on this OS/driver combo.

## Deprioritized (not root cause)

- Guest NVIDIA package work
- K3s device plugin configuration
- vLLM role structure
- MMIO sizing as the primary culprit

## Current state

The repo fast-fails before re-breaking the VM, and `hom-lab-ctl-k3s-02` is back online.

## Definitions

Terms and BIOS/platform settings referenced in this investigation, with context for
`HOM-LAB-HVH-02` (ROG STRIX X570-E GAMING WIFI II, Ryzen 9 5900X, RTX 5090,
Windows Server 2025 + Hyper-V).

### GPU-P (GPU partitioning) and the GPU partition adapter

**GPU-P** is Hyper-V's model for giving a VM direct access to a slice of a physical
GPU instead of passing through the entire card (discrete device assignment / DDA) or
using a fully emulated display adapter.

On the host, `Get-VMPartitionableGpu` reports cards Windows considers splittable. In
the guest, Hyper-V exposes that slice through a **GPU partition adapter** (sometimes
called a GPU-PV or paravirtualized GPU adapter). The adapter is what you attach in
VM settings.

In this investigation:

- The host **does** list the RTX 5090 as partitionable (`GPUPARAV` in the device path).
- The VM **fails to start** when the partition adapter is attached (`12006` /
  `12030`, `0x800705AA`).
- That split — visible on the host, broken at VM start — usually means firmware/PCIe
  platform requirements for safe isolation are not fully met, not that the guest OS
  is misconfigured.

### SR-IOV (Single Root I/O Virtualization)

PCIe capability for exposing multiple virtual functions from one physical device.
Hyper-V checks IOV/SR-IOV prerequisites when evaluating GPU-P. Windows reported
SR-IOV-related `IovSupportReasons` on this host. What to check in firmware:
[SR-IOV](#sr-iov) under **BIOS settings to verify**.

### Access Control Services (ACS)

PCIe capability for isolating device traffic in the PCIe tree. Hyper-V reported missing
ACS at root ports on this host — the strongest platform-level clue. What to check in
firmware: [ACS](#acs-access-control-services) under **BIOS settings to verify**.

### MMIO sizing (Hyper-V host MMIO gaps)

**MMIO** (Memory-Mapped I/O) is the physical address space CPUs and devices use for
registers and GPU framebuffers. Hyper-V reserves **MMIO gaps** per VM and for host
devices. If gaps are too small, VM start can fail when assigning large BAR devices.

This is a common cause of DDA/GPU assignment failures and is controlled on Windows via
registry / `Set-VM` low MMIO gap settings and related host tuning.

**Relation to this investigation:** Deliberately **deprioritized** here. The host
already enumerates a partitionable 5090, and Windows's own `IovSupportReasons` text
points at **firmware PCIe control** and **ACS**, which are stronger, more specific
signals than generic MMIO pressure. Revisit MMIO gaps only if ACS/firmware paths are
exhausted and evidence shifts to BAR allocation errors without ACS wording.

### CPU-attached primary x16 slot (PCIEX16_1)

On the ROG STRIX X570-E GAMING WIFI II, **PCIEX16_1** is the first CPU-direct slot
(full x16 for a Ryzen 5900X when a single card is installed). **PCIEX16_2** shares
CPU lanes (x16 / dual x8 split when both are populated). **PCIEX16_3** hangs off the
X570 chipset and runs at chipset bandwidth (x4 mode per manual).

**Why slot choice matters for virtualization:**

- The **lowest-latency, CPU-attached** path is usually required for stable passthrough
  and partitionable GPU scenarios.
- Chipset downstream slots add bridges/ports where **ACS and isolation behavior** are
  often worse.
- Lane bifurcation (two GPUs at x8/x8) can change topology reporting.

For this host, confirm the 5090 is in **PCIEX16_1**, not PCIEX16_3 or a riser topology
that hides the root port Windows expects.

### Get-VMPartitionableGpu

PowerShell cmdlet that lists GPUs Hyper-V believes can be used for **partitioning**
(GPU-P). Output includes device identity, supported partition counts, and VRAM accounting
fields.

**How to read the results here:**

| Field | Meaning in this case |
| --- | --- |
| `Name` … `GPUPARAV` | Paravirtualized / partitionable GPU class, not whole-GPU DDA only |
| `ValidPartitionCounts` / `PartitionCount` | How many slices the stack thinks the card can expose |
| `TotalVRAM` / `AvailableVRAM` | Host-reported VRAM budget for partitioning (verify units/semantics if tuning) |

Success from this cmdlet means **driver + basic GPU-P eligibility**. It does **not**
prove VM start will succeed; firmware ACS/IOV checks happen later in the attach/start
path.

### IovSupportReasons

Windows/Hyper-V diagnostic strings explaining why **I/O virtualization** prerequisites
are not satisfied. They appear when the stack evaluates SR-IOV-related platform support
before or during GPU assignment.

Use them as **ordered hints**:

1. **BIOS / firmware PCIe ownership** — see [BIOS settings to verify](#bios-settings-to-verify).
2. **ACS at root port** — hardware/topology limitation; see [ACS](#acs-access-control-services) below.

### Hyper-V events `12006`, `12030`, and `0x800705AA`

| Signal | Typical meaning |
| --- | --- |
| Event `12006` | GPU partition resource reservation failed during VM bring-up |
| Event `12030` | VM failed to start (downstream of the reservation failure) |
| `0x800705AA` | Win32 `ERROR_NO_SYSTEM_RESOURCES` — insufficient or unavailable system resources for the requested GPU partition |

Together, these mean Hyper-V accepted the configuration enough to **try** attaching the
partition adapter, then failed while **reserving** host/GPU resources — consistent with
platform IOV/ACS/firmware limits rather than a guest package error.

## BIOS settings to verify

Items to confirm in firmware on `HOM-LAB-HVH-02` (ROG STRIX X570-E GAMING WIFI II,
current BIOS **5044**).

**Manual lookup result:** The extracted user manual
[`E19182_ROG_STRIX_X570-E_GAMING_WIFI_II_V2_UM_WEB.md`](E19182_ROG_STRIX_X570-E_GAMING_WIFI_II_V2_UM_WEB.md)
documents BIOS **entry**, **EZ Flash**, and **FlashBack** paths (Chapter 3). It does
**not** list SVM, IOMMU, Above 4G Decoding, Re-Size BAR, SR-IOV, or ACS — Chapter 3.1
points to a separate **BIOS manual** on ASUS support for full setting detail. Use BIOS
search (**F9** in ASUS UEFI) on the live system for those items.

After any change: save, **cold boot**, then re-check `IovSupportReasons` and retry GPU
partition adapter attach on `hom-lab-ctl-k3s-02`.

---

### BIOS update

**Verify**

- Compare installed version **5044** to the latest stable BIOS on
  [ASUS support](https://www.asus.com/support/) for ROG STRIX X570-E GAMING WIFI II.
- **In BIOS (documented):** Advanced Mode → **Tool** → **ASUS EZ Flash 3 Utility**
  (Chapter 3.3).
- **Without entering BIOS (documented):** BIOS FlashBack™ — rename BIOS file to
  **`SX570E2.CAP`** (or use **`BIOSRenamer.exe`** from the download package), copy to
  USB, insert in BIOS FlashBack™ port, press FlashBack button for 3 seconds (Chapter
  2.2).
- **Target:** newest stable release (not beta unless chasing a specific fix note).

**Definition**

Firmware that initializes hardware before the OS loads. Hyper-V reported that the
*"system BIOS must be updated to allow Windows to control PCI Express"* — the OS may
not have the PCIe management handoff it expects for I/O virtualization. A BIOS update
can fix that without changing hardware.

**Manual source:** Chapter 2.2, 3.2, 3.3 — EZ Flash and FlashBack paths documented.
Setting-level detail defers to ASUS BIOS manual on support site.

Definition — what the setting is and why it matters for this investigation
Items included:

BIOS items to look for: 
SVM Mode
IOMMU
Above 4G Decoding
Re-Size BAR Support
SR-IOV
ACS

Detailed items:
GPU-P and the GPU partition adapter
SR-IOV and how it relates to Hyper-V IovSupportReasons
ACS — why the X570 message matters and why it’s often a platform limit
Above 4G Decoding — what it does and why it’s secondary here
Resizable BAR — performance vs virtualization role
MMIO sizing — why it was deprioritized in this case
PCIEX16_1 slot placement on this board
Get-VMPartitionableGpu — how to read the output fields
IovSupportReasons — how to interpret the two messages
Events 12006 / 12030 / 0x800705AA — what they mean together

---

### SVM Mode

**Verify**

- **Menu (not in user-manual extract):** Advanced → CPU Configuration → SVM Mode — confirm
  on live BIOS with **F9** search for `SVM`.
- **Target:** **Enabled**

**Definition**

**SVM (Secure Virtual Machine)** is AMD's name for CPU hardware virtualization (AMD-V).
Hyper-V needs this enabled so the processor can run VMs and participate in host-side
virtualization, including paths that lead to GPU partitioning.

**Manual source:** **Not found** in `E19182_ROG_STRIX_X570-E_GAMING_WIFI_II_V2_UM_WEB.md`.
Verify on hardware or in the ASUS BIOS manual download.

---

### IOMMU

**Verify**

- **Menu (not in user-manual extract):** Advanced → AMD CBS → NBIO → IOMMU — or **F9**
  search for `IOMMU`.
- **Target:** **Enabled**

**Definition**

The **IOMMU** translates and restricts DMA from PCIe devices so a VM-assigned device
cannot read or write arbitrary host memory. Core building block for safe device
assignment. **Not** the same as **ACS** — enabling IOMMU does not add ACS on root ports.

**Manual source:** **Not found** in user-manual extract. Verify on hardware.

---

### Above 4G Decoding

**Verify**

- **Menu (not in user-manual extract):** Advanced → PCI Subsystem Settings → Above 4G
  Decoding — or **F9** search for `Above 4G`.
- **Target:** **Enabled**

**Definition**

Tells firmware to decode large 64-bit PCIe BAR addresses above the legacy 4 GiB MMIO
limit. The RTX 5090 needs this to expose its full memory-mapped space. Worth confirming
even though the primary failure message points at ACS, not MMIO exhaustion.

**Manual source:** **Not found** in user-manual extract. Verify on hardware.

---

### Re-Size BAR Support

**Verify**

- **Menu (not in user-manual extract):** Advanced → PCI Subsystem Settings → Re-Size BAR
  Support — or **F9** search for `BAR` / `Re-Size`.
- **Target:** **Enabled** — and **record on/off state** when retesting GPU-P

**Definition**

Lets the GPU expose a larger BAR so the CPU can access more VRAM directly. Mainly a
**performance** setting for bare-metal use, not the isolation feature Hyper-V needs for
GPU-P. Document the state during virtualization tests; unlikely to fix ACS errors.

**Manual source:** **Not found** in user-manual extract. Verify on hardware.

---

### SR-IOV

**Verify**

- **Menu (not in user-manual extract):** **F9** search for `SR-IOV`, `IOV`, or
  `Virtualization` under PCIe/NBIO menus.
- **Target:** **Enabled** if the option exists.
- **If absent:** note that — consumer AM4 boards often have no explicit SR-IOV toggle.

**Definition**

PCIe standard for presenting multiple **virtual functions (VFs)** from one physical
device. Hyper-V's GPU-P path shares IOV prerequisite checks with SR-IOV. Windows cited
SR-IOV in `IovSupportReasons`; a missing BIOS option may mean the platform does not
expose SR-IOV controls, not that guest config is wrong.

**Manual source:** **Not found** in user-manual extract. Verify on hardware.

---

### ACS (Access Control Services)

**Verify**

- **Menu (not in user-manual extract):** **F9** search for `ACS` or `PCIe isolation`
  under Advanced / AMD CBS / NBIO.
- **Target:** **Enabled** if the option exists.
- **If absent:** treat as likely **hardware limit** on X570 desktop silicon.

**Definition**

PCIe feature that isolates traffic between devices behind a root port so they cannot
bypass the hypervisor via peer paths. Hyper-V reported *"no ACS at any root port"* —
the strongest clue in this investigation. Consumer X570 boards often lack usable ACS at
CPU root ports; a BIOS toggle cannot add ACS the silicon does not provide.

**Manual source:** **Not found** in user-manual extract. Verify on hardware.

---

### PCIe slot placement (manual-documented, not a BIOS setting)

**Verify**

- GPU in **PCIEX16_1** (top CPU-direct slot), not **PCIEX16_3** (chipset x4).
- For Ryzen 5000 desktop (5900X): CPU provides **2 × PCIe 4.0 x16** (x16 single card, or
  dual x8 if both CPU slots populated).
- **PCIEX16_3** is chipset **PCIe 4.0 x16 physical, x4 mode** and **shares bandwidth
  with PCIE x1_2** per manual.

**Definition**

Slot choice affects PCIe topology and isolation behavior. CPU-attached x16 is the
preferred path for passthrough and partitionable GPU scenarios; chipset downstream slots
add bridges where ACS/isolation is often worse.

**Manual source:** Specifications summary — Expansion slots; board diagram labels
`PCIEX16_1`, `PCIEX16_2`, `PCIEX16_3`; note on x16_3 / x1_2 bandwidth sharing.
