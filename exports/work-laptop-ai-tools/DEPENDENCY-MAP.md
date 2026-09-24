# Dependency map

Where the related projects live, what they are, and how to work in them.
Not a second design doc. Packet `AGENTS.md` still wins for this slice.

Paths: home Mac `~/develop/<repo>`. Work laptop `~/Documents/develop/<repo>`
(deviation `documents-develop-paths`). Do not hardcode `/Users/joshc/develop`.

## Projects

| Project | What it is | How to work | Start here |
| --- | --- | --- | --- |
| This packet | Design authority for the work-Mac Ansible slice | Edit here, then `work-laptop-packet-ops` sync. Do not design in the sibling. | `AGENTS.md` |
| `work-laptop-ai-tools` | Generated sibling. Apply surface on the work Mac | `git pull` on `master`, then `work-laptop-day2-apply`. Fixes go back through the packet. | same `AGENTS.md` after sync |
| `dotfile-vnext` | Parent homelab automation. Owns MCP role logic and export scripts | Ansible `present\|absent` via `bin/codex-env`. Not the laptop day-2 loop. | `AGENTS.md`, `docs/codex_framework/README.md` |
| `homelab-reference-library` | Research library. Facts and process, not live desired state | Open `catalog.yaml` before searching. Stubs are not selected runtimes. | `AGENTS.md`, `catalog.yaml` |
| `global-skills` | Reusable skills for Codex and Cursor | Name the skill in the prompt. Do not copy work-laptop flows into the global catalog. | `skills/catalog.yaml`, `AGENTS.md` |

## Docs that complete the picture

HRL (library checkout; may be absent on a laptop session):

- `implementation-guides/mcp/work-laptop-ai-tools-mcp-slice.md` — this slice’s MCP catalog
- `implementation-guides/mcp/porting-mcp-servers-between-projects.md` — how to port an MCP role
- `models/_shared/mac-candidate-runtimes/SOURCE.md` — WIP Mac runtime candidates
- `models/_shared/mac-candidate-runtimes/ollama-vs-mlx-lm-autocomplete-assessment.md` — tentative autocomplete lean; untested

`dotfile-vnext`:

- `exports/work-laptop-ai-tools/` — this packet
- `roles/mcp_servers/` — shared MCP role logic
- `skills/implementation/work-laptop-export-pack/SKILL.md` — validate / sync / smoke scripts
- `docs/plans/2026-09-02--work-laptop-export-pilot/README.md` — why the slice exists

## Working rules

1. Design in the packet (or parent roles). Sync into the sibling. Apply on the laptop.
2. New MCP stays `absent` until `work-laptop-mcp-commission`.
3. HRL and parent docs explain. They do not replace `host_vars/work-laptop.yaml` or `deviations/register.yaml`.
4. **Preferred local models on the work laptop:** Docker Model Runner —
   `DOCKER-MODEL-RUNNER.md` and `helpers/docker-model-runner/examples/`.
   Ansible automation is **disabled** (`work_laptop_docker_model_runner_automation: disabled`)
   until explicitly commissioned. **Legacy:** `WORK-MAC-LOCAL-MODEL-ARRIVAL.md`
   (controller download to public share → rsync → `~/models` → import). Do not
   extend the share/rsync pipeline for new work. Jan.AI local RAG: role `jan_ide`
   and `JAN-AI-WORK-MAC-RAG.md`.

## Feedback loop

```text
work Mac failure
  → remediation-return (fix + inbox receipt; prefer packet edit)
  → push sibling evidence
  → controller: inbox-evaluate-fix (promote into packet / deviations)
  → packet-ops sync + push sibling
  → work Mac: day2-apply
```

| Direction | Skill | What lands |
| --- | --- | --- |
| Downstream → upstream | `work-laptop-remediation-return` then `work-laptop-inbox-evaluate-fix` | Packet/parent fix + `deviations/` + processed inbox receipt |
| Upstream → downstream | `work-laptop-packet-ops` (+ sibling commit/push) | Manifest-owned files match source |
| Downstream apply | `work-laptop-day2-apply` | Live Mac converges to pulled packet |

Treat sibling dirty trees that change packet behavior the same as `inbox/`
packages: classify, promote or reject, never leave them as the only authority.
Paste-ready prompts: `USEFUL-COMMANDS.md` U1, U3/U4, L4, L5.
