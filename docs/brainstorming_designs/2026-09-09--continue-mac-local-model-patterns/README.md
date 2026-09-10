# Continue Mac-local model stack

Status: **brainstorm → direction update 2026-09-09**.

**Preferred runtime:** Docker Model Runner (DMR). Packet doc:
`exports/work-laptop-ai-tools/DOCKER-MODEL-RUNNER.md`. Examples:
`exports/work-laptop-ai-tools/helpers/docker-model-runner/examples/`.
Ansible automation for DMR is **disabled** until commissioned.

**Legacy (tentatively deprecated):** public-share → rsync → `~/models` →
Ollama/LM Studio. Helpers remain under
`exports/work-laptop-ai-tools/helpers/work-mac-local-models/`. Findings saved
under `helpers/docker-model-runner/examples/save/`.

Capture of the supplied local Continue/Ollama proposal and subsequent edits
remains below for history. Model identifiers stay `pending_research` /
`provisional_example` until live DMR `/models` ids are selected.

- [Brainstorm plan](continue-mac-local-model-plan.md): role choices, experiment
  order, configuration sketch (update toward DMR).
- [Example commands](example-commands.md): legacy reference notes.
- [Script examples](examples/README.md): divider copies of the **legacy**
  human-run scripts. Runnable legacy files stay in the work-laptop packet
  helpers. DMR examples live in the packet `helpers/docker-model-runner/examples/`.

First iteration target remains the work laptop only. New weight arrival should
use DMR pull, not the share/rsync pipeline. Work-laptop Continue deploys
**DMR 1.5B autocomplete** via `continue_ide_local_models` (not Jan/Ollama).
Jan/Ollama recipes: `docs/lessons-learned/continue/jan-and-ollama-local-autocomplete.md`.

Documentation change contract: update this packet and links; verify content;
undo by reverting those additions. Change class: reversible documentation only.
