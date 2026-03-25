# myllynen Collection Cleanup

## Issue Found
Project has both:
1. **Unused collection reference** in `requirements.yml` (lines 30-32)
2. **Vendored copy** in `collections/ansible_collections/myllynen/`
3. **Adapted code** in `roles/access_identity_windows/tasks/ubuntu.yml`

## Current State
- `requirements.yml` declares myllynen collection but we don't use it
- We copied/adapted myllynen code into our own roles instead
- Vendored copy exists but is unused (Ansible prefers local over installed)

## Solution: Option 1 Modified
1. Remove unused collection from `requirements.yml` 
2. Remove vendored copy from `collections/`
3. Keep our adapted code in `access_identity_windows` (already customized)
4. Update comments to reflect we're using adapted code, not the collection

## Files Changed
- `requirements.yml` — remove lines 30-32
- `collections/ansible_collections/myllynen/` — delete directory
- `roles/access_identity_windows/tasks/ubuntu.yml` — update comment to clarify

## Result
Cleaner dependency management. Only declare collections we actually use via FQCN.