# One-off requests and trials

This directory owns the durable record of explicitly authorized one-off or
manual requests. The execution method may be temporary; project stewardship
continues. The user decides accepted debt and deferred automation. Do not infer
that saying "one-off" authorizes unrecorded drift or automatic promotion.

## Minimum record — every explicit one-off request

Create `docs/one_off_tasks/<date>--<short-slug>/README.md` when accepting the
request, then update it with results. Use [record-template.md](record-template.md).
Record the request/authorization, reason if stated, action/result with evidence,
remaining state, and disposition. Do not invent a reason or claim debt was
accepted unless the user said so. No persistent change is a valid outcome.
An existing trial may use its current folder; do not duplicate its record.

A simple entry needs no script, diagram, promotion plan or extra permission
round. This applies even when the user explicitly defers automation. Diagnosis
alone does not authorize mutation. Once authorized, proceed within that scope.

## Ownership and dispositions

The README is an audit record, not the source of desired infrastructure state.
Roles/inventory/playbooks remain that source. Track one of: requested, executed,
restored, removed, reconciled (link project change), or deferred (quote the user's
decision and link follow-up when it exists). Record unresolved disposition as
pending; never silently accept debt on the user's behalf.

## Trials with deployed artifacts

Only trials that deploy new artifacts need a deploy/ directory, reversible
install/uninstall instructions, and `_one_off_tasks` discriminators. Existing
managed files changed by an authorized manual repair need baseline/undo evidence,
not renamed files or invented installers. Secrets never belong in these records.

For new trial files use a header identifying their source record and removal
method. Trial code is provisional and must not be treated as steady-state truth.

## Promotion and cleanup

- Promotion follows the existing plan/Ansible process when authorized. Stop
  extending trial code, archive relevant source in the promotion packet, and
  remove live trial artifacts after verification. Keep the original README with
  outcome and links; never implement from archived backup/one-off-source/.
- Discard removes only authorized trial artifacts and host traces, with probes.
  Retain the README request/decision/result record. Preserve referenced evidence
  or summarize it before deleting bulky disposable artifacts.
- Record retention does not require keeping obsolete installers or secrets.

## Agent routing

`skills/one-off/one-off-lifecycle` routes record-only, trial, promotion, cleanup
and verification. `homelab-ansible-first-entry` routes ordinary managed repairs
to global `interactive-troubleshooting-to-managed-state`. Neither route waives
this record requirement for an explicit one-off request.
