# Suggested uses — Open WebUI / LiteLLM model routes

How I’d actually use each client-facing surface this packet documents.
Entry: Open WebUI on `hom-lab-ctl-dkr-02` (chat + Images) via LiteLLM at
`litellm.hom.lab`. Route diagrams: [`diagrams/`](diagrams/).

Companion still solutions (not owned by this folder):

- A1111: [`../2026-08-06--automatic1111-lab-setup-diagrams-implemented/`](../2026-08-06--automatic1111-lab-setup-diagrams-implemented/)
- ComfyUI: [`../2026-08-06--comfyui-lab-setup-diagrams-implemented/`](../2026-08-06--comfyui-lab-setup-diagrams-implemented/)
- Studio share seeds: role `windows_glam_studio` → `F:\shares\public\studio`

---

## Chat aliases (pick in Open WebUI model list)

### `default`

**Use when:** you want “just chat” without thinking about lanes.

**How I’d use it:** leave WebUI on `default` for day-to-day questions, inventory
notes, and short Ansible/doc drafts. It is the local-first Ornith path — treat it
as the always-on house model, not a specialist.

**Avoid:** long multimodal / vision work (prefer `gemma4-12b` or `studio-coach`);
heavy agentic coding (prefer `qwen3.6-27b`).

Diagram: [diagrams/default.svg](diagrams/default.svg)

---

### `experiment`

**Use when:** you are probing whether Ornith / the GPU lane is healthy.

**How I’d use it:** one short smoke prompt after a Phase B flip back to vLLM, or
after LiteLLM redeploy — “reply with ok and the model id.” If that fails, stop
and check `k3s-02` / DiskPressure / vLLM pod before debugging aliases.

**Avoid:** real work that needs quality or vision; this is a canary, not a daily
driver.

Diagram: [diagrams/experiment.svg](diagrams/experiment.svg)

---

### `gemma4-12b`

**Use when:** general multimodal chat on the desktop Ollama box (AMD).

**How I’d use it:** paste a screenshot of a K9s pane, Grafana board, or A1111
preview and ask “what am I looking at / what should I change?” Also fine for
Arena A-side. Same weights as `studio-coach`, but without the studio coaching
persona — use this when you want a normal assistant with eyes.

**Avoid:** treating it as the 5090 Ornith coder; that is `default` / `experiment`
or Cursor → LiteLLM code lanes.

Diagram: [diagrams/gemma4-12b.svg](diagrams/gemma4-12b.svg)

---

### `studio-coach`

**Use when:** turning messy notes + a reference image into a still brief for
A1111 or ComfyUI.

**How I’d use it:**

1. Attach a topology sketch, UI mock, or prior still.
2. Ask for a **positive prompt**, **negative prompt**, and **denoise / sampler
   hints** aimed at lab-doc content (hosts, services, cards — not portraits).
3. Paste the brief into Open WebUI Images (A1111) or a ComfyUI text node.
4. Iterate once: “tighten labels, flatter colors, less clutter.”

Optional system text on the studio share:
`F:\shares\public\studio\coaching\r_lab_visual_system.txt`.

**Avoid:** open-ended creative chat; use `gemma4-12b` for that.

Diagram: [diagrams/studio-coach.svg](diagrams/studio-coach.svg)

---

### `qwen3.6-27b`

**Use when:** agentic coding / thinking chat on desktop Ollama.

**How I’d use it:** “rewrite this Ansible `when:`”, “explain this failed play
recap”, “draft a checklist from this README section.” Prefer it over `default`
when you want stronger structured reasoning on the AMD box without burning the
5090 Ornith lane.

**Avoid:** vision-heavy studio briefs (`studio-coach`); Arena comparisons that
should stay on the pinned Gemma pair.

Diagram: [diagrams/qwen3.6-27b.svg](diagrams/qwen3.6-27b.svg)

---

### `gpt-oss-20b`

**Use when:** general / reasoning chat that fits ~16GB-class desktop Ollama.

**How I’d use it:** brainstorming runbooks, comparing two design options, or
“explain this error in plain language” when Gemma feels too chatty and Qwen is
overkill. Good spare lane if one of the other Ollama tags is busy or unloading.

**Avoid:** relying on it as the Arena pin (Arena uses Gemma + studio-coach).

Diagram: [diagrams/gpt-oss-20b.svg](diagrams/gpt-oss-20b.svg)

---

### `smart-router`

**Use when:** you want LiteLLM to pick a tier (local → stronger / optional cloud)
instead of picking a model by name.

**How I’d use it:** messy “figure this out” prompts where complexity varies —
paste a long traceback + “propose three fixes ranked.” Let complexity_router
escalate. Keep API keys / cloud policy in mind before expecting cloud tiers.

**Avoid:** deterministic work where you need a known backend for receipts
(prefer named aliases so logs show `qwen3.6-27b` etc.).

Diagram: [diagrams/smart-router.svg](diagrams/smart-router.svg)

---

## Open WebUI feature (not a LiteLLM model)

### `arena`

**Use when:** A/B comparing two pinned chat models side by side.

**How I’d use it:** open Evaluations → Arena with pins `gemma4-12b` and
`studio-coach`. Same prompt twice — e.g. “coach this topology vignette” vs a
neutral rewrite — then keep the better brief for Images. Useful after prompt or
system-text changes to see if the coach persona still helps.

**Avoid:** expecting Arena itself to generate images; Images still goes to A1111.

Diagram: [diagrams/arena.svg](diagrams/arena.svg)

---

## Image companions (owned elsewhere; used with these chat routes)

These are the still stacks this plan’s route set assumes. Full E2E writeups live
in the sibling packets linked above.

### Open WebUI Images → A1111 (CyberRealistic V9 FP16)

**Use when:** quick lab-doc stills from chat without opening ComfyUI.

**How I’d use it:**

1. Draft with `studio-coach` (+ optional reference image).
2. Open WebUI **Images** → generate on HVH-01 A1111.
3. For pose / layout lock, leave WebUI and use A1111 UI + ControlNet OpenPose
   (ControlNet mock E2E in the A1111 plan).

**Requires:** A1111 present on HVH-01; Open WebUI image env pointed at
`a1111-hvh01.hom.lab:7860`.

### ComfyUI Phase B (FLUX FP8 + SDXL; optional LTX)

**Use when:** higher-quality stills or graph-based workflows on the 5090.

**How I’d use it:**

1. Flip GPU time-share to ComfyUI ([k3s-02 GPU flip](../../reference/k3s-02-gpu-timeshare-phase-b.md)).
2. Coach briefs with `studio-coach`, then run ops change-card or agent
   storyboard graphs (ComfyUI plan).
3. Flip back to vLLM/Ornith when chat coding needs the 5090 again.

**Requires:** `k3s_comfyui_runtime_state: present` and vLLM absent on that GPU.

---

## Lab studio share (prompt seeds)

On HVH-01 after `deploy_glam_studio.yaml` (legacy role name; lab-doc content):

| Path under `F:\shares\public\studio` | I’d use it for |
| --- | --- |
| `prompts/lab_doc_still/` | Starting positive/negative text for Open WebUI Images |
| `prompts/controlnet_mock/` | A1111 ControlNet UI/topology mock briefs |
| `prompts/ops_change_card/` | ComfyUI change-card still prompts |
| `prompts/agent_storyboard/` | ComfyUI storyboard frame prompts |
| `coaching/r_lab_visual_system.txt` | Optional system text when chatting as `studio-coach` |

Copy a prompt file → refine with `studio-coach` → generate on A1111 or ComfyUI.

---

## Suggested day flow (one coherent loop)

1. Smoke with `experiment` if the GPU lane just flipped.
2. Daily text on `default` or `qwen3.6-27b`.
3. For a doc illustration: `studio-coach` (+ studio share prompt) → Open WebUI
   Images (A1111) or ComfyUI.
4. If two coach styles fight, settle it in `arena`.
5. Only open `smart-router` when you want auto-tiering, not a named receipt.

---

## What not to expect from this packet

- This folder is **route docs + diagrams**, not the Ansible apply itself.
- Packaged ComfyUI workflow JSON deploy may still be deferred — see ComfyUI plan.
- Creative / portrait product paths are out of scope for the lab E2E solutions.
