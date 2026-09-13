# Repeat Workflow Guide & Operational Runbook

## Overview
This report captures the commands, prompt templates, and model delegation strategy required to repeat the model lane configuration reconciliation workflow.

---

## Model Delegation Strategy

1. **Preparation, Intake & Planning (Gemini Flash Lite)**
   - **Role:** High-context triage, document ingestion, summarizing multi-file assessment reports, and drafting walkthrough outlines.
   - **Why:** Massive context window, exceptional speed, and very low cost per token.

2. **Execution, Ansible Playbook Runs & Parameter Reconciling (GPT-4o-mini)**
   - **Role:** Precise YAML parameter updates, configuration reconciliation across SSOT and gateway/client exports, and generating execution commands.
   - **Why:** Fast, cost-effective, strong structured instruction-following, and reliable handling of configuration files.

---

## Recommended Commands & Prompt Templates

### Step 1: Intake and Assessment (Gemini Flash Lite)
```bash
# Review assessment and walkthrough files
cat model-lane-acceptance/discuss_implementations_retros/retro_all/2026-09-12-qwen3-coder-config-evaluation/02-assessment-and-proposal.md
cat model-lane-acceptance/discuss_implementations_retros/retro_all/2026-09-12-qwen3-coder-config-evaluation/walkthrough.md
```

### Step 2: Parameter Reconciliation & Ansible Execution (GPT-4o-mini)
Use the prompt provided below to instruct **GPT-4o-mini** on executing the parameter updates and running the deployment playbooks.
