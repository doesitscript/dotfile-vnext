Read-only pass on `HOM-LAB-HVH-02` from July 29, 2026 says the storage picture is:

- `C:` = internal OS NVMe (`476 GB`)
- `D:` = internal fixed SSD (`931.5 GB`)
- `F:` = large USB-attached external disk, but mounted as fixed NTFS storage (`1.13 TB` volume on a `1.86 TB` USB disk)
- `G:` / `H:` = small removable FAT32 USB media

Here’s the checklist I’d use.

| Current path | Recommendation | Recommended destination | Brief reason | Extra note | What it is used for | Performance impact |
|---|---|---|---|---|---|---|
| `C:\Users\joshc\Downloads\*` | Move off `C:` | `D:\software\` for installers, or `F:\shares\public\hyperv-cache\staging\` for shared ISO/staging payloads | `C:` should stay for OS/user profile, not long-term installer pileup | Staging, not durable storage | Temporary downloads, installers, and random manual imports | No runtime impact; only file copy time |
| `C:\Users\joshc\hom-lab-ctl-k3s-02-autoinstall.iso.upload` | Move off `C:` | `F:\shares\public\hyperv-cache\remastered-isos\` | ISO/build artifact, rebuildable, not latency-sensitive; external USB is fine for cache-like payloads | Large rebuildable artifact | VM install ISO or upload artifact for guest provisioning | No meaningful impact unless actively mounting it |
| `C:\Users\joshc\PktMon.etl` | Move or delete after review | `D:\ai\diagnostics\events\PktMon.etl` | Diagnostic artifact belongs with other diagnostics, not in the profile root | One-off capture file | Packet capture log for troubleshooting network behavior | No impact after capture completes |
| `D:\ai` | Keep on `D:` | `D:\ai` | This is the right internal-data root; live host shows it exists and is mostly empty | Best internal data lane | Main internal working area for AI-related data and tooling | Good performance on internal SSD |
| `D:\ai\diagnostics` | Keep on `D:` | `D:\ai\diagnostics` | Active diagnostic data is a good fit for fixed internal storage | Fast local troubleshooting data | Collected diagnostics, probes, and local analysis outputs | Better on `D:` for faster local reads/writes |
| `F:\ProgramData\Ansible\hyperv_ubuntu_vm` | Move to `D:` | `D:\ProgramData\Ansible\hyperv_ubuntu_vm` | VM storage is a better fit on the internal SSD than the external USB disk | Prioritize VM disk performance | Hyper-V VM storage payloads, likely VHDX files and guest assets | Yes, this can improve VM disk latency and throughput |
| `F:\ProgramData\Ansible\hyperv_ubuntu_gpu_p_runtime` | Keep on `F:` | `F:\ProgramData\Ansible\hyperv_ubuntu_gpu_p_runtime` | Runtime artifact lane; shareable/rebuildable, so external USB storage is acceptable | Rebuildable runtime payload | Published GPU-P runtime bundle consumed by guest/runtime setup | Small impact only during copy/extract/use |
| `F:\shares\public\artifacts` | Keep on `F:` | `F:\shares\public\artifacts` | Shared artifact/export path; USB is okay because it is capacity-oriented shared storage | Shared output area | Shared artifacts other systems or users may read | Minimal impact unless large transfers are active |
| `F:\shares\public\hyperv-cache` | Keep on `F:` | `F:\shares\public\hyperv-cache` | Cache/staging/ISO content belongs on the big external disk; okay on USB because it is non-primary, reproducible data | Cache and staging lane | Cached ISOs, cloud images, remasters, and staging payloads | Little impact; cache content is not latency-critical |
| `F:\26100.32230.260111-0550.lt_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso` | Keep on `F:`, but move into structure | `F:\shares\public\hyperv-cache\ubuntu-isos\` or a sibling ISO folder there | Fine on external USB because it is a large static install image, not hot runtime data | Just needs better placement | Standalone Windows Server install ISO | No real impact except when mounting/copying |
| `F:\shares\public\Bloodstained - Ritual of the Night [FitGirl Repack]` | Keep where it is | `F:\shares\public\Bloodstained - Ritual of the Night [FitGirl Repack]` | Keep in place per current preference | Intentional exception | Personal game files, not homelab infrastructure data | No infra impact; no important performance effect |

Two important notes:

- I did **not** find live evidence that `D:\ai\models\*` or `F:\shares\public\models\*` currently exist on `HOM-LAB-HVH-02`, so there is not yet a live “D model cache vs F model cache” duplicate to clean up on this host.
- For anything on USB: `F:` is acceptable because it’s the big fixed-mounted external capacity disk already used for Hyper-V/share payloads. `G:` and `H:` are only acceptable for portable boot/recovery/MODS media, not for persistent app, model, VM, or diagnostic storage.

If you want, I can do one more read-only pass just for `C:\Users\joshc\.ollama`, `C:\ProgramData\Ollama`, and any Hugging Face cache paths so we can add a second table specifically for model/runtime caches on this host.
