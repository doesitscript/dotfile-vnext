### On your framing — you’re right

Your skill system is **not** a competing invention. It is an **Agent Skills** implementation ([agentskills.io](https://agentskills.io)) plus library governance on top.

Official format (required): `SKILL.md` with `name` + `description`, optional `scripts/` / `references/` / `assets/`, progressive disclosure.

What *you* add (extensions, not a fork of the idea): `skills/catalog.yaml`, validators, `skill_scope`, handoffs, runtime bridge, HRL dual frontmatter, etc. HRL already says this explicitly in `skills/CONVENTION.md`: format authority = Agent Skills; placement authority = `AGENTS.md`.

My earlier “don’t invent a parallel system” meant: don’t invent a *second* skill *format* for Python projects — reuse Agent Skills packs (e.g. `vault-env-sync`). Sorry if that sounded like global-skills itself was non-standard.

---

### What I consulted

| Source | Finding |
| --- | --- |
| **HRL `catalog.yaml` → `agentskills`** | Already registered: vendor mirror, Context7 packs, implementation guide, update script |
| **`vendor/agentskills/`** | Full `llms.txt` page set mirrored (spec, quickstart, best practices, scripts, evals, client impl) |
| **`generated/context7/agentskills/`** | Three topic packs (overview/spec, skill-creation, client-implementation) |
| **Live agentskills.io** | Same 9 docs as local `llms.txt`; spec matches mirror (retrieved ~2026-07-22) |
| **Context7 MCP** | **Not available in this session** (no Context7 tools). Used live `.md` + your existing Context7 shards |

So for Agent Skills **docs/API material**, HRL is already in good shape. The main miss is elsewhere.

---

### Gaps / recommended updates (Ask mode — I can’t apply them)

Switch to **Agent mode** if you want these written in.

1. **`global-skills` does not cite Agent Skills**  
   `README.md` / `CONVENTION.md` never mention `agentskills.io`. HRL does. **Recommend:** point global-skills at HRL `vendor/agentskills` + `implementation-guides/agentskills/using-agent-skills-format.md` as format authority, same dual-frontmatter story.

2. **Spec’s nested `metadata:` map**  
   Official optional fields include `metadata: { author, version, … }`. Your libraries put many extras as **top-level** keys (`title`, `document_type`, `applies_to`, …). HRL CONVENTION already notes this preference. **Recommend:** document that clearly in global-skills too (compatible clients ignore unknown keys; pure `skills-ref validate` may only care about official fields).

3. **Upstream `skills-ref` validator**  
   Spec points at [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref). You have custom catalog validators. **Recommend:** optional CI/`skills-ref validate` on each pack for official frontmatter, alongside library validators.

4. **Context7 packs still `status: draft`**  
   Refresh/review `generated/context7/agentskills/*/result.md` if you want them “approved”; vendor mirror looks current enough that a full re-crawl isn’t urgent unless you want a newer `retrieved_at`.

5. **Content gap (not format gap)**  
   Still no global **`python-project-bootstrap`** that *composes* Agent Skills + `vault-env-sync`. That’s an implementation skill to *create*, not missing Agent Skills docs in HRL.

6. **Discoverability**  
   Catalog `applies_to: [python, ansible, just]` helps find skills *within* your implementation; it is **your** extension for grouping — not required by agentskills.io. Official discovery is still `name` + `description` (+ client catalog).

---

### Best path for new Python projects (corrected)

1. Treat **Agent Skills** as the format (HRL + agentskills.io).  
2. **Adopt** existing packs (`vault-env-sync` via `install_into_project.py`) — still Agent Skills.  
3. **Scaffold** new globals only when reusable (`scaffold-global-skill`), with official `name`/`description` + your library fields.  
4. Keep product logic in the app; keep portable operator workflows as Agent Skills packs.

I did **not** update any library files (Ask mode). If you want global-skills wired to HRL’s agentskills authority + optional `skills-ref` + bootstrap skill scaffolding, switch to Agent mode and say which of those to do first.
