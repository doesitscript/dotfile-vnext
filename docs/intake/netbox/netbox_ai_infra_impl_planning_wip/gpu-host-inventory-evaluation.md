# GPU host inventory — evaluation

**Type:** evaluation (living SSOT for hardware facts)  
**Status:** in_progress — second-host GPU model identified; guest-ready GPU path still blocked on host capability  
**Related:** [gpu-lane-and-model-lane-mapping-evaluation.md](./gpu-lane-and-model-lane-mapping-evaluation.md), [host-role-reconciliation-discussion.md](./host-role-reconciliation-discussion.md), [ASSESSMENT.md](./ASSESSMENT.md)

Track **what GPU each machine has** and **what role it plays** in the AI stack. Update this file when inventory, facts, or operator decisions change.

---

## Operator host roles (authoritative intent)

Use **inventory host names** in repo work. Intake phrases “5090 lane” / “second GPU lane” are provenance only — see [gpu-lane-and-model-lane-mapping-evaluation.md](./gpu-lane-and-model-lane-mapping-evaluation.md).

| Role | Inventory host | OS hostname | Role in AI project |
|------|----------------|-------------|-------------------|
| **Primary GPU (hvh-02)** | `hom-lab-ctl-hvh-02` | `DESKTOP-VLLM` (legacy) | Primary **vLLM** deep/private coding inference (RTX 5090) |
| **Storage lane (hvh-01)** | `hom-lab-ctl-hvh-01` | `ai-net-server-mgmt` area | MinIO, Langfuse-heavy work, **smaller GPU** — reviewer/embeddings when vLLM is added |
| **Third node (edge desktop)** | `dev-workstation-win` | `DESKTOP-C1ACPUM` | Online; **design/plan/stub only** in current reconciliation — no full integration or catch-up automation |

**Not in active reconciliation:** `dev-3090-win` (RTX 3090) — inventory exists; deferred in edge-dev plan. Do not confuse with third node above.

---

## GPU hardware facts (repo + probes)

| Host | GPU (documented) | VRAM (approx) | Source | Confidence |
|------|------------------|---------------|--------|------------|
| `hom-lab-ctl-hvh-02` | **NVIDIA RTX 5090** | ~32 GB class | `inventory/group_vars/hyperv_lane_gpu/main.yml` (`gpu: rtx-5090`) | high |
| `hom-lab-ctl-hvh-01` | **NVIDIA GeForce GTX 1060 6GB** | ~6 GB class | Live WMI probe (`Get-CimInstance Win32_VideoController`) + `inventory/host_vars/hom-lab-ctl-hvh-01.yaml` | high for model; medium for runtime readiness |
| `dev-workstation-win` | **AMD Radeon RX 9060 XT** | ~16 GB (WMI `AdapterRAM` unreliable) | `inventory/group_vars/dev_workstation.yaml`, troubleshooting docs | high |
| `dev-3090-win` | **NVIDIA RTX 3090** (planned) | ~24 GB class | `inventory/group_vars/dev_3090.yaml` | medium (host deferred) |

### Evidence paths

- `hom-lab-ctl-hvh-02`: `hyperv_lane_gpu`, `llm_compute_windows` target
- `dev-workstation-win`: [DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md](../../one_off_tasks/DESKTOP-C1ACPUM-gpu-fps-troubleshooting.md)
- `hom-lab-ctl-hvh-01`: live WMI probe shows `NVIDIA GeForce GTX 1060 6GB`; inventory SSOT now carries `gpu: gtx-1060-6gb`

---

## Guests vs physical hosts (do not confuse)

| Physical host | Typical guests | AI services today (repo) |
|---------------|----------------|---------------------------|
| **hvh-02** (5090) | `hom-lab-ctl-dkr-02`, `hom-lab-ctl-k3s-02` | LiteLLM, Langfuse, Jupyter on **k3s-02**; MinIO/Postgres on **dkr-02** |
| **hvh-01** (storage) | `hom-lab-ctl-dkr-01`, `hom-lab-ctl-k3s-01` | Storage-lane convergence planned; Langfuse exposure vars on **hvh-01** group suggest intent to run Langfuse/MinIO on this lane |

**Reconciliation note:** ChatGPT intake often said “second GPU host” without naming `hvh-01`. Your clarification maps **second GPU → storage server (`hom-lab-ctl-hvh-01`)**. The repo still runs several “storage” services on the **5090 lane guests** (dkr-02/k3s-02). That is a **placement drift** to resolve in planning, not something to hide.

---

## Next inventory actions

| Action | Host | Why |
|--------|------|-----|
| Record `IovSupport` / partitionable-GPU blocker beside the 1060 fact | `hom-lab-ctl-hvh-01` | Distinguish “GPU exists” from “Ubuntu guest can consume it” |
| Optional probe | `hom-lab-ctl-hvh-02` | Confirm 5090 driver via existing `validate_windows_gpu_hosts.yaml` |
| No automation apply | `dev-workstation-win` | Per scope: document/diagram/stub only |

### Current readiness note for `hom-lab-ctl-hvh-01`

- Live host probe reports `IovSupport=False`.
- `IovSupportReasons` reports BIOS PCIe control and ACS limitations.
- `Get-VMHostPartitionableGpu` returned no partitionable GPU on this host.
- `nvidia-smi` on the Windows host returned `Failed to initialize NVML: Not Found`,
  so host-local NVIDIA runtime health still needs verification even though WMI
  identifies the GPU.
- Result: the host is correctly labeled as a **smaller secondary GPU host**, but
  it is **not currently a guest-ready GPU lane** for the Ubuntu VM path.
