---
title: "Ansible and repo actions — now (Flint-aware)"
status: brainstorm
created: 2026-09-01
companion: flint-openwrt-routing-layer-plan.md
execution_status: pending
executed_at: null
prerequisite_plans:
  - windows-hyperv-management-static-ip-plan.md
---

# Ansible and repo actions — now (Flint-aware)

Action list and **server-side** problem context from the Aug 2026 incident —
portproxy, Ansible, Traefik, DNS, inventory decisions. **Not** fixed by Flint
alone.

**Windows static IP (do first after BIOS):**
[windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md).

**Routing layer only** (what Flint owns / fixes): see
[flint-openwrt-routing-layer-supplement.md](flint-openwrt-routing-layer-supplement.md).
Flint migration phases:
[flint-openwrt-routing-layer-plan.md](flint-openwrt-routing-layer-plan.md).

## Execution marking

When all actionable items in this doc are implemented and verified:

1. Set `execution_status: executed` and `executed_at: YYYY-MM-DD` in frontmatter.
2. Rename → `ansible-repo-actions-now.executed.md`

See [packet README](README.md) and
[brainstorming_designs README](../../README.md#executed-plan-marking).

**Accept for the next 1–2 days:** GT6 still owns DHCP/routes; portproxy may
wedge; Mac may still need `137.x` static route until Flint is live.

---

## Topic index (where each topic lives)

| Topic | Primary doc |
| --- | --- |
| Windows static IP on HVH-01/02 | [windows-hyperv-management-static-ip-plan.md](windows-hyperv-management-static-ip-plan.md) |
| Flint static routes, DHCP leases, cutover | supplement + plan |
| Aug incident — routing angle only | supplement §2 |
| Aug incident — full chain, portproxy, orchestration | **this file** § Problems we hit |
| Portproxy missing vs stale | **this file** § Portproxy |
| Path A vs B (inventory / connection strings) | **this file** § Paths and decisions |
| Ansible Galaxy / portproxy modules | **this file** § Portproxy |
| Orchestration / reconcile cadence | **this file** § Orchestration |
| Long-term options A–E (server/platform) | **this file** § Long-term directions |
| Traefik + DNS vs portproxy | **this file** § DNS, Traefik, and portproxy |
| Actions and checklists | **this file** § Do today |

## DNS, Traefik, and portproxy — direct answer

**Does proper DNS make portproxy work go away?**

**Partly — but DNS and portproxy solve different problems.** None of them
replaces the others automatically; you change *what clients connect to*.

| Mechanism | Layer | What it does in your homelab |
| --- | --- | --- |
| **Portproxy** (`netsh` on HVH) | TCP forward | Publishes `192.168.50.234:5432` → `192.168.138.10:5432` (and HTTP `:80` → Traefik NodePort on HVH-02) |
| **Proper DNS** (`hom.lab` on DNS-01/02) | Name → IP | Stable names; can point at **guest IP** (`138.10`) or **Traefik front door** (`.158:80`) instead of raw portproxy ports |
| **Traefik** (K3s ingress) | HTTP reverse proxy | Routes `langfuse.hom.lab` / `litellm.hom.lab` to the right **pods** inside the cluster |
| **Flint static routes** | L3 routing | Lets every LAN client reach `137.x` / `138.x` without per-host route hacks |

**For the Aug incident (Postgres / Redis / ClickHouse):**

- Traefik **does not help** — those are not HTTP ingress services.
- Proper DNS **can** reduce portproxy dependence if records point at
  `192.168.138.10` (or a name that resolves there) and clients use that name.
- Flint **helps** because routed guest subnets become LAN-wide without Mac static
  routes — but you still need dkr-01 up and correct connection strings.

**For web apps (Langfuse UI, LiteLLM API, Open WebUI):**

- **Traefik is the right tool** — already deployed on k3s-02; routes live in
  `k3s_traefik_routes_entries` / role `k3s_traefik_routes`.
- Today many clients still reach Traefik via **HVH-02 portproxy `:80`** → NodePort,
  plus **interim** `homelab_hosts_file_mac` (`langfuse.hom.lab` → `.158`).
- Proper DNS replaces the **hosts-file hack** and can aim names at `.158:80`
  (Traefik front door). Portproxy on `:80` may remain until you publish Traefik
  on a path that does not need Windows `netsh` — that is a separate, smaller
  portproxy surface than storage ports on HVH-01.

**Summary:** Proper DNS + Flint routing lets you **stop using portproxy for
databases** by resolving names to guest IPs. Traefik + proper DNS lets you
**stop using NodePort URLs and fake router DNS rows** for HTTP services. Neither
removes the need to run `hyperv_networking` until you have proven no client still
hits the old publish paths.

---

## Problems we hit (Aug 2026 — keep this context)

### Symptom chain

1. LiteLLM / Langfuse pods on k3s-02 failed health / crash-looped.
2. Logs showed Prisma `ConnectError` — could not reach Postgres.
3. Connection string targeted **`192.168.50.234:5432`** (inventory publish contract).
4. **Direct probe** `192.168.138.10:5432` (dkr-01 guest) **worked**.
5. **Publish probe** `192.168.50.234:5432` **failed** (timeout).
6. After `deploy_network_stacks` + HVH-01 `hyperv_networking` converge, publish
   path recovered; AI stack came back (vLLM cold start still takes minutes).

### Root cause (not “Postgres was missing”)

| Layer | State |
| --- | --- |
| dkr-01 Postgres container | Up on `138.10` |
| GT6 static route `138.0/24` → `.234` | Present |
| HVH-01 portproxy / `iphlpsvc` | **Dead or missing listener** — classic stale publish layer |
| Orchestration | Recovery playbook did not **gate** on storage stack + hyperv first |

This matches lesson learned:
[`hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md`](../../lessons-learned/networking/hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md).

### Secondary noise (same window)

- k9s showed hundreds of stale `Error` pods and high node RAM — partly **symptom**
  of crash-looping dependents, partly structural with 32B vLLM loaded.
- `recover_ai_inference_lane` **failed at the end** on mac-dev:
  `k3s_traefik_routes_entries` undefined in profile validation — unrelated to
  Postgres but blocks a clean recover receipt.

### What Flint changes vs what it does not

| Problem | Flint helps? |
| --- | --- |
| LAN clients lack route to `138.x` | **Yes** — static routes on Flint |
| Cluster uses `.234` portproxy URL for DB | **No** — change inventory / DNS target |
| `iphlpsvc` wedge on HVH-01 | **No** — unless you stop using that path |
| dkr-01 stack down | **No** — `deploy_network_stacks` |
| HTTP services via hostname | **Indirectly** — with DNS + Traefik, not Flint alone |

---

## Paths and decisions (server / inventory — not Flint)

Two ways k3s-02 can reach Langfuse platform Postgres:

```text
Path A — direct guest IP (routing + Flint makes this LAN-wide)

  k3s-02 pod (137.x)
    → router static route 138.0/24 via 192.168.50.234
    → HVH-01 forwards to 192.168.138.10:5432

Path B — Windows publish contract (current inventory default)

  k3s-02 / LiteLLM env
    → 192.168.50.234:5432
    → HVH-01 portproxy
    → 192.168.138.10:5432
```

**Contract today:** `langfuse_platform_external_services.yml` → publish host `.234`.

**Aug 2026:** Path A worked; Path B failed. Flint does not change that — you
still choose Path A in inventory or keep converging portproxy for Path B.

| Decision | Recommendation |
| --- | --- |
| Cluster DB URL → `192.168.138.10` (Path A) | **Yes** — survives portproxy wedges; pairs with Flint routes |
| Keep Path B for external LAN clients | Optional transition |
| Shrink portproxy DB rows | After Path A proven |

---

## Portproxy (Windows host — Flint does not fix)

Design reference: `192.168.50.234:5432 → 192.168.138.10:5432` (HVH-01; GPU
lane mirrors on `.158` → `137.x`).

### Missing

| Situation | Owner |
| --- | --- |
| HVH-01 reboot without `configure_hyperv_windows_hosts` | Ansible converge |
| Listen IP not on host (Wi‑Fi drift off `.234`) | **Flint** DHCP lease + `hyperv_networking` |
| Dual Wi‑Fi on HVH-01 (`.233` vs `.234`) | Flint lease + delete stale `.233` on GT6/Flint |
| Manual `netsh` edits | Operator discipline |

### Stale

| Situation | Symptom |
| --- | --- |
| `iphlpsvc` wedged | `netsh` shows rules; `nc .234:5432` fails; `nc 138.10:5432` works |
| Wrong backend port | Rule forwards to retired target |
| dkr-01 / stack down | Both paths fail at backend |

Lesson:
[`hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md`](../../lessons-learned/networking/hyper-v-portproxy-can-fail-while-the-guest-service-is-healthy.md).

**Ansible Galaxy:** no portproxy module; `roles/hyperv_networking` (PowerShell +
drift probe) is correct. Gap is orchestration cadence, not module choice.

---

## Orchestration (repo — Flint does not fix)

| Layer | Verdict |
| --- | --- |
| Router static routes | **Flint** after cutover (see supplement) |
| Hyper-V networking | **Ansible** after every HVH reboot |
| Storage Docker stack | **`deploy_network_stacks`** before AI recover |
| Portproxy | Converge until clients leave Path B |
| Recover playbook | **Gap** — needs phase-0 gates |

Ansible gives desired state when playbooks run. Flint removes per-client **route**
workarounds; it does not replace playbook converge after infra events.

---

## Long-term directions (server / platform decisions)

| Option | Notes |
| --- | --- |
| **A. Cadence + gates** (storage + hyperv before AI) | **Do now** — Flint-independent |
| **B. Cluster → guest IP for DB** (Path A) | **Recommended** — stronger with Flint routes |
| **C. Windows reverse proxy (HTTP)** | Traefik on K3s remains primary |
| **D. In-cluster data plane** | Separate platform migration |
| **E. Retire portproxy for DB ports** | After Path A + verification |

Items that were “router UI” work on GT6 move to **Flint migration** (supplement)
and drop from this server action list.

---

## Traefik — useful work now (still valuable after Flint)

Traefik is your **in-cluster HTTP ingress controller**. It receives requests by
hostname (`langfuse.hom.lab`) and forwards to the correct Kubernetes service.
It does **not** terminate Postgres or Redis traffic.

### Already implemented (do not re-litigate)

- Traefik on **k3s-02**; role `k3s_traefik_routes`
- Route registry: `inventory/group_vars/k3s_cluster/main.yml` →
  `k3s_traefik_routes_entries`
- HVH-02 **portproxy** `k3s-traefik-http` → Traefik NodePort (plan:
  `2026-05-27--k3s-hyperv-traefik-implemented`)
- Mac interim DNS: `homelab_hosts_file_mac` + matrix in
  `docs/diagnostics/k3s-hyperv-traefik-interim-dns-matrix.md`

### Work worth doing **now** (Flint-independent)

| Action | Why it still matters after Flint |
| --- | --- |
| Fix `k3s_traefik_routes_entries` in recover validation | Clean recover playbook; registry must be defined for profile checks |
| Audit / complete `k3s_traefik_routes_entries` for Langfuse, LiteLLM, Open WebUI | Stable hostname ingress regardless of router |
| Verify `http://langfuse.hom.lab/` and `http://litellm.hom.lab/` via Traefik (not raw NodePort) | Operator UX; aligns with DNS-01/02 later |
| Read implemented plan + blueprint before changing routes | `docs/plans/2026-05-27--k3s-hyperv-traefik-implemented/README.md` |
| Prepare DNS records (design only) pointing `*.hom.lab` → `192.168.50.158` for HTTP | Same target after Flint; only resolver changes |

### Defer (needs DNS-01/02 or Flint DHCP option 6)

- Replacing **mac hosts file** with authoritative `hom.lab` on DNS servers
- Cancelling GT6 fake-MAC `langfuse` / `litellm` DHCP rows (already deferred)
- Linux/Windows guest hosts-file roles (`homelab-hosts-file-linux-windows-incomplete`)

### Traefik vs portproxy vs DNS (HTTP path)

```text
Today (simplified):

  Browser → langfuse.hom.lab (hosts file → 192.168.50.158)
         → HVH-02 portproxy :80
         → Traefik NodePort on k3s-02
         → Traefik Ingress → langfuse-web pod

After proper DNS (Flint unchanged for HTTP):

  Browser → langfuse.hom.lab (DNS-01 → 192.168.50.158)
         → same portproxy :80 → Traefik → pod
         (portproxy on :80 may remain in transition)

Longer term:

  Optional: DNS → 192.168.137.11 + Traefik NodePort or direct guest publish
  — only after proving path; not required for Flint cutover
```

---

## Do today (Flint-independent)

### Recovery ordering

Encode storage + Hyper-V as hard prerequisites before AI stack recover:

```bash
ansible-playbook playbooks/deploy_network_stacks.yaml
ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml \
  --limit HOM-LAB-HVH-01 --tags hyperv_networking
ansible-playbook playbooks/recover_ai_inference_lane.yaml
```

**Repo follow-up:** add phase-0 gates inside `recover_ai_inference_lane.yaml`
(and consider `site.yaml` chain) so this order is not tribal knowledge.

### Bug fix — recover validation on mac-dev

- [ ] Fix `k3s_traefik_routes_entries` undefined in
      `validate_ai_agent_client_profiles` (recover playbook tail failure)
- [ ] Confirm `inventory/group_vars/k3s_cluster/main.yml` defines the route
      registry expected by validation (Traefik work ties in here)

### Langfuse platform contract — cluster path

- [ ] **Decision:** point in-cluster LiteLLM/Langfuse DB URLs at
      `192.168.138.10` (Path A) instead of `192.168.50.234` portproxy
- [ ] If yes: update `langfuse_platform_external_services.yml` and role
      defaults for k3s consumers only; keep `.234` publish for external LAN
      clients until DNS names exist for storage (`postgres-storage.hom.lab` →
      `138.10` is a DNS-01/02 design task, not required before Path A IP)
- [ ] **Benefit now:** survives `iphlpsvc` wedges; **synergy with Flint:** same
      path works LAN-wide once Flint routes are live

### After any HVH-01 reboot or data-plane incident

```bash
ansible-playbook playbooks/deploy_network_stacks.yaml
ansible-playbook playbooks/configure_hyperv_windows_hosts.yaml \
  --limit HOM-LAB-HVH-01 --tags hyperv_networking
```

No router UI work required for this converge path.

---

## Decide today (low effort, optional)

| Decision | Recommendation | Effort |
| --- | --- | --- |
| Phase-0 gates in recover playbook | **Yes** — do in repo this week | small Ansible change |
| Cluster DB URL → `138.10` | **Yes** — before or with Flint | inventory + role vars |
| Traefik route audit + hostname verify | **Yes** — useful now and after Flint | read + probe |
| Design `hom.lab` DNS records for HTTP services | **Yes** — design only; implement with DNS-01/02 | doc / NetBox |
| In-cluster Postgres / data plane (option D) | **Defer** — not a router fix | large |
| Shrink portproxy rows now | **No** — wait for Path A + DNS proof | — |

---

## Explicitly defer to Flint hardware (do not spend time now)

These are **accepted problems** until the GL.iNet Flint is cut in:

| Item | Why defer |
| --- | --- |
| GT6 static route maintenance | Flint becomes route SSOT |
| GT6 DHCP stale row cleanup (`.70`, `.233`) | GT6 demoted to AP; delete at cutover |
| GT6 `langfuse` / `litellm` fake-MAC DNS rows | Cancelled — DNS-01/02 + Traefik path |
| `router_local_dns` / stock GT6 Option C | Superseded by Flint + DNS servers |
| Remove `hyperv_guest_route_mac` on mac-dev | Verify redundant **after** Flint routes |
| Ansible `homelab_router_gt6_state: present` | Replace with Flint inventory later |
| NetBox Flint device modeling | After stable manual config |

---

## Explicitly not router problems (keep in project regardless)

| Item | Owner | Notes |
| --- | --- | --- |
| dkr-01 Langfuse platform stack uptime | `deploy_network_stacks` / `stacks_fuzlang_net` | Incident root if stack down |
| `iphlpsvc` / portproxy on HVH-01 | `hyperv_networking` converge | **Still required** until clients leave `.234` DB path |
| K3s Traefik ingress / routes | `k3s_traefik_routes`, `k3s_cluster` vars | HTTP only; see § Traefik above |
| hom.lab authoritative DNS | DNS-01 / DNS-02 | Replaces hosts-file + fake router DNS; **softens** portproxy need when records point at guest IPs |
| vLLM / GPU inference recovery | `deploy_vllm_runtime`, GPU roles | Separate from routing incident |

---

## Quick probe commands (until Flint + Path A default)

From mac-dev or k3s-02:

```bash
# Backend healthy?
nc -zv 192.168.138.10 5432

# Publish path (may fail when iphlpsvc wedged)?
nc -zv 192.168.50.234 5432

# Traefik HTTP front (via portproxy on HVH-02)?
curl -sS -o /dev/null -w '%{http_code}\n' -H 'Host: langfuse.hom.lab' http://192.168.50.158/
```

Fail on second only + first OK → converge Hyper-V networking; move DB contract
to Path A. HTTP curl failures → Traefik / portproxy on HVH-02 `:80`, not storage lane.

---

## Checklist summary

**Before Flint / parallel (operator + repo):**

- [ ] [Static IP plan](windows-hyperv-management-static-ip-plan.md) Phase 0 — disable onboard Wi‑Fi BIOS on HVH-01 (**shutdown sent 2026-09-01**)
- [ ] Static IP plan Phases 1–4 — **after BIOS** (Ansible; not started)

**This week (repo — can parallel Phase 0):**

- [ ] Phase-0 gates in `recover_ai_inference_lane.yaml`
- [ ] Fix `k3s_traefik_routes_entries` validation + confirm route registry
- [ ] Decide + implement cluster DB URL → `192.168.138.10` (recommended)
- [ ] Verify Langfuse / LiteLLM via Traefik hostnames (not only NodePort)
- [ ] Sketch DNS-01/02 `hom.lab` records for HTTP services (design)

**After Flint arrives:**

- See [flint-openwrt-routing-layer-plan.md](flint-openwrt-routing-layer-plan.md) Phases 1–3

**Not now:**

- GT6 router UI edits (except emergency)
- Removing all portproxy ( shrink storage DB ports only after Path A proof )
- Router Ansible automation

---

**Companion docs:** [README.md](README.md) ·
[flint-openwrt-routing-layer-plan.md](flint-openwrt-routing-layer-plan.md) ·
[flint-openwrt-routing-layer-supplement.md](flint-openwrt-routing-layer-supplement.md)
