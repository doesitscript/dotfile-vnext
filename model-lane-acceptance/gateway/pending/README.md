# Gateway acceptance — pending (ATDD)

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

None filed yet. Gateway approved contracts live in the parent `manifest.yml`.
