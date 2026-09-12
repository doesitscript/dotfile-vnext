---
lifecycle: active-wip
maturity: beta
scope: model-rollout-and-client-reconciliation
created_at: '2026-09-11'
---

# WIP — new model set, client reconciliation, and macOS deployment

This is the working index for the model iteration introduced by
`plan.md`. “Implemented” means the repository catalog, weight lifecycle, and
primary runtime references have been wired. It does not by itself mean every
weight tree is downloaded, every candidate is served, or every client has been
probed.

## Model list

The five entries below are chat/agent candidates. They are not FIM-only
checkpoints, so they must not replace Continue's autocomplete lane. Continue
autocomplete remains the separately qualified `qwen2.5-coder-1.5b@hvh01`
route until a dedicated FIM/completion artifact is selected and accepted.

| Rank | Model | Artifact / source | Intended runtime | Current state | Client policy |
| --- | --- | --- | --- | --- | --- |
| 1 | Qwen3-Coder-30B-A3B | `cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit` | vLLM on 5090 | selected primary; download/receipt and live probes must be verified | Continue chat and OpenCode default; later reconcile Cline/Kilo/Aider/Cursor |
| 2 | Qwen3.6-35B-A3B | `nvidia/Qwen3.6-35B-A3B-NVFP4` | sequential vLLM evaluation | cataloged candidate; no concurrent 5090 claim | evaluation lane only until load and E1–E4 evidence |
| 3 | gpt-oss 20B | Ollama `gpt-oss:20b` | Ollama / LiteLLM | catalog/client lane; intentionally outside HF downloader | retain or reconcile through the Ollama/Gateway lane |
| 4 | Devstral Small 2 | bartowski Q4_K_M GGUF | llama.cpp-compatible evaluation | cataloged candidate; not vLLM-pinned | evaluation lane only |
| 5 | GLM-4.6 | Unsloth Q4_K_M GGUF | llama.cpp-compatible evaluation | cataloged candidate; experimental | evaluation lane only; verify license/runtime before promotion |

### Variant and placement decision

The selected artifacts are intentionally retained for chat/agent evaluation:
Qwen3-Coder and Devstral are explicitly Instruct artifacts, while the Qwen3.6
NVFP4 and GLM-4.6 GGUF sources are conversational/chat-oriented. No selected
artifact is a FIM-only model. The canonical HF staging share remains on
`HOM-LAB-HVH-01`; the active vLLM/HF cache is on the K3s-02 guest mounted at
`/mnt/k3s-cache/hf/hub`, backed by the storage expansion on `HOM-LAB-HVH-02`.
This is a staging-versus-serving distinction, not a proven need to migrate
the Windows share. A relocation pass must first identify the exact Windows
share consumer and copy/rollback authority.

## Updates made in this slice

- `inventory/group_vars/model_catalog/manifest.yml` records the five-model
  disposition and bounded storage/runtime metadata.
- `playbooks/download_5090_models.yaml`,
  `roles/huggingface_model_weights/`, `roles/huggingface_hub/`, and
  `scripts/download_hf_model.py` provide the foreground, resumable HF weight
  lifecycle for the four HF candidates. The Ollama model is excluded by
  design.
- `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` and the LiteLLM model-client
  IDs point the primary vLLM identity at Qwen3-Coder.
- `inventory/group_vars/continue_ide_hosts/main.yml` and
  `roles/continue_ide/defaults/main.yml` no longer describe Qwen3 as a
  rejected/pending primary candidate.
- `roles/opencode_cli/defaults/main.yml` and
  `inventory/host_vars/mac-dev.yaml` now default OpenCode on this Mac to the
  Qwen3 primary alias.
- Client acceptance sources now map Continue chat, Codex `deep`/`tools`, and
  OpenCode's model picker to the Qwen3 primary; the remaining four candidates
  are represented as pending evaluation entries; OpenCode keeps those picker
  entries disabled until their gateway routes are published.
- Stale default contracts for the local primary, agent profiles, inference
  contract validator, recovery probe text, and generated Codex catalog now
  use the Qwen3 canonical lane. Historical approved manifests are preserved.

The first Mac deployment exposed two Continue-specific source defects. First,
the managed OpenAI-compatible `apiBase` omitted `/v1`. Second, the configured
friendly `~coder-primary` model suffix was not present in the live gateway’s
model list. Continue 2.0 accepted the YAML but could not populate usable
models. The role now uses `http://litellm.hom.lab/v1` and the canonical served
ID `qwen3-coder-30b-a3b@k3s02-vllm`.

## Identified update register

### Update now / in the current implementation packet

| Resource | Required action |
| --- | --- |
| `inventory/group_vars/model_catalog/manifest.yml` | SSOT for candidate identity, quant, storage host, runtime, evidence state, and disposition. |
| `playbooks/download_5090_models.yaml` | Use the bounded HVH-01 staging target and the lifecycle role; keep downloads foreground and explicit. Do not treat this Instruct/chat set as Continue FIM. |
| `roles/huggingface_model_weights/` | Own per-lane directories, resumable helper execution, completion receipts, and absence behavior. |
| `roles/huggingface_hub/` | Own the Hub client prerequisite used by the downloader. |
| `scripts/download_hf_model.py` | Keep the staged helper resumable, pattern-bounded, and receipt-producing. |
| `inventory/host_vars/hom-lab-ctl-k3s-02.yaml` | Keep the vLLM model, served identity, parser, and gateway primary coherent. |
| `roles/k3s_vllm_runtime/` and `playbooks/deploy_vllm_runtime.yaml` | Apply and verify the Qwen3 runtime separately from weight download; do not imply candidate promotion. |
| `roles/k3s_litellm_gateway/`, including `defaults/main/model_client_ids.yml`, and `playbooks/deploy_litellm_gateway.yaml` | Reconcile aliases/routes only after the served model identity is proven. |
| `inventory/group_vars/continue_ide_hosts/main.yml` | Keep the research matrix and role lanes aligned with the new Qwen3 primary. |
| `roles/continue_ide/` and `playbooks/deploy_continue_ide.yaml` | Render the updated primary chat lane to macOS; retain desktop 7B for edit/apply and small local autocomplete where configured. |
| `roles/opencode_cli/` and `playbooks/deploy_opencode_cli.yaml` | Render the new Qwen3 default and picker entry to macOS. |
| `inventory/host_vars/mac-dev.yaml` | Host-specific client defaults; this slice changes OpenCode to the Qwen3 primary. |
| `playbooks/deploy_development_nodes.yaml` | Broad deployment entrypoint; use its scoped Continue/OpenCode tags or the two targeted playbooks for this Mac. |

### Validate later / update only with evidence

| Resource | Required action |
| --- | --- |
| `roles/cline_ide/`, `roles/kilo_ide/`, `roles/aider/`, `roles/zed_ide/` | Reconcile defaults and picker entries to Qwen3 where the corresponding client is enabled on the target host. Do not enable absent clients merely because a model exists. |
| `roles/cursor/` and Cursor MCP post-tasks | Verify Cursor’s effective model/provider surface separately; MCP wiring is not model-serving evidence. |
| `exports/work-laptop-ai-tools/host_vars/work-laptop.yaml` and `exports/work-laptop-ai-tools/playbook.yaml` | Preserve as the work-laptop source packet; port only intentionally shared model changes after checking host-specific policy. |
| `inventory/group_vars/all/ai_agent_profiles.yml` | Replace historical Qwen2.5 defaults only after deciding whether agent-role routing should follow the new primary. |
| `model-lane-acceptance/client-map.yml`, `codex/profile-map.yml`, and `codex/pending/tool-loop.yml` | Keep client lanes aligned to Qwen3; leave Codex tools and Continue chat pending until fresh behavioral receipts pass. |
| `playbooks/validate_homelab_local_clients_probes.yaml` and `playbooks/validate_kilo_litellm_probes.yaml` | Probe effective client configuration and route behavior after deployment. |
| `playbooks/validate_ai_inference_stack_contracts.yaml` | Update expected model identity and run fresh gateway/runtime checks. |
| `docs/plans/2026-09-10--validations-agent-lane-fitness/` and its lite-eval runner | Run E1–E4 against Qwen3 and retain the Qwen2.5 result as the baseline; do not overwrite historical evidence. |
| `docs/plans/2026-09-01--homelab-local-ai-clients-cursor-kilo/README.md` and `model-rollout-agent-handoff-2026-09-11.md` | Reconcile the plan narrative and handoff after fresh serving/client evidence. |
| `docs/plans/2026-09-10--k3s-02-storage-upgrade/` | Append only factual storage/download/runtime receipts; keep the remediation history intact. |
| `roles/k3s_vllm_runtime/`, LiteLLM, and candidate GGUF runtime support | Evaluate Qwen3.6, Devstral, and GLM sequentially; no simultaneous 5090 deployment without a new capacity proof. |

### Storage relocation pass

No relocation is applied in this slice. Current evidence shows the serving
cache already uses the expanded K3s-02 guest storage on HVH-02, while the HF
Windows share on HVH-01 is a canonical staging/download target. Before moving
that share, add a separate apply packet covering the exact SMB consumer,
available capacity, ACLs, model-directory receipts, and rollback. The existing
`qwen2.5-coder-14b@k3s02-vllm` entry is now an empty retired row; it must not
be downloaded, promoted, moved, or assigned to Kilo merely because the cache
has headroom.

### Legacy-lane retirement pass — 2026-09-12

- The `qwen2.5-coder-14b@k3s02-vllm` catalog row is retained only as an empty
  `retired` identity; it has no artifact, runtime, storage host, or source
  routing and must not be downloaded or served.
- Kilo is no longer an active client owner. Kilo compatibility IDs are empty,
  Kilo was removed from the active gateway contract/client map, and recovery
  plus inference-contract validation now use Continue-owned IDs.
- The current `cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit` runtime remains
  present in host vars only as the existing live deployment selection. It is
  also an Instruct artifact. Replacing or blanking it requires selecting a
  concrete non-Instruct/base/FIM runtime first; an empty value would make the
  vLLM deployment and gateway route invalid. No live runtime change was made.

### Historical reference only / do not rewrite as current evidence

| Resource | Reason |
| --- | --- |
| Older Continue/OpenCode evaluation plans and archived lite-eval results | They document Qwen2.5 baselines and must remain reproducible historical comparisons. |
| `docs/plans/2026-09-01--homelab-model-lane-atdd-coordination/` examples and receipts | Earlier selection/approval evidence; supersede with a new receipt rather than editing history. |
| Diagram/source artifacts for existing `gpt-oss-20b` Open WebUI routes | Still valid for the Ollama lane unless that lane is deliberately changed. |

## Deployment sequence for this Mac

Target: inventory host `mac-dev` only. Do not run the Windows HF downloader as
part of this client deployment.

1. Run inventory and task previews for `mac-dev`.
2. Apply `playbooks/deploy_continue_ide.yaml` and
   `playbooks/deploy_opencode_cli.yaml` with `--limit mac-dev`.
3. Verify the rendered Continue config, OpenCode config, selected model IDs,
   gateway reachability, and Ansible second-run idempotence.
4. Run client/gateway probes and Qwen3 E1–E4 before changing Cline, Kilo,
   Aider, Zed, or Cursor defaults.

The intended scoped commands are:

```text
bin/codex-env ansible-playbook playbooks/deploy_continue_ide.yaml -i inventory/inventory.yaml --limit mac-dev
bin/codex-env ansible-playbook playbooks/deploy_opencode_cli.yaml -i inventory/inventory.yaml --limit mac-dev
```

Rollback is a config-only re-converge to the previous explicit model alias,
followed by the same two playbooks and a fresh client probe. Weight deletion
is a separate explicit `state=absent` operation and is not part of macOS
deployment.

## Working receipt

| Check | Status | Evidence |
| --- | --- | --- |
| Repository syntax and Python compile | passed previously | downloader playbook syntax/list-hosts and helper `py_compile` |
| New model catalog/weight owner | implemented | `plan.md`, `manifest.yml`, `roles/huggingface_model_weights/` |
| macOS client config edits | implemented in worktree | Continue matrix, OpenCode defaults, `mac-dev` override |
| Live macOS deployment | passed for scoped clients | `deploy_continue_ide.yaml`: `ok=11 changed=1 failed=0`; `deploy_opencode_cli.yaml`: `ok=18 changed=1 failed=0` |
| Effective client/gateway probes | pending | retain raw output under this plan folder |
| Qwen3 download receipt | pending separate HVH-01 apply | do not infer from catalog or runtime reference |

## Shared-skill qualification receipt — 2026-09-11

Command:

```text
./model-lane-acceptance/scripts/run-model-iteration-acceptance.sh -m infrastructure -v -s
```

The pending matrix loaded all five candidates and the shared
`homelab-litellm-model-lane-pytest` skill ran the exact publication check.
Result: **1/5 published**.

- PASS: `qwen3-coder-30b-a3b@k3s02-vllm`
- FAIL / not currently published: `qwen3.6-35b-a3b@k3s02-vllm`
- FAIL / not currently published: `gpt-oss-20b`
- FAIL / not currently published: `devstral-small-2@k3s02-llama-cpp`
- FAIL / not currently published: `glm-4.6@k3s02-llama-cpp`

This is an availability failure, not a model-quality verdict. The four
non-published candidates need their runtime/gateway publication paths
implemented before their chat/tool receipts can be exercised. The pending
matrix must remain pending until those exact routes are live and their human
receipts are collected.

## Post-recovery Qwen3 behavioral receipt — 2026-09-11

The governed AI inference recovery path re-converged vLLM and LiteLLM after
the stale backend mapping was found. The candidate matrix was then rerun for
Qwen3-Coder only:

| Journey | Result | Evidence |
| --- | --- | --- |
| Publication | PASS | Exact canonical ID present in `GET /v1/models`, HTTP 200 |
| Smoke ping/pong | PASS | Exact `pong`, HTTP 200 |
| Code explanation | PASS | Response identified the sum, HTTP 200 |
| Tool invoke | FAIL | HTTP 200, `finish_reason=stop`, no `tool_calls` |

Qwen3 is therefore available for chat but not yet qualified for the declared
tool-use lane. The tool expectation remains unchanged; parser/tool behavior
must be repaired or separately explained with fresh runtime evidence. This
does not establish Continue Agent fitness.

## macOS deployment receipt — 2026-09-11

Target was `mac-dev` only. The first OpenCode attempt found and fixed a
standalone-playbook variable contract defect (`dotfiles_home` was not set
before the role’s vault lookup). The rerun succeeded.

- Continue: rendered `/Users/joshc/.continue/config.yaml`; six model entries,
  one MCP server, resolved LiteLLM key; first run `changed=1`, second run
  `changed=0`.
- OpenCode: rendered `/Users/joshc/.config/opencode/opencode.jsonc`; default
  is `homelab-litellm/qwen3-coder-30b-a3b@k3s02-vllm`; binary
  probe reported `1.18.26`; first run `changed=1`, second run `changed=0`.
- Read-only remote inspection confirmed the Qwen3 primary in both effective
  configs. Existing Qwen2.5 desktop entries remain as intentional fallback
  lanes.
- Root cause fixed in source: Continue `apiBase` includes `/v1` and the
  configured Qwen3 ID is present in the authenticated `/v1/models` response;
  Continue UI refresh remains the final interactive check.
- No model weights were downloaded or deleted by the macOS deployment. The
  HF download receipt remains pending on the explicit `HOM-LAB-HVH-01`
  storage operation.

## Client reconciliation receipt — 2026-09-12

Source validation passed for the targeted Continue, OpenCode, and vLLM
playbooks; the downloader helper also compiled successfully. The shared
gateway availability suite was rerun against the pending five-model matrix:
Qwen3-Coder passed publication, while Qwen3.6, gpt-oss, Devstral, and GLM
remain unpublished and therefore failed the publication gate. This is an
implementation/publication gap, not a quality pass.

The Mac was re-converged after the source edits. Continue reported ten
rendered models (the four unpublished candidates remain source-declared but
disabled), and OpenCode reported the Qwen3 primary as its default. Both
deployments completed with `failed=0`; no Windows share or model weights were
mutated by this client deployment.

The Qwen3 tool-loop failure remains open: the gateway returned HTTP 200 with
`finish_reason=stop` and no `tool_calls`. Codex `deep` and `tools` therefore
point at the selected Qwen3 lane but remain pending rather than approved.
