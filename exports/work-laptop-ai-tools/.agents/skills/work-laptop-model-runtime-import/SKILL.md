---
name: work-laptop-model-runtime-import
description: "Use when adding a human-run import command from the work-Mac ~/models copy into a work-Mac runtime. Writes an echo line and a matching process line inside the script section markers. Copy from the public share lands first. First runtime is Ollama; LM Studio and any later CLI get their own echo and process pair. Do not use for the controller download step, and do not treat a share copy or a ~/models file as already imported."
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

## Where to add lines

Read `helpers/share_topology.md` and `helpers/work-mac-local-models/share-paths.sh` first.
These lines run on the work laptop. Import lines use `WORK_LAPTOP_LOCAL_MODELS`
(`~/models`) only. The copy step uses `WORK_LAPTOP_PUBLIC_FOLDER` as the
source. If that mount is empty, still add the echo lines (they print `[]`),
but do not invent a mount path and do not copy `CONTROLLER_PUBLIC_FOLDER`.
Ask for the work-laptop mount and write it into `share-paths.sh` before
relying on the process block.

Insert a new runtime's pair above `# ===== SECTION: next-cli =====`.

| Marker | What to add | When it runs |
| --- | --- | --- |
| `SECTION: echo:<tool>` | One printed command per model. Folder value in `[]`. | Always, before the empty-folder exit |
| `SECTION: echo:copy` / `process:copy` | Copy share `models/` onto `~/models`. Do not add import lines here. | Echo always; process after the share mount is set |
| `SECTION: process:<tool>` | The same models, real CLI, unbracketed `"${WORK_LAPTOP_LOCAL_MODELS}"` | After the copy, on the work laptop |
| `SECTION: echo:confirm` / `process:confirm` | One confirm line per tool (`ollama list`, `lms ls`) | Echo always; process after the folder is set |
| `SECTION: next-cli` | Do not put commands here. Next runtime's echo+process pair goes above it. | Never |

Ollama today:

- echo: `echo "printf 'FROM [${WORK_LAPTOP_LOCAL_MODELS}]/huggingface/…/file.gguf' | ollama create <name> -f -"`
- process: `printf 'FROM %s\n' "${WORK_LAPTOP_LOCAL_MODELS}/huggingface/…/file.gguf" | ollama create <name> -f -`

Ollama does not detect a folder drop. Point `FROM` at a GGUF file that exists
in the download dir. Do not invent a filename; use `REPLACE.gguf` until the
human names the file that landed.

LM Studio is the next runtime, not a second share root. Add `echo:lmstudio`
and `process:lmstudio` above `next-cli`. Import with `lms import <file> -y`.
Confirm with `lms ls` in the confirm sections.

## Another CLI

Do not put a new tool's lines inside the ollama blocks. Copy the pair above
`SECTION: next-cli`, then add that tool's confirm line to both confirm sections.

## Do not

- Use `CONTROLLER_PUBLIC_FOLDER` on the work laptop
- Point an import at `WORK_LAPTOP_PUBLIC_FOLDER` instead of `~/models`
- Treat a file on the share or under `~/models` as already imported
- Claim the import worked without the human running the process block
