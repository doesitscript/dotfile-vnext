---
id: continue-apiBase-no-v1
status: promoted
behavior_group: litellm-client-keys
title: Continue apiBase without /v1; Cline/Zed with /v1
---

## Trigger

- Continue probes `GET {apiBase}`; LiteLLM returns 404 on bare `/v1`.

## Accommodation

- Continue: `http://litellm.hom.lab`
- Cline/Zed: `http://litellm.hom.lab/v1`
- Documented in `work-laptop-ide-clients`.

## Re-apply

- Do not “unify” both to the same URL without vendor evidence.

## Generalize

- New IDE clients: research probe path; add a deviation entry if the URL shape differs.
