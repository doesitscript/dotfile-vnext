# Knowledge capabilities

## Purpose

A knowledge capability is a small, task-specific packet that tells an agent
which authoritative resources make it competent for a bounded class of work.
It is invoked by a role; it is not a replacement role, an automatic model
persona, or a claim that a configured MCP is usable.

The design goal is diagnostic and scalable: select the capability that matches
the uncertainty, verify that its sources are actually available, and produce a
short reusable handoff for the next role.

## Core contract

Every capability declares:

| Field | Meaning |
| --- | --- |
| Trigger | What task condition selects it. |
| Consumers | Which roles may invoke it. |
| Authority map | Ordered local, MCP, and upstream sources. |
| Live capability check | How the caller distinguishes configured, listed, and callable resources. |
| Output | The evidence and decisions passed to the next role. |
| Boundary | What the capability must not decide or mutate. |

## Role relationship

```text
Onsite Expert: identifies an uncertainty and assigns a capability
        ↓
Researcher: uses it to gather and organize authoritative evidence
        ↓
Implementer: consumes the resulting readiness brief while changing source/live state
        ↓
Evaluator: checks that the brief was used, deviations are explicit, and evidence meets acceptance criteria
```

The Evaluator may spot-check a source or request targeted research. It does not
re-run every research stream, and it never becomes the Implementer.

## Initial capability: Ansible implementation knowledge

[`ansible-implementation-knowledge.md`](ansible-implementation-knowledge.md)
is the first capability because the current storage work needs Ansible design
knowledge in addition to domain research. It composes existing assets:

- project `ansible-knowledge-gate`;
- the installed Red Hat Ansible MCP;
- repository role/playbook/inventory ownership;
- Context7, `ansible-doc`, and official documentation when needed.

This packet does not create a duplicate Ansible knowledge skill. It defines how
the existing skill and MCP become a consumable multi-agent handoff.

The proposed invocation surface is deliberately a **draft** at
[`skill-drafts/ansible-implementation-knowledge-capability/SKILL.md`](skill-drafts/ansible-implementation-knowledge-capability/SKILL.md).
It composes the established `ansible-knowledge-gate`; it must not become a
second conflicting Ansible authority.

## Lifecycle

1. The Onsite Expert or Coordinator records the unanswered implementation
   questions.
2. A Researcher invokes the matching capability and writes a readiness brief.
3. The Implementer either follows it or records a reasoned deviation.
4. The Evaluator checks the brief against the delivered change and evidence.
5. Repeated unresolved feedback triggers targeted research rather than another
   blind correction pass.

Only promote a capability into a standalone reusable skill after it succeeds on
multiple tasks. Until then, keep the task design and examples here.

## Related folders

- [`../researchers/enhancements/`](../researchers/enhancements/) — research-side use.
- [`../implementer/enhancements/`](../implementer/enhancements/) — consumption contract.
- [`../evaluator/enhancements/`](../evaluator/enhancements/) — review rubric.
- [`examples/storage-ansible-readiness-brief.md`](examples/storage-ansible-readiness-brief.md) — worked storage example.
