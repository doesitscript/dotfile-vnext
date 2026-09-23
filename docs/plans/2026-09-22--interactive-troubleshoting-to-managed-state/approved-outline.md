Yes. I recommend **one reusable global skill, with thin project rules that make it the default for troubleshooting managed systems**. The important work is reconciling the existing rules, because some currently push agents toward more ceremony than your workflow needs.

Here’s the implementation outline I recommend for `dotfile-vnext`:

| Location | Change |
|---|---|
| Global skill library | Create `interactive-troubleshooting-to-managed-state`, owning the reusable workflow and a small evidence template. |
| Project `AGENTS.md` | Add a short mandatory troubleshooting contract and link to the skill. |
| Existing troubleshooting rule | Explicitly permit bounded, reversible experiments; make saved command output sufficient for ordinary diagnosis. |
| `homelab-ansible-first-entry` | Add a troubleshooting route that preserves interactive discovery while requiring the durable fix through the owning Ansible role. |
| Framework partner-process documentation | Replace overlapping instructions with a concise explanation and links to the authoritative workflow. |

**The skill should enforce this sequence:**

1. Identify the failing application, host, user, shell, and invocation.
2. Read the project’s intended state and identify its configuration owner.
3. Define the behavioral acceptance check.
4. Reproduce the failure and troubleshoot through small, evidence-driven experiments.
5. Track any temporary mutations and how to reverse them.
6. Encode the proven fix in the project.
7. Undo only the experiment’s changes and verify the relevant baseline is restored.
8. Apply through automation and repeat the original behavioral check.
9. Apply again and check for unexpected changes.
10. Report what was reproduced, repaired, behaviorally verified, and shown to be idempotent.

Two existing provisions deserve explicit revision:

- **Interactive debugging is currently too narrowly permitted.** The exception should cover diagnosing a managed resource before knowing which Ansible task needs changing.
- **A collector is currently mandatory before proceeding with fixes.** Ordinary troubleshooting should accept a compact saved command receipt. Build reusable collectors when recurrence, complexity, or evidence volume justifies them.

The contract should also prevent unnecessary disruption: restore only changes made during the investigation. If restoring a failure would be unsafe, use an isolated reproduction and state that limitation.

For validation, I would use three small scenarios:

- An installed CLI missing from an application’s PATH.
- A temporary manual fix that must be undone before automation repairs it.
- A case where Ansible reports zero changes but the original application still fails.

Those scenarios check whether the instructions produce your intended behavior—not merely whether the Markdown and metadata validate. Then validate the catalogs and runtime discovery for Cursor and Codex.

The [existing troubleshooting rule](/Users/joshc/develop/dotfile-vnext/.cursor/rules/framework-troubleshooting-mode.mdc:271) is the main reconciliation point. I would implement this as a focused workflow change across the two repositories, without introducing another mandatory planning or research layer.

No files changed in this turn.

Next time:
- Skills used: `project-vs-global-skill-placement-advisor`
- Prompt: `Use project-vs-global-skill-placement-advisor to make this troubleshooting workflow permanent across global-skills and dotfile-vnext.`
