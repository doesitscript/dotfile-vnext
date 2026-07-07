# Option Research: Bucket Patterns Before AWS Pattern Review

This note captures the preliminary bucket-structure ideas discussed before checking for existing AWS or org-specific patterns. It is meant to preserve the reasoning space, not to claim any implementation already exists.

## Framing Assumptions

- The bucket is already used by application teams.
- The bucket likely supports an SDLC workflow rather than a single ad hoc consumer.
- Multiple teams may need to use the same storage pattern over time.
- Future scale matters: more application teams, more data teams, and potentially more pipelines.

## Initial Pattern Hypothesis

The most likely current pattern is:

- One shared S3 bucket used as a platform resource.
- Team separation handled by prefixes, IAM boundaries, and possibly access points.
- Bucket ownership managed centrally by a platform team.
- Individual teams/pipelines writing into their own paths rather than owning separate buckets by default.

## SDLC Pattern for Application Teams

A reasonable application-team layout would look like this:

- `app-team-a/dev/build-artifacts/`
- `app-team-a/test/release-candidates/`
- `app-team-a/prod-approved/`
- `app-team-b/dev/build-artifacts/`
- `app-team-b/test/release-candidates/`
- `app-team-b/prod-approved/`

How this likely works:

- CI jobs upload artifacts into team-owned prefixes.
- Deployment automation reads from those prefixes.
- Each pipeline role is limited to its own path.
- The platform team still manages shared bucket settings such as logging, encryption, and lifecycle.

## Shared Bucket Pattern for Multiple Data Teams

A comparable data-team layout could be:

- `data-team-a/raw/mainframe/`
- `data-team-a/curated/`
- `data-team-b/raw/mainframe/`
- `data-team-b/curated/`
- `transform-common/checkpoints/`
- `transform-common/metadata/`

How this likely works:

- Each team gets its own namespace inside a shared bucket.
- IAM, bucket policy, or access points enforce separation.
- Cross-team access is possible for admins, but not accidentally for neighboring teams.

## Scaling Options Considered

### Option A: Shared Bucket, Strict Prefixes, Separate Roles

Best when:

- teams are in the same or closely related accounts
- retention and encryption needs are similar
- the organization wants low operational overhead

Example:

- `shared-artifacts/app-team-a/...`
- `shared-artifacts/app-team-b/...`
- `shared-artifacts/data-team-a/...`
- `shared-artifacts/data-team-b/...`

Pros:

- easy to add new teams
- low bucket sprawl
- efficient to operate

Tradeoff:

- bucket policy and IAM can become complex as teams and exceptions grow

### Option B: Shared Bucket Per Domain, Prefixes Per Team

Best when:

- app teams and data teams are naturally grouped by domain
- the org wants fewer buckets than one-per-team
- some separation is useful, but not full isolation per team

Example:

- `app-domain-bucket/app-team-a/...`
- `app-domain-bucket/app-team-b/...`
- `data-domain-bucket/data-team-a/...`
- `data-domain-bucket/data-team-b/...`

Pros:

- clearer ownership boundaries
- easier lifecycle or retention policy by domain
- avoids bucket explosion

Tradeoff:

- still requires disciplined prefix and policy management

### Option C: Bucket Per Team or Per Workload

Best when:

- strong isolation matters
- teams have different compliance requirements
- ownership is intentionally decentralized
- lifecycle, replication, or encryption rules differ materially

Example:

- `app-team-a-artifacts`
- `app-team-b-artifacts`
- `data-team-a-ingest`
- `data-team-b-ingest`

Pros:

- strongest separation
- clearest ownership model
- simpler per-team deletion and lifecycle handling

Tradeoff:

- more buckets, more policy objects, more operational overhead

## Bucket Per Pipeline Option

Bucket-per-pipeline was also considered as a valid variant.

Good fit when:

- each pipeline has its own IAM boundary
- each pipeline has distinct retention or lifecycle rules
- teams should not see each other’s artifacts even by accident
- the number of pipelines is small or manageable

Example:

- `mainframe-team-a-input`
- `mainframe-team-a-output`
- `mainframe-team-b-input`
- `mainframe-team-b-output`

Or, if a single bucket is preferred:

- `transform-team-a/raw/`
- `transform-team-a/output/`
- `transform-team-b/raw/`
- `transform-team-b/output/`

Pros:

- strongest isolation
- easy mental model
- low risk of cross-team permission mistakes

Tradeoff:

- bucket count and operational overhead rise quickly as teams grow

## Preliminary Rule of Thumb

- `1-10` pipelines: bucket per pipeline can be practical.
- `10+` pipelines or many teams: shared bucket with prefixes usually scales better.
- Strict compliance or hard isolation: bucket per pipeline remains the safest choice.

## Preliminary Recommendation for the AWS Transform Case

Before checking actual AWS or org patterns, the best working assumption is:

- treat the AWS Transform workflow as a data workload, not an app artifact workload
- use a shared bucket if the organization wants lower operational overhead
- isolate by top-level prefix at minimum
- use access points or tightly scoped IAM if multiple teams need shared access
- switch to separate buckets only when governance or access boundaries demand it

## Summary of the Research Space

The main options are:

1. Shared bucket with prefixes and separate roles
2. Shared bucket per domain with team-level prefixes
3. Bucket per team or per workload
4. Bucket per pipeline

The pre-AWS-pattern conclusion is that bucket-per-pipeline is valid, shared-bucket-with-prefixes is also valid, and the real choice is the tradeoff between isolation and operational overhead.
