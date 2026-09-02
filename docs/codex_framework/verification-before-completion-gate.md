# Verification-before-completion gate

**Purpose:** Close the gap where agents claim pass / complete / working / done from
**stale or summarized evidence**, especially on handoff turns that ask for a brief
status update.

**Authority:** This gate is **not** optional background. It binds Cursor, Codex,
and any subagent doing verification or closeout in this repo.

## Iron law

```
NO PASS / COMPLETE / WORKING / DONE CLAIM IN THIS TURN
WITHOUT FRESH VERIFICATION COMMANDS RUN IN THIS TURN
```

Summarizing a prior turn's output is **not** verification.

## Mandatory Superpowers skill

Before making any completion or pass claim — or before updating a plan receipt
row to `pass` — the agent **must**:

1. **Load** the Cursor Superpowers skill `verification-before-completion`
   (plugin skill; read `SKILL.md` — do not rely on memory).
2. **Identify** the command(s) that prove each claim.
3. **Run** those commands **in the current turn** (full command, full output).
4. **Attach** exit code and relevant output lines to the claim.

If Superpowers is installed, also load `using-superpowers` when choosing process
skills for execute/closeout work.

**Skill lookup:** Cursor plugin `superpowers` → `skills/verification-before-completion/SKILL.md`.

## What counts as a completion claim

Any of the following triggers the gate:

| Trigger | Examples |
| --- | --- |
| Status words | pass, complete, done, working, verified, execute-complete, implemented |
| Plan lifecycle | `lifecycle: implemented`, `-implemented` rename, checklist `[x]` |
| Ansible / host state | "playbook succeeded", "converged", "deployed on mac-dev" |
| Smoke / lane tests | "smoke passed", "returned pong", "lane is up" |
| Negative completion | "nothing left to do", "all obligations satisfied" |

Pure **in-progress** updates with no pass language may cite prior evidence only if
labeled **stale — not re-verified this turn**.

## Non-exemptions (cannot waive the gate)

The following are **not** valid reasons to skip fresh verification or Superpowers:

| Mistaken exception | Why it fails |
| --- | --- |
| System notification: "briefly inform the user" | Brevity limits prose, not evidence |
| Handoff / conversation summary | Summaries ≠ probes |
| Prior-turn command output | Stale for pass claims |
| "User already knows it worked" | User trust ≠ agent evidence |
| Idempotent re-run "should be fine" | Assumption ≠ output |
| Context budget / token saving | Use narrower probes, not zero probes |
| End-of-turn fatigue | Stop with honest `pending`, not false `pass` |

**Only explicit user deferral** waives live apply or re-verification for a named
obligation (e.g. "skip live apply tonight"). Generic "be brief" does **not**
defer verification.

## Repo pairing

| Work type | Also required |
| --- | --- |
| Plan execute or complete | [plan-verification-receipt.md](plan-verification-receipt.md) obligation inventory |
| Ansible capability | `homelab-ansible-first-entry` for apply path; playbook output in evidence |
| Multi-plan / lanes | Independent validator pass per ATDD coordinator pattern |
| Plan lifecycle close | `complete-plan-lifecycle` skill only after full receipt |

## Minimum evidence shape

```markdown
**Evidence (this turn):**
- Command: `<exact command>`
- Exit: 0
- Proof: `<relevant lines>`
```

For multiple obligations, one evidence block per claim or per obligation ID (`O-01`).

## When verification is impossible

State **exactly** what could not run and why (no TTY, host unreachable, missing
credential). Mark obligation `blocked` or `pending` — never `pass`.

## Related surfaces

| Surface | Role |
| --- | --- |
| `AGENTS.md` Working Contract §33 | Durable enforcement |
| `.cursor/rules/framework-user-interaction-style.mdc` | Always-on: brevity ≠ skip verify |
| `.cursor/rules/framework-partner-process.mdc` | Execute / multi-plan closeout |
| `docs/codex_framework/plan-verification-receipt.md` | Obligation inventory |
| Superpowers `verification-before-completion` | Process skill (must load) |
