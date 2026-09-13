# Walkthrough — implement proposal `02-assessment-and-proposal.md`

**Goal:** Keep `qwen3-coder-30b-a3b`. Fix budgeting (chat overflow) and embed
ownership (one `embed` role). **Do not swap models.**

**Machines in play**

| Surface | Where you are |
| --- | --- |
| **Work laptop** | Continue + Cline clients |
| **Homelab gateway** | LiteLLM on k3s (`litellm.hom.lab`) |
| **Homelab runner** | vLLM on k3s-02 (5090) — already correct |
| **LM Studio (local)** | Optional local OpenAI API on `:1234` — must **not** own `embed` |

---

## THE BIG PICTURE (read this once)

The model cup holds **32,768** tokens total.

```
input prompt  +  reserved answer (maxTokens / max_output)  ≤  32,768
```

Before: ~24,577 + **8,192** = 32,769 → **overflow**.  
After:  ~24,577 + **4,096** = 28,673 → **fits**.

Embeddings are a **separate lane**. Only **one** Continue model may have
`roles: [embed]`. Gateway `nomic-embed-text` wins; LM Studio
`continue-nomic-embed` is turned off in inventory.

---

## SECTION 1 — SHRINK THE CHAT ANSWER RESERVE (8192 → 4096)

### 1A. Durable source of truth (edit in git)

Do this first if you want the fix to survive the next playbook run.

| System | File | What to set |
| --- | --- | --- |
| **Commissioned catalog (all clients)** | `dotfile-vnext/inventory/group_vars/all/ai_cli_apps.yml` | For `id: qwen3-coder-30b-a3b`: `max_output: 4096` (not 8192) |
| **Work laptop Continue** | `dotfile-vnext/exports/work-laptop-ai-tools/host_vars/work-laptop.yaml` | Under `continue_ide_models` → chat entry `qwen3-coder-30b-a3b` → `default_completion_options.maxTokens: 4096` |
| **Work laptop Cline** | same `work-laptop.yaml` | Under `cline_ide_models` → chat entry → `max_output_tokens: 4096`; also `cline_ide_default_max_output_tokens: 4096` |

**Exact chat values (Continue block):**

```yaml
default_completion_options:
  contextLength: 32768
  maxTokens: 4096      # was 8192
  temperature: 0.7
  topP: 0.8
```

**Exact chat values (Cline block):**

```yaml
context_window: 32768
max_output_tokens: 4096   # was 8192
temperature: 0.7
top_p: 0.8
```

Sync packet → sibling if you edit the export packet, then apply on the laptop
(see 1B).

### 1B. Apply on the work laptop (Ansible)

**Surface:** terminal on work Mac, `work-laptop-ai-tools` checkout.

```bash
cd ~/Documents/develop/work-laptop-ai-tools   # or your sibling path
git pull
.venv/bin/ansible-playbook playbook.yaml -i inventory.yaml --skip-tags hosts_file
```

This re-renders:

| Rendered file | Role |
| --- | --- |
| `~/.continue/config.yaml` | Continue |
| `~/.cline/data/settings/models.json` | Cline model catalog |
| `~/.cline/data/settings/providers.json` | Cline LiteLLM provider |

**Reload:** quit and reopen VS Code / Continue / Cline extension host after apply.

### 1C. Verify in Continue (UI — spot-check)

**Go to:** VS Code → Continue sidebar → **Settings** (gear) → **Models**.

1. Select **Chat Qwen3-Coder-30B-A3B (5090 vLLM)** (or your chat model using `qwen3-coder-30b-a3b`).
2. Confirm **Context length** = `32768`.
3. Confirm **Max tokens** (output) = **`4096`** — not 8192.

If the UI still shows 8192 after playbook, something overwrote or you are
looking at a different model entry.

### 1D. Verify in Cline (UI — spot-check)

**Go to:** Cline extension → **Settings** → **OpenAI Compatible** (LiteLLM) →
model **qwen3-coder-30b-a3b**.

1. **Context Window Size** = `32768`
2. **Max Output Tokens** = **`4096`**

(Cline UI labels vary; the rendered truth is `~/.cline/data/settings/models.json`.)

---

## SECTION 2 — ONE EMBED OWNER ONLY (gateway yes, LM Studio no)

This is the fix for “two teachers” — **not** doubled embedding size, but two
models both advertising `roles: [embed]`.

### 2A. Durable source of truth (edit in git)

**Surface:** `dotfile-vnext/exports/work-laptop-ai-tools/host_vars/work-laptop.yaml`

**KEEP — gateway embed (sole active owner):**

```yaml
continue_ide_models:
  - name: "nomic-embed-text"
    model: "nomic-embed-text"
    roles:
      - embed
```

This uses Continue’s default LiteLLM `apiBase` (`http://litellm.hom.lab`) and
routes to homelab Ollama `nomic-embed-text` via the gateway.

**DISABLE — LM Studio local embed:**

```yaml
continue_ide_local_models:
  - name: "Nomic Embed Text (LM Studio Embeddings)"
    provider: "openai"
    api_base: "http://127.0.0.1:1234/v1"
    api_key: "lm-studio"
    model: "continue-nomic-embed"
    enabled: false          # ← THE FIX (was true or hand-commented)
    roles:
      - embed
```

With `enabled: false`, Ansible **does not render** this block into
`~/.continue/config.yaml` at all.

**Cline embed catalog (keep, no LM Studio duplicate):**

```yaml
cline_ide_models:
  - name: "nomic-embed-text"
    model: "nomic-embed-text"
    roles:
      - embed
    context_window: 8192
    max_output_tokens: 1
```

Cline has no parallel `continue_ide_local_models` path in this packet — the
LM Studio duplicate was a **Continue-only** inventory problem.

### 2B. LM Studio app (optional local hygiene)

**Go to:** LM Studio desktop app on work laptop.

You do **not** need LM Studio running for `@Codebase` / Continue indexing when
gateway embed is active. Optional hygiene:

- Do **not** load/serve a `continue-nomic-embed` (or other nomic) model on
  `:1234` for Continue unless you are deliberately re-testing local embed.
- If LM Studio is idle, leave it stopped — Continue will not call `:1234` once
  the inventory entry is `enabled: false`.

### 2C. Apply + verify embed (work laptop)

Re-run the playbook from **Section 1B**, then:

**File check (Continue):**

```bash
grep -A6 'roles:' ~/.continue/config.yaml | grep -B5 embed
```

**Expect:**

- One model with `embed`: **`nomic-embed-text`** via LiteLLM base URL.
- **No** `continue-nomic-embed`, **no** `127.0.0.1:1234` embed block.

**Functional check:**

1. Open Continue → use **@Codebase** or re-index a small folder.
2. Confirm requests go to **`nomic-embed-text`** on the gateway (network tab or
   LiteLLM logs on homelab), not LM Studio.

---

## SECTION 3 — LITELLM GATEWAY BUDGETS + SAMPLING (homelab)

Clients send chat to **`qwen3-coder-30b-a3b`** on LiteLLM. Gateway should
advertise the same cup math and HF-aligned repetition penalty.

### 3A. Durable source of truth (edit in git)

**Surface:** `dotfile-vnext/roles/k3s_litellm_gateway/defaults/main.yml`

| Variable | Value |
| --- | --- |
| `k3s_litellm_gateway_primary_vllm_repetition_penalty` | **`1.05`** (was 1.0) |
| `k3s_litellm_gateway_primary_vllm_temperature` | `0.7` |
| `k3s_litellm_gateway_primary_vllm_top_p` | `0.8` |
| `k3s_litellm_gateway_primary_vllm_top_k` | `20` |

**Surface:** `dotfile-vnext/roles/k3s_litellm_gateway/tasks/build_helm_values.yml`
(rendered into Helm values for route `qwen3-coder-30b-a3b`)

| `model_info` key | Value |
| --- | --- |
| `max_tokens` | `32768` |
| `max_input_tokens` | **`28672`** |
| `max_output_tokens` | **`4096`** |

(`28672 + 4096 = 32768` — explicit gateway-side budget teaching.)

Embed route (already wired on k3s-02):

**Surface:** `dotfile-vnext/inventory/host_vars/hom-lab-ctl-k3s-02.yaml`

- `k3s_litellm_gateway_nomic_embed_model: "nomic-embed-text"`

### 3B. Apply on homelab (Ansible controller)

**Surface:** machine with `bin/codex-env` + repo checkout.

```bash
cd ~/develop/dotfile-vnext
bin/codex-env ansible-playbook playbooks/deploy_litellm_gateway.yaml \
  -i inventory/inventory.yaml --limit hom-lab-ctl-k3s-02
```

(Use your normal gateway deploy path if this playbook is wrapped elsewhere.)

### 3C. Verify LiteLLM

**Surface:** browser or curl against gateway.

```bash
curl -s http://litellm.hom.lab/v1/models | jq '.data[] | select(.id=="qwen3-coder-30b-a3b")'
```

Confirm the route is listed and chat completions succeed without
`ContextWindowExceededError` on a heavy prompt (same session that failed before).

Optional: inspect deployed Helm values / LiteLLM config map on k3s for
`repetition_penalty: 1.05` and `model_info.max_output_tokens: 4096`.

---

## SECTION 4 — DO NOT CHANGE (vLLM runner is already correct)

**Surface:** k3s-02 vLLM (`hom-lab-ctl-k3s-02` / `vllm-primary`)

Leave these as-is for this fix:

| Setting | Value |
| --- | --- |
| Model | `cyankiwi/Qwen3-Coder-30B-A3B-Instruct-AWQ-4bit` |
| `max-model-len` | `32768` |
| Tools | `--enable-auto-tool-choice` + `--tool-call-parser qwen3_coder` |
| Client id | `qwen3-coder-30b-a3b` |

No vLLM restart required for the client-budget / embed-inventory fix alone.

---

## SECTION 5 — OPTIONAL LATER (bigger cup)

Only after a **VRAM / kv-cache probe** on the 5090:

- Raise vLLM `--max-model-len` above 32768
- Reconcile LiteLLM `model_info` and client `contextLength` to match

Out of scope for the inbox fix documented here.

---

## SECTION 6 — QUICK CHECKLIST

| # | Proposal item | Surface | Value |
| --- | --- | --- | --- |
| 1 | Chat max output | Continue `work-laptop.yaml` + rendered `~/.continue/config.yaml` | `maxTokens: **4096**` |
| 2 | Chat max output | Cline `work-laptop.yaml` + `models.json` | `max_output_tokens: **4096**` |
| 3 | Chat max output | `ai_cli_apps.yml` | `max_output: **4096**` for `qwen3-coder-30b-a3b` |
| 4 | Sole embed | `work-laptop.yaml` `continue_ide_models` | `nomic-embed-text` + `roles: [embed]` |
| 5 | Disable LM Studio embed | `work-laptop.yaml` `continue_ide_local_models` | `enabled: **false**` on `continue-nomic-embed` |
| 6 | LiteLLM rep penalty | `k3s_litellm_gateway/defaults/main.yml` | `repetition_penalty: **1.05**` |
| 7 | LiteLLM budgets | Helm values for route | `max_input_tokens: **28672**`, `max_output_tokens: **4096**` |
| 8 | Keep model | everywhere | **`qwen3-coder-30b-a3b`** — no swap |

---

## Related artifacts

- Assessment: `02-assessment-and-proposal.md`
- Before/after values: `01-actors-retro-capture.yml`
- Pictures: `diagrams/before.md`, `diagrams/after.md`, `diagrams/metaphor/`
