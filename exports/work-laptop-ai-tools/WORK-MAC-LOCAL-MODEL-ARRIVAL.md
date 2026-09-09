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

## Share layout

Mounts are not the same path. Source: `helpers/work-mac-local-models/share-paths.sh`.

| Machine | Variable | Path |
| --- | --- | --- |
| Controller Mac | `CONTROLLER_PUBLIC_FOLDER` | `~/HomelabSMB/hvh-01-public` (`finder_login`) |
| Controller alternate | comment in `share-paths.sh` | `~/HomelabSMB/hvh-02-public` |
| Work laptop | `WORK_LAPTOP_PUBLIC_FOLDER` | not recorded — do not copy the controller path |

Same share: `\\HOM-LAB-HVH-01\public`. Put weights under `models/<ecosystem>/`.
Do not invent a second root. Do not recreate import commands until the work
laptop mount is filled in.

| Downloader | Public folder |
| --- | --- |
| Hugging Face CLI (`huggingface_cli_mac`) | `models/huggingface` |
| Ollama (lab share path) | `models/ollama` |

Which runtime then receives the import is a separate choice
(`DEPENDENCY-MAP.md` → HRL Mac candidate runtimes). This file only moves the
weight to the laptop.
