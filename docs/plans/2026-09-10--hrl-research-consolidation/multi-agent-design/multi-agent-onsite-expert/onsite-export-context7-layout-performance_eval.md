# Drive layout and performance evaluation — hom-lab-ctl-k3s-02

**Produced by:** On-site Expert / Library Domain Expert  
**Date:** 2026-09-11  
**Evidence basis:** HRL Context7 packs gathered 2026-09-10 plus S1 live discovery (verified
facts from [`receipts/2026-09-11T065746Z-s1-storage-discovery.md`](../../../implementation-campaign/receipts/2026-09-11T065746Z-s1-storage-discovery.md))  
**Scope:** Data-driven placement recommendations for the new secondary VHDX (200 GiB, NVMe D:)
and any additional SATA SSD surface; drive-type performance fit; what each technology
runs best on and why.

---

## Factual corrections — these are hard errors, not caveats

These items were discovered by reading upstream source code during research.
They are not recommendations or considerations — they are wrong behaviors that
will silently fail or produce incorrect results if not corrected.

| # | Incorrect pattern | What actually happens | Correct replacement | Source authority |
| --- | --- | --- | --- | --- |
| **C1** | `TRANSFORMERS_CACHE=<path>` in any env block or Ansible template | **Silent no-op.** Variable is completely absent from `transformers/utils/hub.py` on `main` — zero hits. The file reads `constants.HF_HUB_CACHE` directly. Setting this variable does nothing; the cache goes to the default location regardless. | `HF_HUB_CACHE=<path>` | [`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md) — `transformers/utils/hub.py`, `huggingface_hub/constants.py` |
| **C2** | Shelling out to `huggingface-cli` (e.g. `huggingface-cli scan-cache`) | **Exits 1 every time.** Entry point is `huggingface_hub.cli.deprecated_cli:main` whose only job is to print *"`huggingface-cli` is deprecated and no longer works. Use `hf` instead."* and call `sys.exit(1)`. Any playbook task or script using `huggingface-cli` is broken. | `hf cache ls` / `hf cache rm` / `hf cache prune` / `hf cache verify` | [`huggingface-hub/cache-disk-management`](../../../../../../homelab-reference-library/generated/context7/huggingface-hub/cache-disk-management/result.md) — `huggingface_hub/cli/deprecated_cli.py` |
| **C3** | Writing containerd config override to `config.toml.tmpl` on this node | **Silently downgrades containerd config to version 2.** K3s renders `config.toml.tmpl` as a v2 config if `config-v3.toml.tmpl` is not found. On K3s ≥ v1.31.6+k3s1 (containerd 2.0+), v2 config is legacy — the v3 template is used unless the old name is present. This node runs K3s v1.31.12+k3s1 / containerd v2.0.5. | Write to `config-v3.toml.tmpl`; always include `{{ template "base" . }}` | [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md) — K3s source + containerd 2.0 release notes |

The hf cache command surface has renamed twice in its history
(`huggingface-cli scan-cache|delete-cache` → `hf cache scan|delete` → `hf cache ls|rm|prune|verify`). **Pin to the `huggingface_hub`
version in the running `vllm-openai` image and verify with `hf cache --help` rather than trusting docs at any static version.**

---

## Key findings — narrative summary

**The core problem quantified by research:** Everything shares one 77 GiB root
filesystem. A second model download (~19 GiB) would cross 85% before completing
— exactly the kubelet image GC threshold that triggered `DiskPressure=True` and
left all AI workload pods Pending.

**What the research says each drive class is suited for:**

The primary win is moving model weights off root. A 32B AWQ model is ~19 GiB and
is loaded by memory-mapping the entire file sequentially at pod start — the GPU
sits idle during this window. NVMe matters here because loading from a slower
device delays GPU activation proportionally. Containerd images (30 GiB) are also
a good candidate for the NVMe VHDX: re-pullable, but a re-pull means all pods
are down until images restore. Both belong on the 200 GiB NVMe VHDX, not on a
smaller SATA SSD.

The smaller SATA SSD is best used for workloads where the performance requirement
is "faster than the root disk under contention" rather than "maximum throughput."
That is exactly the swap use case: the Kubernetes project documentation says
directly that swap on a separate SSD is recommended to isolate I/O contention
from kubelet, container runtime, and model loading. Swap writes are bursty, not
continuous — the endurance impact on a modern consumer SSD is negligible. The
systemd journal (sequential append, low IOPS) and the vLLM compile cache
(recompile on loss, 1–3 GiB) are the other natural residents of the smaller
drive.

**The single most important counterintuitive finding:** Prometheus TSDB looks
like a "logs and metrics → cheap SSD" candidate — sequential writes, grows without
bound. The upstream docs break this assumption explicitly: *"local storage is not
clustered or replicated ... not arbitrarily scalable or durable in the face of
drive or node outages and should be managed like any other single node database."*
Metric history is not reproducible. If Prometheus is ever added to this node it
must go on durable storage, not on the model-weight VHDX and not on the smaller
SATA SSD. The same `local-path` advisory-capacity problem means `retentionSize`
is the only real ceiling on this node.

Pod logs appear to be an obvious offload candidate but the kubelet research closes
that off: if pod logs move to a separate filesystem, the kubelet loses the ability
to account for them in its disk-pressure calculation — the filesystem fills
silently with no eviction signal. The correct action is to cap them in place with
`containerLogMaxSize`/`containerLogMaxFiles`, not move them.

---

## 1. Verified hardware baseline (facts, not inference)

*Source: [`receipts/2026-09-11T065746Z-s1-storage-discovery.md`](../../../implementation-campaign/receipts/2026-09-11T065746Z-s1-storage-discovery.md)*

| Surface | Verified value |
| --- | --- |
| Root VHDX | Fixed 80 GiB on `D:` (NVMe, 931.5 GiB total, 373.6 GiB free) |
| Root filesystem | `/dev/sda1` — 77 GiB total, 65 GiB used, 12 GiB free, **85% used** |
| Secondary VHDX | **Not yet created.** Recommended: 200 GiB fixed, same D: drive, slot 0:1 |
| D: drive class | NVMe (Hyper-V host `HOM-LAB-HVH-02`) — high sequential and random IOPS |
| vLLM HF cache | 22 GiB actual (models--Qwen--Qwen2.5-Coder-32B-Instruct-AWQ) |
| containerd store | 30 GiB at `/var/lib/rancher/k3s/agent/containerd` |
| local-path storage | 22 GiB at `/var/lib/rancher/k3s/storage` (PVC backing) |
| Journal | 157.6 MiB |
| Target model | Qwen3-Coder-30B-A3B AWQ — approx 17–19 GiB |

**DiskPressure=True** — vLLM, Langfuse, LiteLLM pods all Pending. Root cause:
22 GiB model cache on a 77 GiB root filesystem leaves no room for a second large
model download without crossing the 85% kubelet GC threshold.

---

## 2. What the research says each technology runs best on

This section is the library-first synthesis. Each technology's requirements come
directly from the HRL Context7 packs gathered on 2026-09-10.

### 2.1 HuggingFace model weights — **needs NVMe, large capacity**

*Sources: [`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md),
[`huggingface-hub/cache-disk-management`](../../../../../../homelab-reference-library/generated/context7/huggingface-hub/cache-disk-management/result.md)*

**Why NVMe:** vLLM loads weights by memory-mapping them from the cache at pod
start. On a 32B AWQ model this is a sequential read of ~19 GiB. Loading from a
cold SSD takes roughly 3–5× longer than from NVMe. The RTX 5090 GPU sits idle
during this window — it is a direct throughput constraint.

**Size per model:** `~19 GiB` for a 32B AWQ 4-bit model (verified against
existing Qwen2.5-Coder-32B-Instruct-AWQ). Qwen3-Coder-30B-A3B AWQ will be
17–19 GiB. A second model doubles that.

**Durability class: `reproducible_expensive`** — re-downloadable from HuggingFace
at the cost of hours of bandwidth. The HF library itself writes a `CACHEDIR.TAG`
into the cache root, declaring it re-downloadable per the Cache Directory Tagging
Standard. RAID0 is therefore acceptable — you pay in time, not in permanent loss.

**Key env vars (exact, from `constants.py`):**
```
HF_HUB_CACHE   ← preferred; moves only the model repo cache
HF_HOME        ← moves everything; also drags the credential — pair with HF_TOKEN_PATH
```
Resolution chain is literal: `HF_HUB_CACHE` → `$HF_HOME/hub` → `$XDG_CACHE_HOME/huggingface/hub` → `~/.cache/huggingface/hub`.

**Recommended placement:** NVMe-backed VHDX, `/mnt/k3s-cache/hf`.

---

### 2.2 vLLM compiled graphs (Torch Inductor, Triton, CUDA graphs) — **SSD, smaller**

*Source: [`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md)*

**Why any SSD is fine:** These are recompiled on first request if missing — loss
is a slow startup, nothing more. Write pattern is burst-at-deploy then rarely
touched.

**Size:** Small — typically 1–3 GiB total for a single model. vLLM sets
`TORCHINDUCTOR_CACHE_DIR` and `TRITON_CACHE_DIR` itself under `VLLM_CACHE_ROOT`.
Moving `VLLM_CACHE_ROOT` relocates all of them in one shot.

**Durability class: `reproducible`** — recompile on first request. A cheap SATA
SSD is entirely appropriate.

**Recommended placement:** Secondary SATA SSD if one is available; otherwise
share the NVMe VHDX. A separate dir keeps the per-model compile cache from
polluting the model weight namespace.

---

### 2.3 containerd image store — **NVMe preferred, SATA SSD acceptable**

*Sources: [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md),
[`containerd/image-store-disk-reclamation`](../../../../../../homelab-reference-library/generated/context7/containerd/image-store-disk-reclamation/result.md)*

**Why NVMe preferred:** containerd stores two copies of each image:
- `io.containerd.content.v1.content` — compressed OCI blobs as pulled (smaller)
- `io.containerd.snapshotter.v1.overlayfs` — extracted/unpacked layer filesystems
  (2–3× larger; what containers actually mount)

Container starts require the snapshotter layers to be readable. A K3s node
restarting all pods after a K3s update reads this store end-to-end. Measured on
this node: **30 GiB** total.

**Durability class: `reproducible`** — re-pulled from registries. K3s docs
explicitly endorse separating agent storage (image store) from server storage
(datastore). From `reference/resource-profiling.md`:

> *"This can be best accomplished by placing the server components
> (`/var/lib/rancher/k3s/server`) on a different storage medium than the agent
> components (`/var/lib/rancher/k3s/agent`), which include the containerd
> image store."*

**Relocation mechanism:** Bind mount only — K3s has no `--containerd-root` flag.
`containerd.Root` is derived as `filepath.Join(dataDir, "agent", "containerd")`.

```
/etc/fstab:
LABEL=OFFLOAD_CACHE  /var/lib/rancher/k3s/agent/containerd  ext4  defaults,nofail  0 2
```

**Hard gate:** The destination filesystem must support overlayfs. **ext4 or xfs
only.** K3s calls `containerd.OverlaySupported()` at startup and will refuse to
start on btrfs (unless fuse-overlayfs is installed).

**Recommended placement:** The 200 GiB NVMe VHDX. If a second smaller SATA SSD
were added, this is a candidate to move there — at the cost of slightly slower
container starts (acceptable for a non-latency-critical K3s AI plane node).

---

### 2.4 local-path PVC storage (K3s StatefulSet backing) — **NVMe, with a critical durability caveat**

*Sources: [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md),
[`kubernetes/kubelet-storage-offload`](../../../../../../homelab-reference-library/generated/context7/kubernetes/kubelet-storage-offload/result.md)*

**Durability class: `durable`** — local-path PVCs are node-local `hostPath`
directories with **no replication and no capacity enforcement**. A 120 GiB claim
on a 77 GB filesystem is advisory only. If the disk dies, the PVC contents are
gone.

On this node, the current 22 GiB `vllm-primary-hf-cache` PVC is backed by
`/var/lib/rancher/k3s/storage/pvc-11cf2794-…`. This PVC is being used as
model-weight storage — see §2.1.

**Relocation mechanisms (three options, increasing granularity):**

**(a) Node-wide default** — affects all new PVCs:
```yaml
# /etc/rancher/k3s/config.yaml
default-local-storage-path: "/mnt/k3s-cache/local-path"
```

**(b) Per-node in `local-path-config` ConfigMap** — unverified whether K3s reverts
manual edits on restart; confirm before automating.

**(c) Dedicated StorageClass** — deterministic; the Ansible-correct option:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd-local-path
provisioner: rancher.io/local-path
parameters:
  nodePath: /mnt/k3s-cache/local-path
volumeBindingMode: WaitForFirstConsumer
reclaimPolicy: Delete
```

**Warning:** existing PVs hold the old absolute path in their spec and are
largely immutable — changing the flag only migrates **new** PVs.

**Recommended placement:** 200 GiB NVMe VHDX. Not on a standalone SATA SSD — the
node-local-only guarantee means a disk failure is permanent data loss regardless
of how fast the disk is; put it on the same class as the model weights.

---

### 2.5 systemd journal — **smaller SATA SSD or capped on root**

*Source: [`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md)*

**Current measured size:** 157.6 MiB — too small to solve root disk pressure.
This is not the emergency fix; it is the right home for this data class.

**Access pattern:** sequential append writes. Does not benefit from NVMe
random-IOPS headroom. A SATA SSD or even a rotational disk is adequate for
journald's workload.

**Durability nuance:** the research note on this is worth quoting directly:

> *"You need these specifically to diagnose the failure that took the disk out.
> Putting logs on the least reliable device is self-defeating."*

This means: logs should go on a dedicated disk that is **not** RAID0 and **not** the
cheapest drive you own. A SATA SSD with `nofail` in `/etc/fstab` is appropriate
for a homelab — acceptable risk, and it keeps logs off the root filesystem while
not losing them on the catastrophic failure you're using logs to diagnose.

**Retention configuration (cap before moving):**
```ini
# /etc/systemd/journald.conf
SystemMaxUse=1G
SystemMaxFileSize=128M
MaxRetentionSec=30day
```

Default is 10% of the filesystem capped at 4 GiB — on a large disk this is
4 GiB you could be using for something else.

**Migration command:**
```bash
systemctl stop systemd-journald
rsync -aHAX --numeric-ids /var/log/ /mnt/logs/varlog/
# fstab: UUID=<uuid> /var/log ext4 defaults,nofail,x-systemd.device-timeout=10s 0 2
systemctl daemon-reload && mount -a
systemctl start systemd-journald
journalctl --disk-usage && df /var/log
```

**`-aHAX` is mandatory** — journal ACLs and xattrs matter.

**Recommended placement:** Dedicated SATA SSD if available. If no second SSD
exists, cap the journal at 1 GiB on root (`SystemMaxUse=1G`) — the current 157.6
MiB is already well within that limit.

---

### 2.6 Kubernetes pod logs — **cap in place; do NOT move**

*Source: [`kubernetes/kubelet-storage-offload`](../../../../../../homelab-reference-library/generated/context7/kubernetes/kubelet-storage-offload/result.md)*

Pod logs live at `/var/log/pods` and `/var/log/containers`. The kubelet, not
logrotate, rotates them. The research is explicit:

> *"the kubelet supports the location being on the same disk as `/var`. Otherwise,
> if the logs are on a separate filesystem from `/var`, then the kubelet will not
> track that filesystem's usage, potentially leading to issues if it fills up."*

Moving pod logs off-root **removes kubelet's ability to account for them in
disk pressure calculation.** The correct action is to cap them:

```yaml
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
containerLogMaxSize: "10Mi"    # default 10Mi — already reasonable
containerLogMaxFiles: 5        # default 5
```

**Recommended placement:** Leave on root. Cap size via kubelet config. Do not
add a logrotate rule — it will fight kubelet.

---

### 2.7 Swap — **smaller SATA SSD; Kubernetes project explicitly recommends this**

*Source: [`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md)*

The Kubernetes project documentation says directly:

> *"When they share the same disk, processes can overwhelm swap, disrupting the
> I/O of kubelet, container runtime, and systemd ... an SSD is probably the
> appropriate choice."*

The reasoning is **I/O contention isolation**, not capacity. Swap write patterns
are bursty rather than continuous, making the endurance impact on a modern SATA
SSD negligible.

**Two hard gates:**
1. kubelet will not start on a node with swap enabled unless `failSwapOn: false`
   is set in `KubeletConfiguration`.
2. Default `swapBehavior` is `NoSwap` — pods get zero swap even when it exists.
   Kubelet and system services *do* use it, which is the useful case.

**Swapfile gotcha:** `fallocate` and `truncate` create sparse files; `swapon`
rejects files with holes. Use `dd`:
```bash
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=4096 status=progress
chmod 600 /mnt/swap/swapfile && mkswap /mnt/swap/swapfile
```

**Recommended placement:** The smaller SATA SSD. This is the canonical use case
for a non-critical SSD — keeps swap contention off the NVMe VHDX that's serving
model weights.

---

### 2.8 Prometheus TSDB — **must NOT go on a non-redundant SSD**

*Source: [`prometheus/tsdb-storage-and-retention`](../../../../../../homelab-reference-library/generated/context7/prometheus/tsdb-storage-and-retention/result.md)*

Prometheus TSDB is the **explicit exception** that breaks every "sequential-write
data goes on cheap SSDs" generalization. The upstream docs state plainly:

> *"local storage ... is not clustered or replicated ... not arbitrarily scalable
> or durable in the face of drive or node outages and should be managed like any
> other single node database."*

Metric history is **not reproducible**. The lab currently has no Prometheus
deployed (verified in S1 discovery), but this guidance applies if/when one is
added.

**Sizing formula (from upstream):**
```
needed_disk_space = retention_seconds × samples_per_second × bytes_per_sample
                  ≈ 15d × 86400 × <scrape_rate> × 1.5 bytes
```

Three sizing traps verified in the research:
1. `retention.size` counts WAL + memory-mapped head chunks — provision above peak
2. Compaction transiently exceeds `retention.size` — add 20% headroom
3. `local-path` does not enforce claim size — `retentionSize` is your only real
   ceiling on this node

**Recommended placement:** If Prometheus is added, it must go on the primary
disk (same tier as the K3s datastore) or a separately redundant volume — not the
model-weight NVMe VHDX and not a standalone SATA SSD.

---

### 2.9 K3s datastore (SQLite), TLS keys, server state — **never move to offload disk**

*Source: [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md)*

These live at:
- `/var/lib/rancher/k3s/server/db/` — SQLite with every Kubernetes object
- `/var/lib/rancher/k3s/server/tls/` — cluster identity; loss = rebuild cluster

**Durability class: `durable`** — no upstream; if these are gone, the cluster is
gone. K3s vendor docs ratify the storage split for this exact reason — separate
server from agent storage so a disk failure on the agent (image store) side does
not destroy the cluster state.

**Recommended placement:** Root disk only. Do not co-locate with model weights
or logs on any offload volume.

---

### 2.10 pip / uv / npm package cache — **smallest drive; lowest priority**

*Source: [`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md)*

All three are `reproducible` — npm upstream calls its cache "strictly a cache...
should not be relied upon as a persistent and reliable data store."

**Sizes:** pip cache varies widely; uv and npm are typically under 5 GiB for a
focused workload.

**One constraint:** `uv` requires its cache to be on the **same filesystem** as
the target Python environment to enable hardlinks rather than copies. Moving
`UV_CACHE_DIR` to a different physical disk than the venv "measurably slows
installs." Do not offload uv cache to a different device than the venv it serves.

**Recommended placement:** If a SATA SSD exists with leftover capacity, this is
the ideal filler. Otherwise, leave on root — the sizes are small enough that
they are not a material contributor to the current disk pressure.

---

## 3. Drive placement allocation — recommended layout

### 3.1 The problem with the current single-disk setup

Everything — model weights (22 GiB), containerd images (30 GiB), PVC backing
(22 GiB), root OS — shares one 77 GiB filesystem. DiskPressure fires at 85%
(65.45 GiB). With 65 GiB used there is effectively no headroom for a second
model download.

### 3.2 Recommended two-drive allocation

| Drive | Class | Mount | Allocation | Workloads |
| --- | --- | --- | --- | --- |
| **Primary VHDX** (existing, root) | NVMe (via D:) | `/` | 80 GiB | OS, K3s server/db, TLS keys, pod logs (capped) |
| **Secondary VHDX** (new, 200 GiB) | NVMe (via D:) | `/mnt/k3s-cache` | 200 GiB | HF model cache, vLLM artifacts, containerd image store, local-path PVC new storage, pip/uv cache |
| **SATA SSD** (if available, smaller) | SATA SSD | `/mnt/logs`, `/mnt/swap` | Remainder | systemd journal, swap (isolated from model-weight IO) |

### 3.3 Why this split makes sense

**NVMe D: secondary VHDX for model weights:**
- Model weight loads are the GPU's bottleneck — memory-mapping 19 GiB at pod
  start is the single most latency-sensitive storage operation on this node.
- The D: drive is already NVMe; the VHDX adds a thin virtualization layer but
  preserves the IO class.
- `reproducible_expensive` durability is acceptable: re-download costs hours,
  not data loss.

**SATA SSD for logs and swap:**
- Swap needs I/O isolation from model loads (Kubernetes project rationale).
- Journal is sequential append — SATA SSD is more than adequate.
- Keeping them off the NVMe VHDX means a journald write spike cannot affect
  model loading latency.
- If no SATA SSD exists: cap the journal (`SystemMaxUse=1G`) and skip adding
  swap for now. The primary win is moving model weights off root.

### 3.4 What must NOT move

| Item | Reason |
| --- | --- |
| K3s SQLite datastore (`server/db`) | Cluster loss on disk failure |
| K3s TLS/CA (`server/tls`) | Cluster identity |
| Prometheus TSDB (if future) | Not reproducible; treat as database |
| Jupyter notebooks (`ServerApp.root_dir`) | Your actual work product |
| HF token (`HF_TOKEN_PATH`) | Credential — keep on internal/redundant disk |

---

## 4. Technology-specific environment variable/config surface

Reference for the Ansible role that implements the above.

### Model cache relocation (S3 cutover)

*Sources: [`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md),
[`huggingface-hub/cache-disk-management`](../../../../../../homelab-reference-library/generated/context7/huggingface-hub/cache-disk-management/result.md)*

```bash
# Preferred: move only the model cache (not the credential)
HF_HUB_CACHE=/mnt/k3s-cache/hf/hub
HF_TOKEN_PATH=/root/.cache/huggingface/token   # stays on root

# All vLLM compile artifacts
VLLM_CACHE_ROOT=/mnt/k3s-cache/vllm

# vLLM then sets these automatically under VLLM_CACHE_ROOT:
#   TORCHINDUCTOR_CACHE_DIR  → /mnt/k3s-cache/vllm/inductor_cache
#   TRITON_CACHE_DIR         → /mnt/k3s-cache/vllm/triton_cache
```

**Do not** use `TRANSFORMERS_CACHE` — removed from transformers main; see correction C1 above.

**Do not** use `huggingface-cli` — deprecated stub that exits 1; see correction C2 above.

### containerd image store relocation

*Source: [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md)*

```bash
# Stop K3s first; rsync with -aHAX --numeric-ids (xattrs required for overlayfs)
rsync -aHAX --numeric-ids /var/lib/rancher/k3s/agent/containerd/ /mnt/k3s-cache/containerd/
# fstab bind mount:
# /mnt/k3s-cache/containerd  /var/lib/rancher/k3s/agent/containerd  none  bind,nofail  0 0
# Verify after K3s restart:
k3s crictl imagefsinfo   # imageFs should reflect the new mountpoint
```

**Filesystem requirement: ext4 or xfs.** K3s startup will fail with
*"overlayfs snapshotter cannot be enabled"* on btrfs.

**Template file for containerd config on this node (containerd 2.0):**
```
/var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl
```
Not `config.toml.tmpl` — K3s silently downgrades to config v2 if it finds the
old name on a containerd 2.x node. See correction C3 above.

### K3s local-path new storage (future PVCs)

*Source: [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md)*

```yaml
# /etc/rancher/k3s/config.yaml
default-local-storage-path: "/mnt/k3s-cache/local-path"
```

This only affects new PVCs — existing PVs hold their old paths.

### Journal cap (apply immediately, no hardware required)

*Source: [`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md)*

```ini
# /etc/systemd/journald.conf
SystemMaxUse=1G
SystemMaxFileSize=128M
MaxRetentionSec=30day
```
Reclaim stale space: `journalctl --rotate && journalctl --vacuum-size=500M`

### Swap on SATA SSD

*Source: [`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md)*

```yaml
# KubeletConfiguration
failSwapOn: false   # required or kubelet won't start with swap enabled
# memorySwap.swapBehavior: NoSwap  ← default; pods still get no swap
```

---

## 5. Durability summary — what can go where

*Cross-cutting taxonomy: [`implementation-guides/storage/storage-offload-taxonomy.md`](../../../../../../homelab-reference-library/implementation-guides/storage/storage-offload-taxonomy.md)*

| Durability class | What goes here | Safe disk class |
| --- | --- | --- |
| `durable` | K3s SQLite, TLS keys, Prometheus TSDB, Jupyter notebooks, Grafana DB | Primary disk or redundant volume |
| `reproducible_expensive` | HF model weights, containerd images, local-path PVC model data | NVMe VHDX (RAID0 acceptable; accept re-download risk) |
| `reproducible` | vLLM compile cache, pip/uv/npm cache, vLLM assets | Any SSD including older SATA |
| `ephemeral` | Pod logs (kubelet-managed), `/tmp`, swap (across-reboot) | Root disk (capped); swap on SATA SSD for IO isolation |
| `logs` | systemd journal | SATA SSD or capped on root; not RAID0 (you need these to diagnose failures) |

---

## 6. The "smaller drive" recommendation

The user noted that the smaller SATA SSD is unsuitable for large model weights.
The research confirms this is the right read, and here is the positive
recommendation for what it is suited for:

**Best uses for a smaller SATA SSD:**

1. **Swap** — Kubernetes project explicitly recommends a dedicated SSD for swap
   to isolate I/O contention from kubelet, container runtime, and model loading.
   `vm.swappiness` at default is fine; swap writes are bursty, not continuous.
   ([`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md))

2. **systemd journal** — Sequential append, low IOPS demand, naturally caps with
   `SystemMaxUse=`. Keeps long-retention logs off the root disk without the
   "logs on the unreliable disk" problem — a SATA SSD with `nofail` is
   reliable enough for a homelab.
   ([`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md))

3. **vLLM compile cache** — `VLLM_CACHE_ROOT` for torch_compile, Inductor, and
   Triton artifacts. Recompile on first request if lost; no meaningful endurance
   concern. 1–3 GiB.
   ([`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md))

4. **pip/npm cache** — Tiny, entirely reproducible. Good filler.
   ([`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md))

5. **`/var/tmp`** — 30-day scratch. `reproducible` by design per `file-hierarchy(7)`.
   ([`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md))

**What does NOT belong on the smaller SATA SSD:**

- HF model weights — 19 GiB+ per model, memory-mapped sequentially at pod start;
  loading from a slower device delays GPU activation proportionally.
  ([`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md))
- containerd image store — best on NVMe; acceptable on SATA SSD for this workload,
  but a re-pull after disk loss means all pods are unavailable until images restore.
  ([`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md))
- Any `durable` data — Prometheus TSDB, Jupyter notebooks, Grafana state.
  ([`prometheus/tsdb-storage-and-retention`](../../../../../../homelab-reference-library/generated/context7/prometheus/tsdb-storage-and-retention/result.md))

---

## 7. Open items before full layout can be automated

| Item | Blocks |
| --- | --- |
| Guest by-id path for the new VHDX after attach | `linux_data_disk_mount_device_by_id` input to the Ansible role |
| Confirm slot 0:1 unoccupied (`Get-VMHardDiskDrive`) | S4 VHDX creation |
| Live `crictl imagefsinfo` after containerd relocation | Proves kubelet detected the imagefs split |
| SATA SSD physical availability, capacity, and by-id path | Swap and journal placement |
| S4 physical selections approved in `decisions-and-authorization.md` | Any Apply step |

---

## Sources checked

All findings derived from HRL Context7 packs retrieved 2026-09-10:

| Pack | Key findings used |
| --- | --- |
| [`vllm/cache-and-artifact-offload`](../../../../../../homelab-reference-library/generated/context7/vllm/cache-and-artifact-offload/result.md) | HF env var precedence chain, `VLLM_CACHE_ROOT`, durability classes, HF_XET_CACHE absolute-path caveat, `uv` same-filesystem constraint |
| [`huggingface-hub/cache-disk-management`](../../../../../../homelab-reference-library/generated/context7/huggingface-hub/cache-disk-management/result.md) | Cache layout (blobs/snapshots), 19 GiB per 32B AWQ model, `CACHEDIR.TAG`, stale `.locks`, `huggingface-cli` exit 1 (C2) |
| [`containerd/image-store-disk-reclamation`](../../../../../../homelab-reference-library/generated/context7/containerd/image-store-disk-reclamation/result.md) | Dual-store model (content + snapshotter), GC mechanism, `discard_unpacked_layers`, template path `config-v3.toml.tmpl` (C3) |
| [`k3s/storage-offload-targets`](../../../../../../homelab-reference-library/generated/context7/k3s/storage-offload-targets/result.md) | No `--containerd-root` flag, bind-mount as the only mechanism, vendor endorsement of agent/server split, overlayfs filesystem constraint |
| [`kubernetes/kubelet-storage-offload`](../../../../../../homelab-reference-library/generated/context7/kubernetes/kubelet-storage-offload/result.md) | `podLogsDir` accounting caveat, imagefs split mechanics, `local-path` StorageClass, CSI hostPath contract |
| [`systemd/os-directory-offload`](../../../../../../homelab-reference-library/generated/context7/systemd/os-directory-offload/result.md) | Journal `SystemMaxUse`, `--rotate` required for vacuum, swap on dedicated SSD rationale, Kubernetes swap quotes |
| [`prometheus/tsdb-storage-and-retention`](../../../../../../homelab-reference-library/generated/context7/prometheus/tsdb-storage-and-retention/result.md) | TSDB durability statement, retention sizing formula, three sizing traps, `local-path` advisory-only claim |
| [`implementation-guides/storage/storage-offload-taxonomy.md`](../../../../../../homelab-reference-library/implementation-guides/storage/storage-offload-taxonomy.md) | Two-axis model (category × durability), split of `logs_and_metrics`, local-path capacity enforcement warning |
| [`receipts/2026-09-11T065746Z-s1-storage-discovery.md`](../../../implementation-campaign/receipts/2026-09-11T065746Z-s1-storage-discovery.md) | Verified current disk usage by path, drive class, DiskPressure state, PVC mapping |
