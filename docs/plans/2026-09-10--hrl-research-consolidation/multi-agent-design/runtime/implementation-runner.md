# One parent runs the implementation pair

Preferred entry: [paired-plan-orchestrator-beta](../orchestration/skills/paired-plan-orchestrator-beta/SKILL.md).
It runs `run-implementation.ts` through the existing `multiagents orchestrator`
MCP server, guarded CodexDriver and owned-process watchdog. No global skill or
client configuration is rewritten by the corrected runner (it suppresses the
installed launcher's exact global writes). Earlier smoke behavior is disclosed
in [the runtime receipt](../parent-orchestration-validation.md). The parent chat
supplies progress observation.

## Run

Fill [implementation-config.example.json](implementation-config.example.json)
with a unique `run_id`, actual paths and a verified Codex executable. `run_dir`
must not exist; use a private runtime container with `config.json` and a new
`run/` child. The role outputs go to `plan_dir`, not runtime cwd. The MCP-generated
client/session files stay in the isolated runtime directory; workers are told
to read and follow the actual project's instructions before substantive work.

```bash
bun /absolute/path/to/runtime/run-implementation.ts /absolute/config.json
```

Keep the parent execution attached and follow JSON events. Immediately after the
session is created, the runner prints the exact read-only terminal monitor
command for that session and fresh run directory. Run it in a second terminal:

```bash
/absolute/path/to/runtime/watch-implementation-output.sh --session-id '<returned-session-id>' --run-dir '/absolute/fresh-run-dir' --endpoint 'http://127.0.0.1:7899' --interval 5 --clear
```

The script uses `curl POST /slots/list` every five seconds and renders a
colorized role table plus the latest durable `events.jsonl` event. `Ctrl-C`
stops only that monitor. The browser dashboard remains useful for connection
health, but its `driver-mode MCP adapter` label is broker adapter metadata; the
installed API does not expose live model prose to that card.

Defaults: at most 8
passes, 15 minutes per pass, 90 minutes total. These are stopping limits, not
success criteria. Source/receipt work survives a stop; restart with a fresh run
directory and ID to continue. Live Apply is still gated by actual authorization.

Before starting, the parent checks broker health through the existing runtime
operator and recovers it if necessary. The runner owns exactly its newly created
session/children/dashboard and reuses shared dashboards. It does not recover or
delete unrelated sessions. Always display http://127.0.0.1:7900 and observed
status; HTTP health alone does not prove the dashboard selected this campaign.

## Handoffs and restart

The runner serializes finite passes and accepts a handoff only after a successful
terminal model turn and exactly one new matching mature role artifact. Artifact
identity binds campaign, invocation, role, upstream hash and the prior artifact.
Old or opposing-role events may not be edited. Runtime noise is ignored.

- Implementer outbox → Evaluator.
- Evaluator feedback → Implementer.
- Evaluator waiting → stop for parent/operator.
- Evaluator ready + peer approval → approved; then owned teardown.

An empty campaign starts with Implementer. Restart follows the unique causal
`responds_to` chain: pending outbox resumes Evaluator, feedback resumes
Implementer, waiting stops for the operator, and ready starts no team, returning
`prior_signoff_present`. This reports retained Evaluator evidence, not fresh
source verification or proof that a previous managed run completed its approval
transport and cleanup; inspect that run's receipts separately. Ambiguous or
malformed histories fail rather than guessing from timestamps. The parent
compares reviewed source/receipt state with current state: if changed or freshness
cannot be established, set `reopen_review: true` to route Evaluator again.
For a resolved operator wait, supply
`operator_resolution_path` naming the actual recorded decision; never use this
option merely to bypass an unchanged blocker.

Workers have session-local workspace-write access to the explicit project,
campaign and runtime directories. No global sandbox/model settings change.
Only the dispatched role's message queue is released; inactive roles remain
held, including the Implementer while final approval is delivered. The installed
broker's explicit `__slot_<id>__` target avoids stale peer-ID routing. These are
installed-runtime compatibility measures, not changes to role judgment.

The preload binds each peer MCP connection through explicit session/slot/role
arguments and driver-mode environment. Only the Evaluator's `approve` tool gets
a thread-local `approval_mode: approve`; the noninteractive approval policy,
other tool permissions and infrastructure authorization remain unchanged. This
uses the [documented per-tool MCP setting](https://learn.chatgpt.com/docs/extend/mcp?surface=cli)
and the installed Codex `thread/start.config` schema, not a parent-forged approval.
Managed policy still wins; a denied tool or missing peer signal is incomplete.

The installed upstream orchestrator may interrupt a silent active turn after
60 seconds even when the parent pass deadline is longer, and its CodexDriver
otherwise defaults every turn to 600 seconds. The implementation preload
suppresses that **upstream** idle interrupt and aligns the private driver turn
timeout to the explicit parent pass timeout only for this parent-managed runner.
A quiet remote/read-only operation remains subject to the runner's finite
per-pass and overall deadlines. Terminal errors still fail the run and preserve
evidence; a counter or empty response cannot pass it.

`.paired-run-lock.json` prevents duplicate controllers. A failed run retains its
lock for inspection. Read its `owner_manifest_path` and use runtime operator
observe/stop on that exact run. Once the previous owner and registered processes
are confirmed absent, start the new config with `--recover-lock`. The runner
rechecks ownership and archives the old lock; it never wipes plan work.

On success or waiting, the session is archived and owned processes stopped.
`result.json`, per-pass receipts, events and final-process observation remain.
Before any cleanup is offered, the parent must materialize the plan-owned
[default end-of-run retention contract](../execution-record-retention-default.md):
transcripts when locally available, runtime evidence, checksum manifest and—if
the campaign is not approved—a continuation checkpoint. The current runner
retains source evidence in `run_dir`; automatic plan-owned transcript/export
materialization remains a follow-up implementation item. After capture is
verified, present the exact retained runtime folder and archived session as
cleanup candidates. Do not tear them down without a separate user choice.
An aborted owner is covered by the independent watchdog; broker archival may
need explicit recovery.

## Verification

[Retained test index and replayable smoke seed](tests/README.md).

```bash
bun test paired-events.test.ts implementation-policy.test.ts implementation-interrupt-guard.test.ts check-implementation-handoff.test.ts artifacts.test.ts
```

A real two-agent transport fixture may use `fixture_mode: true` and explicit
`fixture_skills`. It must have a `PAIRED-RUNTIME-FIXTURE` marker in an isolated
directory with `project_root == plan_dir`, outside dotfile-vnext. This bypasses
storage intake **only for the fixture**, never for real work. Do not confuse a
fixture approval with evidence of storage deployment or full role compliance.
