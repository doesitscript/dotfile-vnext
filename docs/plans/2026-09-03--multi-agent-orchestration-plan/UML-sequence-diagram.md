---
title: UML Sequence Diagram - Codex Multi-Agent Orchestration
created_at: 2026-09-03
status: active
---

# UML Sequence Diagram - Codex Multi-Agent Orchestration

## Purpose

This document shows the intended end-to-end runtime sequence for the
Codex-first paired-agent workflow in `dotfile-vnext`. It is narrower than the
main plan packet: this file focuses on execution flow, orchestration touch
points, role boundaries, and the concrete `multiagents` and Codex features that
the implementation should use.

The main idea is simple:

- the implementer and evaluator skills remain the role brains
- the plan folder remains the durable evidence and handoff record
- `multiagents` becomes the orchestration layer
- Codex app-server threads and turns become the execution transport

## UML Sequence Diagram

This repo's Markdown surfaces render Mermaid reliably. The diagram below is a
UML-style sequence diagram expressed in Mermaid sequence syntax so it renders in
place instead of falling back to raw source text.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant Plan as Plan Folder
    participant MA as multiagents CLI / Scenario
    participant Broker as multiagents Broker
    participant Codex as Codex app-server
    participant Impl as Implementer Skill
    participant Eval as Evaluator Skill

    User->>Plan: Create or select plan packet
    User->>MA: Start paired-agent scenario(plan_dir)
    MA->>Broker: initialize or resume session
    Broker-->>MA: session handle + state

    alt Implementer thread missing
        MA->>Codex: thread/start(role=implementer)
        Codex-->>MA: implementer thread id
    else Implementer thread exists
        MA->>Codex: reuse implementer thread
    end

    MA->>Codex: turn/start(implementer bootstrap)
    Codex->>Impl: invoke skill with plan_dir
    Impl->>Plan: Read plan + existing artifacts
    Impl->>Broker: set_summary(working)
    opt Decision or blocker worth sharing
        Impl->>Broker: store_knowledge(decisions, blockers)
    end
    Impl->>Plan: Write repo changes + review-ready artifact
    Impl->>Broker: signal_done(done_pending_review)
    Broker-->>MA: implementer complete, evaluator needed

    alt Evaluator thread missing
        MA->>Codex: thread/start(role=evaluator)
        Codex-->>MA: evaluator thread id
    else Evaluator thread exists
        MA->>Codex: reuse evaluator thread
    end

    alt Evaluator idle
        MA->>Codex: turn/start(evaluator review)
    else Evaluator active and steerable
        MA->>Codex: turn/steer(review-ready handoff)
    end

    Codex->>Eval: invoke skill with plan_dir
    Eval->>Plan: Read implementer artifacts
    Eval->>Broker: set_summary(reviewing)

    alt Corrections required
        Eval->>Plan: Write feedback artifact
        Eval->>Broker: submit_feedback(actionable=true)
        Broker-->>MA: route back to implementer

        alt Implementer idle
            MA->>Codex: turn/start(implementer corrections)
        else Implementer active and steerable
            MA->>Codex: turn/steer(implementer corrections)
        end

        Codex->>Impl: resume implementer
        Impl->>Plan: Read evaluator feedback
        Impl->>Broker: set_summary(addressing_feedback)
        Impl->>Plan: Apply corrections + refresh artifacts
        Impl->>Broker: signal_done(done_pending_review)
        Broker-->>MA: evaluator re-review needed

        alt Evaluator idle
            MA->>Codex: turn/start(evaluator re-review)
        else Evaluator active and steerable
            MA->>Codex: turn/steer(evaluator re-review)
        end

        Codex->>Eval: resume evaluator
        Eval->>Plan: Re-read corrected artifacts
    else Approval
        Eval->>Plan: Write approval artifact
        Eval->>Broker: approve
    end

    Eval->>Broker: set_summary(approved)
    Broker-->>MA: workflow complete
    MA->>Broker: release participants
    Broker-->>MA: released
    MA-->>User: Report completion
```

## Explanation

The sequence starts with the user selecting a single plan folder and launching
one paired-agent scenario. That is the only place where the user should need to
think about startup. After that point, `multiagents` owns the coordination
logic. It initializes or resumes a session, ensures there is a Codex execution
surface for each role, and decides whether the next action is a new `turn/start`
or a `turn/steer` into an already-active role thread.

The implementer and evaluator skills do not disappear in this model. They still
own the substantive work. The implementer reads the plan, edits the repo, and
writes the review-ready artifacts. The evaluator reads those artifacts, checks
the actual work, and either writes actionable feedback or issues approval. That
division of responsibility is the main quality control feature and should not be
moved into the orchestrator.

The plan folder still matters, but for a narrower reason than before. It is not
the scheduler. It is the durable audit trail. If someone later needs to inspect
what happened, the plan packet should still show when work was ready for review,
what feedback was issued, what corrections were made, and when approval
occurred. `multiagents` can use those artifacts as inputs, but the important
change is that orchestration responsibility moves to the broker/session layer
instead of being inferred only from file polling.

The critical runtime features being exercised are visible directly in the
diagram: `thread/start`, `turn/start`, `turn/steer`, `set_summary`,
`store_knowledge`, `signal_done`, `submit_feedback`, `approve`, and final
participant release. Those are the touch points the implementation should wire
cleanly into the repo-owned scenario and workflow documentation. If the final
implementation cannot explain which one of those calls advances each handoff, it
is not done.

The prior version used a `plantuml` code fence. That is valid source syntax in
the abstract, but it is not the diagram format this repo's Markdown surfaces
reliably render. This version keeps the same sequence semantics while using the
renderer-compatible syntax the repo already uses broadly.

## Key design assertions

- Two role skills still exist and remain independently useful.
- A manual two-terminal bootstrap may still be supported, but it is not the
  preferred steady-state operator flow.
- The preferred operator flow is one paired session start per plan folder.
- File-based artifacts remain mandatory for durable evidence, not for primary
  scheduling.
- Completion requires evaluator approval plus orchestrator release of the
  session participants.
