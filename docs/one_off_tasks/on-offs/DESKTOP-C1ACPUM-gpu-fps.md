# DESKTOP-C1ACPUM — GPU/FPS on-offs and evidence

**Host:** `dev-workstation-win` / **DESKTOP-C1ACPUM** / **192.168.50.132**  
**Gaming user:** `ericc`  
**Problem:** intermittent **1–5 FPS** (Dead by Daylight, ultrawide 3440×1440 @ 180 Hz)

See [../DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md](../DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md) for full analysis (DWM thrashing, overlay soup, diagrams).

**Setup:** [../../diagnostics/amd-gpu-windows-desktop--diagnostics.md](../../diagnostics/amd-gpu-windows-desktop--diagnostics.md) (Eric manual + Ansible).  
**Deploy:** `playbooks/troubleshoot/deploy_dev_workstation_gpu_diagnostics.yaml`  
**Collect:** `playbooks/troubleshoot/collect_dev_workstation_gpu_artifacts.yaml`

---

## Column key

**What we got** = factual evidence from that step only (registry, processes, logs, exports) — same material as reported in the troubleshooting thread. See [README.md](./README.md).

---

## Timeline of toggles and probes

| When (2026-05-29) | Layer | On/off / action | What we got |
|-------------------|-------|-----------------|-------------|
| ~00:38 (during play) | DWM / VRAM | (no toggle) | Diagnostics-Performance **500**: *Desktop Window Manager… video memory over-utilized… thrashing* |
| ~02:45 | SSH | **On** (repo key) | `sshd` Running; `Accepted publickey` for `joshc` from `192.168.50.33`; port **22 Listen** |
| ~02:51 | Lean profile — Wallpaper Engine | **Off** (kill) | `wallpaper64` was running; stopped remotely |
| ~02:51 | Lean profile — AMD ReLive | **Off** | `DvrEnabled=0` for ericc SID `…-1001` |
| ~02:51 | Lean profile — Xbox Game DVR | **Off** | `GameDVR_Enabled=0` for ericc (already 0) |
| ~02:51 | Lean profile — AMD metrics overlay | **On** (diagnosis) | `MetricsOverlayState=1`, `EnableMetricsOverlay=1` |
| ~02:51 | RTSS OSD | **On** (profile) | Created `Profiles\Global`: `OSDShowFramerate=1`, `OSDShowFrametime=1`; RTSS restarted |
| 03:30 | DWM / VRAM | (no toggle) | **New** Diagnostics-Performance **500** (post-reinstall session) |
| 03:34–05:07 | AMD stack | Reinstall (user) | MSI: AMD DVR, WVR64, RSX Chatbot, CNext; logs under `C:\Program Files\AMD\AMDInstallManager\Logs\` |
| ~05:50 (pulse) | AMD ReLive | Reinstall **re-enabled** → remote **Off** again | `DvrEnabled` was **1** after reinstall; set back to **0** |
| ~05:50 (pulse) | AMD metrics overlay | Reinstall reset display → remote **On** again | `MetricsOverlayState` was **0**; set back to **1** |
| ~05:50 (pulse) | AMD Adrenalin reporting | (probe) | `RGStats.db` mtime 05:49; `Games_Session_Info.md`: DBD `running: Yes`, **`95th percentile frame time: 0`**; export `Dead_by_Daylight.md`: **FSR Upscaling: Enabled** |
| ~05:50 (pulse) | AMD Chat | (running) | `AMDChat.exe` ~**6016 MB** WS; WER **`RADAR_PRE_LEAK_64`** 05:11 |
| ~05:50 (pulse) | RTSS | (running) | `RTSS`, `RTSSHooksLoader64`, `EncoderServer`; **no `.log` files** under RTSS dir; Global profile flags present |
| ~05:50 (pulse) | MSI Afterburner | (running) | `MSIAfterburner.exe` 05:37 start; **no `.hml`** hardware log in install tree |
| ~05:50 (pulse) | DBD log | (game running) | `DeadByDaylight.log` **1.4 MB**, mtime **05:50:41**; file locked — could not tail |
| User action (after pulses) | Adrenalin game settings | **Default** (Eric, in UI) | User enabled **Default** settings in Adrenalin for DBD. Last automated export on disk still **05:47:53** with **FSR Upscaling: Enabled** — refresh export after defaults to confirm FSR/RSR state. |
| After user defaults (remote read) | Registry (lean pieces kept) | ReLive **Off**, overlay **On** | `DvrEnabled=0`, `MetricsOverlayState=1`, `EnableMetricsOverlay=1` (remote registry read after user message) |

---

## Tool reporting matrix (latest pulse)

| Tool | Running? | What we got |
|------|----------|-------------|
| **AMD Adrenalin** | Yes — `RadeonSoftware`, `AMDRSServ`, `AMDRSSrcExt`, `cncmd` | Writes under `C:\Users\ericc\AppData\Local\AMD\CN\` (`RGStats.db`, `RAG_CNDB_GAME\*.md`). DBD session line: **`95th percentile frame time: 0`** — no usable FPS sample yet. Artifacts: `artifacts/troubleshooting/ericc-amd-Dead_by_Daylight.md`, `ericc-amd-Games_Session_Info.md` |
| **AMD Chat** | Yes | **`RADAR_PRE_LEAK_64`** for `AMDChat.exe`; ~6 GB working set |
| **RTSS** | Yes | Global profile has frametime OSD flags; **no disk logs** from RTSS |
| **MSI Afterburner** | Yes | **No `.hml`** monitoring log; UI/OSD only unless logging enabled in AB |

---

## Adrenalin — Default settings (user)

Eric reported enabling **Default** settings in AMD Adrenalin (game profile / global experience).

**Expected effect of “Default” in Adrenalin (typical):** per-game driver features return toward AMD defaults — often **FSR upscaling off**, standard texture filtering, no custom tuning preset.

**What we got before that UI change (last export on disk):**

```text
AMD FSR Upscaling: currently set to Enabled, default is Disabled
Gaming Experience: Global Experience
Radeon Anti-Lag: Disabled
Radeon Chill: Disabled
```

**After user change:** re-pull `C:\Users\ericc\AppData\Local\AMD\CN\RAG_CNDB_GAME\Dead_by_Daylight.md` on next probe to record post-default values in **What we got** column above.

---

## Live verification (2026-05-29 ~19:05, DBD running)

| Check | What we got |
|-------|-------------|
| DBD process | `DeadByDaylight-Win64-Shipping` PID **6532**, started **19:01:02** |
| GPU 3D util (DBD PID) | **~85%** then **~54%** on pulse |
| Dedicated VRAM | **~14055 MB** on RX 9060 XT (~16 GB card) — very high pressure |
| Adrenalin DBD profile | **FSR Upscaling: Disabled**; **Texture Filtering: Performance** |
| Metrics config | **Start Logging: Enabled**; **GPU BRD PWR** logging **Enabled**; **Frame Time: track No** (still) |
| Hardware CSV | `C:\Users\ericc\AppData\Local\AMD\CN\Hardware.20260529-185614.CSV` — sample **GPU BRD PWR 29–33 W** at **GPU UTIL 22–56%**; file **stopped updating ~18:56** (before current match) |
| FPS/Latency CSV | `FPS.Latency.20260529-185614.CSV` — **all rows PROCESS=N/A**, no FPS during session |
| Games_Session_Info | **95th percentile frame time: 0** still |
| HWiNFO CSV | **None** in `D:\ai\diagnostics\hwinfo\` |
| Afterburner `.hml` | **None** in `D:\ai\diagnostics\afterburner\` |
| Artifacts | `artifacts/troubleshooting/dev_workstation_win_gpu/dev-workstation-win/20260529-190424/` |

---

## Post-setup verification (2026-05-29 Ansible apply)

| Check | What we got |
|-------|-------------|
| `gpu_diagnostics_windows` deploy | Playbook ok; HWiNFO at `C:\Program Files\HWiNFO64\HWiNFO64.exe`; `D:\ai\diagnostics\` tree created; scheduled task `gpu_diagnostics_windows-hwinfo-csv-log` registered |
| Collector run | `artifacts/troubleshooting/dev_workstation_win_gpu/dev-workstation-win/20260529-185319/` |
| HWiNFO CSV | **No CSV yet** — boot task delay 3 min; may need reboot or manual `HWiNFO64 -lD:\ai\diagnostics\hwinfo\test.csv` |
| Adrenalin DBD export | **FSR Upscaling still Enabled** — Eric manual Tier 1 still required |
| Frame time in export | **95th percentile frame time: 0** (skate. running) — metrics tracking not configured in UI |

---

## Still not in **What we got** (gaps)

- FPS/frametime numeric sample **during** a 1–5 FPS drop (overlay showed 0 percentile in export)
- RTSS frametime line confirmed on screen (profile on disk only)
- MSI Afterburner logged time series
- GPU hotspot temp at stall time

---

## Remote re-apply commands (reference)

Registry targets ericc hive `HKU\S-1-5-21-3510019994-3371490657-3851230505-1001`:

- ReLive off: `DvrEnabled=0` under `Software\AMD\DVR`
- Metrics overlay on: `MetricsOverlayState=1`, `EnableMetricsOverlay=1` under `Software\AMD\CN\Performance`

Scripts: `artifacts/troubleshooting/apply-fps-troubleshoot-profile.ps1`
