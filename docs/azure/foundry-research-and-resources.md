# Azure AI Foundry — research, your resources, models, and allocations

**Researched:** Microsoft Learn (AI Foundry REST APIs, Quota, Models List, Deployments List, Authentication), Az.CognitiveServices cmdlets, live subscription data.

---

## 1. What is Foundry (Microsoft Foundry / Azure AI Foundry)

- **Microsoft Foundry** (portal: [ai.azure.com](https://ai.azure.com)) is the experience for building and operating AI apps. “Azure AI Foundry” in docs refers to the same platform and its APIs.
- **Foundry project** (e.g. **proj-default**): Organizes work (agents, models, endpoints, connections). Your project **proj-default** is the default project for the AI resource **open-ai-fd-lab-01**.
- **Parent resource** = the Cognitive Services / AI Services account that hosts the project (your **open-ai-fd-lab-01**).
- **Models** = base or fine-tuned models you can deploy. Deployments expose a model behind an endpoint with a name you use in code.
- **Allocations** = quota assigned to deployments:
  - **Token per minute (TPM)** — for standard (pay-per-use) deployments.
  - **Provisioned throughput unit (PTU)** — for provisioned deployments.

---

## 2. Your resources (what we have)

From your subscription **Azure for Students** (ID: `36a26ac3-0291-439a-ac8b-fecdfc40c4dc`):

| Resource | Type | Resource group | Location |
|----------|------|----------------|----------|
| **open-ai-fd-lab-01** | Microsoft.CognitiveServices/accounts | open-ai-rg-lab-01 | northcentralus |
| **open-ai-fd-lab-01/proj-default** | Microsoft.CognitiveServices/accounts/projects | open-ai-rg-lab-01 | northcentralus |
| aisearchdsazlab0136a26a | Microsoft.Search/searchServices | open-ai-rg-lab-01 | northcentralus |
| storagedsazlab0136a26a, stdsazlab0136a26a | Microsoft.Storage/storageAccounts | open-ai-rg-lab-01 | northcentralus |
| doesitscript-8935 | Microsoft.CognitiveServices/accounts | rg-joshua.castillo-8935 | eastus |

**Project details (from your screenshot):**

- **Project name:** proj-default (Default project)
- **Endpoint:** `https://open-ai-fd-lab-01.services.ai.azure.com/api/proj`
- **Resource group:** open-ai-rg-lab-01
- **Location:** northcentralus
- **Manage in Azure Portal:** use “View resource” → “Manage this resource in the Azure Portal”

---

## 3. How to view project details

- **In Foundry portal:** Sign in at [ai.azure.com](https://ai.azure.com) → select project **proj-default** (top left) → project landing page shows basic config, **Users**, **Connected resources**.
- **Basic configuration:** Resource ID, parent resource, endpoint, resource group, location, subscription — as in your screenshot.
- **Models + endpoints:** In the left pane, open **Models + endpoints** to see deployments grouped by connection; select a deployment for details and “Open in playground”.
- **Management Center:** From the project landing page, use Management Center to see connected resources and project settings.

---

## 4. Models — what they are and how to list them

- **Catalog models** = models available in a region (e.g. GPT-4o, o3, embeddings). You deploy from this catalog.
- **Deployed models** = deployments in a project; each has a deployment name, model, SKU, and quota allocation.

**List catalog models (region):**

- **PowerShell:** `Get-AzCognitiveServicesModel -Location northcentralus`  
  Returns many models (Kind: OpenAI, SkuName: S0). Model name/version live in the `.ModelProperty` of each object.
- **REST (management):**  
  `GET https://management.azure.com/subscriptions/{subscriptionId}/providers/Microsoft.CognitiveServices/locations/northcentralus/models?api-version=2025-06-01`  
  Requires ARM auth; returns model list with name, version, publisher, capabilities, SKUs (including provisioned capacity).

**List deployed models (project):**

- **Foundry portal:** **Models + endpoints** in the left pane.
- **REST (project API):**  
  `GET {endpoint}/deployments?api-version=v1`  
  With `{endpoint}` = project base, e.g.  
  `https://open-ai-fd-lab-01.services.ai.azure.com/api/projects/proj-default`  
  or `.../api/projects/_project` for default project.  
  Auth: Entra ID token for the AI resource (e.g. `https://cognitive.azure.com`) or API key; without the right token the project API returns 401.

**Result for your subscription:** Catalog models in **northcentralus** are listed successfully via `Get-AzCognitiveServicesModel -Location northcentralus`. **Deployments** for **proj-default** returned none from `Get-AzCognitiveServicesAccountDeployment` (account-level); for Foundry projects, deployments are project-scoped and are best viewed in the portal under **Models + endpoints** or via the project deployments REST API with proper auth.

---

## 5. Allocations — what they are and where to see them

- **Allocation** = quota assigned to a deployment (TPM for standard, PTU for provisioned). Azure assigns quota per subscription, region, and model; you can move quota between deployments in the Foundry portal.
- **Shared quota:** Foundry can provide a shared pool for temporary testing; production should use dedicated quota.

**Where to view and manage allocations:**

1. Sign in at [Microsoft Foundry](https://ai.azure.com) (New Foundry toggle on).
2. Select **Operate** (top right).
3. Select **Quota** in the left pane.
4. Two tabs:
   - **Provisioned throughput unit** — PTU allocations for provisioned deployments.
   - **Token per minute** — TPM allocations for standard deployments.
5. Click a deployment in the list → details pane on the right shows **current quota allocation**, **usage**, and **Affiliated deployments using shared quota**. Use the pencil icon to edit allocation.

**Roles:** To view quota: **Cognitive Services Usages Reader** (subscription). To edit allocation: **Cognitive Services Contributor** + **Cognitive Services Usages Reader**. To request quota increases: **Owner** or **Contributor** on the subscription.

**Identify deployments that have allocations:** In **Operate → Quota**, any deployment listed there has an allocation (TPM or PTU). Deployments with no allocation won’t appear or will show zero.

---

## 6. Summary table

| Goal | How |
|------|-----|
| **Learn about Foundry** | Portal: ai.azure.com; Docs: Azure AI Foundry / Microsoft Foundry on Microsoft Learn. |
| **List your resources** | Done above (open-ai-fd-lab-01, proj-default, RG, location). PowerShell: `Get-AzResource -ResourceGroupName open-ai-rg-lab-01`. |
| **View project details** | Portal: project **proj-default** → Basic configuration, Users, Connected resources, Management Center. |
| **Learn about models** | Docs: “Working with models” (Azure OpenAI in Foundry). Catalog: `Get-AzCognitiveServicesModel -Location northcentralus`. |
| **List deployed models** | Portal: **Models + endpoints**. REST: `GET {projectEndpoint}/deployments?api-version=v1` with correct auth. |
| **Learn about allocations** | Docs: “Manage and increase quotas for resources” (Foundry). |
| **View allocations / find models with allocations** | Portal: **Operate → Quota** → choose **Token per minute** or **Provisioned throughput unit**; list shows deployments and their allocations. |

---

## 7. References

| Topic | URL |
|-------|-----|
| Deployments - List (Foundry) | https://learn.microsoft.com/en-us/rest/api/aifoundry/aiprojects/deployments/list |
| Models - List (management) | https://learn.microsoft.com/en-us/rest/api/aifoundry/accountmanagement/models/list |
| Manage quotas (Foundry) | https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/quota |
| Create a project | https://learn.microsoft.com/en-us/azure/ai-studio/how-to/create-projects |
| Working with models (OpenAI in Foundry) | https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/working-with-models |
| Authentication (Foundry) | https://learn.microsoft.com/en-us/azure/ai-foundry/concepts/authentication-authorization-foundry |

---

*Report generated after researching Foundry docs, listing your Azure resources and regional models, and summarizing portal steps for project details, deployments, and allocations.*
