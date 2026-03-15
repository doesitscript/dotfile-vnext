# Conversation Contexts

This folder stores preserved conversation transcripts and conversation-derived context files that are useful for later analysis.

These files are not active framework rules or source-of-truth implementation docs. They are archive material:
- full or partial conversation captures
- useful context snapshots from past planning or design work
- material that may later be analyzed by another LLM project

## Why this folder exists

Some conversations are valuable beyond the immediate task:
- they capture design reasoning
- they show correction patterns
- they preserve useful framing that may be worth studying later

This folder gives those conversations a home without turning them into active repo instructions.

## Naming

Preferred filename pattern:

`YYYY-MM-DD--short-slug.md`

## Skill Support

This repo includes a skill for archiving conversations into this folder:

- `archive-conversation-context`
  Located at [.cursor/skills/archive-conversation-context/SKILL.md](/Users/joshc/develop/dotfile-vnext/.cursor/skills/archive-conversation-context/SKILL.md)

What it does:
- saves a provided conversation transcript or export file into this folder
- adds a dated slugged filename
- preserves the conversation body for later review

Important limitation:
- the skill archives provided text
- it does not directly extract the full hidden transcript of a live Codex chat unless that transcript already exists as a readable file or pasted text

### What that means

- Exported:
  text that already exists in a form the repo can read, such as a markdown transcript, copied chat log, plain text export, or pasted conversation saved to a file
- Not exported:
  private system state, hidden model context, internal chain-of-thought, tool-side hidden conversation state, or any part of a live chat that is not available as normal readable text
- "Hidden chat transcript" means:
  conversation state that may exist inside the chat product but is not exposed to me as a normal file or pasted message
- "Readable text" means:
  something like `conversation.md`, `chat-export.txt`, or pasted messages that have been saved into a local text file

Made-up example:
- if a chat app internally stores `full_session_state = {...many hidden turns...}` but only shows a visible export file called `chat-export.md`, I can archive `chat-export.md`
- I cannot archive the hidden `full_session_state` unless it has already been turned into readable text and made available to me

## Current Contents

Files in this folder may be:
- manually saved conversation captures
- AI-created archives from provided transcript text
- curated context files kept for later study

Treat them as historical or analytical material unless a file is intentionally promoted elsewhere.
