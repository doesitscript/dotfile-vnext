# Sources and precedence

1. User goal / CONTEXTS (commission intent)
2. `policy/*.yml` + `classify_host` (capability match)
3. Inventory `*_state` and host facts
4. Product `contracts/<product>.yaml` (pattern guidance)
5. HRL + Context7 + vendor packs (research)
6. Legacy `contracts/fuzlang.contract.yaml` (archive only — do not grow)

Inventory remains runtime SSOT for commission; policy remains SSOT for match vocabulary.
