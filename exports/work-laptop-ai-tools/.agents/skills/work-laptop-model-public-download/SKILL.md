---
name: work-laptop-model-public-download
description: "Use when adding a human-run command that downloads a model from the controller Mac into the HVH public share for the work-laptop local-model workflow. Writes one line per model into helpers/work-mac-local-models. Do not use to import into Ollama or LM Studio, and do not run the download unless the user asks to execute it."
---

# Skill: Work-laptop model public download

Write the controller-Mac download lines. The human runs them.

## When to use / not use

Use when:

- the user wants a model downloaded to the public folder for the work Mac
- adding another downloader besides Hugging Face CLI

Do not use when:

- the next step is import into Ollama or LM Studio (`work-laptop-model-runtime-import`)
- the user asked to run the download now (write the line first; run only if they say so)

## File

`helpers/work-mac-local-models/` — see `README.md` and `example-commands.sh`.

Edit the packet in `dotfile-vnext/exports/work-laptop-ai-tools/`, then
`work-laptop-packet-ops` sync. Do not design only in the sibling.

## Section 1 rules

- Read `helpers/work-mac-local-models/share-paths.sh` first.
- Section 1 uses `CONTROLLER_PUBLIC_FOLDER` only.
- Comment the other controller public folder under that variable. Swap the
  value; do not add a second path.
- Hugging Face CLI: one `hf download … --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/…"`
  line per model. No blank lines between those lines.
- A new downloader: one blank line, then that tool's commands, one line each.

## Do not

- Download onto the work laptop as the primary path
- Invent a second share root
- Treat the share copy as imported
