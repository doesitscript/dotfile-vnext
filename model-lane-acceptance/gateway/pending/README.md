# Gateway acceptance — pending (ATDD)

`model-iteration-2026-09-11.yml` is the five-candidate matrix for the new
Qwen3-Coder, Qwen3.6, gpt-oss, Devstral, and GLM lanes. Run it through the
shared global-skills harness:

```bash
./model-lane-acceptance/scripts/run-model-iteration-acceptance.sh \
  -m infrastructure -v -s
```

The infrastructure group proves exact publication in `GET /v1/models`.
After a candidate runtime is published, run the full human-receipt matrix
without `-m infrastructure`. Keep this file pending until the exact
candidate’s receipts are green; do not promote a route because its weights
exist on the model share.

Place **new** lane journeys here when criteria are defined before the model or
route is commissioned.

## Workflow

1. Copy a journey anchor pattern from [`../manifest.yml`](../manifest.yml) or
   global-skills `references/homelab-default-lanes.yml`.
2. Add `title`, `user_story`, and EXPECTED fields.
3. Run against a draft lane id:

```bash
LITELLM_MODEL_LANE_MANIFEST=model-lane-acceptance/gateway/pending/my-new-lane.yml \
  ./model-lane-acceptance/scripts/run-gateway-acceptance.sh -v -s
```

4. When all receipts PASS, merge the lane into [`../manifest.yml`](../manifest.yml)
   and update [`../../client-map.yml`](../../client-map.yml).

## Current pending

The model-iteration matrix is pending. Gateway approved contracts live in the
parent `manifest.yml`.
