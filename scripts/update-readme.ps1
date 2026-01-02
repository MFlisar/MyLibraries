$JSON = "projects.json"
$README = "README.md"
$START_MARKER = "<!-- LIBRARIES START -->"
$END_MARKER = "<!-- LIBRARIES END -->"
$DEFAULT_IMAGE = "media/kotlin-icon.png"

# Projekte-Liste aus JSON holen
$jsonContent = Get-Content $JSON -Raw | ConvertFrom-Json
$projects = $jsonContent[0].projects

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
    $output += "| Image | Libary | Description |`n| - | - | - |`n"
    foreach ($item in $items) {
        $name = $item.name
        $desc = $item.description
        $image = $item.PSObject.Properties['image'] ? $item.image : $DEFAULT_IMAGE
        $repo_url = "https://github.com/MFlisar/$name"
        $output += "| ![Image]($image) | [$name]($repo_url) | $desc |`n"
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
    $newReadmeString = $newReadme -join "`n"
    # Mehrfache Leerzeilen am Ende reduzieren
    $newReadmeString = $newReadmeString -replace "(`n){3,}", "`n`n"
    Set-Content -Path $README -Value $newReadmeString
}

Write-Host "README aktualisiert."
