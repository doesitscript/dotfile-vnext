# Operator monitoring feedback — 2026-09-11T06:52:59Z

Provide a local, token-free console monitoring option for an active named
implementation campaign. It should perform the Observer's periodic read-only
checks and present a compact, operator-readable summary: dashboard reachability,
exact session/slot state, safe worker context summary, latest terminal/runtime
event, governed artifact gate, and exact owned-process status.

The monitor must not call inbox-draining tools, message agents, start/stop
services, modify campaign artifacts, or decide implementation quality. It is an
optional visibility complement to human/agent interpretation, not a replacement
for the parent, Implementer, or Evaluator. Design and implement it in a later
runtime/UI iteration; this feedback makes no change to the active campaign.
