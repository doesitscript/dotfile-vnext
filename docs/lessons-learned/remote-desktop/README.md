# Remote Desktop: raising the RDP frame-rate cap (60 FPS)

Windows can **cap** what Remote Desktop Protocol delivers toward **~30 FPS** by default. Two levers are often used together in the field; they address **different layers** (composition interval vs. graphics encoding).

**Authoritative reference (Part 1):** [Frame rate is limited to 30 FPS in remote sessions](https://learn.microsoft.com/en-us/troubleshoot/windows-server/remote/frame-rate-limited-to-30-fps) (Microsoft Learn).

**Important:** These settings raise **limits or encoding behavior**. They do **not** guarantee 60 FPS. Actual frame rate depends on hardware, session load, and network.

---

## Part 1 — Registry: `DWMFRAMEINTERVAL` (Microsoft Learn)

This is the **supported** way Microsoft documents to raise the **maximum** frame rate the remote display path can deliver toward **60 FPS**.

| Item | Value |
|------|--------|
| Hive | `HKEY_LOCAL_MACHINE` |
| Key | `SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations` |
| Name | `DWMFRAMEINTERVAL` |
| Type | `REG_DWORD` (32-bit) |
| Value (decimal) | `15` (documented as the value that sets the cap toward 60 FPS) |

**Steps (summary):**

1. Open Registry Editor as an administrator (or deploy the same value via your automation).
2. Navigate to `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations`.
3. Create a new **DWORD (32-bit)** value named **`DWMFRAMEINTERVAL`** (exact spelling).
4. Set **Base** to **Decimal** and **Value data** to **`15`**.
5. Exit Registry Editor and **restart the computer** (Microsoft’s article specifies a full restart).

**Undo:** Delete `DWMFRAMEINTERVAL` from that key (or set it back to absent default behavior after documenting what “default” was on your build), then restart again.

**Caveats:**

- Learn article applies to the **remote session host** side (the machine you RDP **into**).
- Some Windows versions and RDS-style setups have reports where **Part 1 alone** still did not yield 60 FPS; treat extra troubleshooting as environment-specific (see Microsoft Q&A threads linked from the same topic area if needed).

**Scripts (PowerShell, run elevated):**

- Part 1: `docs/lessons-learned/remote-desktop/scripts/Set-RdpFrameRateCap.ps1` (optional `-Remove` to undo)
- Part 2: `docs/lessons-learned/remote-desktop/scripts/Set-RdpAvc444Policy.ps1` (optional `-IncludeHardwareEncoding`; `-Remove` to undo both values this script manages)

---

## Part 2 — Group Policy: H.264/AVC 444 and optional hardware encoding

Part 2 does **not** replace Part 1. It changes **how** Remote Desktop Services can prioritize **H.264/AVC 444** graphics encoding, which many users combine with Part 1 for smoother motion and clearer UI in motion-heavy workloads.

Policies live under the **Remote Desktop Session Host** administrative template tree (exact visibility can depend on Windows **edition** and whether RDS Session Host role/features are present).

**Path in Local Group Policy Editor (`gpedit.msc`):**

`Computer Configuration` → `Administrative Templates` → `Windows Components` → `Remote Desktop Services` → `Remote Desktop Session Host` → `Remote Session Environment`

**Policies to document:**

1. **Prioritize H.264/AVC 444 graphics mode for Remote Desktop connections**  
   - Set to **Enabled** if you want this encoding mode prioritized for applicable scenarios.  
   - Read the **Explain** tab in the policy UI for Microsoft’s scope wording (non–RemoteFX / vGPU scenarios, etc.).

2. **Configure H.264/AVC hardware encoding for Remote Desktop connections** (optional)  
   - Can offload encoding to the GPU on supported configurations.  
   - Community write-ups report mixed results (sometimes slightly worse on some hardware); treat as **try and measure**.

After policy changes, a **restart** or at least a policy refresh and **RDS / relevant service** restart may be required depending on the machine; follow the policy UI guidance.

**Undo:** Set policies to **Not Configured** or **Disabled** as appropriate, then refresh policy / restart per your change.

---

## When to restart (Part 1 only)

Apply **Part 1** (create or set `DWMFRAMEINTERVAL` = 15 decimal), then **restart once**. That matches Microsoft Learn.

If you are **only** doing Part 1 for now: you do **not** need to wait on Part 2 before that restart.

---

## References (external)

- Microsoft Learn — frame rate cap / `DWMFRAMEINTERVAL`:  
  https://learn.microsoft.com/en-us/troubleshoot/windows-server/remote/frame-rate-limited-to-30-fps  
- Community overview of AVC 444 policy (not a substitute for reading the policy text in `gpedit.msc`):  
  https://www.edandersen.com/p/improve-remote-desktop-frame-rate-to-60fps-by-enabling-avc-444-encoding  
