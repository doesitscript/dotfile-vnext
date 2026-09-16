# Plan 22 acceptance-gap implementer report

To: The Plan 22 evaluator

## Changes

1. `commissioned-six` is now a real profile in
   `/Users/joshc/develop/homelab-model-lane-pytest/src/homelab_model_lane_pytest/__init__.py`.
   It pins the six enabled commissioned IDs:

   - `qwen3-coder-30b-a3b`
   - `qwen2.5-coder-14b`
   - `qwen2.5-coder-7b`
   - `qwen2.5-coder-1.5b-base-q8_0`
   - `nomic-embed-text`
   - `gpt-oss-20b`

2. The CLI now accepts unknown pytest arguments and strips the leading
   separator used by `just run -- --profile ...`. Both operator paths work:

   ```text
   just run --profile commissioned-six
   just run --profile smoke --lane-filter qwen3-coder-30b-a3b
   just run -- --profile commissioned-six
   ```

   The compatibility forwarding path collected 11 applicable cases. The
   `gpt-oss-20b` tools scenario is not among them because that lane advertises
   chat only after its observed empty-tool-call behavior.

3. `/Users/joshc/develop/homelab-model-lane-pytest/tests/live/conftest.py`
   now prints an end-of-run grouped journey summary. Smoke is grouped as
   `smoke`, chat journeys as `llm_chat`, tools as `llm_tools`, FIM as
   `llm_fim`, and embedding as `embed`.

4. `/Users/joshc/develop/homelab-model-lane-pytest/tests/live/test_journeys.py`
   now sends the `read_file` tool schema and requires a real tool call for a
   tools scenario. It emits separate invoke, execute, follow-up, and overall
   receipts. Follow-up grounding accepts any nontrivial token from the actual
   `/etc/hosts` content, matching the global harness semantics. A refusal or
   empty tool call fails honestly.

5. `/Users/joshc/develop/homelab-model-lane-pytest/manifests/default.yml`
   aligns the shared journey prose with the global default lanes for matching
   scenario IDs. `gpt-oss-20b` remains chat-only and its tools scenario is
   capability-omitted; no unsupported tools success is claimed.

6. The package README and draft SHIM document all-six versus one-model paths,
   including the legacy forwarding form.

## Fresh verification

```text
just unit
============================== 5 passed in 0.09s ===============================

just lint
All checks passed!
19 files already formatted

LITELLM_API_KEY= just run -- --profile commissioned-six --collect-only -q
tests/live/test_journeys.py: 11

just run --profile smoke --lane-filter qwen3-coder-30b-a3b
1 passed, 2 deselected in 0.33s

just test
=========================== 21 passed in 45.67s ==============================
```

The full commissioned-six live receipts, including one PASS per covered
capability class and the grouped summary, are captured in:

`docs/plans/2026-09-13--get-back-ansible-best-practice/plan-22_acceptance_gap_commissioned_six_receipts.txt`

The one-model smoke receipt is captured in:

`docs/plans/2026-09-13--get-back-ansible-best-practice/plan-22_acceptance_gap_one_model_receipt.txt`

The tools-only targeted receipt, showing real invoke/execute/follow-up PASS
blocks, was also freshly run during this pass.

No secret values were printed, committed, or placed in these artifacts.

## Estimate and remaining risk

I estimate this pass reaches approximately **90%** of the requested operator
acceptance bar: six-model profile selection, full live execution, one-model
targeting, global-style receipts, real tools harness evidence, FIM, embed, and
grouped summaries are all exercised. Remaining risk is the intentional
capability omission for `gpt-oss-20b` tools; that model needs a separate
commissioning change before tools can be advertised.

ready for evaluator re-review: yes
