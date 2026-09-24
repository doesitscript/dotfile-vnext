# Bucket: Cold storage

Use for retainable, infrequently accessed data that should leave the hot tier.
Preserve a documented restore/retrieve path and prove it before removing the
source copy.

| Candidate path | Cold-tier destination | Retrieval trigger/path | Integrity proof | Status |
|---|---|---|---|---|
| Steam **live** libraries / recordings (`D:\SteamLibrary`, `I:\SteamLibrary`, `I:\Gamerecordings`) | **Do not use** `H:\COLD-DATA-HOST` or `/mnt/k3s-cold` | N/A — interactive Steam needs attached live paths | N/A | **rejected for cold tier** — current cold is k3s/Hyper-V archive lane; see keep-behavior + Steam media-class matrix |
| Steam **archive demote** (future: rarely played titles only) | Optional later: `H:\COLD-DATA-HOST\steam-archive\…` (host cold), **not** guest `/mnt/k3s-cold` | Restore/copy back into a live library root, then Steam rediscover | Checksums + Steam sees path after restore | pending research — separate from `windows_steam_client` live pointers |
| _new user candidate_ | `/mnt/k3s-cold` or approved HVH-02 cold path | — | — | pending |
