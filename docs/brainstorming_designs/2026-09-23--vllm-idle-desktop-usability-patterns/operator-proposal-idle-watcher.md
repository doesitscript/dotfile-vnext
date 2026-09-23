---
title: Operator proposal — idle watcher for vLLM / lab GPU
status: brainstorm
role: operator_proposal
created_at: 2026-09-23
source: conversation 2026-09-22/23 HVH-02 VRAM / Ollama-like unload discussion
---

# Operator proposal — idle watcher (as stated)

This file preserves the **operator idea** in its own words (cleaned only for
readability). It does not certify feasibility or approve implementation.

## Goal

Be OK with current always-on residency for now, but explore a path where the
lab GPU returns to **desktop usability** after models are not really in use —
similar in *effect* to Ollama unloading after idle — without controlling that
day-to-day from a Mac or by running Ansible every time.

## Desired behavior (user story)

1. Server (HVH-02) may reboot once or twice a day; when used as a desktop
   (e.g. YouTube), GPU should feel available.
2. Later, when lab work starts, first request through LiteLLM/vLLM may be
   slow (even ~10s+); that is acceptable.
3. After roughly **5–10 minutes** (or similar) without real user interaction,
   the setup should free the GPU so desktop mode feels normal again.
4. Prefer something **set-and-forget on the lab**, not Mac-driven control and
   not “I run Ansible when I want sleep.”

## Proposed mechanism (operator sketch)

Create a **Kubernetes-oriented controller / watcher** that:

1. Enables whatever settings or CLI flags are needed so vLLM **admin sleep /
   wake HTTP endpoints** are available (if that path is chosen).
2. Occasionally checks:
   - which models / pods are running, and
   - when a model was **loaded** vs when it was **last used** (interacted with
     by a user, generally speaking).
3. If not used recently, **spin down** the pods that were serving that model
   (operator intent: free / unload the model from GPU memory — whether that is
   literally “unload in process” or “stop the pod” may need clarification).

## Operator mental model of complexity

- Logic feels **specific and easy to check**: ready endpoints + occasional
  “running models” + “last used” + tell K8s to spin down if idle.
- Feels **not extremely complicated** relative to the outline above.
- Admin endpoints are understood as **manual switches** if used alone; the
  watcher would call them (or spin pods) on a schedule/policy so the operator
  does not flip switches by hand.

## Explicit non-goals (as of capture)

- Not asking to implement KEDA/Knative research outcomes in this packet.
- Not requiring Ollama-identical keep_alive inside vLLM.
- Not requiring Mac-side hooks as the control plane.

## Open wording (operator)

“Spin down pods” vs “unload the model” vs sleep-mode `/sleep` may be the same
*effect* (free VRAM for desktop) even if the mechanism differs. Operator wants
the **desktop-usable effect**, not a particular product name.
