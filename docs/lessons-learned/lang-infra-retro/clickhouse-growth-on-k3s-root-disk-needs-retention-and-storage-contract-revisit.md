# ClickHouse Growth On K3s Root Disk Needs Retention And Storage-Contract Revisit

## Status

- `state`: revisit-required
- `scope`: Langfuse / ClickHouse / K3s storage design
- `why_revisit`: the immediate live fix moved Langfuse off the in-cluster stateful path, but the long-term retention and ClickHouse storage policy still need an explicit design choice

## Short Answer

The old `~58 GB` ClickHouse footprint was partly normal and partly a lab design
problem.

- **Normal:** Langfuse stores high-volume tracing / observability data in
  ClickHouse, and that data can grow quickly.
- **Design problem:** we let that growth happen on a **single-node K3s guest
  root disk** using `local-path` storage, with no real capacity enforcement and
  no repo-owned retention / system-log policy.

## Show Me: Where `20Gi` Came From

The old in-cluster Langfuse Helm values asked for `20Gi` of ClickHouse
persistent storage:

```yaml
clickhouse:
  deploy: "{{ k3s_langfuse_platform_clickhouse_deploy | bool }}"
  ...
  persistence:
    enabled: true
    size: 20Gi
```

Source: [roles/k3s_langfuse_platform/tasks/present.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_langfuse_platform/tasks/present.yml:145)

That looks like a safety rail, but in this setup it was not a hard stop.

## Why `20Gi` Did Not Protect The Node

The old storage path used K3s/Rancher `local-path` storage. In that storage
class, the PVC requested size is not a real quota on the host filesystem unless
you add extra quota machinery yourself.

What that means in practice:

1. Kubernetes said: "this volume is requested as `20Gi`."
2. `local-path` created a directory on the node filesystem.
3. ClickHouse kept writing into that directory.
4. The node kept allowing writes until the underlying disk filled.

So `20Gi` was **metadata for scheduling / provisioning intent**, not an
enforced disk ceiling on the K3s node.

## What "Root-Backed Single-Node K3s" Means

In this case:

- **single-node K3s** = the Langfuse cluster workloads were running on one K3s
  VM, `hom-lab-ctl-k3s-02`
- **root-backed** = the persistent data lived under the node's main filesystem
  path, effectively inside the same root VHDX that also held the guest OS,
  container runtime, and K3s state

So the old layout was effectively:

```text
hom-lab-ctl-k3s-02 VHDX
  /                <- guest OS root disk
  /var/lib/rancher/k3s
  /var/lib/rancher/k3s/storage/...clickhouse...
  containerd images
  kube state
  app PVC data
```

That means ClickHouse growth was competing with:

- the guest OS
- container images
- K3s control-plane state
- every other PVC on that node

## Show Me: What "Wrong Place, Wrong Storage Contract" Means

The old runtime shape put Langfuse stateful services directly on the GPU-lane
K3s guest:

- `Langfuse web`
- `Langfuse worker`
- `ClickHouse + ZooKeeper`
- `Redis`
- `MinIO`

See: [two-physical-server-langfuse-distribution-retrospective.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md:191)

At the same time, the repo also had duplicate/orphan stateful Langfuse-adjacent
services elsewhere on the Docker side:

- orphan Docker `ClickHouse`
- orphan Docker `Redis`
- orphan Docker `MinIO`

See: [two-physical-server-langfuse-distribution-retrospective.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md:177)

So the design mismatch was:

- **Wrong place:** heavy stateful analytics storage lived on the GPU-lane K3s
  node instead of the storage lane
- **Wrong storage contract:** the backing disk contract looked like a bounded
  persistent volume, but functionally behaved like "write into the node's root
  disk until the node is under pressure"

## Was `58 GB` Itself "Abnormal"?

Not by itself.

Langfuse's docs explicitly say ClickHouse disk can grow significantly because:

- LLM traces may include large inputs and outputs
- ClickHouse system log tables can consume substantial space if uncapped

So the better reading is not "58 GB proves corruption." It is:

- ClickHouse was behaving like an observability OLAP store
- our node and storage design were not appropriate for unbounded growth

## Do We Need To Do Something About Retention / System Logs?

Yes, but not as an emergency on the old in-cluster path anymore because that
path has already been removed from live use.

We **do** still need a deliberate long-term policy for the **current external
ClickHouse** on the storage lane.

### Minimum follow-up that still matters

1. Choose a Langfuse data-retention policy.
2. Decide whether to disable or aggressively TTL unused ClickHouse system log
   tables.
3. Decide what the expected storage budget is for Langfuse traces.
4. Verify the storage-lane ClickHouse data path is on the right disk class for
   active OLAP writes.

Without that, the new externalized design is structurally better, but it can
still grow without a clear ceiling.

## Should You Attach A Bigger Disk?

Maybe, but only as part of an explicit storage design.

### Good reason to add a bigger disk

- you want to retain a large amount of Langfuse history
- you plan to keep self-managed ClickHouse
- the storage lane needs a dedicated data volume with predictable capacity

### Bad reason to add a bigger disk

- to avoid making a retention decision
- to keep active ClickHouse data on an unsuitable volume layout and hope the
  problem goes away

### About a spinning disk

A spinning disk can be fine for:

- backups
- exports
- colder archive tiers

It is usually a weaker choice for **primary active ClickHouse data** because
ClickHouse benefits from faster random I/O and merge performance. For active
Langfuse OLAP storage, SSD/NVMe or an object-storage-backed design is usually a
better fit than "just put the hot database on a spinny disk."

## Recommended Long-Term Options

### Option A — Keep self-managed ClickHouse on the storage lane

- Add a dedicated data disk / volume for ClickHouse
- Set retention explicitly
- Cap or disable unused ClickHouse system log tables
- Monitor disk growth and free space

### Option B — Keep self-managed ClickHouse but retain less data

- Use shorter Langfuse retention
- Export what matters elsewhere
- Keep the active ClickHouse footprint intentionally small

### Option C — Move toward storage/compute separation later

- external object-storage-backed / managed ClickHouse pattern
- keep the repo contract focused on externalized services and retention policy

## Revisit Checklist

- [ ] Decide Langfuse retention target in days
- [ ] Decide whether ClickHouse system logs should be disabled or TTL-capped
- [ ] Verify where the storage-lane ClickHouse data directory lives physically
- [ ] Decide whether a dedicated SSD/NVMe-backed data volume is needed
- [ ] Record expected steady-state growth budget for Langfuse data
- [ ] Add repo-owned verification for ClickHouse disk usage trend

## Evidence

- Old in-cluster ClickHouse PVC request: [roles/k3s_langfuse_platform/tasks/present.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_langfuse_platform/tasks/present.yml:145)
- Old externalization defaults now disabling bundled stateful services:
  [roles/k3s_langfuse_platform/defaults/main.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_langfuse_platform/defaults/main.yml:30)
- Old mixed/orphan topology:
  [two-physical-server-langfuse-distribution-retrospective.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md:167)

## Sources Checked

- [roles/k3s_langfuse_platform/tasks/present.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_langfuse_platform/tasks/present.yml:145)
- [roles/k3s_langfuse_platform/defaults/main.yml](/Users/joshc/develop/dotfile-vnext/roles/k3s_langfuse_platform/defaults/main.yml:30)
- [docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md](/Users/joshc/develop/dotfile-vnext/docs/lessons-learned/lang-infra-retro/two-physical-server-langfuse-distribution-retrospective.md:167)
- Langfuse docs: `https://langfuse.com/self-hosting/configuration/scaling`
- Langfuse docs: `https://langfuse.com/self-hosting/deployment/infrastructure/clickhouse`
- Rancher local-path-provisioner docs: `https://github.com/rancher/local-path-provisioner/blob/master/README.md`
