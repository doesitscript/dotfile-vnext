# Deploy text-embedding-ada-002 to open-ai-fd-lab-01
# Run in pwsh AFTER: Connect-AzAccount
# Usage: . ./docs/azure/deploy-embed-ada.ps1

$ErrorActionPreference = "Stop"
$subId     = (Get-AzContext).Subscription.Id
$rg        = "open-ai-rg-lab-01"
$account   = "open-ai-fd-lab-01"
$deployName = "embed-ada"

# Path for Invoke-AzRestMethod (uses current Az context for auth — no manual token)
$path = "/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.CognitiveServices/accounts/$account/deployments/$deployName" + "?api-version=2024-10-01"

$payload = @{
  sku        = @{ name = "GlobalStandard"; capacity = 1 }
  properties = @{ model = @{ format = "OpenAI"; name = "text-embedding-ada-002"; version = "2" } }
} | ConvertTo-Json -Depth 5 -Compress

Write-Host "Creating deployment '$deployName' (text-embedding-ada-002)..."
try {
  $r = Invoke-AzRestMethod -Path $path -Method PUT -Payload $payload
  $content = $r.Content | ConvertFrom-Json
  Write-Host "SUCCESS. ProvisioningState: $($content.properties.provisioningState)"
  $content | ConvertTo-Json -Depth 4
} catch {
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  throw
}
