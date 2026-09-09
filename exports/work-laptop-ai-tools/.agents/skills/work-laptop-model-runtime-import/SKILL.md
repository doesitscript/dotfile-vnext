---
name: work-laptop-model-runtime-import
description: "Use when the work-laptop helper should echo copy and import commands for models in models-to-copy.manifest. The script only prints. Add a tool section over that same list. Do not use for the controller download step, and do not treat a printed command as already run."
---

# Skill: Work-laptop model runtime import

Write the work-laptop import lines. The human runs them on that Mac.

## When to use / not use

Use when:

- a model is, or will be, copied to `~/models` and must be imported into a
  runtime on the work laptop
- the selected runtime is Ollama, LM Studio, or another local CLI

Do not use when:

- the model still needs a controller download (`work-laptop-model-public-download`)
- the user only asked which runtime to consider (HRL Mac candidate stubs)

## Files

Runnable scripts (edit these):

- `helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`
- format example: `helpers/work-mac-local-models/example-commands.sh`

Pattern copies:

- `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`

Edit the packet, then `work-laptop-packet-ops` sync.

## Where to add a model or a tool

Read `helpers/share_topology.md` and `helpers/work-mac-local-models/share-paths.sh` first.
Add or remove a line in `models-to-copy.manifest`. The work-laptop helper
echoes copy, Ollama, and LM Studio commands from that same list. It does
not run them.

Import echoes use `WORK_LAPTOP_LOCAL_MODELS` (`~/models`). Copy echoes use
`WORK_LAPTOP_PUBLIC_FOLDER` as the source. If that mount is empty, still
print the commands with the variable name. Do not invent a mount path and
do not copy `CONTROLLER_PUBLIC_FOLDER`. Do not wrap paths in `[]`.

Another runtime is a new `print_echo_<tool>` over the same manifest, called
above `SECTION: next-cli`, plus one confirm line in `echo:confirm`.

## Do not

- Use `CONTROLLER_PUBLIC_FOLDER` on the work laptop
- Point an import at `WORK_LAPTOP_PUBLIC_FOLDER` instead of `~/models`
- Treat a file on the share or under `~/models` as already imported
- Claim the import worked because a command was printed
