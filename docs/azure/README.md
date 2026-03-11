# Azure (Foundry / Cognitive Services) — docs and scripts

## Progress

### Deployment script (`deploy-embed-ada.ps1`)

- **Auth:** Switched to **`Invoke-AzRestMethod`** so the current Az context is used; no manual token. Run after `Connect-AzAccount` in the same pwsh session.
- **Result:** The script runs successfully and the ARM API accepts the request. Deployment of **text-embedding-ada-002** (embed-ada, GlobalStandard, capacity 1) fails with **InsufficientQuota**:
  - *"This operation require 1 new capacity in quota Tokens Per Minute (thousands) - Text-Embedding-Ada-002, which is bigger than the current available capacity 0. The current quota usage is 0 and the quota limit is 0."*
- So: **auth and API usage are working**; the blocker is **TPM quota for that model is 0** on this subscription (e.g. Azure for Students).

**Exact error (for reference):**  
*"This operation require 1 new capacity in quota Tokens Per Minute (thousands) - Text-Embedding-Ada-002, which is bigger than the current available capacity 0. The current quota usage is 0 and the quota limit is 0 for quota Tokens Per Minute (thousands) - Text-Embedding-Ada-002."*

### Next step

- **Request quota:** [aka.ms/oai/stuquotarequest](https://aka.ms/oai/stuquotarequest), or
- **Try Legacy models:** In the portal (Operate → Quota) see if Ada/Babbage show non-zero TPM in your region; if so, try deploying one (e.g. adapt the script to use `ada`). See **models-and-quota-options.md**.

---

## Azure OpenAI (classic) vs Foundry

| Resource | Kind | Location | Deploy text-embedding-ada-002 |
|----------|------|----------|-------------------------------|
| **doesitscript-8935** | **OpenAI** (classic) | eastus | **Succeeded** — not blocked |
| **open-ai-fd-lab-01** | AIServices (Foundry) | northcentralus | **InsufficientQuota** (0 TPM) |

Same subscription (Azure for Students). Classic OpenAI resource had quota; Foundry resource had 0 TPM for that model. Use **deploy-openai-classic.ps1** to deploy to the classic resource; use **deploy-embed-ada.ps1** for Foundry once quota is granted.

---

## Files

| File | Purpose |
|------|--------|
| **guides-azure-openai-model-tasks.md** | **Two Azure OpenAI guides** — 4sysops (PowerShell) + MS Learn (Flask); model tasks and interesting bits |
| **guides-azure-openai-model-tasks.md** | **Two Azure OpenAI guides** — model tasks (chat, NL→SQL, embeddings + document search) and what’s interesting in each |
| **azure-openai-classic.md** | **Azure OpenAI (classic)** — Kind: OpenAI, resource + deploy; result: deploy **succeeded** on doesitscript-8935 |
| **deploy-openai-classic.ps1** | Deploy a model to classic OpenAI resource (doesitscript-8935, eastus) |
| **models-and-quota-options.md** | Do any models avoid the same quota restriction? (serverless, shared, Legacy, students) |
| `interactive-login-pwsh.md` | Sign in with pwsh, get API keys |
| `deploy-embed-ada.ps1` | Deploy text-embedding-ada-002 to **Foundry** (open-ai-fd-lab-01; needs TPM quota) |
| `foundry-research-and-resources.md` | Foundry concepts, your resources, models, allocations |
| `foundry-deployments-api-auth.md` | Correct token audience for project deployments API |
| `deployments-research-and-how-to-deploy.md` | How to deploy, quotas, free tier, model list |
