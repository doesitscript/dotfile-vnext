# Important Multi-Agent Gemini Note

## Short Answer

Gemini 2.5 agents are useful for background research, source summarization, and
first-pass plan drafting. They should not be trusted alone as the final
architect of record for this project.

For the level of outcome we usually target in this repo, final synthesis should
still be handled by a stronger repo-grounded planning model, such as the model
used in this conversation or a Sonnet 4.5-class model.

## Recommended Division Of Labor

| Work | Gemini 2.5 Agents | Final Architect Model |
|---|---|---|
| Source summarization | Good fit | Good fit |
| Extracting plan candidates | Good fit | Good fit |
| Drafting Mermaid diagrams | Usable with review | Preferred for final |
| Repo-aware naming/schema enforcement | Supervised only | Preferred |
| NetBox/Ansible implementation-ready plans | Not alone | Required |
| Final plan quality gate | No | Yes |

## Why

The hard part of this work is not simply writing a plausible plan. The hard part
is enforcing this repo's local operating contract:

- NetBox-backed source-of-truth modeling
- compact naming schema usage
- old-name cleanup and stale-alias prevention
- official folder-backed plan packets
- required Mermaid diagrams
- Ansible role/playbook shape
- safe separation between Docker, K3s, GPU, and platform lanes
- preservation of ongoing work without accidental conflicts

Gemini agents can help gather and organize material, but their output should be
treated as draft input until reviewed against the repo's rules, schema, live
NetBox state, and Ansible surfaces.

## Practical Rule

Use Gemini 2.5 agents as research assistants and draft generators.

Use the main repo-grounded model as the final planner, reviewer, and execution
gatekeeper before anything becomes an official plan or implementation path.

## Three-Phase Findings Workflow

The Jupyter DevOps implementation planning follows a three-phase findings and
review process:

### Phase 1: Initial Findings (Draft Review)
**Purpose:** Structural compliance check on subagent-generated drafts.

**Process:**
- Gemini 2.5 agents produce initial plan drafts from research
- Final architect model (Sonnet 4.5-class) reviews drafts for:
  - Folder structure compliance
  - Mandatory diagram presence
  - Basic naming convention adherence
  - Research integration
- **Output:** Initial findings report identifying what needs attention
- **Status:** ✅ Complete (May 19, 2026)

### Phase 2: Final Pass (Quality Gate Enforcement)
**Purpose:** Apply full repo-specific quality gates and resolve ambiguities.

**Architecture:**
```
User (Decision Authority)
    ↓
Phase 2 Coordinator (Sonnet 4.5 ansible-coordinator)
    ↓ (spawns 6 parallel reviewers)
    ├─ Plan 1 Reviewer (Sonnet 4.5)
    ├─ Plan 2 Reviewer (Sonnet 4.5)
    ├─ Plan 3 Reviewer (Sonnet 4.5)
    ├─ Plan 4 Reviewer (Sonnet 4.5)
    ├─ Plan 5 Reviewer (Sonnet 4.5)
    └─ Plan 6 Reviewer (Sonnet 4.5)
```

**Process:**
1. Coordinator spawns 6 Sonnet 4.5 reviewers (one per plan)
2. **First pass:** Reviewers apply quality gates and collect questions
   - NetBox naming schema enforcement
   - Ansible conventions verification
   - Diagram completeness check
   - Dependency documentation
   - FQCN usage verification
3. Coordinator aggregates questions for user review
4. User provides answers/clarifications
5. **Second pass:** Reviewers apply answers and finalize plans
6. Coordinator produces final synthesis:
   - Dependency graph
   - Implementation order
   - Cross-plan coordination notes
   - Final approval recommendation

**Quality Gates Applied:**
- NetBox-backed source-of-truth modeling
- Compact naming schema usage
- Official folder-backed plan packets
- Required Mermaid diagrams
- Ansible role/playbook shape
- Variable naming (`role_name_` prefix, `vault_<role>_<field>`)
- Tag hierarchies
- Safe separation between Docker, K3s, GPU, and platform lanes

**Output:** Finalized plans ready for implementation
- **Status:** 🔄 Pending (ready to launch)

### Phase 3: Post-Implementation Findings
**Purpose:** Validate actual deployment and operational outcomes.

**Process:**
- Run playbooks against target infrastructure
- Collect evidence from actual deployments
- Verify idempotence
- Test end-to-end workflows
- Document operational learnings
- Update plans with implementation reality

**Output:** Final overall summary at:
```text
-experimental-multi-agent-work-breakup/findings/999-final-overall-summary.md
```
- **Status:** ⏸️ Blocked on Phase 2 completion

## Experimental Tracking

This guidance is now being tracked as an experimental optionality for future
work breakup in this project:

- [-experimental-multi-agent-work-breakup/README.md](-experimental-multi-agent-work-breakup/README.md)
- [-experimental-multi-agent-work-breakup/IMPORTANT-approach-tracking-EXPERIMENTAL.md](-experimental-multi-agent-work-breakup/IMPORTANT-approach-tracking-EXPERIMENTAL.md)

The current test candidate is the Jupyter DevOps implementation plan set in
this directory. Sonnet-class and Gemini 2.5 agents are used to test the
division of labor through the three-phase workflow documented above.

## Sources Checked

- Gemini API model docs: https://ai.google.dev/gemini-api/docs/models/gemini-v2
- Gemini API pricing docs: https://ai.google.dev/gemini-api/docs/pricing
- `gemini-free-tier-model-chooser` skill
