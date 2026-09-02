# 5090 VRAM tuning — before & after (beginner guide)

One-page visual for **why 14B looked “small” but still used most of the GPU**, and **what we changed** to run **32B** at the **same 32k context** without trimming.

![Before and after VRAM bars](./5090-vram-tuning-before-after.svg)

## The mistake in plain English

People often equate **parameter count** with **GPU usage**:

- “14B is half of 32B, so the 5090 must be half empty.”

On a **long-context** coding setup, that is usually **wrong**.

At **32,768 tokens** (`--max-model-len 32768`), most VRAM is not the model weights — it is the **KV cache** (session memory that remembers what was already in the prompt).

**Live measurement (before):** 14B AWQ used **~29 GB of 32 GB** (~89%). The GPU was not “half free.”

## Three memory buckets (remedial)

| Bucket | What it is | Analogy |
| --- | --- | --- |
| **Model weights** | The compressed “brain” loaded once | Textbook size |
| **KV cache** | Memory for tokens already in context | Scratch paper for the long conversation |
| **Runtime overhead** | Activations, CUDA graphs, buffers | Desk clutter while working |

Longer context → **bigger KV cache**, even if the model stays the same size.

## BEFORE — 14B @ 32k (untuned thinking)

| Piece | ~Size | Notes |
| --- | --- | --- |
| Model weights (14B AWQ) | ~9 GB | Smaller brain |
| KV cache (32k, default dtype) | ~20 GB | **Dominates** |
| Overhead | ~1 GB | |
| **Total used** | **~29 GB** | Looked “almost full” already |

**Settings:**

```text
--max-model-len 32768
--gpu-memory-utilization 0.90
(kv-cache-dtype: default — not fp8)
```

**Problem:** We were paying for a **large context window** on a **smaller model**. VRAM was busy, but **capability** was capped at 14B.

## AFTER — 32B @ 32k (tuned to fit)

| Piece | ~Size | What changed |
| --- | --- | --- |
| Model weights (32B AWQ) | ~20 GB | **Bigger model** (smarter lane) |
| KV cache (32k, **fp8**) | ~8 GB | **TUNED** — same context, fewer bytes per token |
| Overhead | ~2 GB | |
| **Total used** | **~30 GB** | ~92% — appropriate for primary 5090 lane |

**Settings (what we tuned):**

```text
--max-model-len 32768          # unchanged — full context preserved
--gpu-memory-utilization 0.92  # slightly more VRAM budget for KV pool
--kv-cache-dtype fp8           # KEY: smaller KV without cutting context
--max-num-seqs 4               # cap concurrent chats (limits peak KV)
```

**Live measurement (after):** **~30 GB / 32 GB** on `hom-lab-ctl-k3s-02`.

## What we did *not* do

We did **not** “make it fit” by slashing context (for example dropping to 16k). That would be a different tradeoff. The homelab goal was **keep 32k** and tune **KV efficiency** + **concurrency**.

## Diagram inventory

| Artifact | Medium | Purpose |
| --- | --- | --- |
| `5090-vram-tuning-before-after.svg` | SVG | Side-by-side VRAM bars + legend |
| This file | Markdown | Remedial explanation |

## Related

- Plan: [../README.md](../README.md)
- **Steady-state runbook:** [docs/reference/models/5090-qwen25-coder-14b-vs-32b.md](../../../../reference/models/5090-qwen25-coder-14b-vs-32b.md)
- HRL: `homelab-reference-library/notes/investigations/2026-09-02--5090-vllm-32b-awq-memory-sizing.md`
- Inventory: `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` (`k3s_vllm_runtime_extra_args`)
