# Deprecated Or Disproven Paths Must Be Replaced, Not Extended

This note exists because a recurring failure pattern showed up in framework-led
implementation work: once a path was already known to be deprecated,
structurally wrong, or repeatedly disproven by evidence, the next instinct was
still sometimes to add one more workaround or tuning layer instead of replacing
the path.

That is dangerous.

It creates technical debt at exactly the moment the evidence is already saying
"stop investing in this branch."

## Rule

When a tool, artifact path, bootstrap path, or implementation surface is any of
the following:

- deprecated by the upstream platform
- deprecated by this repo's accepted direction
- repeatedly disproven by collected evidence
- already replaced by a more native or viable path

the next move should be one of these:

- replace it
- retire it
- isolate it as legacy/fallback only

The next move should **not** be:

- add another workaround layer
- add another compatibility shim
- keep tuning flags on the same broken path
- normalize a deprecated path into looking "good enough"

## Why this matters

Once a path is already known-bad, workaround energy is usually being spent in
the least valuable place:

- it makes the repo harder to explain
- it teaches future work to trust the wrong abstraction
- it increases cleanup cost later
- it delays the switch to the path that should have been used in the first
  place

## Hyper-V example

The Hyper-V Ubuntu investigation exposed this directly.

Bad path:

- raw Canonical `.img -> qemu-img -> vhdx` conversion on Windows

What the evidence already showed:

- Hyper-V rejected the produced VHDX as sparse/compressed
- `Get-VHD` saying `Fixed` was not sufficient
- `fsutil`, `compact`, and `Get-Item` kept proving the artifact was still bad

What should be learned:

- after that point, the job was not to keep layering flags or conversion tweaks
  onto the same path
- the correct move was to replace the source/conversion path with a more native
  resource

Better replacement path:

- Canonical Azure VHD
- normalize the source artifact
- convert with native `Convert-VHD`

## WSL example

The WSL/OpenSSH work had the same shape earlier.

Bad path:

- `bash.exe` as the Windows OpenSSH `DefaultShell`

What was already true:

- `bash.exe` is a legacy compatibility wrapper
- the real supported command path for modern WSL command execution is
  `wsl.exe`
- non-interactive command passthrough behavior differs, and `bash.exe` was the
  wrong surface to keep investing in

What should be learned:

- once that was known, the answer was not to keep adjusting behavior around
  `bash.exe`
- the answer was to replace it with `wsl.exe` plus the correct command option

## Framework improvement

The framework should explicitly guard against this pattern:

1. identify when the current path is deprecated, disproven, or already replaced
2. say so plainly in the conversation
3. stop adding workaround layers to that path
4. switch to replacement-path research or implementation
5. if legacy support must remain, isolate it clearly as fallback/retired logic

## Trigger phrases to watch for

These are warning signs that the wrong instinct may be taking over:

- "one more workaround"
- "just normalize it after creation"
- "keep the deprecated path for now and patch around it"
- "add another flag and see if it helps"
- "layer this on top"

When those phrases appear after the path is already known-bad, the framework
should treat that as a correction moment, not as normal iteration.
