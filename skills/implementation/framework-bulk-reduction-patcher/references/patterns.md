# Patterns

Preferred patch pattern:

1. Keep the governance sentence or rule.
2. Remove the repeated operator sequence.
3. Replace it with a short routing anchor naming the project skill.

Example shape:

- keep: "preview before the first mutating run is required"
- trim: repeated command families and walkthrough prose
- add: "for one-host execution, route to `single-host-apply-and-receipt` or
  `single-host-ansible-rollout`"

Avoid:

- deleting the requirement itself
- replacing explicit rules with generic "follow the process"
- sending cross-repo or global-routing guidance into repo-specific framework
  surfaces without a real need
