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
`continue-mac-local-controller.sh` sources that file. A clean shell without
it is not logged in.

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
| Work laptop | not recorded | empty until filled in | `WORK_LAPTOP_PUBLIC_FOLDER` |

Names are `hvh-01-public` and `hvh-02-public` so they do not collide with a
Finder favorite named `public`.

## Model layout under the share

Weights stay under `models/<ecosystem>/` on the share. A file there is not
imported into a work-Mac runtime. Arrival workflow:
`WORK-MAC-LOCAL-MODEL-ARRIVAL.md`.

| Downloader | Folder under the public folder |
| --- | --- |
| Hugging Face CLI | `models/huggingface` |
| Ollama | `models/ollama` |
