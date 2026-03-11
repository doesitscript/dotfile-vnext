# Deploy a model to Azure OpenAI (classic) resource — Kind: OpenAI
# Run in pwsh AFTER: Connect-AzAccount
# Targets: doesitscript-8935 (eastus) by default. Override with params if needed.

param(
    [string] $ResourceGroupName = "rg-joshua.castillo-8935",
    [string] $AccountName       = "doesitscript-8935",
    [string] $DeploymentName    = "embed-ada",
    [string] $ModelName         = "text-embedding-ada-002",
    [string] $ModelVersion      = "2"
)

$ErrorActionPreference = "Stop"
$subId = (Get-AzContext).Subscription.Id

# Classic OpenAI uses SKU "Standard" (not GlobalStandard)
$path = "/subscriptions/$subId/resourceGroups/$ResourceGroupName/providers/Microsoft.CognitiveServices/accounts/$AccountName/deployments/$DeploymentName" + "?api-version=2024-10-01"

$payload = @{
  sku        = @{ name = "Standard"; capacity = 1 }
  properties = @{ model = @{ format = "OpenAI"; name = $ModelName; version = $ModelVersion } }
} | ConvertTo-Json -Depth 5 -Compress

Write-Host "Azure OpenAI (classic): creating deployment '$DeploymentName' ($ModelName) on $AccountName..."
try {
  $r = Invoke-AzRestMethod -Path $path -Method PUT -Payload $payload
  $content = $r.Content | ConvertFrom-Json
  Write-Host "SUCCESS. ProvisioningState: $($content.properties.provisioningState)"
  $content | ConvertTo-Json -Depth 4
} catch {
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
  throw
}
