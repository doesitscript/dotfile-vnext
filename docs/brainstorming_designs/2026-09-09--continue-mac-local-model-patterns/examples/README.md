# Script examples

Pattern copies of the human-run scripts. Same divider contract as the runnable
files. Do not treat this folder as the place to run them.

Runnable copies:

- `exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-controller.sh`
- `exports/work-laptop-ai-tools/helpers/work-mac-local-models/continue-mac-local-work-laptop.sh`
- `exports/work-laptop-ai-tools/helpers/work-mac-local-models/example-commands.sh`

Skills that add lines: `work-laptop-model-public-download` (controller Mac /
mac-dev) and `work-laptop-model-runtime-import` (work laptop).

## Dividers

Add commands only inside the matching markers. A new CLI is a new pair, not
more lines inside `huggingface` or `ollama`.

| Marker | What to add |
| --- | --- |
| `SECTION: echo:<tool>` | Printed command. Folder value in `[]`. |
| `SECTION: process:<tool>` | Same models, real command, for later on that machine. |
| `SECTION: next-cli` | Empty. Put the next tool's echo+process pair above this marker. |

Controller process blocks run later on mac-dev. Work-laptop process blocks
run on the work laptop after `WORK_LAPTOP_PUBLIC_FOLDER` is set.
