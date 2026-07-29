# Architecture diagram routing (dotfile-vnext)

This project’s diagram **tooling** is the global **`create-diagrams`** skill pack
(not brew/pip Graphviz install guides, not AI-library “diagrams tool” plans as
procedure, not a project-local diagram skill).

## Pack members

| Skill | Use |
| --- | --- |
| `create-diagrams` | Parent — Mingrammer `.py` intermediate model |
| `create-diagrams-dot` | On-demand laid-out `.dot` for exporters |
| `create-diagrams-drawio` | `.drawio` from `.py` |
| `create-diagrams-mermaid` | `.mmd` from Mingrammer model (not Markdown fence extract) |

## Default product preference (this project)

1. **Author** with `create-diagrams` (Mingrammer `.py`).
2. **Default render:** **SVG** (prefer alpha / multi-format path over PNG-only).
3. **Mermaid fenced diagrams** remain allowed when Mermaid is the intentional
   preference (plan structure/routing sketches, continuing an existing Mermaid
   corpus, or the user asks for Mermaid fences).
4. **draw.io** when the user wants editable mxfile → `create-diagrams-drawio`.
5. **Mermaid `.mmd` from the model** → `create-diagrams-mermaid`.

Do **not** treat PNG as the project default. Global pack default PNG still
exists for other repos; **here** prefer SVG unless Mermaid fences are chosen.

## Plan diagram gate (Option 2)

Official plans may satisfy `Architecture/Structure` (and conditional
Capability Routing / Naming/Modeling) with either:

- **Pack artifacts** linked from the plan (paths to `.py` + **SVG** and optional
  `.drawio` / `.mmd`), produced via `create-diagrams`, **or**
- **Fenced Mermaid** in the plan body when Mermaid is preferred or already the
  established form for that diagram class.

`Diagram Inventory` must list what was included and the medium (`pack-svg`,
`pack-drawio`, `mermaid-fence`, etc.).

## Draw.io MCP vs pack

- **`roles/mcp_servers/drawio`** / `mcp_probe_drawio` — interactive MCP editing.
- **`create-diagrams-drawio`** — reproducible `.py` → `.drawio` authoring.

Prefer the pack for new durable architecture diagrams. MCP is not a substitute
for the Mingrammer model.

## Retired procedure

Do not follow brew/pip Graphviz install or “YAML intermediate model” guidance
from older diagrams-tool AI-library plans. Those are historical; route to this
doc and the global pack.
