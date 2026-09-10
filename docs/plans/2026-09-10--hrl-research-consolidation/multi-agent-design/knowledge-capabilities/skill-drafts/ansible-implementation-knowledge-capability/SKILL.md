---
name: ansible-implementation-knowledge-capability
description: >-
  Draft composition capability for a Researcher, Implementer, or Evaluator
  working on an Ansible-managed infrastructure decision. It discovers the
  task-relevant Ansible knowledge sources, distinguishes configured from
  callable MCP resources, invokes the established ansible-knowledge-gate, and
  produces or audits an implementation-readiness brief. This draft does not
  replace ansible-knowledge-gate or the mature paired-agent role skills.
status: design-draft
scope: dotfile-vnext
depends_on:
  - ansible-knowledge-gate
  - paired-agent-plan-evaluator
  - multi-agent-implementer
---

# Ansible implementation knowledge capability

## When to invoke

Invoke only when an agent needs Ansible-specific implementation knowledge to
move from a domain decision into an idempotent, safe, and verifiable change.
Examples include adding storage, changing Kubernetes host configuration,
selecting a module, defining lifecycle state, or evaluating whether an
implementer followed the intended Ansible contract.

Do not invoke for broad domain research that has no Ansible design decision, or
as a substitute for the normal Implementer/Evaluator workflow.

## Role-aware behavior

| Caller | Required result |
| --- | --- |
| Onsite Expert / Coordinator | A scoped implementation research question and priority. |
| Researcher | An implementation-readiness brief with evidence and open gaps. |
| Implementer | A trace from the brief to code, live operations, and receipt evidence. |
| Evaluator | A rubric-based finding, spot-check, or targeted research escalation. |

## Source selection

1. Read the current plan, owner role/playbook, inventory, and project guidance.
2. Invoke `ansible-knowledge-gate`; preserve its module discovery and
   Apply/Verify/Undo contract.
3. When available, query the Red Hat Ansible MCP for its Zen, content best
   practices, and execution-environment guidance.
4. Verify source state separately: configured → listed → successfully invoked.
5. Use Context7, `ansible-doc`, and official documentation for the exact
   module or platform decision when local guidance does not settle it.

## Output contract

Write or evaluate an implementation-readiness brief containing the decision,
owner surfaces, candidate/rejected patterns, lifecycle and safety boundary,
preflight and acceptance checks, sources, and remaining questions.

## Boundaries

- The capability does not mutate hosts by itself.
- It does not issue evaluator approval.
- It does not duplicate the existing Ansible knowledge gate.
- It does not assume an MCP configuration is callable proof.

## Promotion rule

Run this draft against the storage work and at least two further independent
Ansible efforts. Promote only the proven reusable instructions into the project
skill catalog; keep dotfile-vnext-specific role and inventory routing local.
