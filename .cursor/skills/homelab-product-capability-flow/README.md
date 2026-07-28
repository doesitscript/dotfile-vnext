# Skill: Homelab Product Capability Flow

Orchestrates library research → plan → Ansible `present|absent` → apply →
optional NetBox for products like Open WebUI.

**Mental model:** policy defines match vocabulary; inventory holds thin host
facts + commission flags; `classify_host` derives roles at runtime.

See `SKILL.md` and `references/`.
