# Plan research intermission

**Status:** active framework habit  
**Applies to:** official plans (`docs/plans/**`, conversational `<proposed_plan>` /
Plan cards) and non-trivial Cursor plan files that gate Ansible build work.

## Purpose

Stop coordinators locking build steps before evidence lands in the library.

```text
pause → research → update library → revise plan → then build
```

## When required

Use a Phase 2 / research intermission when any of these are true:

- install/runtime pattern is novel or vendor-primary (e.g. Ollama Windows boot)
- FQCNs are unknown or contested (“I don’t know the module”)
- library topic check is thin or zero for the technology
- live probes contradict inventory desired state
- autocomplete / routing / placement depends on research still open

## Shape

1. **Checklist** — concrete research todos (vendor primary, then Ansible
   modules, then placement). Prefer Context7 when MCP is available.
2. **Thin/zero receipt** — Exists / Missing / Research Needed per HRL
   `AGENTS.md` (do not claim library coverage from memory).
3. **Persist** — global skill `conversation-research-to-library` (Context7 packs,
   guides, Q&A, investigation notes + indexes).
4. **Module gate** — project skill `ansible-knowledge-gate` intent → Context7 →
   module matrix before any `win_shell`.
5. **Revise plan** — update Phase 3 / build from library evidence; unlock build
   only when intermission exit criteria pass.

## Exit criterion

Intermission is done when:

- Research Needed items in current scope are either written to HRL, explicitly
  deferred with `moved_to_plan`, or still listed as blocking (plan stays
  incomplete)
- Persist receipt exists (paths on disk)
- Build steps that depended on research were revised or confirmed

## Anti-patterns

- Jumping from Phase 1 sketch to inventory/`present` edits from chat memory
- Treating role folklore as vendor truth
- Marking Phase 2 complete while Research Needed rows remain in scope
- Preferring WebFetch drafts while Context7 MCP is healthy

## Related

- Global skill: `conversation-research-to-library`
- HRL: `AGENTS.md` thin/zero research receipt
- Project: `.cursor/skills/ansible-knowledge-gate/SKILL.md`
- Project: `.cursor/skills/hrl-library-index-entry/SKILL.md`
- Partner process: `docs/codex_framework/partner_process.md`
- Rule: `.cursor/rules/framework-partner-process.mdc`
