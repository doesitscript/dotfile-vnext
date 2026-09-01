Here is a research-backed answer — no changes proposed or made.

---

## 1. When portproxy goes **missing** vs **stale**

Your repo already documents this better than generic Windows lore. These are the realistic failure modes for **your** `guest_published_tcp_ports` design (`192.168.50.234:5432 → 192.168.138.10:5432`, etc.):

### Missing (rules or listeners not there)

| Situation | What breaks |
|-----------|-------------|
| **HVH-01 reboot** without a later `configure_hyperv_windows_hosts` run | `netsh` rows may not be recreated; `iphlpsvc` may not be listening |
| **Never ran Hyper-V networking after inventory change** | Desired rows exist in `hom-lab-hvh-01.yaml` but were never applied live |
| **Declared `listen_address` not on the host** | Your plan `2026-07-09--homelab-lan-edge-drift` documents HVH-02 getting `.159` on Wi‑Fi while portproxy still targets `.158` — rules can’t bind correctly |
| **HVH-01 dual-Wi‑Fi** (`.234` vs `.233`) | Primary adapter / `host_ip` / listen IP can disagree with what’s actually on the external vSwitch |
| **Manual `netsh` edits or cleanup** | Rules removed or pointed elsewhere outside Ansible |
| **Hyper-V switch / vEthernet recreate** | Management IP alias or guest gateway path changes; publish surface probe may show `missing_listen_addresses` |

### Stale (rules **look** right but path is dead)

Your lesson learned [`hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md`](file:///Users/joshc/develop/dotfile-vnext/docs/lessons-learned/networking/hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md) is the canonical case:

| Situation | Symptom |
|-----------|---------|
| **`iphlpsvc` (IP Helper) wedged** | `netsh interface portproxy show v4tov4` shows rows; `nc 192.168.50.234:5432` times out; guest direct path (`192.168.138.10:5432`) works |
| **Rules present, no TCP listener** | Your `hyperv_networking` README now treats this as drift and recreates rules + restarts `iphlpsvc` |
| **Wrong `connect_port` / retired backend** | Brainstorm doc notes HVH-02 `:80` still pointed at old Traefik NodePort `31461` while live was `30189` — rules exist but forward to a dead target |
| **Guest VM down** (dkr-01 stopped) | Portproxy is fine; backend is not — looks like “data plane down” from k3s |
| **Docker stack on dkr-01 stopped** | Same: publish path works only if postgres container is up on `138.10` |

**Important distinction for your incident:** Postgres on `192.168.138.10:5432` was reachable **before** portproxy was fixed; `192.168.50.234:5432` was not. That is classic **stale/dead publish layer**, not “Postgres was never installed.”

---

## 2. Ansible Galaxy / community module for portproxy?

**Research result: no.**

I checked:

- **Ansible Galaxy** search: `portproxy` → **no collections, roles, or modules**
- **Galaxy** search: `windows port forward` → nothing Windows-relevant (only unrelated vendor modules)
- **Installed collections** in your project (`ansible-doc -l`): no `win_portproxy`, `win_port_forward`, or `netsh` module
- **`gocallag.hyperv`** (already in `requirements.yml`): VM, switch, disk — **no portproxy**
- **`ansible.windows`**: `win_http_proxy` / `win_inet_proxy` are **HTTP proxy settings**, not TCP port forwarding
- **`community.windows`**: `win_firewall_rule` covers firewall only

**Context7** on `ansible.windows` / `community.windows` confirms the supported pattern for this class of work is **`ansible.windows.win_powershell`** (or `win_shell`) wrapping `netsh` — which is exactly what `roles/hyperv_networking/tasks/routed_private_subnet.yml` already does, plus your newer `published_port_surface_probe.yml` drift detection.

So: **there is no better-maintained Galaxy module that would replace your approach.** The community-standard implementation *is* scripted `netsh` + service management (`iphlpsvc`), ideally with probe-before-apply. You’re already on that path; the gap isn’t “wrong module choice.”

---

## 3. Do you need “periodic reconciliation”? Is that a flaw in portproxy?

### What Ansible actually guarantees

Ansible gives **desired state when a playbook runs**. It does **not** give continuous enforcement unless something **runs playbooks on a schedule** or an event (reboot hook, CI, `site.yaml` after maintenance).

That is normal for Ansible — not unique to portproxy.

### Is portproxy especially bad?

**Somewhat yes, but for Windows/runtime reasons, not because your role is poorly written:**

1. **`netsh portproxy` is runtime config**, not a first-class Windows Server “feature” with a stable declarative API like `win_feature` or `win_firewall_rule`.
2. **`iphlpsvc` can leave rules on disk while listeners are dead** — your own lesson learned documents this.
3. **Listen IP depends on live NIC state** — Wi‑Fi, DHCP, dual adapters, and Hyper-V vEthernet make “bind to `host_ip`” a moving target unless you converge after network events.
4. **Two-hop dependency** — k3s → `.234` portproxy → guest VM → Docker. More hops = more calculable failure points.

Your role is **already ahead of many homelab setups**: preview probe, assert listen addresses exist, recreate drifted rules, restart IP Helper. That’s more than “run netsh once.”

### So is the problem your portproxy implementation?

**Partially architectural, partially operational cadence:**

| Layer | Verdict |
|-------|---------|
| **Implementation** (`hyperv_networking` + inventory) | Reasonable; matches what Ansible ecosystem offers; includes drift guards your docs recommend |
| **Orchestration** | Weak spot: data-plane + portproxy **not** in routine `site.yaml` / inference recovery phase 0 |
| **Architecture** | Cross-subnet publish (`137.x` k3s → `50.x` publish → `138.x` storage) is inherently fragile; your lang-infra retrospective already flags “publication single point and stale-listener risk” |

You are **not wrong** that steady usage *should* be calculable. The miss is: **calculable dependencies must be in the converge graph and re-run after infra events** — not that portproxy is an invalid tool.

---

## 4. Better long-term directions (not assuming current design is optimal)

These are options your **own library** already points toward; I’m not recommending one now.

### A. Keep portproxy, fix **cadence and gates** (smallest change)

- Run `deploy_network_stacks` + HVH-01 `configure_hyperv_windows_hosts` as **explicit prerequisites** before any AI stack deploy/recover.
- Optional: scheduled converge (cron/`fz`) after Windows reboots — **operational reconciliation**, not a new technology.
- Cheap probe from k3s-02: `nc fuzlang_storage_windows_publish_host 5432` — fail fast with “run storage lane + hyperv networking.”

**Permanent enough** if you accept Windows as the LAN edge and run converge after reboots.

### B. Remove the publish hop for **cluster → DB** (architectural)

Point LiteLLM/Langfuse at an address **routable from k3s-02 without portproxy**, e.g.:

- Direct `192.168.138.10` **if** guest routing from `137.x` is reliable (router static route / Hyper-V routed guest design you already use elsewhere), **or**
- Move Postgres (or all fuzlang) onto the **same guest subnet as k3s-02** (`137.x`) or **into the cluster** (in-cluster Postgres / operator).

**Tradeoff:** simpler runtime path for the AI stack; may complicate storage-lane separation you intentionally built on HVH-01/dkr-01.

### C. Replace `netsh` publish with a **real reverse proxy** on Windows

Traefik/nginx/Caddy on HVH listening on `.234:80` (and TLS later). Still Windows-hosted, but:

- Health checks, upstream config, clearer logs
- Still need Ansible to own config — **not** a Galaxy free lunch

Your retrospective already says: “prefer Traefik as normal HTTP front door” for app traffic; storage ports (5432, 6379) are a different shape.

### D. Eliminate cross-host DB dependency (largest change)

Langfuse + LiteLLM on k3s with **data plane on k3s or co-located guest** — matches “split OS VHDX / reduce blast radius” recommendations in the same retrospective, but is a **platform migration**, not a portproxy tweak.

---

## 5. Direct answers to your questions

**Prisma `ConnectError` — portproxy or something else?**  
For this incident: **publish path to `192.168.50.234:5432`**. Prisma is just the client. Fixing portproxy (and ensuring dkr-01 stack is up) fixes Prisma startup.

**Should state change if Ansible owns it?**  
Inventory didn’t change; **live Windows publish state and/or compose uptime** did. Ansible only holds that if you **run** the owning playbooks after events that disturb Windows networking or Docker VMs.

**Is periodic reconciliation a sign your portproxy design is wrong?**  
Not necessarily wrong — it’s a sign that **(a)** portproxy is runtime-sensitive on Windows, and **(b)** your **converge graph doesn’t yet treat storage publish as a hard prerequisite** for the AI lane. Reconciliation can mean “run Ansible after reboot” rather than “add a second parallel system.”

**Is there a Galaxy module that would do this more reliably?**  
**No** — I did not find one. Your `win_powershell` + probe pattern is the right Ansible-native approach.

**Will typical usage hold up now?**  
**Yes, until the next infra event** (HVH-01 reboot, Wi‑Fi/IP drift, dkr-01 stop, `iphlpsvc` wedge) **without** re-converging storage + Hyper-V networking. That’s calculable — you just need it encoded in process/orchestration, not assumed from inventory alone.

---

**Sources checked:**  
`roles/hyperv_networking/README.md`, `published_port_surface_probe.yml`, `docs/lessons-learned/networking/hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md`, `docs/plans/2026-07-09--homelab-lan-edge-drift-remediation-incomplete/README.md`, `docs/lessons-learned/lang-infra-retro/Singlegeneral-review-single-server-langfuse-two-server-infrastructure-retrospective.md`, HRL `implementation-guides/open-webui/ansible-compose-option-a.md`, Ansible Galaxy search, installed `ansible-doc -l`, Context7 `ansible.windows` / `community.windows`, `gocallag.hyperv` module list.

When you want to go deeper on “best permanent architecture,” the highest-value decision is probably **B vs A**: keep portproxy but gate it, vs route k3s → storage without the `.234` hop. I can map that as a decision matrix only (still no changes) if useful.
