# RTX 5090 Model Lane Selection (2026-09-10)

## Context

Replacing current Qwen2.5-Coder-32B-AWQ primary model with a curated set of 5 models optimized for single-GPU agentic coding and architecture discussion workflows.

**Hardware**: RTX 5090, 32GB VRAM
**Use Case**: Continue/Cursor agent loops, Terraform/Ansible architecture discussion, LiteLLM multi-lane routing
**Validation**: E1–E4 lite-eval suite against actual failure modes (hardcoding, invented ARNs, scope creep)

## Selected Model Lineup

| Rank | Model | Why for this stack | 5090 fit |
|---|---|---|---|
| **1** | **Qwen3-Coder-30B-A3B** | MoE (30B total/~3B active) — current consensus pick for agentic coding on a single consumer card. Strong tool-calling, and the low active-param count keeps it fast enough to not fight Continue/Cursor loop | Q4_K_M ~18GB, Q5_K_M ~22GB, ~100-170 tok/s |
| **2** | **Qwen3.6-35B-A3B** (or 27B dense) | Generalist/architecture-discussion model. The A3B MoE variant runs ~145 tok/s at Q6 on a 5090 with room for long context — useful for the "explain this Terraform module" side of workflow, separate from raw code edits | Q6 ~28GB |
| **3** | **gpt-oss-20b** | Small footprint (21B total/3.6B active) means you can colocate it alongside your coder model in the same 32GB budget rather than swapping models — genuinely useful given LiteLLM routing setup | Q8 fits easily, leaves headroom to run two models at once |
| **4** | **Devstral Small 2** | Agent-specialist, dense 24B. Ranked above GLM-4.5-Air for this use case specifically because it's purpose-built for repo-navigation/tool-use agent loops — closer to what Continue Agent evals are actually testing | Fits at Q4, ~24GB |
| **5** | **GLM-4.6-Air** (not 4.5) | Swapped in over GLM-4.5-Air. 4.5-Air's unquantized footprint (~221GB) makes it a genuine science project on one card even with offloading. GLM-4.6-Air has usable Q4_K_M quants that actually fit in 32GB with room for context, so you get the "heavier, more capable" experimental lane without wrecking GPU lane usability | Q4_K_M fits in 32GB |

## Key Design Decisions

### Why Qwen3-Coder-30B-A3B over Qwen2.5-Coder-32B-AWQ

- MoE architecture with 3B active params vs 32B dense
- Better token/second throughput for agent loops
- Strong tool-calling support
- Proven consensus pick for single-consumer-GPU agentic coding

### Why Qwen3.6-35B-A3B for Architecture Discussion

- Separate model for "explain this module" vs "write this code"
- MoE variant allows long-context discussion without VRAM pressure
- ~145 tok/s at Q6 on 5090 — fast enough for interactive architecture work

### Why gpt-oss-20b for Concurrent Serving

- Small enough to colocate with primary coder model
- Real concurrent-serving capability within 32GB budget
- Matches LiteLLM routing design (multiple lanes, swap-free)

### Why Devstral Small 2 over Other Agent Models

- Purpose-built for repo navigation and tool-use loops
- Dense 24B fits at Q4
- Closer match to Continue Agent eval failure modes than general models

### Why GLM-4.6-Air over GLM-4.5-Air

- 4.5-Air unquantized footprint (~221GB) requires aggressive CPU offload
- 4.6-Air Q4_K_M fits in 32GB with context headroom
- Same architectural ambition, actually usable daily

## Validation Strategy

Since the E1–E4 lite-eval suite is already wired to LiteLLM gateway:

1. Swap `MODEL` env var for each new model
2. Rerun `run_lite_eval.py` against each candidate
3. Compare pass/fail against actual failure modes:
   - **E1**: Date exact (training data cutoff)
   - **E2**: Hardcode grounded (inventing values)
   - **E3**: Invent admit (making up resources)
   - **E4**: Scope no extra resource (adding unrequested resources)

This gives real pass/fail comparison against actual failure modes rather than relying on published benchmarks alone.

## Storage Strategy

- **Fast serving**: HVH-02 D: NVMe (active models)
- **Cold storage**: HVH-02 F: USB 3.0 (experimental/archived models)
- **Move catalog SSOT**: From HVH-01 F: SATA HDD to HVH-02 D: NVMe for faster downloads and vLLM startup

## Next Steps

1. Download all 5 models to fast storage
2. Commission Qwen3-Coder-30B-A3B as primary vLLM lane
3. Update Continue first model entry
4. Run E1–E4 eval suite on each model
5. Document eval results and finalize lane assignments
6. Move non-primary models to appropriate storage tiers based on usage patterns

## References

- Current catalog: `inventory/group_vars/model_catalog/manifest.yml`
- Lite eval suite: `docs/plans/2026-09-10--validations-agent-lane-fitness/lite-eval-qwen25-coder-32b-continue/`
- Storage research: HRL `generated/context7/huggingface-hub/cache-disk-management/`
