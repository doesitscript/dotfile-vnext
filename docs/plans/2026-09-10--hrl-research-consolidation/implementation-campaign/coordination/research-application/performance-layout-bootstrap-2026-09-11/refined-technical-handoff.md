# Refined technical handoff — Implementer / Evaluator input

**Status:** canonical Light input for this campaign  
**Authority:** post-research On-site Expert ↔ Researcher synthesis, Planner-mapped  
**Not authority for:** live Apply, SSH discovery, or reopening broad research

This file is the **only** technical decision package Implementer and Evaluator
should treat as primary work input. They must **not** consume the onsite-expert
transcript, raw Context7 dumps, or Full-era feedback tips as the work itself.

---

## Provenance (what this closes)

| Stage | What happened | Durable source |
| --- | --- | --- |
| Discovery | DiskPressure on `hom-lab-ctl-k3s-02`; single 77 GiB root holds HF cache + containerd + local-path | S1 receipt + transcript discovery |
| Research (Context7 = Researcher role) | Storage offload taxonomy, k3s/containerd/kubelet/vLLM/HF/systemd/prometheus packs; Ansible practice packs | HRL `generated/context7/**`, `implementation-guides/storage/storage-offload-taxonomy.md` |
| Expert challenge | Placement matrix, hard corrections C1–C3, durability prohibitions | `storage-performance-research-application.md` |
| Post-research refinement | imagefs≠nodefs via containerd bind; evictionHard merge trap; `include_role` tag/`apply:` defect; fact `gathering` vs cache | Transcript findings ~2403–2489 |
| Adoption | Campaign placement decisions | `coordination/performance-layout-adoption.md` |
| This handoff | Owner-mapped, chunkable functional areas for Light Implementer/Evaluator | **this file** |

Classification-only packet: [`research-to-decision-packet.md`](research-to-decision-packet.md)  
Planner translation notes: [`plan-materialization-brief.md`](plan-materialization-brief.md)

---

## Hard corrections (non-negotiable wherever the surface appears)

| ID | Wrong | Right | Project touch |
| --- | --- | --- | --- |
| C1 | `TRANSFORMERS_CACHE` | `HF_HUB_CACHE` (token stays via `HF_TOKEN_PATH` on durable root) | `roles/k3s_vllm_runtime/**` |
| C2 | `huggingface-cli` | `hf cache ls/rm/prune/verify` (pin to image’s `huggingface_hub`) | any cache/monitor tasks that shell HF CLI |
| C3 | `config.toml.tmpl` on this node | `config-v3.toml.tmpl` + `{{ template "base" . }}` if a template is ever authorized | do **not** invent a template in Light unless Expert authorizes |
| C4 | Partial `evictionHard` override | Must set `mergeDefaultEvictionSettings: true` or unspecified signals zero | kubelet/K3s config owners only if touched |
| C5 | Move pod logs off `/var` | Cap in place (`containerLogMaxSize` / `containerLogMaxFiles`); never relocate | do not add log-offload owners |
| C6 | Tagged `include_role` without `apply:` | Tags do **not** enter the role; use `apply: { tags: [...] }` | any playbook that includes storage owners under tags |
| C7 | `gathering` unset with fact cache | Default `implicit` ignores cache; set `gathering` so cache is consulted | ansible.cfg / inventory facts config if changed |

---

## Settled placement (desired state)

| Tier | Mount / location | Holds | Must not hold |
| --- | --- | --- | --- |
| Root VHDX | `/` | OS; K3s server db/TLS; capped pod logs | HF weights, containerd image store, new local-path data |
| New 200 GiB NVMe VHDX | `/mnt/k3s-cache` | `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`; containerd via **bind** at `/var/lib/rancher/k3s/agent/containerd`; new local-path under `/mnt/k3s-cache/local-path`; optional `VLLM_CACHE_ROOT` | K3s server state, TLS, credentials, Prometheus TSDB, Jupyter work product |
| SATA SSD (after identity proven) | `/mnt/logs`, `/mnt/swap` | journal (capped), host swap (kubelet-compatible), rebuildable compile/scratch | model weights, durable K3s/DB, pod logs |

**Mechanism that actually fixes DiskPressure for images:** split `imagefs` from
`nodefs` by bind-mounting containerd’s agent store. K3s has **no** independent
containerd-root flag; path is derived from `--data-dir`. Overlayfs requires
**ext4 or xfs** on the destination.

---

## Functional areas → project owners (chunk seeds)

These are **functional areas**, not frozen one-shot tasks. Implementer derives
and refreshes `coordination/implementation-work-queue.md` from this table:
propose the smallest coherent owner group that realizes one area’s target
state, freeze it for Evaluator, then propose the next non-overlapping area
while review runs.

| Area ID | Target state (Light) | Primary owners | Depends on | Light validation |
| --- | --- | --- | --- | --- |
| `FA-hf-cache-desired-state` | Role converges HF cache to `HF_HUB_CACHE=/mnt/k3s-cache/hf/hub`; no `TRANSFORMERS_CACHE`; no deprecated CLI; repeat runs do not redo completed migration | `roles/k3s_vllm_runtime/**`; related vLLM deploy playbook | mount path vars exist or are declared; no live disk identity guess | one bundled syntax/lint/template/argument-contract check |
| `FA-containerd-imagefs-bind` | Offload role converges containerd store onto NVMe backing via bind at K3s agent containerd path; server/db/TLS untouched; overlayfs-capable FS assumed in contract | `roles/k3s_storage_offload/**`; `playbooks/deploy_k3s_data_disk.yaml`; `playbooks/deploy_k3s_storage_expansion.yaml` | data-disk mount role contract; by-id only when Full attaches disk | bundled syntax/lint + static normal-state idempotence assertions (no safety-fixture theater) |
| `FA-local-path-new-only` | New local-path / StorageClass path points at `/mnt/k3s-cache/local-path`; existing PV paths immutable | k3s storage / local-path owners already in repo | FA-containerd or shared mount layout vars | syntax/lint on touched playbooks/templates |
| `FA-capacity-signal` | Storage capacity monitor owned by existing stack; emits usable capacity signal; no broken `df` flags | `roles/storage_capacity_monitor/**`; `roles/logging_alloy/**` only if required; monitor playbooks | none for source contract | template/fixture + syntax/lint |
| `FA-ansible-tag-hygiene` | Storage-related `include_role` call sites that must honor tags use `apply:` | storage deploy/report playbooks that include the owners above | none | `--list-tasks` proof for touched plays (controller-local) |
| `live-attach-and-apply` | Exact guest by-id, attach, mount, Apply, post-change proof | Full Orchestration only | all Light areas that claim source readiness | live evidence — **out of Light** |

Retired from Light: `verify_*_safety.yaml` failure-window / bespoke rollback
fixtures. Lab cattle posture: desired-state convergence + Ansible quality, not
production forensics.

---

## Implementer contract (dynamic queue)

1. Read **this file first**, then latest Evaluator artifact for the active
   chunk only (ignore superseded Full tips unless `orchestration_profile: full`).
2. Propose or refresh queue rows from the functional areas above. Each row:
   `chunk_id`, target state, owners, deps, validation, `available_next_chunk`.
3. Select the earliest ready non-overlapping chunk; implement only those owners.
4. Freeze owner-only diff + hashes + one validation bundle; write
   `review_ready_for_evaluator_*` with `chunk_id` and `available_next_chunk`.
5. While Evaluator reviews a frozen chunk, begin the next independent area only
   when owners/playbooks/queue file do not overlap.

Do **not** paste transcript prose into handoffs. Cite area IDs and this path.

---

## Evaluator contract (Ansible champion)

For each frozen chunk, answer first: **is the area’s target state present in
the declared owners?**

Then give short, file-specific corrections only:

- wrong module / non-idempotent loop / bad argument_specs or naming
- owner overlap or unowned config sprawl
- missing hard correction (C1–C7) where the surface is touched
- failed bundled source validation

Do **not** lead with digests, SSH, whole-campaign S1–S6 matrices, or
safety-fixture demands in Light. Trace fit back to this handoff’s area ID.

---

## Config surfaces (reference, not shell to paste blindly)

```text
HF_HUB_CACHE=/mnt/k3s-cache/hf/hub
HF_TOKEN_PATH=<durable root token path>
VLLM_CACHE_ROOT=/mnt/k3s-cache/vllm   # or SATA when discovered
# containerd: bind /mnt/k3s-cache/containerd → /var/lib/rancher/k3s/agent/containerd
# new local-path: /mnt/k3s-cache/local-path
```

Illustrative shell in research docs is **not** the implementation mechanism.
Implementer maps to existing Ansible owners; Evaluator rejects unowned copies
of research shell as “done.”

---

## Explicit non-inputs for the pair

- Onsite transcript markdown (conversation history only)
- Raw Context7 packs (already synthesized here)
- Quarantined Full feedback that reopens retired safety fixtures
- Parallel-preflight manifests as authorization
- Dashboard / broker status as quality proof
