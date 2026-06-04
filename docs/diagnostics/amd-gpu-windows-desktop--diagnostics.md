# AMD GPU Windows Desktop Diagnostic Sources

**Primary host:** `dev-workstation-win` / **DESKTOP-C1ACPUM** / **192.168.50.132**  
**Gaming user:** `ericc`  
**GPU:** AMD Radeon RX 9060 XT 16GB (TBP ~160W; ASUS `SUBSYS_061E1043`)

Related:

- [../one_off_tasks/on-offs/DESKTOP-C1ACPUM-gpu-fps.md](../one_off_tasks/on-offs/DESKTOP-C1ACPUM-gpu-fps.md) — on/off timeline
- [../one_off_tasks/DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md](../one_off_tasks/DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md) — DWM/overlay analysis
- Ansible: `roles/gpu_diagnostics_windows`, `playbooks/troubleshoot/deploy_dev_workstation_gpu_diagnostics.yaml`

---

## Evidence gap matrix

| Evidence needed | Remote success so far | Why it failed |
|-----------------|----------------------|---------------|
| **GPU board power (W)** | No numeric watts | No Windows perf counter for AMD board power; `GpuEnergyDrv` disabled; no HWiNFO until role apply |
| **FPS / frametime during stall** | `95th percentile frame time: 0` | Adrenalin Frame Time not tracked; no PresentMon/HWiNFO CSV |
| **Time-series log (SSH-pullable)** | None | Afterburner `.hml` not enabled; RTSS has no disk logs |
| **GPU temp / hotspot** | Not collected | Same sensor gap |
| **DWM thrashing** | Event **500** yes | `Microsoft-Windows-Diagnostics-Performance/Operational` |

**What we got** column in on-offs docs = factual pulse/artifact output only ([on-offs README](../one_off_tasks/on-offs/README.md)).

---

## Logging locations

| Source | Path |
|--------|------|
| AMD Adrenalin metrics / exports | `C:\Users\ericc\AppData\Local\AMD\CN\` (`RGStats.db`, `RAG_CNDB_GAME\*.md`) |
| HWiNFO CSV (role) | `D:\ai\diagnostics\hwinfo\` |
| PresentMon CLI (optional) | `D:\ai\diagnostics\presentmon\` |
| MSI Afterburner (manual) | `D:\ai\diagnostics\afterburner\*.hml` |
| Collector script output | `D:\ai\diagnostics\probes\` |
| DWM thrashing | Event log: `Microsoft-Windows-Diagnostics-Performance/Operational` ID **500** |
| DBD game log | `C:\Users\ericc\AppData\Local\DeadByDaylight\Saved\Logs\DeadByDaylight.log` |

---

## Diagnostic commands

- `Get-Counter '\GPU Engine(*engtype_3D)\Utilization Percentage'`
- `Get-Counter '\GPU Adapter Memory(*)\Dedicated Usage'`
- `Get-WinEvent -LogName 'Microsoft-Windows-Diagnostics-Performance/Operational' -MaxEvents 10`
- `D:\ai\diagnostics\probes\collect-gpu-evidence.ps1` (deployed by role)
- Latest HWiNFO CSV: `Get-ChildItem D:\ai\diagnostics\hwinfo\*.csv | Sort LastWriteTime -Desc | Select -First 1`

---

## Ansible apply / verify

```text
bin/codex-env ansible-playbook playbooks/troubleshoot/deploy_dev_workstation_gpu_diagnostics.yaml \
  -i inventory/inventory.yaml --limit dev-workstation-win

bin/codex-env ansible-playbook playbooks/troubleshoot/collect_dev_workstation_gpu_artifacts.yaml \
  -i inventory/inventory.yaml --limit dev-workstation-win
```

Artifacts land under `artifacts/troubleshooting/dev_workstation_win_gpu/<host>/<timestamp>/`.

---

## SDK decision (ADLX / amd-smi)

| Option | Use on this host |
|--------|------------------|
| **HWiNFO64 ≥7.63** | **Primary** — power, temps, integrated PresentMon (FPS, frametime, GPU Busy). CLI `-l` auto-log may require **HWiNFO Pro**; role uses interactive logon task for user `ericc` on `dev-workstation-win`. |
| **PresentMon CLI** | Optional tag `presentmon_cli` if HWiNFO PM sensor is wrong |
| **ADLX** | Phase 3 only if HWiNFO CSV lacks GPU power under load |
| **amd-smi / ROCm** | **Skip** on Windows consumer RX 9060 XT |

---

## BIOS — CSM on Z170 + RX 9060 XT

**CSM enabled** is a poor match for this GPU generation.

- AMD documents **UEFI-only** expectations for **RDNA4 / RX 9000** class cards.
- **CSM on** usually blocks **Above 4G Decoding** and **Resizable BAR (ReBAR)** — both matter for VRAM visibility and performance on modern AMD GPUs.
- Order when tuning BIOS: **disable CSM** (after confirming Windows boots **GPT + UEFI**) → **enable Above 4G** → **enable ReBAR** → enable **XMP** for the DDR4 kit.

Unlikely to be the sole cause of 1–5 FPS stalls, but it is a legitimate structural misconfiguration for this hardware stack.

---

## Eric manual playbook (do as **ericc**)

Registry-only remote changes **do not stick** after Adrenalin/driver reinstall — use the UI.

### Modes

| Mode | Goal | Overlays |
|------|------|----------|
| **A — Highest FPS** | Repro DBD with least compositor/capture load | Metrics **logging ON**, on-screen overlay **minimal** |
| **B — Stall diagnosis** | Capture 1–5 FPS stall | Add **Ctrl+Shift+O** + RTSS frametime (one session) |

Start with **Mode A**; use **Mode B** only for stall capture.

### 0) Before Adrenalin

| Setting | Where | For highest FPS |
|---------|--------|-----------------|
| Xbox Game Bar capture | Settings → Gaming → Captures | **OFF** |
| Xbox Game Bar | Settings → Gaming | **OFF** |
| Wallpaper Engine | Tray / Steam | **Exit** |
| AMD Chat | Adrenalin / tray | **Quit** |
| Discord overlay | Discord → Game Overlay | **OFF** |
| Steam overlay | Steam → In-Game | **OFF** for DBD test |

### 1) Adrenalin — Global

**Gaming → Global Graphics:** Anti-Lag **OFF**, Chill **OFF**, Boost **OFF**, Sharpening **OFF**, Enhanced Sync **OFF**, VSync **Off unless app specifies**, Texture Filtering **Performance**, AA **Use application settings**.

**Media & Capture → ReLive:** Record / Stream / Instant Replay / toolbar **OFF**.

**Performance → Tuning:** Preset **Default**, Power Tuning **Disabled** (0%), no manual OC.

**Performance → Metrics:** **Start Logging ON** (0.25s or 1s). Track **Yes**: GPU Power, GPU Temp, Hotspot, GPU Usage, **FPS**, **Frame Time**, VRAM (optional). Log path: `C:\Users\ericc\AppData\Local\AMD\CN\`. Mode A: overlay **OFF**; Mode B: overlay **ON**, test **Ctrl+Shift+O** in DBD.

### 2) Adrenalin — Dead by Daylight

| Setting | Set to |
|---------|--------|
| Gaming Experience | **Default** |
| AMD FSR Upscaling | **Disabled** |
| FSR OTA | **Disabled** |
| Chill / Anti-Lag / Sharpening / Enhanced Sync | **Off** |
| Texture Filtering | **Performance** |
| FreeSync | **On** or **AMD optimized** |
| Custom Color | **Disabled** if possible |

### 3) MSI Afterburner + RTSS (optimized for this host)

Tonight’s evidence: **windowed DBD** produced bogus **~50 W** and **N/A FPS** in logs;
**fullscreen exclusive** + correct Monitoring lines produced **~100 W @ ~99% GPU** and
**~60 FPS / ~18–23 ms** in `D:\ai\HardwareMonitoring.hml`, matching Adrenalin
`GPU BRD PWR` in `Hardware.*.CSV`. MSI cannot force **~160 W TBP** if the game is
**CPU-bound** at **~60 FPS** — that is not an Afterburner bug.

#### 3a) MSI Afterburner — Settings → Monitoring

For each row below, enable **Show in On-Screen Display** only in **Mode B**, and
enable **Log history to file** in both modes:

| Graph line (pick exact AMD/RX 9060 XT labels) | Purpose |
|-----------------------------------------------|---------|
| GPU temperature | Thermals |
| GPU usage % | Load |
| GPU memory usage | VRAM (expect **~3.8–4.2 GB** fullscreen DBD, not desktop **~14 GB** DWM spikes) |
| GPU clock / memory clock | Boost confirmation |
| **Power** — prefer **GPU power**, **Total graphics power**, or **Board power** | Must read **~90–110 W** at **~95%+ GPU** in a fight; if still **~50 W** at high %, try the next power line in the list |
| **Framerate** | Requires RTSS (see 3b) |
| **Frametime** | Stall diagnosis |
| Framerate 1% low | Optional Mode B |

**Do not log** every available sensor — fewer lines = less overhead and smaller `.hml`.

**Settings → Monitoring → Log history:**

- **Log file:** `D:\ai\diagnostics\afterburner\dbd_session.hml` (or keep `D:\ai\HardwareMonitoring.hml` if Eric prefers — both work; repo collector checks `afterburner\` and probes list `D:\ai\`)
- **Log updating frequency:** **1000 ms** (1 s) is enough; 100 ms is unnecessary disk/CPU churn

**Settings → General:**

- **Unlock voltage control** — leave **off** during diagnosis (no OC while debugging)
- **Enable low-level IO driver** — on (required for sensors)
- **Start with Windows** — optional; if RTSS/AB add boot friction, start manually before DBD only

**Settings → AMD (if shown):**

- **ULPS** — **disable** (AMD ultra-low power state; reduces idle stutter/black screens on some titles)

**Not in Afterburner (common mistakes):**

- Do not use **Benchmark** or **Scanner** during DBD troubleshooting
- Do not run **two full OSD stacks** (Adrenalin **Ctrl+Shift+O** + RTSS) in **Mode A** — pick one for on-screen; **log both** if needed (Adrenalin CSV + MSI `.hml`)

#### 3b) RivaTuner Statistics Server (bundled with MSI)

FPS/frametime in the `.hml` file come from **RTSS**, not Afterburner alone.

| Setting | Value |
|---------|--------|
| General → **Show On-Screen Display** | On (Mode B) / Off (Mode A) |
| General → **On-Screen Display support** | On |
| **Framerate limit** | **Off** for diagnosis (no artificial cap hiding real FPS) |
| **Application detection level** | Standard or higher if DBD hook fails |
| **Profiles → Global** (or per-game) | `OSDShowFramerate=1`, `OSDShowFrametime=1` already on this host |

**DBD must be fullscreen** (or borderless fullscreen with working hook) for stable FPS columns.
If **Framerate** column in `.hml` is **N/A**, the game was windowed, hook failed, or RTSS
was not running before launch — **restart RTSS**, then **restart DBD**.

**Overlay Editor (Mode B):** one compact line: `GPU %`, `Power W`, `FPS`, `ms` — avoid
duplicate AMD Adrenalin overlay on top.

#### 3c) What MSI/RTSS cannot fix (use BIOS / lean stack instead)

| Symptom | MSI alone? | Real lever |
|---------|------------|------------|
| **~50 W @ high GPU%** (windowed) | Fixed by **fullscreen** + correct power line | Display mode |
| Power **~100 W not ~160 W** at **~60 FPS** | Not broken — game not drawing TBP | CPU limit, in-game cap, scene load |
| **1–5 FPS** stalls | Logs only; does not prevent | DWM/VRAM, overlays, **16 GB @ 2133**, CSM/ReBAR, XMP |
| Adrenalin **FPS.Latency** `N/A` | Separate tool | Adrenalin metrics + game detection |
| Ground-truth power dispute | Use **HWiNFO** sensor | Manual Sensors log → `D:\ai\diagnostics\hwinfo\` |

#### 3d) Recommended DBD session order (Eric)

1. Start **RTSS** → **MSI Afterburner** (verify Monitoring graphs move).
2. Confirm **log file** path and **Log history** checked on power/FPS/frametime.
3. Launch **DBD fullscreen** (not windowed).
4. **Mode A:** logging on, **no** RTSS OSD (or minimal); Adrenalin overlay off.
5. On stall → note clock time; **Mode B** next match with RTSS OSD line enabled.

### Printable checklist

```text
[ ] Windows Game DVR OFF
[ ] Wallpaper Engine exited
[ ] AMD Chat quit
[ ] Adrenalin ReLive OFF
[ ] DBD: FSR OFF, Experience Default, Texture Performance
[ ] Metrics logging ON, Frame Time tracked
[ ] RTSS started before DBD; framerate limit OFF
[ ] MSI Monitoring: power + FPS + frametime → Log history ON
[ ] MSI log → D:\ai\diagnostics\afterburner\ (or D:\ai\HardwareMonitoring.hml)
[ ] DBD fullscreen (not windowed)
[ ] Mode A: one OSD stack only; Mode B: RTSS frametime visible
```

---

## During a 1–5 FPS drop

1. Note time (for event log window).
2. Mode B: confirm overlay shows FPS/frametime/power if enabled.
3. After match: agent runs collect playbook or SSH pulls `D:\ai\diagnostics\`.

---

## Undo

| Item | Restore |
|------|---------|
| Ansible | `gpu_diagnostics_windows_state: absent` + playbook |
| ReLive / Game DVR / overlays | Re-enable in Adrenalin / Windows / Steam |
| Scheduled HWiNFO task | Removed on role absent |

---

## Known bad actors (this host)

- **DWM Event 500** — video memory thrashing
- **AMD Chat** — `RADAR_PRE_LEAK_64` ~6 GB
- **Driver reinstall** resets `DvrEnabled` / `MetricsOverlayState`
- **FSR Enabled** on DBD profile after reinstall (disable for FPS test)
