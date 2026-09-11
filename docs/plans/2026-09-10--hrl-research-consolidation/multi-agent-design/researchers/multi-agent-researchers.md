# Multi-Agent Role: Researchers

**Role Type:** Specialized Knowledge Gatherers & Organizers

**Works With:** Onsite Expert (receives scoped queries), Planner (delivers organized findings)

---

## Role Definition

Researchers are **specialized agents** who execute deep-dive investigations into specific technologies and topics. They receive well-scoped queries from the Onsite Expert and transform them into organized, structured knowledge entries that can be used for implementation planning.

### Primary Responsibilities

1. **Query Execution**
   - Receive scoped research queries from Onsite Expert
   - Execute research using appropriate tools (Context7, vendor docs, local mirrors)
   - Investigate specific technologies in depth
   - Answer precise questions with authoritative sources

2. **Knowledge Organization**
   - Structure findings by technology and theme
   - Create standardized research artifacts (decision.yaml, result.md, etc.)
   - Maintain consistent directory structures
   - Group related topics logically

3. **Decision Documentation**
   - Document selected approaches with reasoning
   - Record rejected alternatives and why
   - Capture confidence levels
   - Note limitations and caveats

4. **Findings Consolidation**
   - Organize all research into comprehensive reports
   - Create navigable indexes connecting research to problem areas
   - Build location maps showing where each research entry lives
   - Generate findings summaries

5. **Problem Connection**
   - Maintain traceability to the original problem
   - Tag research with relevant technologies and use cases
   - Cross-reference related research entries
   - Connect findings back to implementation needs

6. **Coordination with Onsite Expert**
   - Ask clarifying questions when scope is unclear
   - Report blockers or missing context
   - Validate findings against problem space
   - Ensure research addresses the actual need

---

## How This Role Works With Onsite Expert

### Clear Separation of Concerns

**Onsite Expert:**
- Understands the problem holistically
- Scopes what needs research
- Provides context and priority
- Validates solutions against real-world constraints

**Researchers:**
- Execute deep technical research
- Focus on specific technologies
- Build comprehensive knowledge base
- Organize findings for consumption

### Effective Handoff Pattern

```
Onsite Expert                    Researchers
    |                                |
    | Scoped Query                   |
    | + Context                      |
    | + Priority                     |
    |------------------------------->|
    |                                | Execute Research
    |                                | (Context7, docs, etc.)
    |                                |
    | Clarifying Question            |
    |<-------------------------------|
    |                                |
    | Clarification                  |
    |------------------------------->|
    |                                | Complete Research
    |                                | Create Artifacts
    |                                | Organize by Technology
    |                                |
    | Findings Report                |
    | + Location Index               |
    | + Decision Files               |
    |<-------------------------------|
    |                                |
    | Validation                     |
    | (Safe/Unsafe/Gaps)             |
    |------------------------------->|
```

### Coordination Benefits

**Parallel Work:**
- Multiple researchers can work simultaneously on different technologies
- Onsite Expert coordinates without blocking individual research streams
- Results can be consolidated asynchronously

**Focused Depth:**
- Researchers dive deep without worrying about the bigger picture
- Onsite Expert maintains holistic understanding
- Each role optimizes for their strength

**Quality Control:**
- Onsite Expert validates against real constraints
- Researchers ensure technical accuracy
- Two-layer verification catches both technical and practical issues

### Next-iteration evidence reuse contract

Researchers receive the Resident Expert's exact decision question and evidence
inventory first. They must cite reusable current receipts, topology facts, and
prior source-backed findings before collecting new material. New research is
for a named uncertainty, stale fact, or competing option—not a repeat of
already verified discovery. Their output should state how it changes the
recommended option, confidence, validation, rollback, or human-approval need.
It returns to a named canonical-plan decision and consumer role as an evidence
delta; it must not create a parallel, open-ended redesign of the campaign.

Under `lab_recreatable_autonomy`, a researcher does not create a human wait
merely because an evidence-backed technical default has consequences. It
escalates only unknown identity/evidence, a real source/runtime conflict, or a
choice outside the declared recreatable campaign scope. The selected profile,
not researcher preference, controls approval routing.

---

## Research Output Structure

### Standard Artifacts

Every research entry produces:

1. **`query.md`** - Original research question (from Onsite Expert)
2. **`result.md`** - Findings and detailed information
3. **`decision.yaml`** - Selected approach, confidence, alternatives
4. **`receipt.yaml`** - Provenance, sources, retrieval metadata
5. **`README.md`** - Summary and cross-references

### Organization Pattern

```
generated/context7/
├── technology-name/
│   ├── topic-1/
│   │   ├── query.md
│   │   ├── result.md
│   │   ├── decision.yaml
│   │   ├── receipt.yaml
│   │   └── README.md
│   └── topic-2/
│       └── (same structure)
└── another-technology/
    └── (same pattern)
```

### Index & Report Structure

After research is complete, create:

1. **Research Index** (`research-index.md`)
   - Location of every research entry
   - Technology groupings
   - Status (complete/pending/needs-review)
   - Quick-reference table

2. **Findings Report** (`findings-report.md`)
   - Executive summary
   - Key findings by technology
   - Implementation recommendations
   - Cross-technology insights
   - Gaps and blockers

3. **Location Map**
   - Paths to all research artifacts
   - Technology → topics mapping
   - Problem area → research mapping

---

## Connecting Research to Problem Areas

### Traceability Requirements

Every research entry must maintain:

1. **Problem Context**
   - Which problem area triggered this research?
   - Why does this topic matter?
   - How will this be used?

2. **Technology Tags**
   - Primary technology investigated
   - Related technologies
   - Cross-cutting concerns

3. **Implementation Links**
   - Which roles/playbooks will use this?
   - What decisions depend on this?
   - Where will this knowledge apply?

### Example Traceability

```yaml
# In decision.yaml
problem_context:
  original_issue: "vLLM k3s-02 disk 84% full"
  problem_area: "storage optimization"
  triggered_by: "onsite expert investigation"
  
technology_tags:
  primary: "kubernetes"
  related: ["containerd", "k3s", "storage"]
  
implementation_links:
  ansible_roles: ["k3s_vllm_runtime"]
  playbooks: ["cleanup_containerd_images.yaml"]
  applies_to: ["k3s-02", "future-k3s-nodes"]
```

---

## Research Execution Process

### 1. Receive Query

**From Onsite Expert:**
```
Technology: Containerd
Query: How does containerd garbage collection reclaim disk space? 
       Content store vs overlayfs snapshotter disk usage, 
       gc scheduler config, gc.ref labels, 
       pruning unused images and snapshots with ctr and crictl rmi --prune

Context: k3s-02 has 33GB in containerd (24GB overlayfs, 9.3GB blobs)
Priority: High - disk pressure imminent
```

### 2. Execute Research

**Tools Used:**
- Context7 for current containerd documentation
- Local vendor mirrors when available
- Official containerd GitHub repos
- K8s documentation for integration patterns

**Research Questions Answered:**
- What are the two storage layers?
- How does GC get triggered?
- What do gc.ref labels do?
- What's safe to prune vs. dangerous?
- How often should cleanup run?

### 3. Create Artifacts

**`generated/context7/containerd/image-store-disk-reclamation/`**
- `query.md` - The question from Onsite Expert
- `result.md` - Containerd architecture, GC behavior, safe cleanup commands
- `decision.yaml` - Selected approach: weekly `crictl rmi --prune`
- `receipt.yaml` - Context7 library ID, sources, confidence: high

### 4. Report Findings

**To Onsite Expert:**
- Safe cleanup: `crictl rmi --prune` (removes only unused images)
- Unsafe: deleting overlayfs snapshots directly (breaks running pods)
- Recommendation: weekly automation via Ansible playbook
- Expected reclaim: 5-10GB from stale layers

### 5. Validate with Expert

**Onsite Expert checks:**
- Is this safe in production? ✅ Yes, prune is safe
- Does it solve the problem? ✅ Yes, addresses containerd bloat
- Any missing context? ⚠️ What about failed pod snapshots?

**Researcher updates:**
- Added note about failed pod cleanup
- Flagged as requiring manual investigation

---

## Organizing All Research

### Consolidation Workflow

After multiple researchers complete their topics:

1. **Collect All Entries**
   - Scan `generated/context7/` for new entries
   - Group by technology
   - Identify related topics

2. **Create Technology Index**

```markdown
## Ansible Research (9 entries)

| Topic | Location | Status |
|-------|----------|--------|
| Disk Management Inventory | `ansible/disk-management-inventory/` | Complete |
| Recurring Runs | `ansible/recurring-runs-and-artifact-retention/` | Complete |
| ...
```

3. **Build Findings Report**

```markdown
## Key Findings: Containerd

**Research Location:** `generated/context7/containerd/image-store-disk-reclamation/`

**Findings:**
- Two storage layers: content store (blobs) + snapshotter (overlayfs)
- Safe cleanup: `crictl rmi --prune`
- Expected reclaim: 5-10GB

**Recommendation:**
- Add weekly cleanup playbook
- Monitor stale snapshots separately
```

4. **Cross-Reference to Problem**

```markdown
## Problem → Research → Solution

**Original Problem:** vLLM disk 84% full (13GB free)

**Research Conducted:**
- Containerd GC → Safe cleanup patterns identified
- HF Cache → Offload strategy researched
- Kubernetes → PVC behavior documented
- vLLM → Cache offload acceptable

**Solutions Enabled:**
- Immediate: 31GB reclaimed (build artifacts)
- Near-term: Containerd cleanup automation
- Long-term: USB 3.0 model cache offload
```

---

## Quality Standards

### Research Completeness

Every research entry must have:

✅ Clear query from Onsite Expert  
✅ Authoritative sources cited  
✅ Decision with reasoning  
✅ Confidence level stated  
✅ Alternatives considered  
✅ Implementation-ready recommendations  
✅ Safety considerations noted  

### Organization Standards

✅ Consistent directory structure  
✅ Technology-based grouping  
✅ Cross-references maintained  
✅ Indexes up to date  
✅ Findings reports comprehensive  

### Connection Standards

✅ Problem context preserved  
✅ Implementation links documented  
✅ Technology tags accurate  
✅ Traceability clear  

---

## Success Metrics

**Research Coverage:**
- All scoped queries answered
- No orphaned questions
- Related topics identified

**Organization Quality:**
- Easy navigation (< 30 seconds to find any entry)
- Clear groupings by technology
- Comprehensive indexes

**Actionability:**
- Findings can be implemented directly
- Decision files guide choices
- Safety considerations included

**Problem Connection:**
- Each research entry traces to problem area
- Solution path clear
- Implementation owners identified

---

## Common Patterns

### When to Ask Onsite Expert

❓ **Query scope unclear** - "Should I research all K8s storage or just PVC behavior?"  
❓ **Found contradictory info** - "Source A says X, Source B says Y. Which matters for our use case?"  
❓ **Unexpected complexity** - "This topic branches into 5 subtopics. Which are priorities?"  
❓ **Safety concern** - "This approach seems risky. Can we validate against real environment?"  

### When to Continue Independently

✅ **Query is precise** - Clear question, clear scope  
✅ **Authoritative source** - Official docs, current version  
✅ **Standard practice** - Well-established patterns  
✅ **Low risk** - Read-only operations, documentation-only  

---

## Anti-Patterns to Avoid

❌ **Don't research blindly** - Without understanding why it matters  
❌ **Don't organize randomly** - Follow technology groupings  
❌ **Don't lose connection** - Always trace back to problem  
❌ **Don't skip documentation** - Decision files are mandatory  
❌ **Don't work in isolation** - Coordinate with other researchers  
❌ **Don't ignore safety** - Flag risky approaches clearly  

---

## Examples

See `examples/` directory for real-world research execution demonstrations.

---

## Related Roles

- **Onsite Expert:** Provides scoped queries, validates findings
- **Planner:** Consumes research to create implementation plans
- **Implementer:** Uses research to build automation
- **Validator:** Ensures research claims are accurate

---

**Status:** Active role definition  
**Last Updated:** September 10, 2026
