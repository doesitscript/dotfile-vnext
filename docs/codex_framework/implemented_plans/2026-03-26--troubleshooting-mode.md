# Troubleshooting Mode

Accepted and implemented framework plan for first-class troubleshooting mode.

## Summary

Add a first-class troubleshooting mode to the Codex framework and Ansible rule
layer. This mode activates on repeated failure or explicit request, requires
per-run reporting of collected vs missing evidence surfaces, and makes
operator-facing evidence options easy to enable.

## Key Decisions

- default auto-trigger: repeated failure for the same component or capability
- manual trigger: explicit troubleshooting or debugging request
- evidence hierarchy:
  1. component-native logs, events, status, or vendor diagnostics
  2. explicit remote command output
  3. module results and registered task output
  4. Ansible verbosity or transport output
- `-vvvv` is additive detail, not a substitute for logs, events, or explicit
  remote stdout/stderr
- troubleshooting runs must always report:
  - component(s)
  - evidence surfaces identified
  - collected this run
  - missing this run
  - actual output seen this run

## Repo-Level Outcomes

- add `framework-troubleshooting-mode.mdc`
- update framework docs to describe the mode and implemented-plan history
- update Ansible rule layer with standard troubleshooting variables and
  operator-facing evidence options
- add `docs/diagnostics/multipass--windows--diagnostics.md` as the first
  concrete component diagnostics reference
- use the Multipass Windows role as the first pilot for evidence tags and
  troubleshooting variables

## Operator Options

- `-vv`
- `-vvv`
- `-vvvv`
- `-e debug_remote_output=true`
- `-e ansible_troubleshooting_mode=true`
- `-e debug_collect_component_evidence=true`
- `--tags evidence`
- `--tags debug_resources`
