# Self-evaluation — Morph MCP usage (this conversation)

Copied from the agent’s Morph-audit reply in the same thread (2026-09-23), kept
as the evaluation artifact for this packet.

---

## Morph MCP usage this conversation

**0 calls.** Morph was available (`user-morph-mcp`, status `ready`: `codebase_search`, `edit_file`, etc.). I never invoked it.

What I used instead: native `Grep`/`rg`, `Read`, `Shell`, Context7, Cursor `TodoWrite`, and native `StrReplace` for the HRL Q&A edits.

---

## Surfaces that direct Morph — used or not

| Surface | Injected this turn? | What it says | Followed? |
| --- | --- | --- | --- |
| `.cursor/rules/morph-warpgrep-evaluation.mdc` (`alwaysApply: true`) | Yes | Prefer WarpGrep for **broad semantic** “where/how”; **do not** for exact keywords/symbols/regex — use `rg`. Prefer `edit_file` for multi-hunk edits. | Mostly yes on the keyword carve-out. Soft miss: no opening WarpGrep for “how does azure cloud image shared cache work in `hyperv_ubuntu_vm`?” |
| `.cursorrules` / `framework-context-budget.mdc` | Yes | Keep Morph rule always-on and lean | Used as intended (rule was present) |
| `AGENTS.md` Morph block (Ansible-managed) | Not as Cursor always-on; same text as Morph MDC | Same WarpGrep / Fast Apply guidance | N/A for this Cursor session boot |
| `framework-mcp-and-tool-usage.mdc` | **No** (on-demand) | Stronger: use `codebase_search` **before repeated** native grep/read for unfamiliar cross-file work | Not available this turn by design |
| Morph tool schema (`codebase_search`) | Available | Vendor: “ALWAYS use this tool to start your search”; not for keyword dumps | **Conflicts** with repo keyword carve-out; I followed the **repo** rule |
| `roles/mcp_servers/*` / Morph plan docs | Not opened | Install/ops authority | N/A — not an agent habit surface for this turn |

---

## Fault assignment

**Not a Morph outage.** Tools were ready; I didn’t call them.

**Mostly not surface fault for this task.** The always-on Morph rule explicitly says keyword/symbol search → native `rg`. My probes were things like `azure.*vhd`, `shared_cache`, `livecd.ubuntu` — that path matches the carve-out.

**Soft agent miss (me):** One semantic WarpGrep at the start of the role exploration would have matched “prefer at the beginning of codebase explorations.” I skipped it because I already had strong keywords and HRL Q&A hits.

**Real surface tension (worth fixing later):**
1. Morph vendor schema: “ALWAYS start with this tool”
2. Repo Morph MDC: “Do not use for exact keywords”
3. `framework-mcp-and-tool-usage.mdc` is stricter about Morph-before-grep, but it’s **off always-on** for context budget — so the stronger habit often never loads

So: **zero Morph uses is mostly compliant with the always-on Morph rule for this research turn; the miss is habit (no opening semantic WarpGrep), not Morph being broken, and the stronger MCP rule never fired because it isn’t always-on.**
