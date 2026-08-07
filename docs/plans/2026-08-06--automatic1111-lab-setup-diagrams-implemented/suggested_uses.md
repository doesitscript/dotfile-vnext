# Suggested uses — Automatic1111 lab E2E solutions

How I’d use each **usable surface** this packet documents. Entry points:
Open WebUI Images + A1111 at `http://a1111-hvh01.hom.lab:7860`, optional
`positive-negative-prompt-assist` for briefs, lab share for presets/outputs.

Diagrams: [`diagrams/`](diagrams/). Sibling chat routes:
[`../2026-08-06--open-webui-litellm-model-route-diagrams-implemented/suggested_uses.md`](../2026-08-06--open-webui-litellm-model-route-diagrams-implemented/suggested_uses.md).
Sibling Phase B stills:
[`../2026-08-06--comfyui-lab-setup-diagrams-implemented/`](../2026-08-06--comfyui-lab-setup-diagrams-implemented/).

**Prerequisite:** `windows_automatic1111_state: present` on HVH-01; Open WebUI
Images pointed at A1111. No GPU flip needed (independent of k3s-02 Ornith).

---

## Shared surfaces (use with both E2E solutions)

### Open WebUI chat + `positive-negative-prompt-assist`

**Use when:** turning runbook / NetBox / plan notes into a still brief.

**How I’d use it:** pick `positive-negative-prompt-assist` in Open WebUI; attach an optional sketch;
ask for positive + negative prompts for a **documentation still** (topology,
badge, UI mock). Paste into Images or into A1111’s prompt boxes.

**Avoid:** using it as a general chat model — use `gemma4-12b` / `default` for
that (see Open WebUI suggested uses).

---

### Open WebUI Images button

**Use when:** fastest path from brief → PNG without opening A1111’s full UI.

**How I’d use it:** after `positive-negative-prompt-assist`, open Images, paste the prompt, generate
on HVH-01 CyberRealistic. Good for E2E 1 (lab-doc still). Weak for ControlNet
knobs — switch to direct A1111 UI for E2E 2.

---

### Automatic1111 Web UI (`a1111-hvh01.hom.lab:7860`)

**Use when:** you need denoise, img2img, or ControlNet OpenPose / softedge.

**How I’d use it:** open the Gradio UI for E2E 2; keep `/sdapi` for Open WebUI
Images. After boot, confirm CyberRealistic is the active checkpoint.

Diagram: [diagrams/automatic1111-lab-architecture.svg](diagrams/automatic1111-lab-architecture.svg)

---

### Lab share (`F:\shares\public\studio`)

**Use when:** presets and landing outputs.

| Path | Role |
| --- | --- |
| `prompts/lab_doc_still/` | Topology / badge still presets |
| `prompts/controlnet_mock/` | UI mock presets + negatives |
| `examples/lab_doc_still_example.txt` | Paste-ready first still |
| `coaching/r_lab_visual_system.txt` | Coach system text |
| `images/output/lab_doc/` | Lab-doc PNG landing zone |
| `images/output/mocks/` | ControlNet mock landing zone |

Sync: `ansible-playbook playbooks/deploy_lab_studio.yaml`
(`windows_lab_studio` on HVH-01).

---

### CyberRealistic V9 FP16 + ControlNet OpenPose

**Use when:** SD1.5 stills that fit GTX 1060 `--medvram`.

**How I’d use it:** leave CyberRealistic as default for Images; enable ControlNet
OpenPose (or softedge) only in the A1111 UI when locking layout from a
screenshot/wireframe.

---

## E2E Solution 1 — Open WebUI Images lab-doc still

**Surface goal:** a quick documentation vignette for plans, issues, or runbooks.

**How I’d use it end-to-end:**

1. Write 3–5 bullets about the thing to illustrate (hosts, services, before/after).
2. Open WebUI → `positive-negative-prompt-assist` → “produce a lab-doc still prompt; flat diagram
   style; no people.”
3. Optionally merge with `prompts/lab_doc_still/r_topology_vignette.txt` and
   `r_negative.txt`.
4. Open WebUI **Images** → generate via A1111.
5. Save/copy to `images/output/lab_doc/` and embed in the markdown.

**Good first subject:** “k3s-02 + LiteLLM + Open WebUI boxes with arrows.”

**Avoid:** ControlNet deep work here (use E2E 2); expecting FLUX quality on the
1060.

Diagram: [diagrams/automatic1111-e2e-lab-doc-still.svg](diagrams/automatic1111-e2e-lab-doc-still.svg)

---

## E2E Solution 2 — ControlNet reference-locked UI / topology mock

**Surface goal:** polish a screenshot or wireframe while keeping layout locked.

**How I’d use it end-to-end:**

1. Drop a UI screenshot or topology sketch into `images/input/mocks/` (or upload
   in A1111).
2. Optional: `positive-negative-prompt-assist` to polish the positive prompt (“homelab dashboard
   mock, readable panels”).
3. Open A1111 Web UI → **img2img** + ControlNet (OpenPose or softedge) using the
   reference image.
4. Start denoise conservative (~0.35–0.5) so layout holds; raise only if the
   mock stays too photo-identical to the source.
5. Save to `images/output/mocks/` for design review / capacity notes.

**Good first subject:** a real Open WebUI or NetBox screenshot you want
“cleaned” for a slide.

**Avoid:** trying to do this entirely inside Open WebUI Images (ControlNet knobs
are incomplete there); I2V; Phase B Comfy graphs (sibling packet).

Diagram: [diagrams/automatic1111-e2e-controlnet-mock.svg](diagrams/automatic1111-e2e-controlnet-mock.svg)

---

## Suggested day flow

1. Keep A1111 up on HVH-01 for any doc illustration work (no GPU flip).
2. Draft with `positive-negative-prompt-assist`.
3. Prefer **Images → A1111** for simple vignettes (E2E 1).
4. Escalate to **A1111 UI + ControlNet** only when layout lock matters (E2E 2).
5. Use ComfyUI Phase B only when you need FLUX/graph quality (sibling plan).

---

## What not to expect yet

- This packet is **doc + diagrams**; runtime lifecycle is
  `playbooks/deploy_automatic1111.yaml` + `deploy_lab_studio.yaml`.
- Packaged ControlNet “recipes” beyond role defaults may still be manual in the
  Gradio UI.
