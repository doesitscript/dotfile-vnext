# Codex Project Suggested Work

This note captures Codex's suggested next major production-path milestones after
the network-server Hyper-V and Docker convergence milestone.

## Suggested Next Milestones

If Codex were calling shots, the next four milestones would aim at turning this
from configured lab nodes into a repeatable service platform.

1. Make `site.yaml` the real lab entrypoint.

   One command should converge `server-225` and `network-server` through
   intent-driven targeting: access, Hyper-V, Docker VM, Docker engine/client,
   routes, and verification. This is the foundation that prevents more
   snowflake playbook drift.

2. Bring up the first real service plane.

   Use `network-server` as the primary Docker service node and deploy the first
   meaningful stack there. Given the existing vars, start with the
   storage/observability substrate: MinIO, Postgres, Redis, ClickHouse,
   Langfuse-adjacent pieces, or whichever is currently closest to useful.

3. Add recovery as a first-class capability.

   Before adding many more services, make backup, restore, and health
   verification real. A service is not produced until we can prove it starts,
   survives reboot, exposes the expected endpoint, and has a restore path.

4. Add the next workload plane: K3s VM.

   After Docker is stable, build the planned K3s Ubuntu VM on `server-225` using
   the same generalized Hyper-V VM pattern. Kubernetes gives the lab a second
   deployment lane for workloads that should not become endless Docker Compose
   snowflakes.

## Operating Instinct

Do not spend the next milestone polishing names in isolation. Pull naming,
targeting, docs, and role cleanup forward only when they directly support one of
these production-path capabilities.
