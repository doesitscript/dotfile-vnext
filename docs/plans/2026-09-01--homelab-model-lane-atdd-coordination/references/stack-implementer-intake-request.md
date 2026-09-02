# Stack implementer intake request (template)

Use this prompt when asking a **stack implementer** to produce the first artifact
for ATDD coordination. The **agent** varies by campaign (Codex CLI, Ansible-only
deploy, IDE client role, etc.); the output shape stays the same.

## Role: stack implementer

Deploys and configures runtime surfaces — inventory, Ansible roles, LiteLLM routes,
vLLM/Ollama, client templates — so acceptance criteria can pass. Does **not** write
acceptance YAML or weaken test expectations.

## Prompt to stack implementer

```markdown
Before acceptance testing begins, produce a **client/model map** markdown file for
this campaign.

Save as: `<plan-folder>/coordination/client-model-map.md`
(or path given by the operator; example campaign uses
`docs/plans/2026-09-01--homelab-local-ai-clients-codex/coordination/`)

Required sections:

1. **Scope** — which clients were configured (IDE extension, CLI, etc.); state this
   is configuration truth, not acceptance approval.

2. **Per client** — table: role or profile | LiteLLM `model@host` route | hosted
   model | status (`approved` | `experimental` | `pending_research`).

3. **Repo pointers** — inventory paths, roles, templates, plan folder links.

4. **Boundaries** — shared GPUs, experimental routes, explicitly not configured.

5. **Qualification notes** — what was live-tested vs configured-only.

Do not write acceptance YAML or weaken test criteria. The **acceptance author**
(Cursor or future agent) will diff this map against `model-lane-acceptance/client-map.yml`
and author EXPECTED probes.

Example output shape: see dotfile-vnext plan
`2026-09-01--homelab-model-lane-atdd-coordination/examples/stack-implementer-intake-client-model-map.example.md`
```

## Acceptance author next step

After the map exists, run skill `homelab-model-lane-atdd-coordinator` (when built)
with `client-model-map: <path>`, or follow
[stack-implementer-handoff-template.md](stack-implementer-handoff-template.md) for
mid-plan coordination.
