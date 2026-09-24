# Bucket: Keep behavior / configuration

Use when current placement or behavior matches the storage policy and changing it
would add risk or needless churn. Record the reason so the candidate is not
reopened without new evidence.

| Candidate path | Current behavior | Why keep it | Revisit signal | Status |
|---|---|---|---|---|
| `C:\ProgramData\Ansible` (root tree) | Repo-owned Ansible/Windows workspace: artifacts, downloads, role contract roots, and (on some hosts) Hyper-V staging. HVH-02 already moves bulky live VHDXs to `D:\ProgramData\Ansible\hyperv_ubuntu_vm` and second-tier rebuild bases to `H:\COLD-DATA-HOST\hyperv-cache`. | Deleting or cold-migrating the whole tree would break active roles (`windows_artifact_*`, `windows_ollama_runtime`, Hyper-V VM paths). Not regenerable as one object; contents are mixed hot/cache/contract. | Size on C: still high after reclaim, or a named subpath is obsolete — triage that subpath as its own candidate (do not reopen wholesale root delete). | pending — awaiting user accept |
