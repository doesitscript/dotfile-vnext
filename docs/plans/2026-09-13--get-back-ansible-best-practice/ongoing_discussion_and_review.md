# Ongoing discussion and review

Date started: 2026-09-14

Living notes from plan-folder evaluations and follow-up Q&A. Prefer updating
this file over scattering the same clarifications across chat only.

---

## Deferred vs done (evaluation closeout)

After the plan-10 → plan-11 → plan-12 passes, the **commissioned LiteLLM /
client path** was in good shape for closeout. Items labeled **deferred** were
intentionally not built in those passes — not bugs, not “never.”

| Item | Meaning | Do now? |
| --- | --- | --- |
| Real profiles (`ai_profiles`) | Empty `{}` hook reserved; no researcher/chat/executor merge yet | No — OK empty |
| Download boolean / listed ≠ auto-download | Stronger per-weight enable control | Optional when download list grows |
| Wire download to gateway registry | One SSOT invents both LiteLLM backends and HF download candidates | Later — risks auto-download coupling |
| Generic route loop | One loop renders all LiteLLM routes from records | Later — when copy-paste tax hurts |

“Deferred + correct” = leave them for a later milestone; do not half-implement
or claim them complete.

---

## How model downloads work today

**Opt-in by playbook list membership**, not by catalog presence.

| Surface | Means “download HF weights on HVH-01”? |
| --- | --- |
| Row in `model_catalog/manifest.yml` | No |
| LiteLLM `k3s_litellm_gateway_local_backends` / client model ids | No |
| Continue / Cline `ai_cli_commissioned_models` | No |
| Entry in `playbooks/download_5090_models.yaml` → `huggingface_model_weights` | **Yes** (when that playbook runs) |

So many catalog / gateway / client identities can exist while only a short
download shortlist is pulled. That supports evaluating a few weights without
pulling everything.

Ollama-served lanes (desktop / HVH-01 tags) use a different pipeline than this
HF share playbook; listing them in LiteLLM does not run
`download_5090_models.yaml`.

Playbook authority: `playbooks/download_5090_models.yaml`
Role lifecycle (whole list today): `huggingface_model_weights_state: present|absent`
(`roles/huggingface_model_weights`).

---

## What “wire download to gateway registry” is *not*

It does **not** mean: enable a model → automatically download weights “into”
the LiteLLM gateway.

- **Gateway registry** = route/runtime wiring (`api_base`, provider, served name).
- **Download** = pull weight trees onto the model share.

Wiring them later would mean one structured inventory source can generate both
lists so they do not drift — **with** an explicit per-weight download
`present|absent` (or equivalent) so commissioned-for-gateway ≠ must-download.

---

## Generic route loop (copy-paste tax)

Today `roles/k3s_litellm_gateway/tasks/build_helm_values.yml` appends local
routes with explicit per-lane Jinja blocks (chat sampling vs embed vs FIM
notes differ). Adding a lane often means another copied block plus backend /
client-id / validation wiring.

A **generic route loop** would render from a list of route records in one
pass. Deferred until that migration can preserve rendered behavior; explicit
blocks remain acceptable while the commissioned set is small.

---

## Ansible-semantics note for download enable/disable

Prefer role/playbook lifecycle language over ad-hoc `enabled: true` flags when
the repo pattern is already state-based:

- Role-level today: `huggingface_model_weights_state: present|absent` applies
  to the list passed into the role.
- Desired next step (when needed): **per-weight** desired state in inventory
  (e.g. each candidate carries `state: present|absent`, or the playbook
  filters a catalog to `state == present` before calling the role), so
  “listed in catalog” stays distinct from “weights must exist on the share.”

Do not invent a parallel boolean vocabulary if `present|absent` can express
the same control.

---

## Related plan artifacts

- `plan-07_antipattern_audit.md`
- `plan-11_reviewed.md` (under `review_and_refactor_reviewed/` after move)
- `plan-12_evalutation_reviewed.md`
- `plan-04_the_download_pipeline.md` / `plan-05_the_download_pipeline.md`
