'Why It's Only Slow at Pod Startup (Then Fast Forever)
At pod startup: vLLM reads the entire 19 GB model from disk into GPU VRAM. This is a one-time sequential read of the full safetensors file:

NVMe (D:): ~5 seconds
USB 3.0 write speed (F:): ~9 minutes at 36 MB/s'<-- We're looking at doing this and it may already be implemented. Go ahead and implement it it's OK if it's already been implemented is what I'm trying to say.>


## VERIFCATION ###
'So three things follow: nothing rejected your 120Gi + 200Gi claims on an 80 GB disk (both went Bound instantly), nothing stops a pod from filling the whole root filesystem, and when it does fill, the damage hits kubelet, containerd, and every other pod — not just the greedy one.

'<-- I assume we are now corrected on this situation that we have averted the situation or storage can get out of control and affect the coolant container D etc..>

' and that pod has cycled four times in the past eight days.'<-- Have we addressed why this pod restarted a times?>

#Explain:
On growing it: the VHDX is a Fixed 80 GB disk at D:\ProgramData\Ansible\hyperv_ubuntu_vm\hom-lab-ctl-k3s-02\, and D: only has 69 GB free <---I don't quite understand this is there not something we can do with the VHDX?>

'
<!-- Explain -->
'the 85/80/2m defaults are from reference documentation<-- what is this?
###

 F:\shares\public\models\huggingface on HVH-01 — your declared model catalog SSOT — is a spinning SATA HDD (Toshiba MK1059GSM). Your model storage root is the slowest media in the lab.

Q:'Which storage path for the model weights?

'
Option C & THe following: 'The GPU is full. nvidia-smi reports 32,607 MiB total with 30,202 MiB in use and 1,986 MiB free — the running 32B AWQ model has it. So downloading several big models is fine; serving them concurrently is not. On a single 5090 a 32B AWQ 4-bit (~19 GB) fits and a 70B AWQ 4-bit (~40 GB) does not, at any disk size.'<-- i'm thiking of unloading these and moving them to "cold storage" Is there a way that we could create a experimental folder on the USB device and that's our cold storage and it's our experimental folder two for models, I can store them on there when I'm not planning on using them right away and maybe I can import them into the faster storage when I'm planning on evaluating them. I have a list of models that I don't think are currently in a list of models that you just showed me. So I feel like it's safe to move these off and unload them from the GPU.>'

q: 'What are you downloading? (sizes drive the disk math and whether they can co-reside on the 5090)

'
No I'm not planning on running all decent ones. And this is gonna be more of a evaluation of each over time, but this is a reaquest to get them downloaded and setup in our infrastructure and project, and to make teh first entry, the replacement to the current primary model on the 5090. the first model is also what will be replacing the continue extension first model entry, replaced the old first entry: 'Rank Model Why for your stack 5090 fit 1 Qwen3-Coder-30B-A3B MoE (30B total/~3B active) — this is the current consensus pick for agentic coding on a single consumer card. Strong tool-calling, and the low active-param count keeps it fast enough to not fight your Continue/Cursor loop Q4_K_M ~18GB, Q5_K_M ~22GB, ~100-170 tok/s 2 Qwen3.6-35B-A3B (or 27B dense) Your generalist/architecture-discussion model. The A3B MoE variant runs ~145 tok/s at Q6 on a 5090 with room for long context — useful for the "explain this Terraform module" side of your workflow, separate from raw code edits Q6 ~28GB 3 gpt-oss-20b Agreed with the other list here. Small footprint (21B total/3.6B active) means you can colocate it alongside your coder model in the same 32GB budget rather than swapping models — genuinely useful given your LiteLLM routing setup Q8 fits easily, leaves headroom to run two models at once 4 Devstral Small 2 Agent-specialist, dense 24B. I'd rank this above GLM-4.5-Air for your use case specifically because it's purpose-built for repo-navigation/tool-use agent loops — closer to what your Continue Agent evals are actually testing Fits at Q4, ~24GB 5 GLM-4.6-Air (not 4.5) I'd swap this in over GLM-4.5-Air. 4.5-Air's unquantized footprint (~221GB) makes it a genuine science project on one card even with offloading. GLM-4.6-Air has usable Q4_K_M quants that actually fit in 32GB with room for context, so you get the "heavier, more capable" experimental lane without wrecking your GPU lane's usability Q4_K_M fits in 32GB'
