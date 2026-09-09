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

Exact import flags stay with the tool. They are not catalogued here.

## Share layout

Controller mount today: `~/HomelabSMB/hvh-01-public` (`finder_login`).
Put the weight under `models/<ecosystem>/` for the tool that downloaded it.
Do not invent a second root.

| Downloader | Public folder |
| --- | --- |
| Hugging Face CLI (`huggingface_cli_mac`) | `models/huggingface` |
| Ollama (lab share path) | `models/ollama` |

Which runtime then receives the import is a separate choice
(`DEPENDENCY-MAP.md` → HRL Mac candidate runtimes). This file only moves the
weight to the laptop.
