# Azure OpenAI (classic) — resource and deployment

**Azure OpenAI (classic)** = Cognitive Services account with **Kind: OpenAI**. Older product; Foundry (Kind: AIServices) is the newer superset. Same ARM deployment API; quota is per subscription/region/model.

## Your existing resource

| Name | Resource Group | Kind | Location |
|------|----------------|------|----------|
| **doesitscript-8935** | rg-joshua.castillo-8935 | **OpenAI** | eastus |

## Create a classic Azure OpenAI resource (PowerShell)

```powershell
New-AzCognitiveServicesAccount `
  -ResourceGroupName "<resource-group>" `
  -Name "<account-name>" `
  -Type OpenAI `
  -SkuName S0 `
  -Location "<region>"
```

Only **Standard (S0)** tier is available for Azure OpenAI. Region must support the models you want to deploy.

## Deploy a model (same ARM API as Foundry)

Use **Invoke-AzRestMethod** with path:

`/subscriptions/{subId}/resourceGroups/{rg}/providers/Microsoft.CognitiveServices/accounts/{account}/deployments/{deploymentName}?api-version=2024-10-01`

Body: `{ "sku": { "name": "Standard", "capacity": 1 }, "properties": { "model": { "format": "OpenAI", "name": "<model>", "version": "<version>" } } }`

For **classic OpenAI** the SKU name is typically **Standard** (not GlobalStandard). Capacity 1 = 1,000 TPM.

## Commands reference

| Action | Command |
|--------|--------|
| List Cognitive Services accounts | `Get-AzCognitiveServicesAccount` |
| Get API keys | `Get-AzCognitiveServicesAccountKey -ResourceGroupName <rg> -Name <account>` |
| List deployments | `Get-AzCognitiveServicesAccountDeployment -ResourceGroupName <rg> -AccountName <account>` |
| Create resource | `New-AzCognitiveServicesAccount -Type OpenAI -SkuName S0 ...` |
| Remove resource | `Remove-AzCognitiveServicesAccount -ResourceGroupName <rg> -Name <account>` |

## Deployment result (2026-03-11)

Deployment of **text-embedding-ada-002** (deployment name: **embed-ada**) to the classic OpenAI resource **doesitscript-8935** (eastus) **succeeded**.

- **ProvisioningState:** Succeeded  
- **SKU:** Standard, capacity 1 (1,000 TPM)  
- **Conclusion:** We are **not** blocked from deploying models on **Azure OpenAI (classic)** (this resource had quota). The blocker was only on the **Foundry** resource (open-ai-fd-lab-01, northcentralus), which had 0 TPM for the same model.

To reproduce: run `./docs/azure/deploy-openai-classic.ps1` after `Connect-AzAccount`.

## References

- [Create and deploy Azure OpenAI resource (classic)](https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource)
- [Deployments Create Or Update REST API](https://learn.microsoft.com/en-us/rest/api/aiservices/accountmanagement/deployments/create-or-update)
