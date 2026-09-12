# Draft plan v1 (researched) — quality / HRL suggestions

**Sibling of:** [draft-plan-v1-researched.md](./draft-plan-v1-researched.md)
**Implementation update:** [2026-09-11--update_new_infra.md](./2026-09-11--update_new_infra.md)
**Purpose:** Review whether the in-flight implementation is module-first and HRL-aligned, or drifting toward shell/scripting.
**Verdict:** Direction is right (repo roles, gated apply, no RAID0, separate VHDX). Several steps still look **probe-script heavy** and under-use packs that already name better mechanisms.

---

## 1. What already looks solid

| Surface | Why this is OK |
| --- | --- |
| `roles/linux_data_disk_mount` mutation core | Uses `community.general.parted`, `community.general.filesystem`, `ansible.posix.mount` — correct module palette from HRL `ansible/disk-management-inventory`. |
| `roles/k3s_storage_offload` local-path | Uses `kubernetes.core.k8s_info` / ConfigMap edit for `nodePathMap` — matches K3s pack Mechanism 4. |
| `roles/k3s_vllm_runtime` HF path | Already asserts **`HF_HUB_CACHE`** under `/mnt/k3s-cache/...` — native config, not a bind of `~/.cache`. Matches vLLM/HF packs. |
| Separate VHDX (no RAID0 / no occupied SATA reformat) | Matches live evidence + user decision; better than v0 physical RAID ideas. |
| Apply gates / check_mode fixes | Necessary maturity; keep them. |

Concern is **not** “roles don’t exist.” Concern is **how probes, identity, and offload targets are expressed**.

---

## 2. Where it feels like scripting (and what HRL prefers)

### 2.1 `linux_data_disk_mount` — lots of `ansible.builtin.command`

Current pattern: `readlink`, `lsblk`, `udevadm settle`, `findmnt` via `command:` for identity and parent checks.

| Prefer (HRL / Ansible maturity) | Instead of |
| --- | --- |
| `ansible_devices` / `ansible_mounts` facts (gather or `setup` subset) | Repeated `lsblk`/`findmnt` argv tasks |
| Resolve once → `set_fact` stable `by-id` + serial, then assert | Multi-step command chains on every run |
| `community.general.filesystem` **with label** (`opts: -L k3s-cache` or equivalent) + `ansible.posix.mount` `src: LABEL=…` | Mounting only `/dev/disk/by-id/…-part1` as the durable fstab identity |
| `ansible.builtin.wait_for` / udev settle as **one** bounded wait after parted | Ad-hoc settle + re-`readlink` sprawl without a single “partition ready” contract |

**HRL authority:** `generated/context7/ansible/disk-management-inventory` — mount by `LABEL=`/`UUID=`; filter disks via `ansible_devices` serial/model; preflight “partitions empty” asserts.

**Gap vs plan §2.4:** Plan already says `device_by: LABEL=k3s-cache`. Role still mounts by partition by-id. That is identity-stable *enough* for Hyper-V WWNs, but **weaker than the researched contract** and harder to read in inventory.

### 2.2 `k3s_storage_offload` — `findmnt` / `rsync` / `command` heavy

Bind-mounting containerd **is** the HRL-recommended mechanism (K3s has no independent containerd root flag). The quality issue is implementation shape:

| Prefer | Instead of |
| --- | --- |
| Persist bind with `ansible.posix.mount` (`src=` destination on cache FS, `opts=bind`, fstab) | Shell-shaped mount/umount/rsync sequences unless a module truly cannot express the migrate step |
| One explicit migrate task (rsync or `synchronize`) behind `*_apply`, then mount module owns steady state | Mixing discovery + migrate + service restart in opaque command blocks |
| Verify imagefs≠nodefs via facts/`df` registered once + assert | Multiple findmnt parses as the primary contract |
| Document evictionHard `mergeDefaultEvictionSettings` if any kubelet eviction YAML is touched | Silent partial overrides (HRL kubelet pack trap) |

**HRL authority:** `generated/context7/k3s/storage-offload-targets` Mechanism 1; taxonomy “bind mount for leaf under derived `--data-dir`.”

### 2.3 Hyper-V VHDX — `win_powershell` vs collections

`hyperv_vm_data_disk` correctly uses structured `ansible.windows.win_powershell` (not nested `ssh … powershell -Command`). Still lower on the maturity ladder than declaring desired VM disk state via a collection module when fit is good.

| Candidate (installed / listed in this env) | Fit note |
| --- | --- |
| `gocallag.hyperv.vm_disk` | Purpose-built Hyper-V VM disk attach — evaluate before growing more PS scripts |
| `community.windows.win_disk_facts` | Host-side disk inventory (physical SATA facts) — better than one-off PS probes for Samsung/Plextor documentation |
| `community.windows.win_partition` / volume modules | Host *guest* OS disks — **not** for Hyper-V VHDX attach; keep for Windows-native volumes only |

**Suggestion:** Keep today’s PS role if `gocallag.hyperv.vm_disk` fails the module matrix (idempotence, controller location, dynamic VHDX create). Do **not** expand PS further without a Fit yes/partial/no receipt against that collection. Host physical-disk **facts** should move to `win_disk_facts` + inventory YAML, not stay as chat/probe residue.

### 2.4 Logs/scratch (item 6) — wrong mechanism risk

Plan inventory still shows `/var/log/pods` with `mechanism: native_or_bind`. HRL is clearer:

| Target | Preferred mechanism | Pack |
| --- | --- | --- |
| Pod logs | **`podLogsDir` in KubeletConfiguration** (native) | `kubernetes/kubelet-storage-offload` |
| Journal | Bind or whole `/var/log` mount — **no path key**; never symlink | `systemd/os-directory-offload` |
| HF / vLLM cache | **`HF_HUB_CACHE` / `VLLM_CACHE_ROOT`** (already partly in `k3s_vllm_runtime`) | `vllm/cache-and-artifact-offload` |
| containerd | Bind only | `k3s/storage-offload-targets` |

**Suggestion for the 32 GiB logs VHDX:** Prefer kubelet `podLogsDir: /mnt/k3s-logs/...` (ConfigMap / k3s config template owned by an Ansible file/template task), **not** a blind bind of `/var/log/pods` invented in shell. Account for the HRL caveat that moving pod logs can change kubelet disk-pressure accounting.

---

## 3. Better HRL packages to lean on (checklist)

Use these as the implementation brief, not only as bibliography:

| Pack / guide | Use next |
| --- | --- |
| `implementation-guides/storage/storage-offload-taxonomy.md` | Enforce `category` + `durability` + `mechanism` in host_vars; placement asserts |
| `generated/context7/ansible/disk-management-inventory/` | Rewrite identity/mount contract to facts + LABEL/UUID |
| `generated/context7/k3s/storage-offload-targets/` | Keep containerd bind; avoid `--data-dir` wholesale move; avoid hand-edited containerd tmpl |
| `generated/context7/kubernetes/kubelet-storage-offload/` | `podLogsDir`, imagefs/nodefs verify, evictionHard merge trap |
| `generated/context7/vllm/cache-and-artifact-offload/` | Confirm HF env only; no `TRANSFORMERS_CACHE` |
| `generated/context7/systemd/os-directory-offload/` | Only if OS logs/tmp/swap are in scope — never symlink |
| `generated/context7/windows-server/storage-offload-targets/` | Host VHDX placement / non-goals (pagefile) |
| `generated/context7/prometheus/tsdb-storage-and-retention/` | Hard refuse putting TSDB on the 300 GiB ephemeral cache disk |

**Library debt still open:** Hyper-V vendor/guide registration incomplete in HRL — if `gocallag.hyperv` becomes the owner, register that choice in HRL/catalog so agents stop defaulting to more PS.

---

## 4. Suggested quality bar for the rest of this apply

Concrete upgrades to pursue **while finishing** the current campaign (not a rewrite for its own sake):

1. **Inventory contract**
   Persist `physical_disks` + `storage_offload_mounts` with `durability` and `mechanism` exactly as taxonomy shows. The Plextors are now separate repurposed NTFS host volumes, not occupied or deferred RAID members.

2. **Mount identity**
   After first format: set FS label (`k3s-cache`, `k3s-logs`); switch `ansible.posix.mount` `src` to `LABEL=…`. Keep by-id only for **partition/format selection**, not as the long-term fstab key.

3. **Replace command probes where facts suffice**
   `ansible_devices` / `ansible_mounts` / `win_disk_facts` for asserts; reserve `command` for true gaps (e.g. overlay-in-`/proc/filesystems` if no fact).

4. **Logs disk = native kubelet path**
   Implement item 6 via `podLogsDir` (or documented k3s config fragment), not ad-hoc bind of `/var/log/pods`.

5. **HF/vLLM**
   Commission paths through existing `k3s_vllm_runtime` C1 contract once cache mount is live — do not add a second bind-based HF “offload.”

6. **Module matrix receipt before more Hyper-V PS**
   Compare `gocallag.hyperv.vm_disk` vs current role; keep PS only with Fit=partial/no recorded in the plan receipt.

7. **Verify like the packs say**
   Assert imagefs ≠ nodefs (`df` on containerd mount vs `/`), overlay supported, no disk-pressure taint, HF cache under labeled mount — not “play recap green.”

---

## 5. What not to do

- Do not “fix quality” by rewriting working `parted`/`filesystem`/`mount` into shell.
- Do not introduce symlinks for offload targets (explicitly banned in taxonomy + systemd pack).
- Do not move `--data-dir` wholesale to “simplify” containerd.
- Do not reformat occupied Samsung/Plextor volumes to chase a “purer” physical layout.
- Do not treat `win_powershell` expansion as progress without a module-matrix pass.

---

## 6. Bottom line

Your concern is **partly right**: identity and offload verification lean on `command`/`findmnt`/`lsblk`/`win_powershell` more than the HRL packs prescribe, and mount durability is still **by-id-partition** rather than **LABEL/UUID**.

It is **not** fair to call the whole approach “just scripting”: the mutate path already uses the right community modules for partition/FS/mount/K8s ConfigMap, and HF is already on a native env contract.

**Next best quality move:** finish apply with the current roles, then tighten identity/mount/logs mechanisms to match taxonomy + kubelet/k3s packs (LABEL mounts, facts-based asserts, `podLogsDir`, Hyper-V module matrix) before declaring the storage upgrade mature.
