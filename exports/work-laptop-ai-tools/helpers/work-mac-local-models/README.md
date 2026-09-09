# Work-Mac local model commands

Human-run command files. Agents write the lines. You run them. Ansible does
not.

Workflow: `WORK-MAC-LOCAL-MODEL-ARRIVAL.md`.
Share map: `helpers/share_topology.md`. Paths: `share-paths.sh`.

```text
controller Mac → public share → work laptop import
```

## File shape

Scripts use named dividers. Skills add lines only inside the matching pair.
One command per model. No blank lines inside a tool block.

| Marker | Machine | What goes here |
| --- | --- | --- |
| `SECTION: paths` | both | Print folder variables. Values are wrapped in `[]`. |
| `SECTION: echo:<tool>` | that tool's machine | Printed command only. Folder value in `[]`. |
| `SECTION: process:<tool>` | same machine, later | Same models as that echo block. Unbracketed folder variable. |
| `SECTION: echo:confirm` / `process:confirm` | work laptop | One confirm line per tool. |
| `SECTION: next-cli` | both | Empty marker. Insert the next tool's echo+process pair above it. |

1. **Download** — controller Mac (`mac-dev`). `CONTROLLER_PUBLIC_FOLDER` only.
   Hugging Face is `echo:huggingface` plus `process:huggingface`.
2. **Import** — work laptop. `WORK_LAPTOP_PUBLIC_FOLDER` only. Ollama is
   `echo:ollama` plus `process:ollama`. A file on the share is not imported.
3. **Confirm** — work laptop confirm sections.

Another CLI does not extend the huggingface or ollama blocks. Copy an
echo+process pair and place it above `SECTION: next-cli`.

## Example

`example-commands.sh` — format example. Do not run it as this plan.

Pattern copies of these scripts also live in
`docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`.
Edit the copies in this folder; that examples folder is the design mirror.

This plan's commands:

- Controller Mac: `continue-mac-local-controller.sh` — prints `echo:huggingface`.
  `process:huggingface` is the later mac-dev download. No Ollama.
- Work laptop: `continue-mac-local-work-laptop.sh` — prints `echo:ollama`, then
  runs `process:ollama` only after `WORK_LAPTOP_PUBLIC_FOLDER` is set.
