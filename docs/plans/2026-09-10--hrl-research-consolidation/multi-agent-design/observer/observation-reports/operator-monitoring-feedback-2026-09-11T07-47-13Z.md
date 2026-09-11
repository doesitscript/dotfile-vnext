# Deterministic helper-path feedback — 2026-09-11T07:47:13Z

Observed issue: a global helper wrapper resolved a relative script path against
the caller's `dotfile-vnext` working directory. The Implementer correctly
classified this as a path-resolution failure and used the owning skill's
absolute path; no repository implementation failure or Apply action occurred.

Next iteration requirement: a reusable helper invocation must be static and
repeatable. Its launcher must derive and pass an absolute path from the helper's
own installed/declared skill root, independent of caller cwd. Do not leave this
to agent diagnosis, fallback logic, or a per-run workaround. Add a regression
test that invokes the helper from at least two unrelated working directories
and proves the same target script is used.
