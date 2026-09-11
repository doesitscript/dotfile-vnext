# On-site Expert recommendation — 2026-09-11T085155Z

**Responding to:**
- [`onsite-expert_correction_blocker__test_the_export.md`](../onsite-expert_correction_blocker__test_the_export.md)
- [`onsite-expert_undone_or_deferred__test_the_export.md`](../onsite-expert_undone_or_deferred__test_the_export.md)

**Campaign evidence consulted:**
- `feedback_for_review_by_evaluator_2026-09-11T083117Z.md` (final governed Evaluator verdict)
- `coordination/continuation-checkpoint-2026-09-11T08-38-28Z.md`
- `coordination/decisions-and-authorization.md`
- `receipts/2026-09-11T065746Z-s1-storage-discovery.md` (S1 verified baseline)
- `receipts/2026-09-11T080420Z-s3-s5-owner-design.md` (S3/S5 scaffold and module receipt)
- `receipts/2026-09-11T082317Z-s4-safety-corrections.md` (S4 safety correction receipt)
- Current source: `roles/linux_data_disk_mount/tasks/absent.yml`, `derive_partition.yml`,
  `roles/hyperv_vm_data_disk/tasks/present.yml`

**Authority boundary:** This is advisory. No Apply authority is granted; all
recommendations are subject to independent Evaluator review. Facts are
distinguished from inference where they differ.

---

## Part 1 — S4 correction blockers

### Correction 1 — Exact mountpoint identity in `absent.yml`

**Best recommendation**

**The defect, precisely:** `absent.yml` uses `findmnt --target <path>` for the
live mount source lookup (lines 24–35 and 41–46 of the current source). The
`--target` flag returns the deepest filesystem that *contains* the path — not
necessarily a filesystem mounted *at* that path. This is confirmed by the
Evaluator's own read-only probe: `findmnt --target /tmp` returned `/dev/sda1`
on `hom-lab-ctl-k3s-02`; `findmnt --mountpoint /tmp` returned no match and
rc=1. On a second absent run — after the data disk has already been unmounted
and the mount directory is preserved but empty — `--target <mount_path>` will
return the root filesystem, causing the subsequent identity assertion to compare
the root device against the selected secondary disk. That assertion will fail
(correctly, because the devices don't match), but the role will do so after
having *treated the root filesystem as a candidate* rather than cleanly
determining "nothing is mounted here."

**Recommended contract:** Replace both `findmnt --target` invocations in
`absent.yml` with `findmnt --mountpoint`. Behavior change:

| State | `--target` output | `--mountpoint` output |
| --- | --- | --- |
| Disk mounted at path | SOURCE = partition device, rc=0 | SOURCE = partition device, rc=0 |
| Path exists but nothing mounted there | SOURCE = root device, rc=0 | empty, **rc=1** |
| Path doesn't exist | SOURCE = root device, rc=0 | empty, **rc=1** |

The role already treats `rc in [0, 1]` as non-failing and uses `rc == 1` to mean
"not mounted" throughout the absent assertions and when-guards. Switching to
`--mountpoint` makes rc=1 the correct and unambiguous "not mounted here" signal
for all three states above. No other logic changes are required.

**The fstab lookup** at lines 41–46 uses `findmnt --fstab --target <path>`. This
should be `findmnt --fstab --mountpoint <path>` for the same reason — though the
fstab case is less dangerous (fstab lookups are read-only), the precedent is
cleaner.

**Smallest idempotence test that proves fail-closed behavior:**

Use the existing controller-local safety playbook fixture pattern. Add one
static-contract assertion that verifies: given a mock absent call where the
device stat reports the disk does not exist AND `findmnt --mountpoint` returns
rc=1 for both live and fstab, the role reaches `assert: _live_source.rc == 1
and _fstab_source.rc == 1` without ever setting `_linux_data_disk_mount_live_source.stdout`
to a device path. The test fails closed because it checks that the "disk absent,
not mounted" path does not populate a SOURCE value — meaning the root filesystem
can never become the resolved device.

The test does not require a live second absent run on the managed host. The
controller-local safety playbook already exercises the "device not found" path
via the existing missing-selection fixture; the new assertion extends that same
fixture to confirm the live/fstab source registers as empty, not as a
containing-filesystem device.

**Assumptions:** The current role logic that guards all `when: _..._device_stat.stat.exists`
tasks is already correct; the only broken surface is the `--target` vs
`--mountpoint` in the two `findmnt` calls themselves.

**Risk:** None introduced — `--mountpoint` is strictly more precise.

**Rollback/wait condition:** If `findmnt --mountpoint` is not available on the
target host (it is a util-linux 2.27+ feature, available on any Ubuntu 20.04+),
the alternative is `mountpoint -q <path>` for existence and a separate `findmnt`
for the SOURCE. Ubuntu 20.04+ is confirmed as the target; `--mountpoint` is safe.

---

### Correction 2 — Stable whole-disk `/dev/disk/by-id/` validation

**Best recommendation**

**The defect, precisely:** The current input gate in `present.yml` (and mirrored
in `absent.yml`) checks:
```yaml
- linux_data_disk_mount_device_by_id | trim | length > 0
- not (linux_data_disk_mount_device_by_id | regex_search('-part[0-9]+$'))
```

This rejects explicit partition paths (e.g. `/dev/sdb1`, `/dev/disk/by-id/xxx-part1`).
It does **not** reject raw kernel device names like `/dev/sdb`, `/dev/sdc`, or
`/dev/vdb`. A caller supplying `/dev/sdb` passes the gate, `community.general.parted`
runs against it, and the role only afterward attempts to derive and validate
`/dev/sdb-part1` — which is not a valid path and will not be a symlink under
`/dev/disk/by-id/`. The failure happens downstream of a destructive-capable
operation.

**Recommended validation shape:** Add one assertion to the existing gate in both
`present.yml` and `absent.yml`:

```yaml
- linux_data_disk_mount_device_by_id | regex_search('^/dev/disk/by-id/')
```

This is sufficient and non-brittle. It does not require the path to exist (the
stat check handles that downstream); it purely enforces naming. Combined with the
existing `-partN` rejection, the gate now requires: non-empty, starts with
`/dev/disk/by-id/`, does not end with `-partN` suffix. That is the precise
definition of a stable whole-disk by-id path.

**Do not** add a check for whether the path is a symlink or resolves to a
whole-disk device at assertion time. Symlink resolution is already performed
downstream via `readlink -f` and `lsblk --nodeps`. Adding redundant resolution
in the early gate conflates an input-format check with a live-existence check
and creates a second place where the resolution logic can diverge.

**Required negative fixture:** The controller-local safety playbook should add:
1. A call with `linux_data_disk_mount_device_by_id: "/dev/sdb"` — must fail at
   the assertion gate with a message that names the path requirement, before
   `community.general.parted` is referenced in the task list.
2. A call with `linux_data_disk_mount_device_by_id: "/dev/disk/by-id/xxx-part1"` —
   must fail at the existing `-partN` rejection, not the new one (this confirms
   the two checks are independent).

**Inference flag:** I have not run these fixtures; I have read the current source
and the Evaluator's description of the failure mode. The assertion and fixture
shape above are based on the current gate structure, not a live probe.

**Risk:** Minimal. The assertion is purely additive — it rejects a broader class
of invalid inputs without changing any behavior for a correctly formed by-id path.

**Rollback/wait condition:** None. This is a source guard only; no host state is
involved.

---

### Correction 3 — Host free-space reserve recheck before VHDX creation

**Best recommendation**

**The defect, precisely:** The current `present.yml` apply operation (`Create
and attach selected Hyper-V data disk`) does not receive `HostReserveBytes` as a
parameter and does not re-read host free space before calling `New-VHD`. The
preview block reads `$drive.Free` and computes `host_free_bytes - reserve` to
gate creation there, but the apply block operates independently. If host free
space decreases between preview completion and apply execution (e.g. another
VHDX is created on the same host, or a large file lands on D:), the reserve
check is stale.

**Recommended fix shape:**

1. Add `HostReserveBytes` as a `[Parameter(Mandatory)][Int64]` in the apply
   script's `param()` block.
2. Pass it from the task: `HostReserveBytes: "{{ (hyperv_vm_data_disk_host_reserve_gib | int) * 1073741824 }}"` — identical to the preview block.
3. Inside the script, immediately before `New-VHD`, add:
```powershell
$drive = Get-PSDrive -Name $driveName -PSProvider FileSystem -ErrorAction Stop
if ($drive.Free - $RequestedSizeBytes -lt $HostReserveBytes) {
    throw "Insufficient host free space: $([Int64]$drive.Free) bytes free; " +
          "need $RequestedSizeBytes bytes plus $HostReserveBytes reserve"
}
```

The `$driveName` derivation is already present in the apply script's parent
block; the `Get-PSDrive` call is the same pattern used in the preview. This
makes the check self-contained and consistent.

**For fixed-size VHDXs:** the check `drive.Free - RequestedSizeBytes >= HostReserveBytes`
is exactly right — a fixed-size VHDX claims all its space at creation time.

**For dynamic VHDXs:** the check is conservative (it reserves space that will
only be consumed gradually), which is the correct safe default. A dynamic VHDX
should be the caller's explicit choice and is already enforced by `ValidateSet`.

**Required static fixture extension:** The controller-local safety playbook
fixture for the apply block should add a synthetic test where:
- `RequestedSizeBytes + HostReserveBytes > drive.Free` (simulated via a fixture
  that sets a very large reserve or very small reported free space in the
  PowerShell mock)
- The expected outcome is an explicit error before any `New-VHD` call

The existing size-mismatch and reserve-already-crossed checks cover the preview;
the new fixture proves the apply path is also guarded.

**Inference flag:** I have read the apply script body. The `$driveName` derivation
from the path's root already exists in the script block at the same scope level.
I am confident the Get-PSDrive call can be inserted immediately before `New-VHD`
without structural change.

**Risk:** Low. The check is additive and fails closed. The only failure mode is a
false positive if D: genuinely fills between preview and apply, which is the
correct behavior.

**Remaining read-only evidence needed:** None for the correction shape. To
confirm the fixture covers the right conditional, a dry run of the safety
playbook with the updated fixture and the new parameter would be needed — this
is normal post-correction verification, not pre-correction research.

---

## Part 2 — Deferred S3/S4/S5 decisions

### Question 1 — Default best path for S3/S4/S5

#### S3 — Persistent vLLM cache backing

**Best recommendation:** Move the vLLM HuggingFace cache to the new secondary
mount once S4 creates it. Keep the existing cache intact during cutover; do
not delete it from the root filesystem until the new mount is verified
accessible and the vLLM pod has resumed successfully.

**Motivation:** The current state is unambiguous: 22 GiB actual cache on a root
filesystem at 85% capacity with DiskPressure=True and all vLLM/Langfuse/LiteLLM
pods Pending. The cache *is* the dominant offloadable surface — 30 GiB for
containerd and 22 GiB for the local-path storage exist, but the containerd data
is managed by K3s/kubelet GC (S2, no-change) and the local-path backing is the
declared PVC (moving it safely requires PV/PVC lifecycle work). The cache
directory is the simplest surface to move without a PVC migration.

**Recommended cutover sequence:**
1. S4 VHDX created and guest mount confirmed at selected path (e.g. `/mnt/k3s-cache`).
2. Stop the vLLM deployment (scale to 0 replicas) to quiesce cache writes.
3. `rsync -a --progress <source_cache_dir>/ /mnt/k3s-cache/`
4. Verify byte count and spot-check a model directory on the new path.
5. Update the vLLM PVC or `HF_HOME` environment variable to point to the new mount.
6. Scale vLLM back to 1 replica; confirm pod reaches Running state and DiskPressure clears.
7. Only then delete the original cache directory from the root filesystem.

**Reversal condition:** If step 6 fails (pod does not reach Running within a
defined window, or DiskPressure does not clear), scale back to 0, restore the
original `HF_HOME` or PVC config, scale back up. The original cache is still
present until step 7, so this is a clean revert.

**Evidence defines success:** `kubectl get pods -n <vllm_namespace>` shows
Running; `kubectl describe node hom-lab-ctl-k3s-02` shows `DiskPressure=False`
or equivalent pressure cleared; `df -h /` on the guest shows used% below 80%.

**Backup/data safety:** The 22 GiB cache contains only downloaded model weights
— it is re-downloadable from HuggingFace if the rsync or cutover fails
catastrophically. However, a re-download requires internet access and time.
Keeping the original until step 7 is sufficient operational backup for the
duration of the cutover. No additional backup infrastructure is needed for model
weights.

**Assumptions:** The vLLM deployment can be safely stopped momentarily (no
live-traffic guarantee is documented in the campaign evidence). If there is a
requirement for zero-downtime cutover, the sequence changes (hard-link or
bind-mount approach), but there is no evidence of such a requirement.

---

#### S4 — Physical VHDX capacity and design

**Best recommendation:** Single second VHDX, fixed type, 200 GiB, on the same
D: drive of `HOM-LAB-HVH-02`.

**Motivation and evidence:**
- Host D: has 373.6 GiB free on a 931.5 GiB NVMe volume (S1 verified fact).
- Current cache: 22 GiB (S1 verified). Qwen3-Coder-30B-A3B AWQ is approximately
  17–19 GiB. Two or three additional models of similar size represents 50–60 GiB.
- A 200 GiB VHDX leaves ~170 GiB free on D: after creation, well above any
  reasonable host reserve.
- Fixed type: predictable allocation, simpler reserve math, consistent
  performance. Dynamic VHDX offers no benefit for a dedicated cache volume where
  space will be populated immediately.

**Recommended values for the `decisions-and-authorization.md` decision row:**
| Parameter | Recommended value | Basis |
| --- | --- | --- |
| `hyperv_vm_data_disk_size_gib` | `200` | 22 GiB current + Qwen3 ~18 GiB + headroom |
| `hyperv_vm_data_disk_type` | `fixed` | Predictable; reserve math is exact |
| `hyperv_vm_data_disk_vhdx_path` | `D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-k3s-02\hom-lab-ctl-k3s-02-data.vhdx` | Consistent with existing VHDX naming convention at `D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-k3s-02\` |
| `hyperv_vm_data_disk_host_reserve_gib` | `50` | Keeps 120+ GiB free on D: after creation; conservative given 373.6 GiB free now |
| `hyperv_vm_data_disk_controller_number` | `0` | SCSI 0, next available location |
| `hyperv_vm_data_disk_controller_location` | `1` | Slot 0 is the existing system disk |
| Guest by-id path | Selected from `ls -la /dev/disk/by-id/` after VHDX attach | Must be read-only discovered post-attach, not pre-selected |
| Guest mount path | `/mnt/k3s-cache` | Descriptive; no conflict with standard paths |

**Inference flag:** Controller location `0:1` is inferred from the S1 discovery
that the existing disk is at controller `0:0` and no second attachment exists.
The guest by-id path cannot be pre-selected — it depends on the VHDX serial
assigned at creation. This is already correct in the role design (serial is
read via `lsblk` and compared against a provided expected value after provisioning).

**Host reserve risk:** At 373.6 GiB free, a 50 GiB reserve leaves 120+ GiB
headroom even after the 200 GiB VHDX. The reserve is intended to prevent
D: from being filled by future VHDXs/operations. 50 GiB is conservative;
the user may choose a lower value, but it should remain > 20 GiB.

**Backup/outage authority:** The VHDX creation and attachment step requires a
brief VM disk attachment operation; the K3s VM need not be stopped for VHDX
attachment on Hyper-V (hot-add is supported). However, the partition/filesystem/
mount steps on the guest will be disruptive if any workloads are using the mount
path (they won't be, because it's a new path). The outage window is effectively
the duration of the `community.general.parted` and `community.general.filesystem`
tasks — a few seconds. No full-VM shutdown is required unless the Hyper-V role
implementation requires it (it does not, based on the current role source).

---

#### S5 — Monitoring

**Preference (current-stack-first):** Host-native systemd timer with disk usage
check feeding journald, forwarded to Loki/Grafana via the existing Alloy path.

**Motivation:** The current stack is journald → Alloy → Loki/Grafana (verified
in S1 and the S3/S5 receipt). Prometheus, node_exporter, and Alertmanager have
no confirmed owner or deployed instance. Adding a systemd timer is a one-role
addition with no new service dependency, and Grafana already provides dashboard
visibility and basic alert evaluation if a Loki alerting rule is configured.

**Recommended minimum viable policy:**
```
Owner: systemd timer on hom-lab-ctl-k3s-02
Cadence: hourly (OnCalendar=hourly)
Check command: df --output=pcent /mnt/k3s-cache | tail -1 → write to journald via systemd-cat
Warning threshold: 75%
Critical threshold: 90%
Mounts in scope: /mnt/k3s-cache (the new data mount) and / (root filesystem)
Alert destination: journald → Alloy → Loki; Grafana dashboard + log alert rule
Metric retention: follow Loki retention (existing policy)
```

**When to choose Prometheus/Alertmanager instead:** If paging/on-call alerting
(PagerDuty, Alertmanager receiver) is required — Loki alerting rules require a
Grafana alert contact point, which may not be configured. If `kubectl get
prometheusrule` shows active rules in the cluster, that is evidence the
Prometheus path already has ownership.

**The user decision required is:** `current-stack-first` (timer + journald)
vs `prometheus-compatible` (node_exporter + PrometheusRule + Alertmanager).
Both designs are available but neither is executable until this choice is
recorded in `decisions-and-authorization.md`.

---

### Question 2 — Read-only evidence genuinely needed before committing

Genuinely blocking (not nice-to-have rediscovery):

1. **Guest by-id path for the new disk.** Cannot be determined until the VHDX
   is attached. The role already requires it as an explicit input
   (`linux_data_disk_mount_device_by_id`). After attach but before initialization,
   a read-only `ls -la /dev/disk/by-id/` on `hom-lab-ctl-k3s-02` will show the
   new disk's by-id symlink and serial. This is mandatory for the
   `linux_data_disk_mount_expected_serial` value.

2. **Confirmation that controller slot 0:1 is unoccupied.** The S1 discovery
   showed one attachment at 0:0. If the VM configuration has been changed since
   then, a second slot check is needed. This is a single `Get-VMHardDiskDrive
   -VMName hom-lab-ctl-k3s-02` read-only probe.

Not needed before committing (already captured or inferable):
- Disk pressure state — already verified DiskPressure=True (S1 fact).
- Cache directory size — already captured at 22 GiB (S1 fact).
- Host free capacity — already captured at 373.6 GiB (S1 fact).
- K3s version — already captured; v1.31.12 (S1 fact).
- The exact VHDX path on the host — derivable from the existing naming convention.

---

### Question 3 — Evidence defining successful cutover and reversal condition

**Successful cutover evidence (all required):**
1. `kubectl get pods -n <vllm_namespace>` shows vLLM pod in `Running` state.
2. `kubectl describe node hom-lab-ctl-k3s-02` shows `DiskPressure=False` in Conditions.
3. `df -h /` on the guest shows used% ≤ 80% (DiskPressure threshold is 85%;
   80% provides margin).
4. `df -h /mnt/k3s-cache` shows the new mount is accessible and has the expected
   data (model directory spot check).
5. vLLM can successfully load a model (a read-only inference request completes).

**Reversal condition (trigger a wait or revert):**
- If (3) does not clear after cache move and pod restart within 10 minutes,
  something other than the cache is contributing. Do not delete the original
  cache directory. Check `du -sh /var/lib/rancher/k3s/agent/containerd` — if
  it has grown, there may be a containerd/K3s issue to investigate separately.
- If (1) fails (pod stays Pending or CrashLoops), check pod events for a
  different root cause before concluding storage is the problem.
- Rollback trigger: revert `HF_HOME`/PVC config to original path, scale vLLM
  back up, confirm pod resumes from original cache. The original 22 GiB cache
  must not be deleted until (1)–(5) are all confirmed.

---

### Question 4 — S2 no-change decision

**Best recommendation: the no-change decision remains correct.**

**Motivation:** The evidence is unambiguous. Kubelet attempted to free
3,778,818,867 bytes and found 0 eligible image bytes. The image inventory is
small. The root cause is that the declared 120 GiB PVC is backed on a 77 GiB
root filesystem — this is a capacity/backing design problem, not a GC policy
problem. Changing image GC thresholds, adding a containerd prune timer, or
restarting containerd would produce no disk reclamation (zero eligible bytes)
and would add operational complexity for no benefit.

**Is there a justified low-risk S2 improvement?** One candidate: the five
exited CRI containers and five NotReady sandboxes observed in S1 were not
removed and are not eligible image bytes, but they do represent containerd state
that could be pruned with `crictl rmp --all`. This is bounded: it reclaims
container state, not image bytes, and will not materially affect disk pressure.
If S3/S4 solve the pressure and these are still present afterward, they can be
addressed via normal K3s/kubelet lifecycle, not as a separate S2 change.

**Conclusion:** Retain the no-change S2 decision. The CRI container/sandbox
state is a future nice-to-have, not a blocking or priority item.

---

### Question 5 — Runtime evidence retention horizon

**Preference:** Retain through the next successful Evaluator pass on the three
S4 corrections (i.e., until the Evaluator's next verdict does not contain
blocking corrections and the campaign advances past `changes-requested`).

**Motivation:** The execution records and plan artifacts are the Evaluator's
input for the recheck. Deleting them before that review destroys the continuity
chain. After the Evaluator pass that clears the S4 blockers, the execution
records from prior passes are no longer needed for governance and can be
archived or removed.

**What must not be deleted before that:** Campaign README, accounting,
authorization ledger, receipts, and the feedback artifacts — these constitute
the plan artifact record. The `execution-records/` runtime evidence (session
files, process records) is what can be released after the final Evaluator pass.

**What can be cleaned immediately:** Nothing. The private runtime directory and
session record cleanup noted in the undone/deferred document is explicitly a
user decision and must not touch plan artifacts or shared services regardless
of timing.

---

## Summary matrix

| Item | Label | One-sentence motivation |
| --- | --- | --- |
| `findmnt --mountpoint` in absent.yml | **Best recommendation** | `--target` ambiguously returns the root filesystem for unmounted paths; `--mountpoint` is unambiguous |
| `/dev/disk/by-id/` prefix assertion | **Best recommendation** | Closes the raw-device input gap before `parted` runs; additive, no behavior change for valid inputs |
| VHDX apply reserve recheck | **Best recommendation** | Preview check is stale at apply time; re-reading free space inside `New-VHD` closes the time-of-check gap |
| S3 cutover: move cache to new mount, keep original until verified | **Best recommendation** | Reversible, no data risk, cache is re-downloadable as last-resort |
| S4: 200 GiB fixed VHDX at D: slot 0:1, 50 GiB reserve | **Preference** | Matches current capacity evidence; exact values require user authorization |
| S5: current-stack-first systemd timer + journald | **Preference** | Avoids new service dependency; upgrade to Prometheus if paging required |
| S2: no-change retained | **Best recommendation** | Zero eligible image bytes; capacity is the root cause |
| Runtime evidence: retain through next Evaluator pass | **Preference** | Continuity for governance; release after S4 clears |

**Next actor per the checkpoint:** Implementer — address only the three S4
source corrections, then publish a fresh receipt and outbox. This recommendation
document does not grant Apply authority and does not change the Evaluator
requirement.
