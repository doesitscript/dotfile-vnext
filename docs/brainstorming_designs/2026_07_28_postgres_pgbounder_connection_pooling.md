# Postgres connection pressure → PgBouncer (brainstorm)

**Status:** advisory brainstorm. Not approved implementation scope.  
**Observed:** 2026-07-28 on shared fuzlang Postgres `192.168.50.234:5432`  
**Deferred:** implement **PgBouncer** later (this note is not the build plan).

---

## Known issues

### 1. Shared Postgres hits `max_connections` (“too many clients already”)

Stock `postgres:16` on the fuzlang-net stack has **no** raised `max_connections` (image default, typically ~100). Langfuse web + worker + LiteLLM all open direct pools against the same host. When the limit fills, **new** sessions fail even though Postgres and Langfuse health can still look up.

**Soft mitigations used (temporary):**

- Rollout restart `langfuse-web` / `langfuse-worker` / `litellm`
- `pg_terminate_backend` on idle `langfuse` backends

These clear the jam; they do not stop it recurring.

### 2. LiteLLM holds an oversized share of Postgres backends

During the 2026-07-28 saturation check (~99 backends in use), **LiteLLM alone held ~60** connections vs ~38 for the Langfuse DB. When implementing pooling / limits later, **rein in LiteLLM’s pool size** (app-side `DATABASE_URL` / pool settings), not only Langfuse.

---

## Planned postgres-side work (later)

| Item | Intent |
| --- | --- |
| **PgBouncer** | Sit in front of Postgres; apps point `DATABASE_URL` at the pooler (e.g. `:6432`); few real backends for many clients |
| **LiteLLM pool cap** | Explicitly reduce LiteLLM’s connection pool so it cannot dominate shared `max_connections` |
| Optional stopgaps | Raise Postgres `max_connections`; Prisma/`connection_limit` on Langfuse URLs; idle timeouts |

### Why PgBouncer (reminder)

PgBouncer is a lightweight **connection pooler** in front of PostgreSQL. Apps connect to it; it keeps a small set of real DB connections and multiplexes client sessions onto them.

Pool modes (short):

- **session** — one DB connection per client session (safest, less multiplexing)
- **transaction** — return after each transaction (best under pressure; some session features break)
- **statement** — rare; most restrictive

Today: apps → `192.168.50.234:5432` directly.  
Target later: apps → PgBouncer → Postgres.
