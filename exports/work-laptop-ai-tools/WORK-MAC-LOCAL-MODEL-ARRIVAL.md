# Work Mac local model arrival

> **Tentatively deprecated (2026-09-09).** Prefer
> [`DOCKER-MODEL-RUNNER.md`](DOCKER-MODEL-RUNNER.md) (Docker Model Runner).
> Public-share → rsync → `~/models` → Ollama/LM Studio import stays for
> emergency/legacy only. Ansible for DMR is **disabled** until commissioned.
> Findings saved under
> `helpers/docker-model-runner/examples/save/`.

Specific workflow for getting a model onto the work laptop to run locally
**via the legacy share pipeline**. Use this only when explicitly continuing
that path. Do not download the weight on the laptop as the primary path for
new work — use DMR pulls instead.


## Stages

```text
controller Mac (this Mac)
  → download into the HVH public share under models/<ecosystem>/
  → work laptop copies listed model folders from models-to-copy.list to ~/models
  → import commands point at ~/models, not at the share
```

A file on the share is not installed. A file under `~/models` is the owned
Mac copy. The import arrow is still required: it creates the runtime's
entry or link. One weight under `~/models` is meant to be shared by every
tool, not copied again per tool.

## Currently

Only a few tools are in use. Those runtimes do not detect a folder drop.
The model list is `helpers/work-mac-local-models/models-to-copy.list`.
The helper scripts only print commands from that list. You run them.
From the work laptop, copy only those listed folders to `~/models` (same
path as the share), then run that tool's import command against the local
file. Do not copy the whole `models/` tree. The copy is one-way and does
not delete files already on the Mac.
Do not treat "the file is in public" or "the file is in ~/models" as "the
runtime has the model."

Exact flags stay with the tool. Human command files live in
`helpers/work-mac-local-models/`. Skills: `work-laptop-model-public-download`,
`work-laptop-model-runtime-import`.

First concrete path (Continue on the work laptop, Hugging Face then Ollama
import, no `ollama pull`):

- Controller: `helpers/work-mac-local-models/continue-mac-local-controller.sh`
- Work laptop: `helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`
- Plan: `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns`
- Pattern copies: `docs/brainstorming_designs/2026-09-09--continue-mac-local-model-patterns/examples/`
- Jan RAG chat weight on that same list: `Qwen/Qwen3-4B-GGUF` /
  `Qwen3-4B-Q4_K_M.gguf` (`JAN-AI-WORK-MAC-RAG.md`). Jan links that local
  file. It does not download a second copy.

Add or remove a model in the manifest. Do not hand-write the same model
into each tool section. Another tool is another echo section over that same
list. The scripts do not run the commands.

## Share layout

Mounts are not the same path. Do not copy path literals into this workflow.

- Staging host: `HOM-LAB-HVH-01` (`\\HOM-LAB-HVH-01\public`). Public root
  has `apps`, `artifacts`, `driver-staging`, `models`, `studio`. Not HVH-02.
- Map: `helpers/share_topology.md` (UNC, hosts, mount methods, model folders)
- Shell: `helpers/work-mac-local-models/share-paths.sh`
  (`CONTROLLER_PUBLIC_FOLDER`, `WORK_LAPTOP_PUBLIC_FOLDER`,
  `WORK_LAPTOP_LOCAL_MODELS`)

Run `helpers/work-mac-local-models/setup_shares.sh` to mount
`\\HOM-LAB-HVH-01\public` at `~/mnt/hvh-01-public`; that is the fixed
`WORK_LAPTOP_PUBLIC_FOLDER` used by the copy commands. If Finder already
mounted the share under `/Volumes`, the helper unmounts that duplicate first
(deviation `smb-stable-mount-hvh01`). Do not copy the controller path. The
local root is recorded: `~/models`. Copy needs the share mount; import uses
`~/models`. A later role may manage the mount and that local tree; this packet
only records them.

| Downloader | Public folder | Work-laptop copy |
| --- | --- | --- |
| Hugging Face CLI (`huggingface_cli_mac`) | `models/huggingface` | `~/models/huggingface` |
| Ollama (lab share path) | `models/ollama` | `~/models/ollama` |

Which runtime then receives the import is a separate choice
(`DEPENDENCY-MAP.md` → HRL Mac candidate runtimes). This file only moves the
weight to the laptop.
