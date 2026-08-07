$ErrorActionPreference = "Continue"
$root = "F:\shares\public\apps\stable-diffusion-webui"
$py = "$root\venv\Scripts\python.exe"
$log = "C:\ProgramData\Ansible\windows_automatic1111\webui.log"

schtasks /End /TN Ansible-Automatic1111-WebUI 2>$null | Out-Null
Get-Process python -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2

if (-not (Test-Path $py)) {
  Write-Output "MISSING_VENV_PYTHON"
  exit 2
}

Write-Output "PIP_PINS"
& $py -m pip install "setuptools<81" "numpy<2" "wheel" "pytorch-lightning==1.9.5" "torchmetrics==1.4.0"
if ($LASTEXITCODE -ne 0) { Write-Output "PIP_PINS_FAILED"; exit 3 }

Write-Output "CLIP_INSTALL"
& $py -m pip install --no-build-isolation "https://github.com/openai/CLIP/archive/d50d76daa670286dd6cacf3bcd80b5e4823fc8e1.zip"
if ($LASTEXITCODE -ne 0) { Write-Output "CLIP_FAILED"; exit 4 }

New-Item -ItemType Directory -Force -Path "$root\repositories" | Out-Null

function Ensure-Repo {
  param(
    [string]$Name,
    [string]$Url,
    [string]$Commit
  )
  $dir = Join-Path "$root\repositories" $Name
  if (-not (Test-Path (Join-Path $dir ".git"))) {
    if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
    Write-Output "CLONE $Name"
    git clone $Url $dir
  } else {
    Write-Output "FETCH $Name"
    git -C $dir fetch --unshallow 2>$null
    git -C $dir fetch --all
  }
  if ($Commit) {
    git -C $dir fetch origin $Commit
    git -C $dir checkout $Commit
    if ($LASTEXITCODE -ne 0) {
      Write-Output "CHECKOUT_FAILED $Name $Commit"
      exit 5
    }
  }
}

Ensure-Repo -Name "stable-diffusion-stability-ai" -Url "https://github.com/w-e-w/stablediffusion.git" -Commit $null
Ensure-Repo -Name "k-diffusion" -Url "https://github.com/crowsonkb/k-diffusion.git" -Commit "ab527a9a6d347f364e3d185ba6d714e22d80cb3c"
Ensure-Repo -Name "generative-models" -Url "https://github.com/Stability-AI/generative-models.git" -Commit "45c443b316737a4ab6e40413d7794a7f5657c19f"
Ensure-Repo -Name "stable-diffusion-webui-assets" -Url "https://github.com/AUTOMATIC1111/stable-diffusion-webui-assets.git" -Commit $null
Ensure-Repo -Name "BLIP" -Url "https://github.com/salesforce/BLIP.git" -Commit $null

$bat = @"
@echo off
set PYTHON=C:\Python310\python.exe
set VENV_DIR=F:\shares\public\apps\stable-diffusion-webui\venv
set STABLE_DIFFUSION_REPO=https://github.com/w-e-w/stablediffusion.git
set COMMANDLINE_ARGS=--api --listen --port 7860 --medvram --opt-split-attention --skip-python-version-check --ckpt-dir F:/shares/public/models/stable-diffusion/Stable-diffusion
cd /d F:\shares\public\apps\stable-diffusion-webui
echo. | call webui.bat >> C:\ProgramData\Ansible\windows_automatic1111\webui.log 2>&1
"@
Set-Content -Path "$root\webui-user.bat" -Value $bat -Encoding ASCII

Remove-Item $log -ErrorAction SilentlyContinue
schtasks /Run /TN Ansible-Automatic1111-WebUI
Write-Output "STARTED"
exit 0
