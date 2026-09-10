---
name: work-laptop-model-runtime-import
description: "LEGACY share/rsync path. Prefer DOCKER-MODEL-RUNNER.md. Use only when echoing copy/import for models-to-copy.list. Script only prints. Do not extend for new work; DMR Ansible is disabled until commissioned."
---

# Skill: Work-laptop model runtime import (legacy)

> Prefer `DOCKER-MODEL-RUNNER.md` and
> `helpers/docker-model-runner/examples/`. This skill maintains the deprecated
> rsync → `~/models` → Ollama/LM Studio echo path.

Write the work-laptop import lines. The human runs them on that Mac.

## When to use / not use

Use when:

- the user explicitly continues the **legacy** copy/import pipeline
- a model is, or will be, copied to `~/models` and must be imported into a
  runtime on the work laptop via that path

Do not use when:

- new local-model work (use DMR examples / redeploy checklist)
- the model still needs a controller download (`work-laptop-model-public-download`)
- the user only asked which runtime to consider (HRL Mac candidate stubs)
- implementing Ansible for DMR (automation disabled until commissioned)

## Files

Runnable scripts (edit these):

- `helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`
- format example: `helpers/work-mac-local-models/example-commands.sh`

Pattern copies:

- `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`

Edit the packet, then `work-laptop-packet-ops` sync.

## Where to add a model or a tool

Read `helpers/share_topology.md` and `helpers/work-mac-local-models/share-paths.sh` first.
Add or remove a line in `models-to-copy.list`. Do not drop a model because its share folder is missing. The work-laptop helper
echoes copy, Ollama, and LM Studio commands from that same list. It does
not run them.

Import echoes use `WORK_LAPTOP_LOCAL_MODELS` (`~/models`). Copy echoes use
`WORK_LAPTOP_PUBLIC_FOLDER` as the source. If that mount is empty, still
print the commands with the variable name. Do not invent a mount path and
do not copy `CONTROLLER_PUBLIC_FOLDER`. Yellow lines may use `[]` and are
not for pasting. The following plain line is the paste command and must
not contain `[]`.

Another runtime is a new `print_echo_<tool>` over the same manifest, called
above `SECTION: next-cli`, plus one confirm line in `echo:confirm`.

## Do not

- Use `CONTROLLER_PUBLIC_FOLDER` on the work laptop
- Point an import at `WORK_LAPTOP_PUBLIC_FOLDER` instead of `~/models`
- Treat a file on the share or under `~/models` as already imported
- Claim the import worked because a command was printed
