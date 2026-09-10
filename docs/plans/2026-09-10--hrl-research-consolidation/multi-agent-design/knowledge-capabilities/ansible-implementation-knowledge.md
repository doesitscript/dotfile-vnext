# Ansible implementation knowledge capability

## Trigger

Use when a task will create, modify, validate, or remove Ansible-managed
infrastructure and the next decision involves role design, module choice,
lifecycle state, host targeting, idempotence, or execution safety.

## Consumers and boundaries

| Role | Uses this capability to | Must not do |
| --- | --- | --- |
| Onsite Expert / Coordinator | identify the knowledge gap and assign the research question | select an unverified implementation by intuition |
| Researcher | obtain and organize implementation evidence | apply infrastructure changes or sign off |
| Implementer | consume the readiness brief before changing code or live state | replace evaluator approval with research |
| Evaluator | assess whether evidence and implementation agree | redo every research stream or write implementation changes |

## Authority map

1. Existing role, playbook, inventory, project `AGENTS.md`, and active plan.
2. The project `ansible-knowledge-gate` skill, including its module matrix and
   Apply / Verify / Undo requirements.
3. The Red Hat Ansible MCP, when it is callable:
   - `zen_of_ansible`
   - `ansible_content_best_practices`
   - `list_available_tools`
   - execution-environment schema, sample, rules, and best-practices resources
4. Context7, `ansible-doc`, and official Ansible documentation for the exact
   module, collection, or platform question.

Configuration is not proof of usability. Record separately whether an MCP was
configured, appeared in the client namespace, and successfully answered a
capability call.

## Required output: implementation-readiness brief

The Researcher writes a concise brief with:

1. The decision being enabled and its source-backed rationale.
2. Existing owner surfaces and host/target scope.
3. Candidate modules or patterns, including rejected alternatives.
4. Lifecycle contract: desired state, idempotence mechanism, Apply / Verify /
   Undo path, and destructive boundary.
5. Read-only preflight probes and post-apply acceptance checks.
6. Open questions marked `blocking`, `non-blocking`, or `resolved`.
7. Exact sources used, including the MCP availability result.

The storage-ready template is in
[`examples/storage-ansible-readiness-brief.md`](examples/storage-ansible-readiness-brief.md).

## Non-goals

- It does not use `ansible_navigator`, environment setup, project creation, or
  execution-environment build tools merely because they exist.
- It does not substitute a generic best-practice statement for evidence about
  the target host or repository.
- It does not turn a research outcome into an approval to mutate live systems.

## Maturity criteria

Keep this as a plan-local design until it supports at least two additional
Ansible/infrastructure efforts. Then assess whether the reusable portion should
be added to the project `ansible-knowledge-gate` or promoted to a separate
project skill. A global skill is appropriate only if it can be truthful without
dotfile-vnext-specific inventory, roles, wrappers, and plan artifacts.
