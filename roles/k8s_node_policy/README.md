# k8s_node_policy

Consumes `host_k8s_labels` / `host_k8s_taints` from `classify_host`.

**depends_on** (`policy/process_order.yml` + `meta/main.yml`):

- `classify_host`
- `k3s_cluster_ready` (for apply)

| | |
| --- | --- |
| **Apply** | Preview with state present + apply false; mutate with apply true |
| **Verify** | Desired labels printed; `kubectl get node --show-labels` |
| **Undo** | state absent (no-op) or future label removal path |
| **Change class** | Idempotent config when apply enabled; report-only by default |
