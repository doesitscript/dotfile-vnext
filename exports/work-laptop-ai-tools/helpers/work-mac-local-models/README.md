# Work-Mac local model commands

Echo-only helpers. They print the commands you run. They do not download,
copy, or import. Ansible does not. They are not Continue-extension config.

Workflow: `WORK-MAC-LOCAL-MODEL-ARRIVAL.md`.
Share map: `helpers/share_topology.md`. Paths: `share-paths.sh`.
Model list: `models-to-copy.list`.

Add or remove a model in that manifest. Every echo section is generated
from those same lines. Do not copy model lines into a script by hand.
Do not wrap folder values in `[]`. That form created a real directory
named `[/Users/joshc/HomelabSMB/hvh-01-public]` under this folder.

```text
controller Mac → public share models/<listed folder>
  → work laptop copies those listed folders only to ~/models
  → you run the import command for each tool you care about
```

## What gets printed

| Script | Machine | Echo sections |
| --- | --- | --- |
| `continue-mac-local-controller.sh` | controller Mac | `echo:huggingface` |
| `continue-mac-local-work-laptop.sh` | work laptop | `echo:copy`, `echo:ollama`, `echo:lmstudio`, `echo:confirm` |

Copy is one `rsync -a` per listed folder, same path as the share. No
`--delete`. It does not copy the rest of `models/` and does not clean the
Mac. Fill `WORK_LAPTOP_PUBLIC_FOLDER` before you run a printed copy line.

Another tool is another `print_echo_<tool>` over the same manifest, called
from the matching script above `SECTION: next-cli`.

`example-commands.sh` shows the line shape only. Do not run it as the list.
