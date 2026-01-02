# Benötigt: powershell-yaml (Install-Module -Name powershell-yaml -Scope CurrentUser)
Install-Module -Name powershell-yaml -Scope CurrentUser
Import-Module powershell-yaml

$YML = "data/projects.yml"
$README = "README.md"
$START_MARKER = "<!-- LIBRARIES START -->"
$END_MARKER = "<!-- LIBRARIES END -->"

# Projekte-Liste aus YAML holen
$yamlContent = Get-Content $YML -Raw
$parsed = ConvertFrom-Yaml $yamlContent
$projects = $parsed[0].projects

$output = ""
foreach ($groupObj in $projects) {
    $group = $groupObj.group
    $open_flag = $groupObj.open
    $items = $groupObj.items
    if ($open_flag -eq $true) {
        $output += "`n<details open>`n`n"
    } else {
        $output += "`n<details>`n`n"
    }
    $output += "<summary>$group ($($items.Count))</summary><br>`n`n"
    $output += "| Libary | Description |`n| - | - |`n"
    foreach ($item in $items) {
        $name = $item.name
        $desc = $item.description
        $repo_url = "https://github.com/MFlisar/$name"
        $output += "| [$name]($repo_url) | $desc |`n"
    }
    $output += "`n</details>`n`n"
}

# Bereich im README ersetzen (ohne Tempfile)
$readmeLines = Get-Content $README

# Index des Start- und End-Markers finden
$startIdx = ($readmeLines | Select-String -Pattern ([regex]::Escape($START_MARKER))).LineNumber
$endIdx = ($readmeLines | Select-String -Pattern ([regex]::Escape($END_MARKER))).LineNumber

if ($startIdx -and $endIdx -and $endIdx -ge $startIdx) {
    $startIdx = $startIdx - 1  # 0-basiert
    $endIdx = $endIdx - 1
    $before = $readmeLines[0..$startIdx]
    $after = $readmeLines[$endIdx..($readmeLines.Count-1)]
    $outputLines = $output -split "`n"
    $newReadme = @($before) + $outputLines + $after
    Set-Content -Path $README -Value $newReadme
}

# Ergebnis prüfen
$check = Get-Content $README -Raw
if ($check -match [regex]::Escape($output.Trim())) {
    Write-Host "README erfolgreich aktualisiert."
} else {
    Write-Host "Fehler: README wurde nicht korrekt aktualisiert!"
}
