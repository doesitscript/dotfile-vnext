# Implementer runtime contract

## Purpose

These runtime files are implementer-owned advisory surfaces for the paired-agent
loop. They do not count as evaluator artifacts and they do not prove plan
quality by themselves.

## Files

- `IMPLEMENTER-RUNTIME-STATUS.txt`
- `implementer-monitor.sh`
- `implementer-heartbeat.log`

## Truth boundary

- A static evaluator may treat these files as "last observed" evidence only.
- A heartbeat timestamp does not prove a process is running at review time.
- Only a live terminal/process inspection can justify a present-tense claim such
  as "monitor is running now."
- For packet review, these runtime files are non-governing and must never
  outrank evaluator `feedback_*`, `waiting_*`, or `ready_*` artifacts.

## Review use

- Use the status file to understand the implementer's last observed resolver
  state.
- Use the heartbeat log to see that polling was attempted and when it last wrote.
- Use the plan packet files and evaluator artifacts, not the runtime files, to
  decide whose turn it is.
