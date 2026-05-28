---
deprecated: true
deprecating_reason: WSL scope reform 2026-05-28 — server paths must not use WSL
coordinator_review: pending
name: Logging Loki Alloy Stack
overview: "Implement a full Grafana Loki + Alloy logging stack across all managed surfaces: two new roles (logging_loki for the server, logging_alloy for the cross-platform agent), a new playbook, and targeted log source configuration per surface — Windows, WSL/Linux, and macOS."
todos: []
isProject: false
---

# Logging Stack — Grafana Loki + Alloy (All Surfaces)

## Architecture

```mermaid
flowchart TD
    subgraph win [
```



