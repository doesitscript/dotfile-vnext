# Lab ComfyUI — k3s-02 Phase B — instructions

## Artifacts
- script: `comfyui-lab-architecture.py`
- image: `comfyui-lab-architecture.svg` (also `.png`, `.dot`)
- stem: `comfyui-lab-architecture`

## Modification notes
- Shows Phase B **on**: ComfyUI deployment holds the 5090; Ornith shown dashed as absent.
- LAN publish port `30188` matches `hom-lab-hvh-02` publish map / `comfyui.hom.lab`.
- If publish moves behind Traefik ingress only, rename the Ing node accordingly.
- Flip detail lives in `docs/reference/k3s-02-gpu-timeshare-phase-b.md` (optional separate flip diagram).

## Re-render
- docker: `~/.codex/skills/create-diagrams/scripts/render_with_docker.sh comfyui-lab-architecture.py .`
- mode: docker (no local `diagrams` / `dot`)
