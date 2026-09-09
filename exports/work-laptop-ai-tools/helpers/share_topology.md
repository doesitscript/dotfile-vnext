# Share topology

Where the HVH public folders are, and how each machine sees them.

This file is the human map. Shell variables live in
`helpers/work-mac-local-models/share-paths.sh`. Scripts and other docs point
here or source that file. Do not invent a second root.

Mounts are not managed by this packet yet. A later Ansible role may own
present/absent for a machine. On the controller Mac that role already exists
in the parent repo (`roles/macos_smb_public_mounts`, `finder_login` on
`mac-dev`). This packet only records the paths.

## Shares

Both hosts expose the same share name, `public`, on `F:\shares\public`.

| Host | UNC | IP form | Windows path |
| --- | --- | --- | --- |
| `HOM-LAB-HVH-01` | `\\HOM-LAB-HVH-01\public` | `\\192.168.50.234\public` | `F:\shares\public` |
| `HOM-LAB-HVH-02` | `\\HOM-LAB-HVH-02\public` | `\\192.168.50.158\public` | `F:\shares\public` |

Controller Hugging Face auth is not a stored `hf auth login`. The token
lives in `~/.config/homelab/huggingface_cli_mac.env` (`HF_TOKEN` from vault).
`continue-mac-local-controller.sh` and `continue-mac-local-work-laptop.sh`
source `share-paths.sh`. A clean shell without the Hugging Face env file is
not logged in.

Model staging is **HVH-01 only**. Observed public-root layout on
`~/HomelabSMB/hvh-01-public` (2026-09-09): `apps`, `artifacts`,
`driver-staging`, `models`, `studio`. `models/` contains `huggingface`,
`ollama`, and `stable-diffusion`.

HVH-02 public does not have `models/`. Do not stage weights there.

## How a machine sees the share

The UNC is the share. The local folder depends on the machine and the mount
method. Do not copy the controller Mac path onto the work laptop.

| Machine | Method | Local folder | Shell |
| --- | --- | --- | --- |
| Controller Mac (`mac-dev`) | `finder_login` (current) | `~/HomelabSMB/hvh-01-public` | `CONTROLLER_PUBLIC_FOLDER` |
| Controller Mac | `finder_login` (other share) | `~/HomelabSMB/hvh-02-public` | comment in `share-paths.sh` |
| Controller Mac | `automount` (not current) | `~/mnt/hvh-01-public`, `~/mnt/hvh-02-public` | not the model-command default |
| Work laptop | SMB mount (`setup_shares.sh`) | `~/mnt/hvh-01-public` | `WORK_LAPTOP_PUBLIC_FOLDER` |
| Work laptop | local copy (owned) | `~/models` | `WORK_LAPTOP_LOCAL_MODELS` |

Names are `hvh-01-public` and `hvh-02-public` so they do not collide with a
Finder favorite named `public`.

## Model layout under the share

Weights stay under `models/<ecosystem>/` on the share. A file there is not
imported into a work-Mac runtime. Arrival workflow:
`WORK-MAC-LOCAL-MODEL-ARRIVAL.md`.

| Downloader | Folder under the public folder | Same folder on the work laptop |
| --- | --- | --- |
| Hugging Face CLI | `models/huggingface` | `~/models/huggingface` |
| Ollama | `models/ollama` | `~/models/ollama` |

Observed HVH-01 `models/` also has `stable-diffusion`. Do not copy that
child unless it is listed in `models-to-copy.list`.

## Work-laptop local copy

The work laptop owns one weight tree: `~/models`
(`WORK_LAPTOP_LOCAL_MODELS`). The model list is
`helpers/work-mac-local-models/models-to-copy.list`. Helpers only print
commands. You run them. Copy is one-way `rsync -a` of each listed folder,
same path under `~/models` as under the share `models/` folder. No
`--delete`. It does not copy the rest of `models/` and does not delete
files already on the Mac.

Import commands then point at files under `~/models`. The intended contract
is one Mac copy, with each tool's import creating a registry entry or link
to that file rather than a second weight. Jan's Llama.cpp import is
documented as a link. Other CLIs are not yet proven to link; still point
them at `~/models`, and do not treat a share file as imported.

A later role may manage the share mount and this local tree. This packet
only records them.
