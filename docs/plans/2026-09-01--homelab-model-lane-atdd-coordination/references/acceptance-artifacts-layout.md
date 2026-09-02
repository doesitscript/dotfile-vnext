# Model-lane acceptance artifacts

| Layer | Location | Holds |
| --- | --- | --- |
| Harness | global-skills `homelab-litellm-model-lane-pytest` | pytest, receipts, gating |
| Specs | `model-lane-acceptance/` | YAML manifests, client map, pending vs approved |
| Coordination | global-skills `homelab-model-lane-atdd-coordinator` (execute phase) | handoffs, stack-implementer templates |

## `model-lane-acceptance/` (implemented)

```text
model-lane-acceptance/
├── client-map.yml
├── gateway/manifest.yml
├── gateway/pending/
├── codex/profiles-approved.yml
├── codex/pending/
└── scripts/run-*-acceptance.sh
```

## Deferred — scale

Not yet designed: multi-day run history, per-client-group manifest trees, parallel
model cohorts. Revisit before expanding beyond the current flat layout.

## References

- [ATDD flow diagram](../diagrams/atdd-developer-flow.md)
- HRL: `homelab-reference-library/implementation-guides/pytest/user-journey-receipt-tests.md`
