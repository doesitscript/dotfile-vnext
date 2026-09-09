---
name: work-laptop-model-public-download
description: "Use when adding a human-run download command on the controller Mac (mac-dev) into the HVH public share. Writes an echo line and a matching later process line inside the script section markers. Hugging Face is the first CLI; another downloader gets its own echo and process pair. Do not use to import into Ollama or LM Studio, and do not run the download unless the user asks."
---

# Skill: Work-laptop model public download

Write the controller-Mac download lines. The human runs them later on mac-dev.

## When to use / not use

Use when:

- the user wants a model downloaded to the public folder for the work Mac
- adding another downloader besides Hugging Face CLI

Do not use when:

- the next step is import into Ollama or LM Studio (`work-laptop-model-runtime-import`)
- the user asked to run the download now (write both lines first; run the process block only if they say so)

## Files

Runnable scripts (edit these):

- `helpers/work-mac-local-models/continue-mac-local-controller.sh`
- format example: `helpers/work-mac-local-models/example-commands.sh`

Pattern copies (same dividers, not the run target):

- `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`

Edit the packet in `dotfile-vnext/exports/work-laptop-ai-tools/`, then
`work-laptop-packet-ops` sync. Do not design only in the sibling.

## Where to add lines

Read `helpers/share_topology.md` and `helpers/work-mac-local-models/share-paths.sh` first.
Section 1 uses `CONTROLLER_PUBLIC_FOLDER` only. Do not add a second share root.

Each downloader is an `echo:<tool>` block plus a matching `process:<tool>` block.
Insert a new tool's pair above `# ===== SECTION: next-cli =====`.

| Marker | What to add | When it runs |
| --- | --- | --- |
| `SECTION: echo:<tool>` | One printed command per model. Folder value in `[]`. | Always, when the script is run |
| `SECTION: process:<tool>` | The same models, real CLI, unbracketed `"${CONTROLLER_PUBLIC_FOLDER}"` | Later on mac-dev, only if the human asks |
| `SECTION: next-cli` | Do not put commands here. It marks where the next CLI pair goes. | Never |

Hugging Face today:

- echo: `echo "hf download … --local-dir \"[${CONTROLLER_PUBLIC_FOLDER}]/models/huggingface/…\""`
- process: commented `hf download … --local-dir "${CONTROLLER_PUBLIC_FOLDER}/models/huggingface/…"`
  after `require_controller_model_staging` and sourcing `HF_TOKEN`

No blank lines inside one tool's echo block. One blank line between tool pairs.

## Another CLI

Do not extend the huggingface blocks for a different tool. Copy the pair:

1. `SECTION: echo:<tool>` — print the command with `[${CONTROLLER_PUBLIC_FOLDER}]`
2. `SECTION: process:<tool>` — the same command for later on mac-dev, still commented until asked
3. Place that pair above `SECTION: next-cli`

Keep the ecosystem folder under `models/<ecosystem>/` on the HVH-01 share.

## Do not

- Download onto the work laptop as the primary path
- Invent a second share root
- Treat the share copy as imported
- Run the process block unless the user asks to download now
