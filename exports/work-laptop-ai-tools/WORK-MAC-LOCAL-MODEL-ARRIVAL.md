# Work Mac local model arrival

Specific workflow for getting a model onto the work laptop to run locally.
Use this whenever the job is "get a model onto the work Mac." Do not download
the weight on the laptop as the primary path.

## Stages

```text
controller Mac (this Mac)
  → download into the HVH public share
  → share keeps that downloader's ecosystem folder
  → work laptop sees the same share
  → import into the local runtime
```

A file on the share is not installed. The last arrow is required.

## Currently

Only a few tools are in use. Those runtimes do not detect a folder drop.
From the work laptop, run that tool's import command against the share copy.
Do not treat "the file is in public" as "the runtime has the model."

Exact flags stay with the tool. Human command files live in
`helpers/work-mac-local-models/`. Skills: `work-laptop-model-public-download`,
`work-laptop-model-runtime-import`.

First concrete path (Continue on the work laptop, Hugging Face then Ollama
import, no `ollama pull`):

- Controller: `helpers/work-mac-local-models/continue-mac-local-controller.sh`
- Work laptop: `helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`
- Plan: `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns`
- Pattern copies: `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`

Script dividers (`echo:<tool>`, `process:<tool>`, `next-cli`) are the only
places to add another CLI. Hugging Face and Ollama are the first pairs, not
the only allowed tools.

## Share layout

Mounts are not the same path. Do not copy path literals into this workflow.

- Staging host: `HOM-LAB-HVH-01` (`\\HOM-LAB-HVH-01\public`). Public root
  has `apps`, `artifacts`, `driver-staging`, `models`, `studio`. Not HVH-02.
- Map: `helpers/share_topology.md` (UNC, hosts, mount methods, model folders)
- Shell: `helpers/work-mac-local-models/share-paths.sh` (`CONTROLLER_PUBLIC_FOLDER`, `WORK_LAPTOP_PUBLIC_FOLDER`)

`WORK_LAPTOP_PUBLIC_FOLDER` is not recorded. Do not copy the controller path.
Do not invent a second root. Do not recreate import commands until that
variable is filled in. A later role may manage these mounts; this packet
only records them.

| Downloader | Public folder |
| --- | --- |
| Hugging Face CLI (`huggingface_cli_mac`) | `models/huggingface` |
| Ollama (lab share path) | `models/ollama` |

Which runtime then receives the import is a separate choice
(`DEPENDENCY-MAP.md` → HRL Mac candidate runtimes). This file only moves the
weight to the laptop.
