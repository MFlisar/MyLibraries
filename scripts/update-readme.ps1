function Convert-MarkdownToHtml($markdown) {
    $html = ConvertFrom-Markdown -InputObject $markdown
    return $html.Html
}

function Get-Image($item, $defaultImage) {
    return $item.PSObject.Properties['image'] ? $item.image : $defaultImage
}

function Build-Table($items, $maxImageWidth, $defaultImage) {
    $table = "<table style='padding:10px;'>`n"
    $table += "  <tr><th>Image</th><th>Libary</th><th>Description</th></tr>`n"
    foreach ($item in $items) {
        $name = $item.name
        $descHtml = Convert-MarkdownToHtml $item.description
        $desc = $descHtml + "<picture><img src='https://img.shields.io/maven-central/v/$($item.'main-maven-id')?label=&style=for-the-badge&labelColor=444444&color=grey' alt='maven version'/></picture>"
        $image = Get-Image $item $defaultImage
        $repo_url = "https://github.com/MFlisar/$name"
        $table += "  <tr>" +
            "<td valign='top'><picture><img src='$image' alt='Image' style='max-width:$maxImageWidth;'/></picture></td>" +
            "<td valign='top'><a href='$repo_url'>$name</a></td>" +
            "<td valign='top'>$desc</td>" +
            "</tr>`n"
    }
    $table += "</table>`n"
    return $table
}

function Update-Readme($readmePath, $startMarker, $endMarker, $output) {
    $readmeLines = Get-Content $readmePath
    $startIdx = ($readmeLines | Select-String -Pattern ([regex]::Escape($startMarker))).LineNumber
    $endIdx = ($readmeLines | Select-String -Pattern ([regex]::Escape($endMarker))).LineNumber
    if ($startIdx -and $endIdx -and $endIdx -ge $startIdx) {
        $startIdx = $startIdx - 1
        $endIdx = $endIdx - 1
        $before = $readmeLines[0..$startIdx]
        $after = $readmeLines[$endIdx..($readmeLines.Count-1)]
        $outputLines = $output -split "`n"
        $newReadme = @($before) + $outputLines + $after
        $newReadmeString = $newReadme -join "`n"
        $newReadmeString = $newReadmeString -replace "(`n){3,}", "`n`n"
        Set-Content -Path $readmePath -Value $newReadmeString
    }
}

# --------------
# - SKRIPT
# --------------

$JSON = "projects.json"
$README = "README.md"
$START_MARKER = "<!-- LIBRARIES START -->"
$END_MARKER = "<!-- LIBRARIES END -->"
$DEFAULT_IMAGE = "media/kotlin-icon.png"
$MAX_IMAGE_WIDTH = "200px"

$jsonContent = Get-Content $JSON -Raw | ConvertFrom-Json
$projects = $jsonContent[0].projects

$output = ""
foreach ($groupObj in $projects) {
    $group = $groupObj.group
    $open_flag = $groupObj.open
    $items = $groupObj.items
    $output += "`n<details" + ($(if ($open_flag) { " open" } else { "" })) + ">`n`n"
    $output += "<summary>$group ($($items.Count))</summary><br>`n`n"
    $output += Build-Table $items $MAX_IMAGE_WIDTH $DEFAULT_IMAGE
    $output += "`n</details>`n`n"
}

Update-Readme $README $START_MARKER $END_MARKER $output

Write-Host "README aktualisiert."