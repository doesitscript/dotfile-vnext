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
- minimum evidence floor for Ansible troubleshooting:
  - actual command/probe/log/event output
  - saved collector artifacts when the repo exposes a collector/playbook path
- `-vvvv` is additive detail, not a substitute for logs, events, or explicit
  remote stdout/stderr
- `-vvv` is the default retry verbosity floor for Ansible troubleshooting runs
- troubleshooting runs must always report:
  - component(s)
  - evidence surface status
  - collector/playbook wiring status
  - evidence surfaces identified
  - collected this run
  - missing this run
  - actual output seen this run
  - assessment from the collected artifacts

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

## After-Action Additions

The troubleshooting framework gained two clarifications during later Hyper-V
debugging work and those changes are now part of the implemented behavior.

### Evidence label clarification

`Evidence:` is for collected outputs, saved artifacts, and source-backed
findings only.

For non-troubleshooting implementation recaps, use a different label such as:
- `Outcomes:`
- `Summary of Changes:`

It is not the right label for:

- "here is what I am about to run"
- narration of an in-progress attempt
- speculative interpretation before concrete output exists

When the message is about the next action, the framework should instead use one
of the active role labels such as:

- `Planner/Steward view:`
- `Researcher view:`
- `Executor view:`

High-quality evidence examples:

- raw stdout/stderr from a remote probe
- Windows Event Log or journald excerpts
- explicit service status or vendor diagnostic output
- saved collector artifacts with full paths

Lower-quality evidence examples:

- "I ran X" without showing the result
- paraphrases with no quoted output
- interpretations based only on what a command "should" mean

The floor in troubleshooting mode is actual output, not command intent.

When multiple output surfaces exist for a failing component, the troubleshooting
step must inspect recent entries from all identified surfaces and base the
assessment on those collected artifacts.

### Interactive debugging clarification

Some troubleshooting evidence is best collected through a live shell, REPL,
console, or SSH session where the operator can see each step and adjust in
place. The framework should not force every investigation through delayed batch
execution when an interactive path would produce better evidence.

Pinned example:

- Hyper-V Ubuntu VHDX conversion debugging on `server-225-win` was materially
  clearer through an interactive Windows OpenSSH session than through delayed
  remote command batches.

### Alternative-resource clarification

When repeated attempts against the current resource stop producing new evidence,
the framework should explicitly step back and ask whether a different upstream
artifact or source format could achieve the same end state more directly.

Examples of this pattern:

- trying a different published image format for the same OS release
- replacing a failing conversion source with a more native upstream artifact
- abandoning a "stock" bootstrap path when an equivalent artifact gets to the
  same result with less transformation

Pinned example:

- the Hyper-V Ubuntu investigation stopped assuming the raw Canonical `.img`
  path was the only bootstrap option, tried Canonical's published Azure VHD
  instead, normalized that source artifact on the host, converted it with
  native `Convert-VHD`, and successfully booted the VM

### Automatic wiring clarification

The automatic path inside troubleshooting mode is now explicitly:

1. trigger on repeated failure or explicit request
2. identify the component and output locations
3. use or create the diagnostics note under `docs/diagnostics/`
4. verify the identified evidence surfaces with explicit probes
5. inspect recent entries from all identified evidence surfaces
6. use the collector/playbook if it exists, or wire a narrow one if missing
7. rerun with troubleshooting controls enabled and `-vvv` by default for
   Ansible retries

Additional clarification:

- after repeated failure, output-surface retrieval is mandatory
- if the repo is not yet collecting those surfaces, wiring them into the
  troubleshooting collector/playbook pattern is part of troubleshooting mode,
  not optional cleanup work

Pinned example:

- WinRM/OpenSSH on `server-225-win` now has diagnostics notes plus a dedicated
  saved-artifact entrypoint at
  `playbooks/troubleshoot/collect_windows_remote_access_artifacts.yaml`
- the Windows remote-access collector now groups evidence by logical scope so
  troubleshooting can scale from normal access checks to deeper drop-path
  analysis without flattening all surfaces into one undifferentiated bundle

### Scoped collector clarification

When a component has multiple logical evidence layers, the collector pattern may
group artifacts by evidence scope rather than treating every output surface as a
flat list.

Preferred shape:

1. keep all relevant groups enabled by default for the current component
2. let the collector document those groups explicitly
3. allow narrower runs when the operator is targeting a specific layer

Pinned example:

- Windows remote-access troubleshooting now uses:
  - `control_surfaces`
  - `network_path`
  - `firewall_drop_path`

## Unaddressed

These remain open framework debts even though the troubleshooting mode itself is
implemented.

- interactive-debugging skill gap
  - the framework now recognizes interactive debugging as a valid
    troubleshooting move, but there is still no dedicated reusable skill or
    helper pattern that standardizes how to do it cleanly
  - likely future shape:
    - identify when troubleshooting should switch from batch execution to an
      interactive session
    - define how to narrate role transitions around an interactive run
    - define how to capture outputs from the session into durable evidence
      artifacts afterward
- stronger evidence hygiene
  - future responses should keep `Evidence:` strictly for proof and reserve
    action narration for role-labeled sections
- alternative-resource exploration trigger
  - the framework now recognizes that "try a different but equivalent upstream
    artifact" is often the right move after a conversion or bootstrap path keeps
    failing
  - but there is not yet a standardized trigger or checklist that says when the
    agent must stop pushing the current artifact and systematically evaluate
    equivalent alternatives
