# Plan: Build `control_tower_operational` and `control_tower_combined`

## Summary

Create two new AWS AFT documentation packs under `vendors/aws/`:

- `control_tower_operational/` for normalized OneNote-exported operational content
- `control_tower_combined/` for section-based synthesis that merges:
  - the operational pack
  - the existing AWS docs pack in `control_tower/`

This work must use the repo's pack conventions, create explicit repo-local index artifacts, and require live Context7 access during implementation. If Context7 tools are not callable in the implementation session, stop and treat that as a blocker rather than degrading the workflow.

## Key Changes

- Build `control_tower_operational/` with:
  - `README.md`
  - `metadata.json`
  - `page-index.json`
  - one normalized markdown file per operational page
  - one separate markdown file for the top-level AFT overview/architecture/components content from the combined export
- Extract operational pages from `original_page_content_combined.md` by matching titles from `original_page_titles.png` against the embedded page titles in the export.
- Treat notebook hierarchy explicitly in `page-index.json`:
  - real pages become output files
  - container-only labels such as `Runbook / FAQ` are recorded as grouping metadata, not required output pages
  - any truncated screenshot labels are resolved to the closest exact title found in the combined export and documented in the index
- Operational output set must include:
  - top-level AFT overview/architecture/components page
  - `Draft: Change enablement`
  - `AWS Account Decommissioning Procedure`
  - `Vend an AWS Account`
  - `Add an OU (Organization Unit)`
  - `DRAFT: Cleanup and Retrigger a Failed Account Request`
  - `DRAFT: Apply AFT Account: Global Terraform at Scale`
  - `DRAFT: AFT Lambda upgrade release analysis`
  - `DRAFT: AFT Lambda Vulnerability Remediation`
  - `DRAFT: Remediation of Default VPCs in non-governed regions (VPC Flow Logs)`
- Normalize page files for AI use:
  - preserve commands, URLs, and operational meaning
  - remove export noise only where it is clearly formatting junk
  - add provenance headers
  - annotate malformed export regions, especially table-wrapped or comment-wrapped content
- Build `control_tower_combined/` with:
  - `README.md`
  - `metadata.json`
  - `section-index.json`
  - one markdown file per target section from `sections.png`, excluding `Key Contacts` and `CMDB Application Service CIs Created`
- Combined section set:
  - `Overview`
  - `Update Process`
  - `Architecture`
  - `Runbook / Playbook`
  - `Security`
  - `Disaster Recovery / Multi-region Concerns`
  - `Monitoring and Alerting`
  - `Costs`
- Every combined section file must use the same internal structure:
  - short section summary
  - Bread-specific operational guidance
  - AWS vendor guidance from `control_tower/`
  - source map listing contributing operational pages and AWS doc files
  - gaps / open questions
- Sparse sections must still be created. If source coverage is thin, the file should say so explicitly instead of being omitted or padded with guesses.
- Context7 usage during implementation is mandatory:
  - resolve/query the relevant AWS Control Tower documentation surface
  - use it to validate terminology and current topic coverage for the combined sections
  - record library ID, queried topics, and purpose in README/metadata
  - do not treat existing repo evidence as a substitute if Context7 is unavailable

## Public Interfaces / Artifacts

Create these repo-visible artifacts:

- `control_tower_operational/README.md`
- `control_tower_operational/metadata.json`
- `control_tower_operational/page-index.json`
- `control_tower_operational/*.md`
- `control_tower_combined/README.md`
- `control_tower_combined/metadata.json`
- `control_tower_combined/section-index.json`
- `control_tower_combined/*.md`

Index files should minimally record:

- title or section name
- output file path
- source file path(s)
- matched source title(s) or AWS doc slug(s)
- grouping label when applicable
- notes, gaps, and Context7 references where applicable

## Test Plan

- Verify every real page title from the screenshot-backed notebook list is mapped once, and every container-only label is marked as non-page hierarchy metadata in `page-index.json`.
- Verify the top-level overview/architecture/components content is captured separately and not lost inside comment-page extraction.
- Verify all index entries point only to files that exist.
- Verify all eight combined section files exist, including sparse sections such as DR and monitoring.
- Verify each combined section includes all required subsections: summary, Bread guidance, AWS guidance, source map, and gaps.
- Verify each combined section cites at least one real source and explicitly states when coverage is one-sided or incomplete.
- Verify README/metadata provenance includes the OneNote export inputs, sibling-pack dependencies, and the exact Context7 lookup references used.
- Verify malformed export content, especially the vulnerability-remediation page, preserves commands and intent after normalization.
- Verify implementation halts if Context7 tools are not callable in the session.

## Assumptions

- Live Context7 access is a hard requirement for implementation, not an optional enhancement.
- The existing `vendors/aws/control_tower/` pack remains the AWS-doc source pack and is not restructured in this slice.
- `Runbook / FAQ` is treated as notebook hierarchy metadata unless the implementation finds a true page body with that exact title.
- `Key Contacts` and `CMDB Application Service CIs Created` remain out of scope for the combined pack.
