# Password Flow Research Lesson

When a password or privilege-escalation path behaves unexpectedly, do not guess from surface behavior alone.

The better pattern is:
- inspect the real failure output
- check the module or tool documentation/source
- confirm how password passing is actually implemented
- only then choose the next implementation shape

This was the useful behavior demonstrated during the `remote_desktop_mac` work:
- the initial assumption about how privilege should be handled was wrong
- the fix came from stopping, reading the `community.general.homebrew_cask` behavior, and then choosing a different install primitive when the evidence showed the module path was still not sufficient

This is the kind of repeatable Codex behavior worth preserving:
- do not hand-wave
- do not patch around credential flow blindly
- prefer source-backed correction over speculative retries
