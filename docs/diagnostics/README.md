# Diagnostic Discovery Store

Per `REQUIRED-EVIDENCE-NO-ASSUMPTIONS-ON-FAILURE.mdc` RULE 8a1, when research is triggered (two inference-based fix attempts failed), the agent's first effort is diagnostic-discovery: find where the component reports operational state, failures, and diagnostic output.

This folder stores those findings for reuse. If a file exists for the component+OS, the agent uses it — no need to re-research. If not, the agent performs discovery, creates the file, and stores the findings.

## Naming

`<component>--<os>--diagnostics.md`

Examples:
- `openssh--linux--diagnostics.md`
- `openssh--windows--diagnostics.md`
- `docker--linux--diagnostics.md`
- `docker--windows--diagnostics.md`
- `winrm--windows--diagnostics.md`
- `systemd--linux--diagnostics.md`

## File Structure

```markdown
# <Component> Diagnostic Sources

## Logging Locations
- <path or subsystem>

## Diagnostic Commands
- <command>

## Event / Channel Sources
- <event log channel or journal unit>

## Vendor / Tooling Diagnostics
- <vendor CLI or tool>

## Notes
- <caveats or special behavior>
```
