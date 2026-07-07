# AWS Transform Bucket Pattern Research Plan

## Summary
Create a research-first report that uses live AWS and repository data to determine the best bucket strategy for the AWS Transform pipeline. The report should answer the current open question by comparing observed existing patterns with scalable bucket options for application teams, data teams, and multiple pipelines.

## Key Changes / Research Steps
- Inventory every resource mentioned in the draft and classify each as:
  - currently used
  - planned to use
  - unclear
- For each resource, capture:
  - likely AWS account
  - likely owning tool or platform
  - where it is referenced in the repo or docs
- Inspect repositories for existing Harness setup and Harness pipeline patterns.
- Inspect live AWS usage to determine whether the enterprise-integration bucket or Harness-account bucket is already used by application teams, and how.
- Identify the current bucket pattern in use:
  - shared bucket with prefixes
  - bucket per team
  - bucket per pipeline
  - bucket per domain
- Research AWS guidance and compare it to the observed org pattern.
- Produce a report that distinguishes:
  - what is observed in live AWS / repo data
  - what is inferred from patterns
  - what is recommended for this specific AWS Transform use case

## Report Outputs
- A resource table with columns for:
  - resource name
  - current/planned status
  - owning team/tool
  - AWS account
  - notes
- A bucket pattern comparison section covering:
  - application teams
  - data teams
  - multiple teams sharing one bucket
  - bucket-per-pipeline variant
- A recommendation section that states:
  - the preferred bucket strategy for the current pipeline
  - the scaling strategy if more teams and pipelines are added
  - when to switch from shared-bucket to bucket-per-pipeline isolation
- A short conclusion answering the original open question directly.

## Assumptions
- The final deliverable is a research report, not an implementation.
- Live investigation will be done later using AWS and repo sources, not just the draft notes.
- The report should preserve uncertainty clearly rather than forcing a premature decision.
- The most important decision is whether the org should use shared buckets, per-pipeline buckets, or a hybrid prefix-based model.

## Acceptance Criteria
- The report answers the bucket question with evidence from live data.
- The report includes a clear inventory of mentioned resources and tools.
- The report identifies the observed existing bucket pattern before recommending a future pattern.
- The report is readable by stakeholders who were not part of the original discussion.
