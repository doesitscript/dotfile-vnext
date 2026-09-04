# Evaluation rubric — work-laptop improvement review

Use after `git pull` and commit/comment intake. Prefer evidence over memory.

## Dimensions

### 0. Inbound deviations (first when laptop feedback exists)

Ask:

- Did a work-laptop push/PR/commit fix a runtime mismatch?
- Is that fix in `deviations/register.yaml`?
- Is there a re-apply recipe for wipe/reinstall?
- Are peers in the same `behavior_group` listed (or marked none)?
- Would a *new* tool of the same class hit this tomorrow?

| Severity | Condition |
| --- | --- |
| P0 | Inbound fix with **no** register entry (will resurface) |
| P1 | Entry exists but accommodation not in role/skill (reinstall fragile) |
| P2 | Promoted for one tool; peers in group still vulnerable |
| OK | Registered + promoted + peers covered or explicitly deferred |

**Accepted deviation ≠ debt.** Unregistered or non-generalized deviation = debt.

### 1. Runtime reliability (tech debt)

- Day-2 apply with `--skip-tags hosts_file`?
- Continue/Cline fail loud on missing LiteLLM key?
- `cx-*` Documents paths?
- MCP parse-time deps packaged when `absent`?
- npm `prefix=` / missing shim handled?

High priority if the same failure appears twice in the commit window.

### 2. Skill coverage vs repeated work

| Loop | Expected skill |
| --- | --- |
| pull + playbook + verify | `work-laptop-day2-apply` |
| Continue/Cline/Zed/`cx-*` | `work-laptop-ide-clients` |
| enable MCP | `work-laptop-mcp-commission` |
| adopt MCP role | `work-laptop-mcp-adopt` |
| vault hydrate/status | `work-laptop-vault*` |
| validate + sync sibling | `work-laptop-packet-ops` |
| debt + inbound laptop feedback | `work-laptop-improvement-review` |

Gap = loop in commits/comments but skill missing, outdated, or ignores
`deviations/`.

### 3. Skill quality

- Frontmatter matches real triggers (including “laptop pushed a fix”)?
- Handoffs: improvement-review → packet-ops → day2-apply?
- Skills tell agents to **read `deviations/register.yaml`** before inventing paths?

### 4. Authority / process

- Edits sibling-only?
- Sync without push / push without laptop pull?
- Secrets risk?

### 5. Known themes checklist

Mark: fixed / open / deferred / **registered deviation**.

- [ ] Continue empty UI ↔ LiteLLM vault key → `litellm-key-ide-clients`
- [ ] Cline like Continue
- [ ] `cx-*` Documents paths → `documents-develop-paths`
- [ ] hosts_file skip day-2 → `hosts-file-skip-day2`
- [ ] Codex/Context7 npm prefix → `npm-global-prefix`
- [ ] `common/supergateway` parse-time dep
- [ ] MemoriesToml migration
- [ ] MCP catalog default `absent`
- [ ] vault_pass helper → `vault-pass-helper`
- [ ] brew uv idempotence → `homebrew-uv-idempotence`

## Priority order for the receipt

1. Unregistered inbound laptop feedback
2. Resurface / reinstall without re-apply recipe
3. Generalization gaps inside a behavior_group
4. Day-2 / empty IDE breaks
5. Skill handoff drift
6. Docs polish

## Non-actions (default defer)

- Enabling absent MCP without user ask
- Re-enabling remote Continue autocomplete
- VS Code native `mcp.json`
- Deleting an accepted deviation to “simplify” home-Mac defaults
- Promoting packet skills to global-skills without proven cross-repo reuse
