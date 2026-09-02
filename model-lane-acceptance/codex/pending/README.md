# Codex acceptance — pending (ATDD)

Contracts here are **criteria first, implementation second**. A failing run is
expected until Codex executes shell tools and returns the bounded answer.

## How to read FAIL receipts

| Receipt step | FAIL means |
| --- | --- |
| `final-answer` | Model did not return exact EXPECTED text |
| `no-unexecuted-exec-request` | Model printed exec JSON instead of executing |

Do **not** weaken `expect_no_unexecuted_exec_request` to force green. Fix runtime
(vLLM parser, Codex sandbox, profile) and re-run.

## Promote to approved

When all steps PASS:

1. Move scenario into [`../profiles-approved.yml`](../profiles-approved.yml).
2. Update [`../profile-map.yml`](../profile-map.yml) status.
3. Update client map notes in [`../../client-map.yml`](../../client-map.yml).

## Current pending

| File | Journey |
| --- | --- |
| [`tool-loop.yml`](tool-loop.yml) | Teammate handoff file → shell read → `ready-for-review` |
