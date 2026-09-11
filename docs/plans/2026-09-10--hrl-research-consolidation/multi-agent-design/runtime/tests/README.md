# Retained tests and replay scenario

Keep these beside the plan-owned runtime they test. This is the existing test
coverage and a preserved smoke seed, not a new testing framework.

## Fast tests (no agents or services started)

From the parent `runtime/` directory:

```bash
bun test paired-events.test.ts implementation-policy.test.ts implementation-interrupt-guard.test.ts check-implementation-handoff.test.ts artifacts.test.ts
```

- [paired-events.test.ts](../paired-events.test.ts): finite handoffs, identity,
  artifact ownership and causal restart routing.
- [implementation-policy.test.ts](../implementation-policy.test.ts): scoped
  Evaluator approval permission; other roles/settings unchanged.
- [implementation-interrupt-guard.test.ts](../implementation-interrupt-guard.test.ts):
  prevents the installed upstream's false 60-second turn interrupt while the
  parent runner's own finite deadlines remain in force.
- [check-implementation-handoff.test.ts](../check-implementation-handoff.test.ts):
  reviewed intake and snapshot rejection cases.
- [artifacts.test.ts](../artifacts.test.ts): preparation review/release gates.

## Small real-agent scenario

[paired-smoke/seed/](paired-smoke/seed/) preserves the original two fixture
prompts. Start with no `work.txt` or handoff artifacts:

`Implementer writes candidate → Evaluator requests verified → Implementer fixes
it → Evaluator verifies and approves → parent archives/cleans its owned run`.

1. Copy only `paired-smoke/seed/` into a **fresh isolated directory outside
   dotfile-vnext/global-skills**, e.g. a unique directory under `develop/oneoffs`.
   The marker and instruction files are seed inputs; no historical verdicts
   should be copied into a fresh scenario.
2. Copy [config.example.json](paired-smoke/config.example.json), replace all
   `REPLACE_*` values with absolute paths/a fresh run ID. Both project and plan
   must be the copied seed directory; `run_dir` is a not-yet-existing child.
   Point fixture_skills at its `implementer.md` and `evaluator.md`.
3. Follow [the existing runner instructions](../implementation-runner.md),
   including runtime-operator preflight, ownership and attached monitoring:

   ```bash
   bun /absolute/path/to/runtime/run-implementation.ts /absolute/path/to/config.json
   ```

This step starts two agents and consumes model usage; it is opt-in, not part of
the fast tests. Dashboard: http://127.0.0.1:7900 (report observed status at replay).

Expected proof: four accepted task passes, `work.txt` exactly `verified` plus
newline, `result.json` status `approved`, Implementer peer slot approved,
archived session, and no live owned child identities in final observation.
Timeout or a ready artifact without peer approval is not a passing live run.

For a restart check, use a fresh runtime directory/ID against the same processed
fixture: expect `prior_signoff_present` and zero model turns. Setting
`reopen_review: true` instead explicitly requests a fresh Evaluator-first pass.
Use a fresh seed copy to replay from the beginning; never reset a real plan or
delete another run's lock. Offer scoped cleanup afterward, retaining evidence
and preserving shared services.

## What was actually run

[Parent orchestration validation](../../parent-orchestration-validation.md)
records the original runs and their limits. [last-approved-result.json](paired-smoke/last-approved-result.json)
is the byte-preserved successful run-5 result. Full raw evidence is retained at
`/Users/joshc/develop/oneoffs/paired-parent-smoke-kYIPPF`.
Run-3 demonstrated the four-pass correction; run-5 demonstrated approval after
the final binding fix using Evaluator-first resume. Do not recast these as a
single fresh four-pass run of the final code or a storage deployment.

For later redesigns: retain this small replay, update the directly affected
tests, and append actual outcomes to the receipt. No entire new suite is needed.
