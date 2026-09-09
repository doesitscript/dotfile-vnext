---
name: work-laptop-model-runtime-import
description: "Use when adding a human-run command that imports a model from the public share into a work-Mac runtime. First runtimes are Ollama and LM Studio. Writes one line per model into helpers/work-mac-local-models. Do not use for the controller download step, and do not treat a share copy as already imported."
---

# Skill: Work-laptop model runtime import

Write the work-laptop import lines. The human runs them on that Mac.

## When to use / not use

Use when:

- a model is, or will be, on the public share and must be imported into a
  runtime on the work laptop
- the selected runtime is Ollama or LM Studio

Do not use when:

- the model still needs a controller download (`work-laptop-model-public-download`)
- the user only asked which runtime to consider (HRL Mac candidate stubs)

## File

`helpers/work-mac-local-models/` — section 2 import, section 3 confirm.
See `README.md` and `example-commands.sh`.

Edit the packet, then `work-laptop-packet-ops` sync.

## Section 2 rules

- These lines run on the work laptop. `PUBLIC_FOLDER` must be that Mac's mount
  of the same share.
- One command per model. No blank lines inside a tool block.
- After all lines for one runtime, one blank line, then the next runtime.
- First tools: Ollama, then LM Studio. Another runtime gets the same blank-line
  split.
- Ollama does not detect a folder drop. Import with `ollama create <name> -f -`
  and a `FROM <gguf>` on stdin. Point `FROM` at a GGUF file that exists in the
  download dir. Do not invent a filename; use `REPLACE.gguf` until the human
  names the file that landed.
- LM Studio does not detect a folder drop. Import with
  `lms import <file> -y`.

## Section 3

One confirm line per tool, blank line between tools (`ollama list`, then
`lms ls`). If a confirm flag fails, fix the line from that tool's help. Do
not claim the import worked without the human running it.
