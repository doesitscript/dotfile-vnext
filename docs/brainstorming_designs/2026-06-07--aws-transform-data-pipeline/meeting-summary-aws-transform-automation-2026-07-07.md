# Meeting Summary: AWS Transform Automation (Endevor → AWS Transform Pipeline)

**Date:** July 7, 2026
**Attendees:** Alex Morgan (initiative owner, acquisitions modernization), Ryan Cooper and Jordan Blake (Harness / pipeline team), Josh (AWS Platform team, Marcus's team)
**Referenced (not present):** Marcus Webb (AWS Platform team manager), Evan Pierce, Taylor Brooks, Drew Walsh, Riley Hayes, Casey Lane, Morgan Ellis

---

## Purpose

Alex requested this meeting to determine whether Harness can (and should) automate the flow of mainframe code from GitHub into S3 and AWS Transform, replacing the current manual tracking process for mainframe changes.

## Background

- The mainframe code snapshot used to build the current AWS servers dates back to **January 2026**. Mainframe development has continued since then, but changes have not been fed back into AWS — the team has been **manually tracking** all prescreen-offer-related changes and reconciling scope at go-live.
- Alex has already solved the first leg: **extracting code from Endevor (mainframe repo) and manually committing it to GitHub**, done roughly once a month. This took about two months to figure out.
- The proposed automation: on commit/push to GitHub, a Harness pipeline uploads the code to **S3 in the enterprise-integration account**, triggers **AWS Transform** via AWS CLI, Transform writes its analysis output back to S3, and **Kiro** reads/diffs the outputs so requirements can be derived from the changes.
- Alex originally considered an IAM identity provider connecting GitHub directly to S3; Marcus Webb advised that **Harness is the right mechanism**, which prompted this call.
- Rationale for building this once: it took Evan roughly **four months** to learn how to run AWS Transform and interpret its output. This pipeline captures that knowledge so future mainframe teams onboarding to AWS don't repeat that effort.

## Key Discussion Points

### Feasibility
The Harness team sees no major obstacle. This is a simple utility pipeline: a trigger on a completed merge/PR, an upload to S3, and an AWS CLI command to kick off AWS Transform — the same pattern already used with card services and Greenfield. There is no production/dev/staging concern; the repo feeds transformation analysis only and nothing deploys to production.

### Tool approvals
A concern was raised that Kiro had previously been disallowed on another project as an unapproved AI solution at the organization. Alex confirmed **Kiro, AWS Transform, and S3 are all approved**. The open item is the *pattern* for getting code from GitHub to S3, which is what this effort is validating.

### Governance
Marcus's earlier feedback was about ensuring the process is governed properly and owned by the right teams (his prior understanding was that data teams would own their own pipelines). The AWS Platform team oversees the Terraform/AWS side, so they need visibility into what commands the pipeline runs. No objection — just a need to get in sync.

### Permissions / S3 access (the main open question)
There is a single **Harness AppDeploy account** in AWS, currently containing three S3 buckets (PT, pipelines, and analytics or similar). The first decision needed from Marcus:

1. Grant the Harness AppDeploy account read/write access to Alex's existing S3 bucket in the enterprise-integration account, **or**
2. Create a new (fourth) S3 bucket inside the Harness account for this workflow.

Everything downstream (CLI access, delegated permissions) depends on this answer.

### Where the pipeline lives in Harness
- Harness is organized by value-stream projects (acquisitions, shop integration, core integration, core engineering, etc.), independent of AWS accounts.
- This pipeline will live in **acquisitions** for now. It may extend to servicing after acquisitions modernization completes.
- Related note: the database pipeline discussed in an earlier call (fraud match / credit abuse work Taylor is driving) will also live under acquisitions.
- The pipeline is **temporary by design** — once the mainframe is fully migrated to AWS, it retires. Jordan confirmed projects/pipelines can be moved later if needed, but the preference is to place it where it will live to avoid re-tagging.

### Timeline
No urgency. Alex is targeting **September–October** for instant credit needs, with flexibility to slip into next year. He estimates the GitHub → Kiro leg may take about two months to work out, similar to the Endevor → GitHub effort, hence starting early.

## Decisions

- Harness will be used as the mechanism to move code from GitHub to S3 and trigger AWS Transform (pending Marcus's sign-off on account/bucket access).
- The pipeline will be created under the **acquisitions** project in Harness.
- Riley can be pulled in to help with the pipeline work (stepping into the role Drew previously filled); exact resourcing to be decided by Ryan and Jordan.

## Action Items

| # | Action | Owner | Due |
|---|--------|-------|-----|
| 1 | Schedule a short meeting with Marcus + this group (including Josh) to resolve the S3 access question (grant Harness AppDeploy access vs. create a new bucket) | Ryan | This week |
| 2 | Review the current delegated-permissions setup for the Harness account and pre-answer permission questions ahead of the Marcus meeting | Josh | Before the Marcus meeting |
| 3 | Decide resourcing (Riley vs. others) for pipeline build-out | Ryan & Jordan | TBD |
| 4 | Identify the exact AWS CLI commands needed to trigger AWS Transform from the pipeline | Alex + Harness team | After access question is settled |

## Open Questions

- Will Marcus approve the Harness AppDeploy account accessing the enterprise-integration S3 bucket, or should a new bucket be created in the Harness account?
- What specific AWS CLI commands and IAM permissions does the AWS Transform trigger require?
- Longer term: does database/utility pipeline work grow enough to warrant its own dedicated Harness project, or does it stay under acquisitions?
