# PowerShell bootstrap logging + error handling contract

Applies to:
- all PowerShell bootstrap/provisioning scripts in this repo (bin/bootstrap*.ps1, bootstrap_*.ps1, scripts that set up WSL/WinRM/Ansible, etc.)

Non-goals:
- this is not a general PowerShell style guide
- this does not require shared helper functions or modules

Principles
- human-facing progress uses Write-Host
- diagnostics use Write-Verbose
- real failures use throw
- recoverable failures use try/catch, show a clear warning, then continue when safe
- do not print the same message to both host and verbose
- do not use “STEP/OK/SKIP” wrapper functions

Streams and when to use them
1) Write-Host (human-facing progress, always visible)
Use for:
- what is being checked or done
- which values are being used
- what command is about to run (high-level)
- what the user should do next

Message format (preferred)
- "Checking X: Key1[Value] Key2[Value]"
- "Doing X: Key1[Value] Key2[Value]"
- "Using X: Key1[Value] Source[host_vars|override|default]"
- "Warning X: Key1[Value] Continuing[True]"
- "Failed X: Key1[Value] Error[Message]" (only at top-level catch or immediately before terminating)

Color conventions (use sparingly)
- Cyan: checking/doing/using
- Yellow: warning/non-fatal/continuing
- Green: important success that matters
- Red: fatal error line (usually only in top-level catch)

Secrets rule
- never print secrets
- indicate presence only
  - "win_password[***] Present[True]"
  - optionally, verbose may include length only, not content

2) Write-Verbose (diagnostics, only visible with -Verbose or VerbosePreference=Continue)
Use for:
- computed paths and derived values
- branch decisions and why
- exact command strings
- captured stdout/stderr (sanitized)
- exception details inside catch blocks

Do not use verbose to repeat host messages.

3) throw (hard failures)
Use throw for:
- missing required files
- missing required fields
- null/empty required variables after parsing
- failed external commands when continuing makes the rest meaningless

Throw messages must be “fix-forward”
Include:
- what is missing or failed
- exact path or key name
- what to do to fix it (example line if relevant)

Examples:
- throw "Required file missing: <path>. Fix: create it with keys: wsl_user, wsl_distro."
- throw "Required field missing: wsl_user in <path>. Fix: add `wsl_user: <username>`."

ErrorActionPreference and VerbosePreference
- bootstrap scripts should set:
  - $ErrorActionPreference = "Stop"
- while actively debugging, scripts may set:
  - $VerbosePreference = "Continue"
- later we can gate verbose preference behind a switch, but for now it can stay enabled to reduce friction

Control flow standards
Top-level structure
- wrap the main body in one top-level try/catch
- let throws bubble up to the top-level catch
- avoid `exit 1` inside inner logic
- prefer `return` from the script after success or handled failure

Recoverable operations
Use try/catch and continue when safe:
- wsl --terminate failures
- optional checks that can be skipped
- best-effort cleanup

Pattern:

Write-Host "Checking X: ..." -ForegroundColor Cyan
try {
  ...
  Write-Verbose "X details..."
}
catch {
  Write-Host "Warning X: ... Continuing[True]" -ForegroundColor Yellow
  Write-Verbose "X exception: $($_.Exception.Message)"
}

Banned patterns (do not introduce)
- function Write-Step / Write-Ok / Write-Skip wrappers
- printing the same message via Write-Host and Write-Verbose
- Write-Error + exit 1 inside inner blocks
- obscure failure messages like “Object reference not set” without context

Reference snippet
See:
- templates/powershell/bootstrap_header.ps1.snippet

Repo checks
Run:
- scripts/check_ps_bootstrap_style.ps1
After changing bootstrap scripts, this should return clean or point to exact offending lines.
