# Agent Design Principle: Authoring vs Consuming

**Agents are consumers of their own skills during execution.**
**The repo agent (Cursor/Claude) is the author of those skill files.**

These are two different roles. Do not confuse them.

---

## The Separation

| Role | Who | What they do |
|---|---|---|
| Consumer | Any agent skill (coordinator, planner, researcher, observer) | Calls MCP tools, follows phases, does the work |
| Author | Cursor / Claude (repo agent) | Reads skill files, updates them, improves instructions |

An agent does not edit itself. When a skill needs updating — new tools, better
phases, corrected patterns — bring it to the repo agent.

---

## Why This Matters

Blur this line and you get:
- Skills trying to modify their own instructions mid-session
- No clear owner when a skill needs improving
- Confusion about what is execution vs authoring

---

## Practical Rule

> When a skill needs to know about a new tool, phase, or pattern:
> bring it to Cursor and say "update the skill files with this."
>
> Do not ask the agent to teach itself.

---

## On Building an Agent Designer Skill

An `agent-designer` skill is a legitimate future goal. Not ready yet.
The right time is after more agent designs have been worked through hands-on
and the patterns are clear from experience, not theory.

`docs/agent-design/` accumulates those learnings until there is enough to
formalize into a skill.
