Root cause found. The entire log is one error repeating at ~50 times per second:

Error: open-in-target not supported in extension
  at open-in-targets (openai.chatgpt-26.324.21329-darwin-x64/out/extension.js)
  url=vscode://codex/open-in-targets
The openai.chatgpt extension (version 26.324.21329) is stuck in a tight error loop — it keeps trying to handle a vscode://codex/open-in-targets protocol request, fails every time with the same unsupported error, logs a full stack trace, and immediately retries. That generates ~6 MB/minute of IPC traffic, which is exactly the memmove-heavy stream read loop we saw pinning both extension hosts at 240%.

Let me check if there's a newer version available:

199 out of 200 sampled log lines are that same error. The loop is total — essentially 100% of the extension's activity is logging this failure.

Here's the complete picture:

Root cause: openai.chatgpt extension version 26.324.21329 is caught in a tight error retry loop handling a vscode://codex/open-in-targets protocol URL that is not supported in the extension host context. It logs the full stack trace on every attempt, generating ~50 errors per second and ~6 MB/minute of IPC traffic. Both extension hosts (dotfile-vnext and workflows) spike to ~240% CPU each because both windows have the extension loaded and the log/IPC flood saturates the Node.js stream loop.

This matches the "consistently over days" pattern — the loop has been running since this Cursor session started.

Evidence chain:

Extension hosts: 241% + 241% CPU, not draining after 15s idle
CPU sample: 72% of time in memmove inside a uv_run → OnStreamRead → V8 pipe-read loop
Codex logs: 5.2 MB files rotating every 60 seconds, 7 files deep (started log rotation hours ago)
Log content: Error: open-in-target not supported in extension at vscode://codex/open-in-targets — same error, same URL, 199/200 lines
Fix options, in order of preference:

Disable the openai.chatgpt extension — immediate relief, CPU drops back to baseline within seconds. In Cursor, go to Extensions sidebar → search "chatgpt" → Disable.

Update the extension — open Extensions sidebar, check for updates on openai.chatgpt. The open-in-targets handler bug is likely fixed in a newer build.

Full Cursor restart — will stop it temporarily but the loop will re-establish unless the extension is updated or disabled.

The earlier session's high renderer CPU (the Cursor Helper (Renderer) at ~100%) was a separate symptom — likely GC pressure from accumulated heap bloat caused by this same flood running for days. Both issues have the same root: this extension's error loop.

how do i list tags on a repo for git repo

git tag
For more detail with the tag messages:

git tag -n
Or to see tags with the commit they point to:

git log --tags --simplify-by-decoration --pretty="format:%d %H %ai"
