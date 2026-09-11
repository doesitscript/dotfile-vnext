# On-site Expert undone or deferred work — test the export

## Purpose

This is deliberately separate from the correction-blocker set. It identifies
work that was not completed, was intentionally left unchanged, or requires a
reversal/cleanup decision. It does **not** claim that infrastructure changes
were rolled back.

## What is known to be undone or deferred

### No live Apply occurred

No storage Apply was authorized or performed. There is therefore no storage
mutation to reverse, and no claimed runtime rollback to validate. The absence
of an Apply is a safety fact, not evidence that the desired storage outcome was
completed.

### S2 was intentionally left unchanged

Existing K3s/kubelet garbage collection ownership and zero eligible reclaimable
bytes supported an accepted no-change result. This is a bounded decision to
avoid speculative cleanup, not an incomplete deletion task.

### S3, S5, and S6 remain deferred

- **S3:** persistent backing lacks selected target, backup/data-safety,
  cutover, integrity, health, and reversal evidence.
- **S5:** monitoring policy and owner remain unselected.
- **S6:** research/module/docs/diagram closeout depends on S3-S5 and live
  verification; it has not been completed.

### Runtime cleanup completed after evidence capture

The managed session was archived and all owned processes eventually stopped.
The plan-owned execution record was retained. Later cleanup of the retained
private runtime directory/session record remains an explicit user decision;
it is not part of this feature work and must not delete plan artifacts or
shared broker/dashboard services.

## On-site Expert questions

1. Which deferred S3/S4/S5 choice should be treated as the default best path
   given the known controller/Hyper-V/K3s context, and why?
2. What additional read-only facts are genuinely necessary before committing to
   that recommendation? Separate them from merely nice-to-have rediscovery.
3. What evidence defines a successful cutover, and what exact condition should
   trigger reversal or a waiting state?
4. Is the no-change S2 decision still the best preference, or is there a
   justified low-risk improvement to recommend? State the motivation either
   way.
5. Should retained runtime evidence be kept through the next Evaluator pass or
   longer? Recommend a retention horizon and explain the tradeoff.

## Required response

Write the recommendation in `response_on-site_expert/` using
[`instruction.MD`](instruction.MD). Keep deferred work separate from confirmed
defects and do not convert a recommendation into Apply authority.
