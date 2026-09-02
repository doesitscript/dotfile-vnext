# IN-PROGRESS

## Beta — homelab local AI clients (Continue + OpenCode + 5090 32B)

**Status:** `incomplete-wip` / **beta** — live on homelab; extension CLI probes pass.

**Plan:** `docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/README.md`

**Promote to stable only after:** Kilo Code evaluation on restored
`qwen2.5-coder-32b@k3s02-vllm` lane — tool_calls, agent routing, `kilo.jsonc`
limits, and `playbooks/validate_kilo_litellm_probes.yaml` with operator sign-off.
Continue/OpenCode paths are ahead of Kilo validation.

**Sibling (not started):** Codex CLI homelab profile
(`docs/plans/2026-09-01--homelab-local-ai-clients-codex/`).

# SMB Between host is blocked
When installing drivers to HPH – 01, said that SMB was blocked. This should not be the case. I do have S&P already solved to an extent so I wanna make sure this is a simple fix like firewall issues or something like that first and need to make sure that the AI doesn't try to reinvent or blindly try to resolve this.

## Later — mac-dev brew roles (Ansible)

Track as new/extended roles wired through `playbooks/deploy_development_nodes.yaml`
(`--limit mac-dev`). Prefer native Homebrew when it works; expect macOS 12 /
security / trust friction (see below). Manual brew testing is exploratory only.

| Capability | Brew formula(s) | Intended role / tag (draft) | Why |
| --- | --- | --- | --- |
| Graphviz render runtime (`dot`) | `graphviz` (+ brew deps such as `netpbm`, possibly `svn` on this host) | `graphviz_cli` (or `diagrams_graphviz_runtime`) | OS dependency for Mingrammer `diagrams` render; PATH historically expected `/usr/local/opt/graphviz/bin` |
| (optional) diagrams Python env | *not* brew — project/home venv + `pip install diagrams` | out of brew role scope; `create-diagrams` skill | Authoring is PyPI |

### Role design notes — security / unsupported tooling / whitelist

When implementing these roles, document (README + defaults comments) that:

1. **Missing Graphviz may be intentional.** Older or unsupported Homebrew
   formulae / dep chains can disappear after cleanup, OS upgrades, or security
   policy — not only operator error. Same class of problem as other Monterey
   special-cases (`tunnelblick_mac` deprecated DMG, `aws_cli` avoiding broken
   Homebrew `awscli`, Docker wrappers in `common/shell_config` /
   `ansible_dev_tools` for tools that cannot compile natively).
2. **May need an explicit allowlist / trust step**, similar to older tools we
   already handle:
   - Homebrew tap trust (`brew trust …`; avoid blanket
     `HOMEBREW_NO_REQUIRE_TAP_TRUST`)
   - Pinned deprecated upstreams with documented CVE/compatibility tradeoffs
     (Tunnelblick pattern)
   - Docker fallback when native brew is blocked or too costly to build on
     macOS 12
3. **Role should support dual delivery:**
   - `present` via brew when formula installs cleanly
   - documented Docker fallback for render-only Graphviz (skill-owned), so
     agents are not blocked when brew is unavailable
4. Do **not** silently reinstall security-rejected packages without operator
   acknowledgment in the role README / change class notes.

Playbook entry remains `deploy_development_nodes` / mac-dev lane.

## Manual brew test (this session)

- [x] Attempted `brew install graphviz` (heavy macOS 12 compile; stopped when
      pivoting to Docker)
- [ ] `dot -V` local — still deferred
- [x] Render `skill_eval/account_isolation.py` via Docker fallback →
      `account-isolation.png` + `RECEIPT.md`

## Active — create-diagrams Docker fallback

- [x] Skill wired for Docker when local `dot`/`diagrams` missing
      (`references/docker-render.md`, `scripts/render_with_docker.sh`)
- [x] Skill-eval PNG produced under
      `oneoffs/issue/zic-integration/docs/diagrams/skill_eval/`

Deferred (unchanged): full `generate-project-state-report` / `ansible-coordinator` /
`generate-mcp-briefing` measurement runs.
