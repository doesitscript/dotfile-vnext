# Patches MediaTek/TP-Link mtkwl6ex-style INFs so Windows Server can match
# desktop-only NTAMD64.10.0...16299 decorations.
param(
    [Parameter(Mandatory = $true)]
    [string]$StagingDir,

    [Parameter(Mandatory = $true)]
    [string]$InfName
)

$ErrorActionPreference = 'Stop'

$infPath = Get-ChildItem -LiteralPath $StagingDir -Recurse -Filter $InfName -ErrorAction SilentlyContinue |
    Select-Object -First 1

if (-not $infPath) {
    throw "INF '$InfName' not found under $StagingDir"
}

$original = Get-Content -LiteralPath $infPath.FullName -Raw
$content = $original
$changes = New-Object System.Collections.Generic.List[string]

$manufacturerPattern = '(?m)^(%[^%]+%\s*=\s*\w+,\s*NTAMD64\.10\.0\.\.\.16299)(\s*)$'
$content = [regex]::Replace(
    $content,
    $manufacturerPattern,
    {
        param($m)
        $line = $m.Groups[1].Value
        if ($line -match ',\s*NTAMD64\.10\.0\s*$') {
            return $m.Value
        }
        $changes.Add('manufacturer_decoration_extended')
        return ($line + ', NTAMD64.10.0' + $m.Groups[2].Value)
    }
)

$sectionPattern = '(?ms)\[(?<name>\w+\.NTAMD64\.10\.0\.\.\.16299)\](?<body>.*?)(?=\r?\n\[|\z)'
$sectionMatches = [regex]::Matches($content, $sectionPattern)
foreach ($match in $sectionMatches) {
    $shortName = $match.Groups['name'].Value -replace '\.\.\.16299$', ''
    if ($content -match "(?ms)\[$([regex]::Escape($shortName))\]") {
        continue
    }
    $changes.Add("duplicated_section:$shortName")
    $content += "`r`n[$shortName]$($match.Groups['body'].Value)"
}

if ($content -match '(?m)^CatalogFile\s*=') {
    $content = [regex]::Replace(
        $content,
        '(?m)^CatalogFile\s*=.*$',
        '; CatalogFile disabled after Server INF patch (catalog no longer matches edited INF)'
    )
    $changes.Add('catalog_file_disabled')
}

if ($content -eq $original) {
    $Ansible.Changed = $false
    $Ansible.Result = @{
        changed = $false
        inf_path = $infPath.FullName
        changes = @()
        status = 'no_changes_needed'
    }
} else {
    Set-Content -LiteralPath $infPath.FullName -Value $content -Encoding Unicode -NoNewline
    $Ansible.Changed = $true
    $Ansible.Result = @{
        changed = $true
        inf_path = $infPath.FullName
        changes = @($changes)
        status = 'patched'
    }
}
