# Models and quota — do any avoid the same restriction?

**Context:** Deployment of **text-embedding-ada-002** failed with **InsufficientQuota** (quota limit 0 TPM for that model in your subscription/region). This doc summarizes whether any models or deployment types avoid that requirement.

---

## Short answer

- **Standard / GlobalStandard deployments** (what we used): **Every model** needs TPM quota assigned to your subscription for that model + region. There is no “no quota” option for this path.
- **Serverless API deployments:** Do **not** require quota from your subscription (pay-per-request). But they require a **paid Azure subscription**; **free or trial subscriptions (including Azure for Students) do not qualify.**
- **Azure for Students:** Many models show **0 TPM** in allowed regions. Some reports say **Legacy** models (e.g. Ada, Babbage) or **Global Batch** can have non-zero quota in some student subs — worth trying in the portal or via script, but not guaranteed.

So: **no model lets you bypass the “need quota” rule for standard deployments**; serverless avoids quota but is not available on Azure for Students.

---

## 1. Standard / GlobalStandard (what we used)

- Quota is **per subscription, per region, per model** in **Tokens Per Minute (TPM)**.
- You must have **available TPM** for that model in that region to create or use the deployment.
- **All** catalog models (embedding, chat, etc.) follow this for Standard/GlobalStandard; there are no standard deployments that “don’t need quota.”

**Your case:** text-embedding-ada-002 in **northcentralus** has quota limit **0** → deployment correctly rejected with InsufficientQuota.

---

## 2. Serverless API deployments

- **Do not use** your subscription’s TPM quota; billing is **pay-per-request**.
- **Requirement:** *“An Azure subscription with a valid payment method. Free or trial Azure subscriptions won't work.”*  
  So **Azure for Students is not eligible** for serverless in the docs.
- If you later use a **pay-as-you-go** subscription, serverless is the option that avoids the “same operational restriction” (no TPM quota needed).

Ref: [Deploy models as serverless API deployments (classic)](https://learn.microsoft.com/en-us/azure/foundry-classic/how-to/deploy-models-serverless).

---

## 3. Shared quota

- Foundry has a **shared quota pool** for **temporary** testing so you don’t have to wait for a quota increase.
- It is for **temporary test endpoints**, not production.
- It does **not** remove the need for quota in general: you still create a deployment; shared quota can supplement when there is *some* capacity. If your **limit is 0** for a model (as with text-embedding-ada-002), shared quota does not give you a way around that — you still need a non-zero quota limit for that model/region (e.g. via request or different subscription).

---

## 4. Azure for Students specifics

From [Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/5780281/quota-issues-(0-tpm)-and-regional-restrictions-on):

- **Structural limitation:** Student subscriptions often have **0 TPM** for modern models (e.g. gpt-4o, gpt-4o-mini, gpt-3.5-turbo) in the **allowed regions** (e.g. northcentralus, southcentralus, etc.).
- In some cases the **only** non-zero quota reported is for **“Legacy” models (Ada, Babbage, etc.)** or **Global Batch** (e.g. enqueued tokens), which may not fit real-time/agents use cases.
- **Practical options:**  
  - Submit a **quota request** ([aka.ms/oai/stuquotarequest](https://aka.ms/oai/stuquotarequest)); approval for student subs is **not guaranteed**.  
  - Use a **pay-as-you-go** (or education/sponsorship) subscription for more quota and fewer regional limits.

---

## 5. What you can try on Azure for Students

| Action | Notes |
|--------|--------|
| **Request quota** | [aka.ms/oai/stuquotarequest](https://aka.ms/oai/stuquotarequest) — ask for a small TPM (e.g. text-embedding-ada-002 or gpt-4o-mini) in your allowed region. |
| **Try Legacy models** | In the Foundry portal (Discover → Models), try deploying **ada** or **babbage** (if listed) in your region; some student subs have quota for these. You can adapt `deploy-embed-ada.ps1` to use `ada` / `babbage` and the same SKU to test. |
| **Check Operate → Quota** | In [ai.azure.com](https://ai.azure.com) → Operate → Quota → Token per minute, see which models (if any) show non-zero limit in your region. |
| **Switch subscription** | Pay-as-you-go (or university education tenant) for reliable TPM and optional serverless. |

---

## 6. References

| Topic | URL |
|--------|-----|
| Quotas and limits (Foundry) | https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits |
| Manage quota | https://learn.microsoft.com/en-us/azure/ai-foundry/how-to/quota |
| Serverless (no quota; paid sub required) | https://learn.microsoft.com/en-us/azure/foundry-classic/how-to/deploy-models-serverless |
| Quota request (student) | https://aka.ms/oai/stuquotarequest |
| Q&A: 0 TPM and regional restrictions (Azure for Students) | https://learn.microsoft.com/en-us/answers/questions/5780281/quota-issues-(0-tpm)-and-regional-restrictions-on |
