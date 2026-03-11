# Deployments research — what we can deploy, quotas, and how to deploy one

**Researched:** Microsoft Learn (Deploy Foundry Models portal, Create model deployments CLI/Bicep, Working with models, Quotas and limits), Azure for Students Q&A, live model list in northcentralus.

---

## 1. Deployments overview

- **Deployment** = you assign a catalog model (by name, version, format) to a **deployment name** and allocate **quota** (TPM or PTU). That deployment name is what you use in the `model` parameter when calling the API.
- **Where:** In Foundry, deployments are created in the context of your **Foundry resource** (your **open-ai-fd-lab-01**) and can be scoped to a **project** (e.g. **proj-default**) in the portal; the same resource is used for CLI/ARM.
- **Prerequisites:** Cognitive Services Contributor (or equivalent) on the resource; Azure subscription (Azure for Students has limited quota — see below).

---

## 2. What it takes to deploy a model

1. **Pick a model** from the catalog available in your **region** (you’re in **northcentralus**). See list below.
2. **Pick a deployment type (SKU):** e.g. **Standard** or **GlobalStandard** (TPM-based). Capacity is in units of 1 = 1,000 TPM for Standard.
3. **Quota:** Your subscription must have **available TPM quota** for that model + region. You allocate some of that quota to this deployment when you create it.
4. **Create the deployment** via:
   - **Portal (recommended for first deploy):** [Microsoft Foundry](https://ai.azure.com) → **Discover** → **Models** → pick model → **Deploy** (Custom or Default) → set deployment name and complete. This shows quota and any errors (e.g. “Insufficient quota”).
   - **Azure CLI:** `az extension add -n cognitiveservices` then `az cognitiveservices account deployment create` with `--model-name`, `--model-version`, `--model-format`, `--sku-name`, `--sku-capacity`.
   - **ARM/Bicep:** PUT to `.../Microsoft.CognitiveServices/accounts/{account}/deployments/{name}` or use the Bicep template from the [create-model-deployments](https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-models/how-to/create-model-deployments) doc.

**Azure OpenAI models sold directly by Azure** (e.g. gpt-4o-mini, text-embedding-ada-002) do **not** require Azure Marketplace. Partner/community models may require Marketplace acceptance.

---

## 3. Free tier / tokens (Azure for Students)

- **Azure for Students** has **limited** Azure OpenAI/Foundry quota. Many users see **“Insufficient quota for selected options”** when deploying (e.g. gpt-4o-mini).
- **Free tokens:** There is no separate “free token” bucket documented; you get **default TPM quota per model/region**. On student subs that default is low; you can **request an increase** via [quota request](https://aka.ms/oai/stuquotarequest) (approval not guaranteed).
- **Which models might work:** Embedding models (e.g. **text-embedding-ada-002**) are sometimes available when chat models are not. **gpt-4o-mini** often hits quota limits on student subs. Try in the portal to see current availability.
- **Shared quota:** Foundry can provide a **shared quota pool** for temporary testing; production should use dedicated quota. In **Operate → Quota** you can see and reallocate TPM between deployments.

---

## 4. Models available in your region (northcentralus)

These were listed via `Get-AzCognitiveServicesModel -Location northcentralus`. You can deploy any of these **if** you have quota.

**OpenAI (sold by Azure, no Marketplace):**

| Model                     | Version    | Example SKUs        |
|---------------------------|------------|----------------------|
| text-embedding-ada-002    | 2          | Standard, GlobalStandard |
| text-embedding-3-small    | 1          | (check portal/CLI)  |
| text-embedding-3-large    | 1          | (check portal/CLI)  |
| gpt-4o-mini               | 2024-07-18 | Standard, GlobalStandard |
| gpt-35-turbo               | 0125       | (check portal/CLI)  |
| gpt-4o                     | 2024-11-20 | (check portal/CLI)  |
| o1-mini, o3-mini, etc.     | (various)  | (check portal/CLI)  |

**Microsoft (sold by Azure):**

| Model              | Version | Example SKU   |
|--------------------|---------|---------------|
| Phi-4-mini-instruct| 1       | GlobalStandard |

**Others in region:** DeepSeek, Mistral, Cohere, Meta Llama, and more (see full list from `Get-AzCognitiveServicesModel -Location northcentralus`). Partner/community models may require Marketplace.

---

## 5. Try to deploy one (recommended path)

**Option A — Portal (most reliable for first deploy and quota visibility)**  
1. Sign in to [Microsoft Foundry](https://ai.azure.com), ensure **proj-default** (or your project) is selected.  
2. **Discover** (top right) → **Models**.  
3. Pick a model (e.g. **text-embedding-ada-002** or **gpt-4o-mini**).  
4. **Deploy** → **Custom settings** (or Default).  
5. Set deployment name, accept terms if shown, **Deploy**.  
6. If you see **“Insufficient quota”**, try another model (e.g. embedding) or request quota: [aka.ms/oai/stuquotarequest](https://aka.ms/oai/stuquotarequest).

**Option B — Azure CLI (if you install Azure CLI)**  
```bash
az login
az account set --subscription 36a26ac3-0291-439a-ac8b-fecdfc40c4dc
az extension add -n cognitiveservices

# Example: deploy text-embedding-ada-002
az cognitiveservices account deployment create \
  -n open-ai-fd-lab-01 \
  -g open-ai-rg-lab-01 \
  --deployment-name embed-ada \
  --model-name text-embedding-ada-002 \
  --model-version 2 \
  --model-format OpenAI \
  --sku-name GlobalStandard \
  --sku-capacity 1
```

**What we tried from this repo:**  
- **ARM PUT** to create a deployment (Standard / GlobalStandard, text-embedding-ada-002) returned **401 InvalidAuthenticationToken**. So from this environment the ARM token was not accepted for that call; deployment via **portal or Azure CLI** (after `az login`) is the reliable path.

---

## 6. After deploying

- **List deployments:** Portal **Build** → **Models**, or CLI: `az cognitiveservices account deployment list -n open-ai-fd-lab-01 -g open-ai-rg-lab-01`.
- **Quota/allocations:** **Operate** → **Quota** in the Foundry portal (Token per minute tab).
- **Use the model:** Endpoint base: `https://open-ai-fd-lab-01.services.ai.azure.com`; in requests set `model` to your **deployment name**.

---

## 7. References

| Topic | URL |
|-------|-----|
| Deploy in portal | https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-models/how-to/deploy-foundry-models |
| Deploy with CLI/Bicep | https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-models/how-to/create-model-deployments |
| Quotas and limits (Foundry) | https://learn.microsoft.com/en-us/azure/foundry/openai/quotas-limits |
| Manage quota | https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/quota |
| Azure for Students + OpenAI | https://learn.microsoft.com/en-us/answers/questions/2183197/azure-openai-with-azure-for-students |
| Quota request (student) | https://aka.ms/oai/stuquotarequest |
