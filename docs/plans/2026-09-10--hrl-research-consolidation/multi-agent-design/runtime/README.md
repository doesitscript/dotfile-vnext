# Run the preparation stage

For the later implementation stage, use
[`check-implementation-handoff.ts`](check-implementation-handoff.ts) with the
absolute `implementation-campaign` directory. It needs Bun and reads only the
project snapshot; it does not launch agents or touch services. Tests:
`bun test check-implementation-handoff.test.ts artifacts.test.ts` from this
directory. The [beta role prompts](../agent-prompts/implementation-beta-prompts.md)
use the mature implementation loop. The preparation controller below does not
schedule that later loop.

This controller starts exactly two Codex agents through the installed
`multiagents orchestrator` MCP server. It runs route → research → compose →
independent review → release, with up to two correction rounds. It does not
start an Implementer, Evaluator, infrastructure deployment, or a full pipeline.

## Inputs and run

Copy `validation-config.json` to a new config, choose a unique `run_id` and an
empty `preparation_output_root`, and keep the source/project/HRL roots as inputs.
Use an explicit working `codex_binary`; no global model/config changes are made.
`operator_skill_root` selects the reusable ownership/dashboard helper.

```sh
bun run runtime/run-preparation.ts /absolute/config.json
```

Run from this packet or use the script's absolute path. Bun and the installed
multiagents package/SDK must exist. A healthy existing broker is required;
broker installation/reconfiguration is not an implicit side effect. The runner
prints the dashboard URL and a heartbeat every 20 seconds. Default bounds are
300 seconds per work pass and 1500 seconds for the campaign; config can set
`pass_timeout_seconds` and `run_timeout_seconds`.

The run name carries the effort, stage and owner PID. The broker normalizes
that name; the returned session ID is recorded separately from pipeline/task/
run identifiers. `runtime/inputs.json`, `checkpoint.json`, event logs, and the
ownership manifest provide the pickup point. No secret configuration is copied
into this packet or config example.

## Ownership and stop

Before model work, an independent watchdog records a heartbeat against the
actual harness PID. Child processes carry `MULTIAGENTS_RUN_ID` and are recorded
by PID/start time/command; periodically captured descendants are included.
The shared broker and IDE are excluded. The preload suppresses this installed
package's untracked automatic Terminal/web launches; the reusable runtime
operator explicitly starts and registers the dashboard instead.

On normal finish, failure, or a handled signal, the controller calls its own
`end_session`, verifies archival, closes the transport, stops manifest-owned
processes, and records the final inventory. If the controller is abruptly
killed, its independent watchdog stops the recorded identities. This is not a
kernel-level guarantee against an instantly daemonized unregistered child or
machine power loss; exact manifest reconciliation remains the restart path.

For an interrupted run, use the manifest path and run ID printed in its inputs:

```sh
python3 /absolute/operator-skill/scripts/owned_processes.py observe --manifest /absolute/processes.json --run-id actual-run-id
python3 /absolute/operator-skill/scripts/owned_processes.py stop --manifest /absolute/processes.json --run-id actual-run-id
```

Never use a global process-name kill or infer ownership from parent PID 1 alone.
Session-record deletion is separate from process stopping and requires an
evidence export; use the runtime operator's named-session cleanup procedure.
Successful runs retain archived session records and artifacts for inspection;
offer their optional cleanup, preserving source plans, reviewed handoffs and
evidence. The runner does not reset the source plan.

## Resume and verification

```sh
bun run runtime/run-preparation.ts /absolute/config.json --resume
bun test runtime/artifacts.test.ts
```

Resume is explicit, with matching pipeline/task/run/root identity. It reuses
only completed pass receipts whose artifact and upstream digests still match.
Partial or modified outputs do not count as finished work. A changed plan
invalidates its old review. A completed release check verifies without creating
a new team or replacing the original run provenance. Reboot recovery may need
the runtime operator to archive a stale broker record after the watcher stopped
its processes; do not merge another run's artifacts.

`runtime/handoff.json` is the future pipeline integration boundary: exact plan,
review and release paths plus the reviewed SHA-256, pipeline/task/run identity,
and `downstream_activation: authorized_separately`. A future orchestrator
verifies this envelope and uses the mature roles' existing inputs/permissions.
It must not treat preparation review as implementation approval.

Scope and role behavior are defined in
[the shared contract](../agent-prompts/execution-contract.md); implementation
and test receipts are linked from the packet entrypoint.
