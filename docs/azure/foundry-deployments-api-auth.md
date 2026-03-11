# Foundry project deployments API — correct credential

The **401** on `GET {projectEndpoint}/deployments?api-version=v1` was due to **wrong token audience**, not missing deployments.

## What the API expects

- **Authentication:** `Authorization: Bearer <token>` (Entra ID). API key is **not** accepted for this project API on `*.services.ai.azure.com`.
- **Token audience (required):** The token must be for the **resource-specific** audience:
  - **`https://<your-resource-name>.services.ai.azure.com`**
  - For your resource: **`https://open-ai-fd-lab-01.services.ai.azure.com`**

These do **not** work (401):

- `https://management.azure.com` (ARM)
- `https://cognitiveservices.azure.com` (generic Cognitive Services)

## Get the token in PowerShell

```powershell
# 1. Sign in (interactive) so the token can be issued for the resource
Connect-AzAccount

# 2. Get a token with the resource-specific audience
$tokenObj = Get-AzAccessToken -ResourceUrl "https://open-ai-fd-lab-01.services.ai.azure.com"
$token = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($tokenObj.Token))

# 3. Call the deployments API
$headers = @{
  "Authorization" = "Bearer $token"
  "Content-Type"  = "application/json"
}
$uri = "https://open-ai-fd-lab-01.services.ai.azure.com/api/projects/proj-default/deployments?api-version=v1"
Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
```

Run this in an **interactive** `pwsh` session (not `pwsh -NoProfile` in a one-off command). If `Get-AzAccessToken -ResourceUrl "https://open-ai-fd-lab-01.services.ai.azure.com"` fails with `SharedTokenCacheCredential authentication failed`, run `Connect-AzAccount` in that same session and try again so the credential can obtain a token for that audience.

## Summary

| Cause of 401 | Fix |
|--------------|-----|
| Wrong token audience (e.g. ARM or generic Cognitive Services) | Use `Get-AzAccessToken -ResourceUrl "https://open-ai-fd-lab-01.services.ai.azure.com"` and send that token as `Bearer` on the request. |

Empty deployments would return **200** with an empty list, not 401.
