# runtime_plane

Reports which `runtime_planes` are enabled on a host versus `policy/runtime_planes.yml`.

Does **not** install Docker/Hyper-V/K3s — those stay in their owning roles. This
role is the plane interpreter / future orchestrator gate.

| | |
| --- | --- |
| **Apply** | Report with state present; mutate only when apply true (later) |
| **Verify** | Enabled planes listed; unknown planes flagged |
| **Undo** | state absent |
| **Change class** | Report / orchestration gate |
