---
name: work-laptop-model-public-download
description: "Use when adding a model to the work-Mac helper manifest so the controller helper echoes a Hugging Face download command. The script only prints. Do not hand-write echo lines, and do not run the download unless the user asks."
---

# Skill: Work-laptop model public download

Write the controller-Mac download lines. The human runs them later on mac-dev.

## When to use / not use

Use when:

- the user wants a model downloaded to the public folder for the work Mac
- adding another downloader besides Hugging Face CLI

Do not use when:

- the next step is import into Ollama or LM Studio (`work-laptop-model-runtime-import`)
- the user asked to run the download now (add the manifest line first; run the printed command only if they say so)

## Files

Runnable scripts (edit these):

- `helpers/work-mac-local-models/continue-mac-local-controller.sh`
- format example: `helpers/work-mac-local-models/example-commands.sh`

Pattern copies (same dividers, not the run target):

- `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`

Edit the packet in `dotfile-vnext/exports/work-laptop-ai-tools/`, then
`work-laptop-packet-ops` sync. Do not design only in the sibling.

## Where to add a model

Read `helpers/share_topology.md` and `helpers/work-mac-local-models/share-paths.sh` first.
Add or remove a line in `helpers/work-mac-local-models/models-to-copy.list`.
That file is the source of truth. `continue-mac-local-controller.sh` only
echoes `hf download` lines from it. It does not download.

Fields: `share_rel|hf_repo|gguf_file|ollama_name`

Print two lines per command. The red line is a `#` comment that explains the next command, parameter by parameter. The Hugging Face command is green. Paste both. The `#` line does not run. Do not drop a model because its share folder is missing. Do not add a second share root.
Another downloader is a new `print_echo_<tool>` over the same manifest,
called above `SECTION: next-cli`. Do not copy model lines by hand.

## Do not

- Download onto the work laptop as the primary path
- Invent a second share root
- Treat the share copy as imported
- Run the echoed download unless the user asks
