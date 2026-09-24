# Bucket: Keep behavior / configuration

Use when current placement or behavior matches the storage policy and changing it
would add risk or needless churn. Record the reason so the candidate is not
reopened without new evidence.

| Candidate path | Current behavior | Why keep it | Revisit signal | Status |
|---|---|---|---|---|
| `C:\ProgramData\Ansible` (root tree) | Repo-owned Ansible/Windows workspace: artifacts, downloads, role contract roots, and (on some hosts) Hyper-V staging. HVH-02 already moves bulky live VHDXs to `D:\ProgramData\Ansible\hyperv_ubuntu_vm` and second-tier rebuild bases to `H:\COLD-DATA-HOST\hyperv-cache`. | Deleting or cold-migrating the whole tree would break active roles (`windows_artifact_*`, `windows_ollama_runtime`, Hyper-V VM paths). Not regenerable as one object; contents are mixed hot/cache/contract. | Size on C: still high after reclaim, or a named subpath is obsolete — triage that subpath as its own candidate (do not reopen wholesale root delete). | pending — awaiting user accept |
| Steam live pointers (`D:\`/`I:\SteamLibrary`, `I:\Gamerecordings`) | `windows_steam_client_*` declares live paths; recordings bulk on USB `I:`; primary library still on `D:` | Live gaming paths must stay attached. Current **cold** (`H:` / k3s-cold) is for restore-on-demand k3s/Hyper-V archives — wrong class for Steam play/record. Prefer **USB bulk** now; evaluate **capacity SSD** later if USB I/O hurts; do not steal `F:\LOGS-HOST` without a purpose change. | USB full / I/O pain → consider dedicated capacity SSD library root; rarely-played titles → future archive-demote row in cold-storage.md (not live pointer flip) | captured 2026-09-23 — OD-05 |
