# EVAL model note fit framework

Date: 2026-09-02
Purpose: make model-to-hardware evaluation repeatable, teachable, and less
dependent on stale repo assumptions.

## Authority order

Use evidence in this order:

1. Live host probe on the target machine
2. Runtime-specific packaging facts for the exact served artifact
3. Official model/vendor documentation
4. Repo deployment config and older internal notes

Interpretation:

- The repo is authoritative for what this project can deploy today.
- The repo is not automatically authoritative for whether a model is a good fit.
- Older notes are inputs, not decisions.

## What "fit" means

A model fits only when all four dimensions are acceptable:

1. Hardware fit
   The target GPU VRAM, host RAM, storage, and thermals can hold the model and
   keep it responsive enough for the intended work.
2. Runtime fit
   The serving stack can actually run the model format and feature set
   (`ollama`, `vllm`, llama.cpp-derived backends, vendor offline runtimes).
3. Workload fit
   The model is suitable for the real job: autocomplete, code edit, tool-using
   agent, long-context review, chat, or vision.
4. Operational fit
   The deployment, restart, verification, and rollback path are simple enough
   for the current maturity of the lab.

## Required inputs

Capture these before recommending a model:

- Host name and date
- GPU model and VRAM
- Host RAM
- Runtime and version family
- Intended context window
- Expected concurrency
- Intended workload class
- Candidate model tag or exact repo id
- Quantization / packaging form

## Minimum evaluation flow

1. Establish the machine
   Confirm the exact host, GPU, VRAM, runtime, and storage path.
2. Define the workload
   Separate coding chat, edit/apply, tool loop, autocomplete, long-context
   reasoning, and vision. These are different lanes.
3. Check runtime compatibility
   Confirm the runtime accepts the model family and quantization.
4. Estimate memory fit
   Start with the packaged weight footprint, then reserve headroom for KV cache,
   runtime overhead, and interactive latency.
5. Probe the live host
   Verify the real deployment target if reachable.
6. Run behavior checks
   Test the actual workload, not just "reply ok".
7. Record the decision boundary
   Say what is proven, what is inferred, and what remains blocked.

## Operator heuristics

These are house heuristics, not upstream guarantees:

- If a packaged model footprint already consumes nearly all VRAM, treat it as a
  risky interactive fit even if it technically loads.
- For a 16GB class desktop, a roughly 14GB packaged model can be a viable
  single-user candidate, but it still needs live proof for context length and
  latency.
- A model that only produces JSON-shaped tool requests without completing the
  tool loop is not a qualified tool-using agent lane, even if its plain chat is
  acceptable.
- A model can be a good host-local candidate and still be a bad Codex lane.

## Acceptance checks by workload

Autocomplete:

- low latency on short prompts
- stable formatting
- no need for deep tool use

Edit/apply chat:

- follows focused file-edit instructions
- returns coherent patch plans
- stays within context budget

Tool-using agent:

- emits valid tool calls
- completes the tool loop through the actual gateway/client path
- does not stall or degrade into pseudo-tool JSON

Long-context review:

- survives the target window on realistic repo input
- remains coherent after large context ingestion

Vision:

- prove image round-trip behavior separately from text chat

## Required outputs

Every completed evaluation should leave:

1. One `EVAL-model-note-fit` document
2. One explicit selected / rejected / deferred decision
3. One deployment target update only if the host-fit decision is strong enough
4. One separate lane-publication decision for LiteLLM/Codex/Continue if needed

## Template sections

Each `EVAL-model-note-fit` note should include:

- date
- host
- hardware target
- scope
- authority order used
- evaluation method
- candidate comparison
- decision
- non-decision / boundary
- next steps
- sources
