<#
.SYNOPSIS
    <one line summary>

.DESCRIPTION
    <longer description of what it does and why>

    Behavior:
    - Idempotency: <idempotent | destructive-idempotent | non-idempotent>
    - Scope/Targets: <what machines/services/files it affects>
    - Assumptions: <prereqs like admin, WSL installed, modules present>
    - Safety: <what it might change/delete and how to run safely>

.PARAMETER <ParamName1>
    <what this parameter controls, including default behavior>

.PARAMETER <ParamName2>
    <what this parameter controls, including default behavior>

.INPUTS
    None.

.OUTPUTS
    None. (Writes progress to host; throws on unrecoverable errors.)

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\<scriptname>.ps1

    <what this does>

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .\<scriptname>.ps1 -<ParamName1> <value> -<ParamName2> <value>

    <what this does>

.NOTES
    Idempotency:
        <describe idempotent behavior plainly>

    Destructive actions:
        <what it may delete/unregister/remove>

    Assumptions:
        <admin required, network required, etc.>

    Logging and errors:
        - Human-facing progress uses Write-Host
        - Diagnostics use Write-Verbose
        - Unrecoverable failures throw
        - Recoverable operations use try/catch and continue when safe
        - Secrets are never printed

    Exit codes:
        0  Success
        1+ Failure (terminating error / thrown exception)

.LINK
    <path or doc reference, e.g. docs/powershell/LOGGING_AND_ERRORS.md>
#>
param(
    # ...
)
