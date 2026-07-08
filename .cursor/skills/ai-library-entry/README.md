# AI Library Entry Capability

`ai-library-entry` is the repo-native kickoff for durable additions to
`ai-resource-library`.

It owns routing and validation for mixed entry work across:

- `vendors/`
- `sdk-context/`
- `indexes/`
- `prompts/`

Use `vendor-doc-collection` as the narrower export helper after this capability
has already decided that the entry needs a structured vendor-doc tree.

## Owned files

- `.cursor/skills/ai-library-entry/SKILL.md`
- `.cursor/skills/ai-library-entry/README.md`
- `.cursor/skills/ai-library-entry/capability.yml`
- `.cursor/skills/ai-library-entry/references/routing-matrix.md`
- `.cursor/skills/ai-library-entry/references/entry-spec.template.yml`
- `.cursor/skills/ai-library-entry/references/validate_entry_spec.rb`
- `.cursor/rules/framework-ai-library-entry.mdc`

## Update rule

Update the skill, the validator, the template, and the companion rule together.
The `owned_files` list in `capability.yml` is the update/remove source of
truth.
