# Cursor Python extension activation hang

> **Status: brainstorming / evidence capture — NOT repo work**
>
> Live Cursor investigation (2026-08-04) of stuck `Python extension loading…`
> and greyed-out Python Debugger. Not approved automation scope.

## How Agents Should Treat This Packet

- Read this README first; load the findings note only when debugging Cursor
  Python / interpreter / debugpy activation.
- Do not treat settings changes here as durable repo policy unless promoted.
- Prefer re-checking `~/Library/Application Support/Cursor/logs/<session>/`
  over assuming this packet is current.

## Packet Artifacts

| File | Role |
|------|------|
| [`cursor-python-extension-activation-hang.md`](./cursor-python-extension-activation-hang.md) | Symptoms, log evidence, root cause, applied fix, verify steps |
| [`.aiignore`](./.aiignore) | Local advisory context boundary |

## Promotion Path

If this becomes a reusable operator skill or macOS controller note, promote via
`docs/intake/` then `docs/plans/` / global skill pack as appropriate.
