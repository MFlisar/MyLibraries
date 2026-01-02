$JSON = "projects.json"
$README = "README.md"
$START_MARKER = "<!-- LIBRARIES START -->"
$END_MARKER = "<!-- LIBRARIES END -->"
$DEFAULT_IMAGE = "media/kotlin-icon.png"
$MAX_IMAGE_WIDTH = "200px"

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
    $output += "<table>`n"
    $output += "  <tr><th>Image</th><th>Libary</th><th>Description</th></tr>`n"
    foreach ($item in $items) {
        $name = $item.name
        $desc = $item.description + "<br>" + "<img src='https://img.shields.io/maven-central/v/$($item.'main-maven-id')?label=&style=for-the-badge&labelColor=444444&color=grey' alt='maven version'/>"
        $image = if ($item.PSObject.Properties['image']) { $item.image } else { $DEFAULT_IMAGE }
        $repo_url = "https://github.com/MFlisar/$name"
        $output += "  <tr>" +
            "<td valign='top'><img src='$image' alt='Image' style='max-width:$MAX_IMAGE_WIDTH;'/></td>" +
            "<td valign='top'><a href='$repo_url'>$name</a></td>" +
            "<td valign='top'>$desc</td>" +
            "</tr>`n"
    }
    $output += "</table>`n"
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
