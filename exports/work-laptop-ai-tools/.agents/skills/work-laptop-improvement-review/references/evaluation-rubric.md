# Evaluation rubric — work-laptop improvement review

Use this after `git pull` and commit/comment intake. Prefer evidence over
memory.

## Dimensions

### 1. Runtime reliability (tech debt)

Ask:

- Can day-2 apply succeed with `--skip-tags hosts_file` without surprise sudo?
- Do Continue/Cline present runs fail loud on missing LiteLLM key (not empty UI)?
- Are `cx-*` roots correct for `Documents/develop` on the work Mac?
- Do MCP roles still resolve `meta/dependencies` at parse time when `absent`?
- Corporate npm `prefix=` / missing `codex` shim still handled?

High priority if a recent commit message or user thread re-hit the same failure.

### 2. Skill coverage vs repeated work

For each repeated laptop/packet loop in recent commits or docs:

| Loop | Expected skill |
| --- | --- |
| pull + playbook + verify | `work-laptop-day2-apply` |
| Continue/Cline/Zed/`cx-*` | `work-laptop-ide-clients` |
| enable MCP | `work-laptop-mcp-commission` |
| adopt MCP role | `work-laptop-mcp-adopt` |
| vault hydrate/status | `work-laptop-vault*` |
| validate + sync sibling | `work-laptop-packet-ops` |
| this review | `work-laptop-improvement-review` |

Gap = loop happened in commits/comments but skill missing, outdated, or not
handed off from AGENTS.md.

### 3. Skill quality (process this project better)

- Description frontmatter discoverable for the real trigger phrases?
- Handoffs name the next skill (packet-ops → day2-apply; vault → ide-clients)?
- Prohibited behavior still match slice rules (no VS Code native MCP by default)?
- Porting checklist include Cline mirror, `/v1` split, Documents paths?

### 4. Authority / process debt

- Edits landing only on sibling?
- Sync without push / push without laptop pull instructions?
- Secrets risk (vault decrypt on shares, keys in chat)?

### 5. Known themes from this slice (checklist)

Mark each: fixed / still open / deferred intentionally.

- [ ] Continue empty UI ↔ LiteLLM vault key
- [ ] Cline commissioned like Continue
- [ ] `cx-*` Documents/develop roots
- [ ] hosts_file skip for day-2
- [ ] Codex npm prefix / shim repair
- [ ] `common/supergateway` parse-time dep packaged
- [ ] MemoriesToml / Codex config migration
- [ ] MCP catalog default `absent` until commission

## Priority order for the receipt

1. Breaks day-2 or empty IDE with no skill handoff
2. Repeated commit churn on same class of fix
3. Skill description/handoff drift from AGENTS.md
4. Nice-to-have docs polish

## Non-actions (default defer)

- Enabling absent MCP servers without user ask
- Re-enabling remote Continue autocomplete
- VS Code native `mcp.json`
- Promoting packet skills to global-skills unless reuse across repos is proven
