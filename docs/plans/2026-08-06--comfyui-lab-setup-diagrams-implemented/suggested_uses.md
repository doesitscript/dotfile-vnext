# Suggested uses — ComfyUI lab E2E solutions

How I’d use each **usable surface** this packet documents. Entry points:
ComfyUI at `http://comfyui.hom.lab:30188/` (Phase B on), Open WebUI +
`positive-negative-prompt-assist` for briefs, lab share for outputs.

Diagrams: [`diagrams/`](diagrams/). Sibling chat routes:
[`../2026-08-06--open-webui-litellm-model-route-diagrams-implemented/suggested_uses.md`](../2026-08-06--open-webui-litellm-model-route-diagrams-implemented/suggested_uses.md).
Sibling Phase A stills:
[`../2026-08-06--automatic1111-lab-setup-diagrams-implemented/`](../2026-08-06--automatic1111-lab-setup-diagrams-implemented/).

**Prerequisite:** GPU time-share flipped to ComfyUI (vLLM/Ornith absent on the
5090). See [k3s-02 GPU flip](../../reference/k3s-02-gpu-timeshare-phase-b.md).

---

## Shared surfaces (use with both E2E solutions)

### ComfyUI web UI / API (`comfyui.hom.lab:30188`)

**Use when:** you need a node-graph still on the high-VRAM host.

**How I’d use it:** open the UI after the flip; load or build a single-still
graph; paste a brief from `positive-negative-prompt-assist`; save PNG to the lab share (or Comfy
output → copy to `F:\shares\public\studio\images\output\…`). Prefer API
`/prompt` later when graphs are packaged.

**Avoid:** leaving Phase B on overnight if you need Ornith for Cursor coding —
flip back when done.

Diagram: [diagrams/comfyui-lab-architecture.svg](diagrams/comfyui-lab-architecture.svg)

---

### `positive-negative-prompt-assist` (Open WebUI → LiteLLM → desktop Ollama)

**Use when:** turning plan/PR/session notes into a Comfy-ready still brief.

**How I’d use it:** paste Apply/Verify/Undo notes or a session timeline; ask for
positive + negative prompts aimed at **documentation visuals** (boxes, labels,
cards — not portraits). Then paste into Comfy text nodes.

**Avoid:** using Ornith on the 5090 for coaching while Comfy holds the GPU —
coach on desktop Ollama via this alias.

---

### Lab share (`F:\shares\public\studio`)

**Use when:** landing outputs and reusing seed presets.

**How I’d use it:**

| Path | Role |
| --- | --- |
| `prompts/ops_change_card/` | Positive preset for change-card stills |
| `prompts/agent_storyboard/` | Frame preset for storyboard stills |
| `coaching/r_lab_visual_system.txt` | System text behind `positive-negative-prompt-assist` |
| `images/output/cards/` | Change-card PNG landing zone |
| `images/output/storyboards/` | Storyboard frame landing zone |

Sync with `ansible-playbook playbooks/deploy_lab_studio.yaml`
(`windows_lab_studio` on HVH-01).

---

### Model PVC / catalog (FLUX FP8 + SDXL)

**Use when:** the graph needs weights on the Comfy pod.

**How I’d use it:** leave downloads to `k3s_comfyui_runtime` when present; pick
FLUX FP8 for general still quality, SDXL when you need ControlNet/LoRA
ecosystem nodes. Do not invent new HF IDs in the graph until they are in
`model_catalog`.

---

## E2E Solution 1 — Ops change-card illustrator

**Surface goal:** one illustrated “what changed” card for a plan packet, GitHub
issue, or Ansible write-up.

**How I’d use it end-to-end:**

1. Draft the change in a plan README or PR (Apply / Verify / Undo sketch).
2. In Open WebUI, pick `positive-negative-prompt-assist`. Paste the notes; ask for a **single
   change-card brief** (title, before/after panels, flat icon style).
3. Optionally open `prompts/ops_change_card/r_change_card.txt` on the share and
   merge the coach output with that preset.
4. Flip GPU to ComfyUI; open `comfyui.hom.lab:30188`.
5. Run a **single-still** graph (until packaged JSON exists: load checkpoint →
   text encode → sample → VAE → save). Paste the brief into the positive node.
6. Drop the PNG into `images/output/cards/` and attach it to the plan or issue.

**Good first prompts:** “HVH-01 A1111 present vs absent”, “Phase B on vs off”,
“LiteLLM alias positive-negative-prompt-assist added”.

**Avoid:** video/I2V; multi-frame storyboards (that is E2E 2); burning time on
portrait aesthetics.

Diagram: [diagrams/comfyui-e2e-ops-change-card.svg](diagrams/comfyui-e2e-ops-change-card.svg)

---

## E2E Solution 2 — Agent-run storyboard stills

**Surface goal:** a short **still** timeline of a multi-agent session (planner →
researcher → executor) for demos and retros.

**How I’d use it end-to-end:**

1. Capture a session summary (chat export, plan receipt, or optional Langfuse
   role timeline).
2. In Open WebUI with `positive-negative-prompt-assist`, ask for **N frame prompts** (one per role
   or step), documentation-illustration style, labeled boxes.
3. Merge with `prompts/agent_storyboard/r_frame.txt` if useful.
4. On ComfyUI, generate **one still per frame** (same graph, new seed/prompt each
   time — or a batched graph when packaged).
5. Save to `images/output/storyboards/` and embed in a demo/retro markdown.

**Good first set:** 3 frames — Planner / Researcher / Executor — for a real
Ansible plan execute you just finished.

**Avoid:** generating a movie (I2V); treating Langfuse as required (dashed /
optional in the architecture).

Diagram: [diagrams/comfyui-e2e-agent-storyboard.svg](diagrams/comfyui-e2e-agent-storyboard.svg)

---

## Suggested day flow

1. Confirm you actually need Phase B stills (else stay on A1111 Phase A).
2. Flip GPU → ComfyUI; smoke the UI (`/system_stats` or load a tiny graph).
3. Coach on `positive-negative-prompt-assist` (desktop Ollama).
4. Run **one** change-card **or** a 3-frame storyboard — not both in one sitting
   until graphs are packaged.
5. Flip GPU back to Ornith when Cursor needs the 5090.

---

## What not to expect yet

- Packaged ComfyUI workflow JSON under `roles/k3s_comfyui_runtime/files/workflows/`
  is still deferred — you assemble or import graphs manually until that lands.
- This packet is **doc + diagrams**; Ansible apply for Comfy itself is
  `playbooks/deploy_comfyui_runtime.yaml`.
