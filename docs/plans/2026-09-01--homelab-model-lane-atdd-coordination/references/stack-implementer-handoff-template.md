# Stack implementer handoff templates

File-based coordination between **acceptance author** and **stack implementer**.
Copy, fill, and save under the active plan's `coordination/handoffs/` tree.

## To stack implementer (`to-stack-implementer/NNN-<slug>.md`)

```markdown
---
handoff_id: NNN
from: acceptance-author
to: stack-implementer
campaign: <plan-folder or label>
date: YYYY-MM-DD
manifest: <path to pending or approved YAML>
probe_command: <exact script invocation>
---

## Ask

<one paragraph: what stack behavior must change>

## FAIL receipts (paste full blocks)

```text
(paste every relevant FAIL receipt — USER / EXPECTED / ACTUAL)
```

## Scope

- In scope: ...
- Out of scope: ...

## Do not

- Weaken EXPECTED in manifest
- Promote pending/ to approved
- Mark campaign stable without acceptance author re-probe
```

## From stack implementer (`from-stack-implementer/NNN-<slug>-response.md`)

```markdown
---
handoff_id: NNN
from: stack-implementer
to: acceptance-author
campaign: <plan-folder or label>
date: YYYY-MM-DD
ready_for_reprobe: true
---

## Changes

| Area | Files / hosts | Summary |
| --- | --- | --- |
| ... | ... | ... |

## Re-probe

```bash
<exact command for acceptance author to run>
```

## Notes

<any caveats, blocked upstream, or partial fixes>
```
