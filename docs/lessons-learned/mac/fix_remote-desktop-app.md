Why this happened in the first place (in one sentence)
Your RDP client is unsigned, unnotarized, and community‑patched, so macOS treats it as suspicious and XProtectRemediat periodically inspects its sandbox, which can escalate into quarantine or removal.

The lines you showed:

Code
(Sandbox) System Policy: XProtectRemediat(...) deny file-read-data .../com.microsoft.rdc.macos/TemporaryItems
prove that XProtectRemediat was already interacting with the app’s sandbox container.

That’s the early warning sign.
