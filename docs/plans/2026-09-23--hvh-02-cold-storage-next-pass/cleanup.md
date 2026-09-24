# Bucket: Cleanup

Use for content that is obsolete, duplicate, generated, expired, or safely
rebuildable. Do not delete until ownership, retention, and recovery evidence are
recorded.

| Candidate path | Evidence / reason | Action | Verify | Status |
|---|---|---|---|---|
| `C:\Windows\LiveKernelReports\WATCHDOG-20260308-2040.dmp` | Windows Live Kernel Report (WATCHDOG) from 2026-03-08. System-generated diagnostic dump, not workload data. Not regenerable as useful content (only by reproducing the fault). Age ~6 months from triage date; no repo-owned dump hygiene role today. Cold storage is a poor fit: nothing restores this for a service. | Confirm no open incident needs this dump, then delete (or empty after copy only if forensics still wanted). Do not migrate to `/mnt/k3s-cold` as default. | Path gone or size reclaimed on HVH-02; no dependent service complains; optional: note if sibling dumps remain under `LiveKernelReports`. | accepted — cleanup authorized when execute slice runs |
| `D:\Gamerecordings` + `F:\Gamerecordings` | Steam Game Recording trees. D leftover after setting change (~58 GiB); F active on LOGS-HOST SSD (~12 GiB). Canonical bulk dest `I:\Gamerecordings` (USB data). | Oneoff robocopy move (`remove_source_after: true`) via skill jobs `hvh02-gamerec-d-to-i` (running) then `hvh02-gamerec-f-to-i` (scheduled ~45m after D ETA). | Sources gone after success; data under `I:\Gamerecordings`; Steam pointed at I: | in_progress — D Running; F NextRun ~2026-09-23 20:55 local |
