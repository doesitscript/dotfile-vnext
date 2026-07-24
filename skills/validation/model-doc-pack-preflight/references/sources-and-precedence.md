# Sources and Precedence

1. HRL `models/<slug>/` pack (via global library-first-model-doc-pack lookup)
2. This repo `inventory/group_vars/model_catalog/` for lane selection and storage
3. Role defaults / host_vars for runtime pins
4. Live probes only after docs + inventory alignment

Do not copy full model cards into this repo.
