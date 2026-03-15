# Skill: Archive Conversation Context

Use this skill when the user wants to preserve a conversation transcript or exported chat as a dated markdown file under `docs/lessons-learned/conversation-contexts/`.

This skill is for archiving provided conversation text. It is not a live chat transcript extractor.

## What this skill can do

- take a provided transcript file or pasted conversation text
- save it into `docs/lessons-learned/conversation-contexts/`
- give it a dated slugged filename
- preserve the conversation body in markdown for later analysis

## What this skill cannot do

- it cannot directly export the full hidden transcript of the current Codex conversation unless that transcript already exists as readable text
- it should not claim to have captured a conversation "in its entirety" when only partial visible context is available

## When to use this skill

Use it when:
- the user has a local transcript/export file to archive
- the user pastes a conversation and wants it saved cleanly
- the user wants a dated conversation-context artifact for later LLM analysis

Do not use it when:
- the user expects Codex to magically extract the entire hidden conversation transcript from the chat system
- only a partial recollection exists and the user asked for a full transcript

## Workflow

1. Confirm the source text exists in a readable form:
   - a local file, or
   - pasted text supplied by the user
2. If no readable transcript exists, say clearly that full export is not possible from live hidden chat state.
3. Choose a short title from the user request or the conversation topic.
4. Save the transcript with:
   - date prefix
   - slugged title
   - original conversation body preserved
5. Store it in `docs/lessons-learned/conversation-contexts/`.

## File naming

Use this pattern:

`YYYY-MM-DD--short-slug.md`

Example:

`2026-03-15--planner-steward-framework-checkpoint.md`

## Script

Use `scripts/save_conversation_context.py` for deterministic file creation.

Preferred usage:

```bash
python3 .cursor/skills/archive-conversation-context/scripts/save_conversation_context.py \
  --input /path/to/transcript.md \
  --title "Planner Steward Framework Checkpoint"
```

If the user gives pasted text instead of a file, first write the text to a temporary local file in the workspace, then run the script.
