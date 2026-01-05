import classes.ProjectItem
import classes.Projects
import kotlinx.serialization.json.Json
import utils.MarkdownUtil
import java.io.File
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Paths

fun main() {

    val fileProjectsJson = "projects.json"
    val fileZensical = "zensical.toml"
    val defaultImagePath = "/media/kotlin-icon.png"
    val maxImageWidth = "200px"
    val librariesFolder = "docs/libraries/"

    // 1) Lösche alle bestehenden Markdown-Dateien
    val dir = File(librariesFolder)
    if (dir.exists()) {
        dir.listFiles { f -> f.extension == "md" }?.forEach { it.delete() }
    }

    // 2) Lese JSON und generiere neue Markdown-Dateien
    val jsonContent = String(Files.readAllBytes(Paths.get(fileProjectsJson)), StandardCharsets.UTF_8)
    val projects = Json.decodeFromString<Projects>(jsonContent)
    for (projectGroup in projects.projects) {

        val items = projectGroup.items
        val fileNameFromGroup = projectGroup.fileNameFromGroup

        val pageHeader = """
            ---
            icon: lucide/blocks
            ---

        """.trimIndent()

        val tableHeaders = listOf("Image", "Library", "Description")
        val table = MarkdownUtil.buildTable(
            headers = tableHeaders,
            items = items
        ) { item: ProjectItem ->
            listOf(
                item.markdownTableCellImage(maxImageWidth, defaultImagePath),
                item.markdownTableCellLibrary(),
                item.markdownTableCellDescription()
            )
        }

        // baue Inhalt der Datei
        val content = buildString {
            append(pageHeader)
            appendLine()
            append(table)
        }

        // schreibe Datei
        val filePath = Paths.get(librariesFolder, "$fileNameFromGroup.md")
        Files.write(filePath, content.toByteArray(StandardCharsets.UTF_8))
    }

    // 3) update navigation in zensical
    val navInset =      "        "
    val navStartTag =   "        # BEGIN-NAV-LIBRARIES"
    val navEndTag =     "        # END-NAV-LIBRARIES"
    val zensicalContent = String(Files.readAllBytes(Paths.get(fileZensical)), StandardCharsets.UTF_8)
    val newNavigation = buildString {
        append("$navStartTag\n")
        for (projectGroup in projects.projects) {
            val group = projectGroup.group
            val fileNameFromGroup = projectGroup.fileNameFromGroup
            append("$navInset{ \"$group\" = \"libraries/$fileNameFromGroup.md\" },\n")
        }
        append(navEndTag)
    }

    val updatedZensicalContent = zensicalContent.replace(
        Regex("(?s)$navStartTag.*?$navEndTag"),
        newNavigation
    )
    Files.write(Paths.get(fileZensical), updatedZensicalContent.toByteArray(StandardCharsets.UTF_8))

    println("Docs generated.")
}
