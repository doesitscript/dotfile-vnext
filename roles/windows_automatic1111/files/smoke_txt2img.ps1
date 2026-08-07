$bodyObj = @{
  prompt = "a red cube on a table, simple"
  steps = 12
  width = 512
  height = 512
  cfg_scale = 5
}
$body = $bodyObj | ConvertTo-Json
$r = Invoke-RestMethod -Uri "http://127.0.0.1:7860/sdapi/v1/txt2img" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 300
Write-Output ("images=" + $r.images.Count)
