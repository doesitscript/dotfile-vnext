---
name: hrl-research-entry-create
description: Create structured Context7 research entries in the Homelab Reference Library
status: draft
priority: high
---

# HRL Research Entry Create

**Status:** 🚧 DRAFT - Not ready for execution  
**Role:** Researchers  
**Phase:** Research execution and artifact creation

---

## ⚠️ Draft Status

This skill is **draft work** documenting the research entry creation pattern used in the storage optimization project. It is not yet implemented as an executable skill.

**Do not attempt to execute** - This requires further development and testing.

---

## Purpose

Execute focused research queries using Context7 (or other authoritative sources) and create structured, reusable knowledge entries in the Homelab Reference Library. Transform vendor documentation into actionable implementation guidance.

---

## When to Use

Use this skill when:
- ✅ Have a scoped research query from Onsite Expert
- ✅ Query specifies technology, question, and context
- ✅ Need to create durable HRL research artifact
- ✅ Expected output is decision + implementation guide

Do NOT use when:
- ❌ Query is too vague (needs query formulation first)
- ❌ Answer already exists in HRL
- ❌ Quick lookup (not durable research)

---

## Inputs

**Required:**
- `technology` - Which technology (ansible, kubernetes, containerd, etc.)
- `topic` - Specific topic slug (disk-management-inventory, image-gc, etc.)
- `query` - Precise question or research prompt
- `context` - Why this research matters, current state

**Optional:**
- `priority` - High/Medium/Low
- `expected_output` - What the answer should look like
- `sources_hint` - Known good sources (Context7 lib IDs, vendor URLs)

---

## Research Sources Priority

1. **Context7** - Current vendor documentation (preferred)
2. **Vendor docs** - Official documentation sites
3. **Committed mirrors** - Already in HRL vendor/ directory
4. **Implementation experience** - Known patterns from deployments
5. **Community resources** - When vendor docs are sparse

---

## Workflow

### Phase 1: Research Execution
1. **Use Context7 to fetch documentation:**
   ```
   Query: [scoped question with specifics]
   Library: [appropriate Context7 library]
   Context: [why this matters]
   ```

2. **Extract key information:**
   - Core concepts
   - Configuration options
   - Best practices
   - Safety considerations
   - Common pitfalls

3. **Identify decision points:**
   - What approaches exist?
   - What are trade-offs?
   - What's recommended?

### Phase 2: Artifact Creation

Create research entry at:
```
generated/context7/<technology>/<topic>/
```

**Required files:**

1. **`README.md`** - Entry overview
   ```markdown
   # [Topic Title]
   
   ## Overview
   [What this research covers]
   
   ## Context
   [Original problem/question]
   
   ## Key Findings
   - Finding 1
   - Finding 2
   
   ## Related Entries
   - Link to related research
   ```

2. **`query.md`** - Original research query
   ```markdown
   # Research Query
   
   ## Technology
   [Technology name]
   
   ## Question
   [Precise question asked]
   
   ## Context
   [Why this research was needed]
   
   ## Priority
   [High/Medium/Low + reasoning]
   
   ## Expected Output
   [What kind of answer was expected]
   ```

3. **`result.md`** - Research findings
   ```markdown
   # Research Findings: [Topic]
   
   ## Summary
   [Executive summary of findings]
   
   ## Core Concepts
   [Key concepts explained]
   
   ## Configuration
   [Config options, parameters, settings]
   
   ## Best Practices
   [Recommended approaches]
   
   ## Safety Considerations
   [What to avoid, risks]
   
   ## Implementation Guidance
   [How to apply this]
   
   ## Examples
   [Concrete examples or commands]
   
   ## Sources
   - [Context7 library reference]
   - [Vendor documentation URLs]
   - [Other authoritative sources]
   ```

4. **`decision.yaml`** - Research decision record
   ```yaml
   ---
   technology: <technology>
   topic: <topic-slug>
   research_date: YYYY-MM-DD
   
   query:
     question: |
       [Original question]
     context: |
       [Why research was needed]
     priority: high|medium|low
   
   sources:
     preferred_source: context7|vendor_docs|mirror|other
     context7_library: [library ID if used]
     vendor_urls:
       - [primary vendor doc URL]
     other_sources:
       - [any other sources]
   
   findings:
     summary: |
       [Brief summary of key findings]
     
     approaches_evaluated:
       - name: [Approach 1]
         description: |
           [What it is]
         pros:
           - [Advantage 1]
         cons:
           - [Disadvantage 1]
         safety: safe|unsafe|conditional
       
       - name: [Approach 2]
         ...
   
   decision:
     selected_approach: [Name of chosen approach]
     rationale: |
       [Why this was chosen]
     
     confidence: high|medium|low
     
     safety_considerations:
       - [Safety note 1]
       - [Safety note 2]
     
     implementation_notes:
       - [Note 1]
       - [Note 2]
   
   validation:
     needs_real_world_test: true|false
     validated_by: onsite_expert|none
     validation_notes: |
       [Any validation performed]
   
   revalidation:
     should_revalidate: true|false
     revalidate_when: |
       [When to revisit this decision]
   ---
   ```

5. **`receipt.yaml`** - Research execution metadata
   ```yaml
   ---
   research_id: [technology]-[topic]
   technology: <technology>
   topic: <topic-slug>
   
   execution:
     researcher: [agent/person who executed]
     start_date: YYYY-MM-DD
     completion_date: YYYY-MM-DD
     duration_hours: [estimate]
   
   query_received:
     from: onsite_expert
     query_file: query.md
     priority: high|medium|low
   
   research_performed:
     sources_consulted:
       - source_type: context7
         library: [library ID]
         query: |
           [Query used]
       - source_type: vendor_docs
         urls:
           - [URL 1]
     
     findings_file: result.md
     decision_file: decision.yaml
   
   deliverables:
     - README.md
     - query.md
     - result.md
     - decision.yaml
     - receipt.yaml
   
   handoff:
     to: onsite_expert
     status: complete|needs_validation|blocked
     notes: |
       [Any notes for handoff]
   ---
   ```

### Phase 3: Quality Check

Before marking complete:

✅ **Completeness:**
- All 5 required files present
- Query, findings, and decision all align
- Sources clearly cited

✅ **Actionability:**
- Implementation guidance clear
- Safety considerations explicit
- Examples/commands included

✅ **Traceability:**
- Original query preserved
- Decision rationale documented
- Validation notes if applicable

✅ **Organization:**
- Filed under correct technology
- Topic slug is clear and consistent
- Related entries linked

---

## Output Structure

```
generated/context7/<technology>/<topic>/
├── README.md          ← Entry overview
├── query.md           ← Original research query
├── result.md          ← Research findings
├── decision.yaml      ← Decision record
└── receipt.yaml       ← Execution metadata
```

---

## Example: Containerd Image Store Entry

### Location
```
generated/context7/containerd/image-store-disk-reclamation/
```

### Files Created

**README.md:**
```markdown
# Containerd Image Store Disk Reclamation

## Overview
Research on how containerd manages disk space across content store
and overlayfs snapshotter, with focus on safe cleanup patterns.

## Context
k3s-02 VM has 33GB consumed by containerd (24GB overlayfs, 9.3GB blobs).
Need to understand garbage collection patterns and safe cleanup commands.

## Key Findings
- Two-layer storage: content store (blobs) + snapshotter (overlayfs)
- `crictl rmi --prune` is safe for cleanup (only removes unreferenced)
- Manual deletion can break running pods
- Weekly automation recommended

## Related Entries
- `kubernetes/kubelet-image-garbage-collection/` - K8s-level GC
- `ansible/recurring-runs-and-artifact-retention/` - Automation patterns
```

**query.md:**
```markdown
# Research Query

## Technology
containerd

## Question
How does containerd garbage collection reclaim disk space? 
Content store vs overlayfs snapshotter disk usage, 
gc scheduler config, gc.ref labels, 
pruning unused images and snapshots with ctr and crictl rmi --prune

## Context
k3s-02 has 33GB in containerd (24GB overlayfs, 9.3GB blobs).
Need safe cleanup patterns that won't break running pods.
Disk pressure at 84% (13GB free / 77GB total).

## Priority
High - disk pressure imminent, need cleanup options

## Expected Output
- Explanation of two storage layers
- Safe cleanup commands
- Unsafe operations to avoid
- Expected disk reclamation
- Automation recommendations
```

**result.md:**
```markdown
# Research Findings: Containerd Image Store Disk Reclamation

## Summary
containerd uses two-layer storage: content store (blobs) and 
overlayfs snapshotter (layers). Safe cleanup via `crictl rmi --prune`
removes only unreferenced images. Manual deletion risks breaking pods.

## Core Concepts

### Content Store
- Location: `/var/lib/containerd/io.containerd.content.v1.content/`
- Stores: Image blobs, config, manifests
- Identified by: SHA256 digests
- Read-only: Content-addressable storage

### Snapshotter (overlayfs)
- Location: `/var/lib/containerd/io.containerd.snapshotter.v1.overlayfs/`
- Stores: Filesystem layers, container diffs
- Structure: Base layers + container deltas
- Mutable: Active container writes here

[... detailed findings continue ...]

## Safety Considerations
⚠️ **DO NOT manually delete from content store or snapshots**
   - Breaks running pods
   - Orphans container state
   - Not idempotent

✅ **Safe cleanup: crictl rmi --prune**
   - Only removes unreferenced images
   - Respects running containers
   - Idempotent operation

## Implementation Guidance
```bash
# Check current disk usage
crictl imagefsinfo

# List images
crictl images

# Safe cleanup (removes only unreferenced)
crictl rmi --prune

# Verify reclaimed space
crictl imagefsinfo
```

**Automation:**
Weekly cron via Ansible:
- Schedule: Sunday 3am
- Command: crictl rmi --prune
- Monitor: Disk space trend
- Alert: If reclaimation < expected

## Sources
- Context7: containerd-docs library
- Vendor: https://github.com/containerd/containerd/docs/gc.md
- K8s docs: https://kubernetes.io/docs/concepts/architecture/garbage-collection/
```

**decision.yaml:**
```yaml
---
technology: containerd
topic: image-store-disk-reclamation
research_date: 2026-09-10

query:
  question: |
    How does containerd garbage collection reclaim disk space?
  context: |
    33GB consumed, need safe cleanup patterns
  priority: high

sources:
  preferred_source: context7
  context7_library: containerd-docs
  vendor_urls:
    - https://github.com/containerd/containerd/docs/gc.md

findings:
  summary: |
    Two-layer storage (content + snapshotter). Safe cleanup via
    crictl rmi --prune. Weekly automation recommended.
  
  approaches_evaluated:
    - name: Manual content store deletion
      description: Directly delete blobs from content store
      pros:
        - Maximum disk reclamation
      cons:
        - Breaks running pods
        - Not idempotent
        - Requires deep containerd knowledge
      safety: unsafe
    
    - name: crictl rmi --prune (Recommended)
      description: Use crictl to prune unreferenced images
      pros:
        - Safe, respects running pods
        - Idempotent
        - Simple automation
      cons:
        - Conservative (may leave some unused data)
      safety: safe
    
    - name: containerd gc scheduler
      description: Built-in GC via containerd config
      pros:
        - Automatic
        - Native to containerd
      cons:
        - Less control over timing
        - Requires containerd restart to configure
      safety: safe

decision:
  selected_approach: crictl rmi --prune (weekly automation)
  rationale: |
    Safe, simple, and effective. Weekly schedule balances disk
    space reclamation with minimal overhead. Conservative approach
    appropriate for production.
  
  confidence: high
  
  safety_considerations:
    - Only removes unreferenced images
    - Safe to run while pods are running
    - No risk to production workloads
  
  implementation_notes:
    - Create Ansible playbook
    - Schedule via cron (weekly, Sunday 3am)
    - Add monitoring for disk trend
    - Alert if reclamation below expected

validation:
  needs_real_world_test: true
  validated_by: onsite_expert
  validation_notes: |
    Test run recovered 2.3MB (most images in use, as expected).
    Confirms safety. Expect 5-10GB from stale layers over time.

revalidation:
  should_revalidate: true
  revalidate_when: |
    If disk usage patterns change significantly, or after
    major containerd version upgrades.
---
```

**receipt.yaml:**
```yaml
---
research_id: containerd-image-store-disk-reclamation
technology: containerd
topic: image-store-disk-reclamation

execution:
  researcher: researcher-agent-1
  start_date: 2026-09-10
  completion_date: 2026-09-10
  duration_hours: 1.5

query_received:
  from: onsite_expert
  query_file: query.md
  priority: high

research_performed:
  sources_consulted:
    - source_type: context7
      library: containerd-docs
      query: |
        containerd garbage collection, content store, 
        overlayfs snapshotter, crictl rmi --prune
    - source_type: vendor_docs
      urls:
        - https://github.com/containerd/containerd/docs/gc.md
        - https://github.com/containerd/containerd/docs/ops.md
  
  findings_file: result.md
  decision_file: decision.yaml

deliverables:
  - README.md
  - query.md
  - result.md
  - decision.yaml
  - receipt.yaml

handoff:
  to: onsite_expert
  status: complete
  notes: |
    Research complete with high confidence. Test run validated
    safety. Ready for Ansible automation implementation.
---
```

---

## Quality Checklist

Before marking research complete:

✅ **All files present:**
- README.md
- query.md
- result.md
- decision.yaml
- receipt.yaml

✅ **Query-to-decision alignment:**
- Decision addresses original query
- Context preserved throughout
- Priority reflected in depth

✅ **Implementation ready:**
- Clear guidance provided
- Examples/commands included
- Safety explicit

✅ **Sources cited:**
- Context7 library ID or vendor URLs
- Authoritative sources used
- No fabricated information

✅ **Decision documented:**
- Approach selected with rationale
- Alternatives evaluated
- Safety and trade-offs clear

---

## Integration Points

**Receives from:**
- `multi-agent-research-query-formulator` - Scoped queries

**Feeds into:**
- `hrl-research-location-index` - For navigation
- `hrl-research-consolidator` - For synthesis
- Onsite Expert validation

---

## Notes for Implementation

When ready to implement:

1. **Template system:**
   - File templates with required sections
   - YAML schema validation
   - Consistency checks

2. **Context7 integration:**
   - Library resolution
   - Query optimization
   - Result extraction

3. **Quality gates:**
   - Completeness validation
   - Source verification
   - Decision logic check

---

## Related Skills

- `hrl-research-location-index` (navigation)
- `hrl-research-consolidator` (synthesis)
- `multi-agent-coordination-checkpoint` (validation)

---

**Status:** Draft workflow template  
**Last Updated:** September 10, 2026  
**Ready for execution:** No - needs development
