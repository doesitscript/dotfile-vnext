# IN-PROGRESS

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
