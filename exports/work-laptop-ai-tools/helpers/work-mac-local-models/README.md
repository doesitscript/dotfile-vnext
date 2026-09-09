# Work-Mac local model commands

Human-run command files. Agents write the lines. You run them. Ansible does
not.

Workflow: `WORK-MAC-LOCAL-MODEL-ARRIVAL.md`.

```text
controller Mac → public share → work laptop import
```

## File shape

Each script has three sections. One command per model. No blank lines inside
a tool block. A blank line only between tools.

1. **Download to the public folder** — run on the controller Mac.
   `PUBLIC_FOLDER` is the live mount. The comment under it is the other public
   folder; swap the variable value, do not add a second root.
2. **Import onto the work Mac** — run on the work laptop, against that Mac's
   mount of the same share. Set `PUBLIC_FOLDER` there before these lines.
   First tools: Ollama, then LM Studio. A file on the share is not imported.
3. **Confirm** — one line per runtime, blank line between tools.

Hugging Face CLI is the only downloader today. Another downloader gets a
blank line, then its own one-line commands.

## Example

`example-commands.sh` — review, then run a section on the machine named in
that section. Do not run the whole file on one Mac.
