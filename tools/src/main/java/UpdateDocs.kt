import classes.ProjectItem
import classes.Projects
import kotlinx.serialization.json.Json
import utils.MarkdownUtil
import java.io.File
import java.lang.System

fun main() {

    val root = File(System.getProperty("user.dir")).parentFile

    val fileProjectsJson = File(root, "projects.json")
    val fileZensical = File(root, "zensical.toml")
    val defaultImagePath = "media/kotlin-icon.png"
    val folderLibraries = File(root, "docs/libraries/")

    // 1) Lösche alle bestehenden Markdown-Dateien
    if (folderLibraries.exists()) {
        folderLibraries.listFiles { f -> f.extension == "md" }?.forEach { it.delete() }
    }

    // 2) Lese JSON und generiere neue Markdown-Dateien
    val jsonContent = fileProjectsJson.readText(Charsets.UTF_8)
    val projects = Json.decodeFromString<Projects>(jsonContent)
    for (projectGroup in projects.projects) {

        val items = projectGroup.items
        val fileNameFromGroup = projectGroup.fileNameFromGroup

        val pageHeader = """
            ---
            icon: lucide/blocks
            title: ${projectGroup.group}
            ---

        """.trimIndent()

        val tableHeaders = listOf("Image", "Library", "Description")
        val table = MarkdownUtil.buildTable(
            headers = tableHeaders,
            items = items
        ) { item: ProjectItem ->
            listOf(
                item.markdownTableCellImage(defaultImagePath) + "{: style=\"max-width:100%;height:auto;\"}",
                item.markdownTableCellLibrary(),
                item.markdownTableCellDescription()
            )
        }

        // baue Inhalt der Datei
        val content = buildString {
            append(pageHeader)
            appendLine()
            append(table)
            append("{: style=\"table-layout:fixed;width:100%;\"}")
        }

        // schreibe Datei
        val file = File(folderLibraries, "$fileNameFromGroup.md")
        file.writeText(content, Charsets.UTF_8)
    }

    // 3) update navigation in zensical
    val navInset =      "        "
    val navStartTag =   "        # BEGIN-NAV-LIBRARIES"
    val navEndTag =     "        # END-NAV-LIBRARIES"
    val zensicalContent = fileZensical.readText(Charsets.UTF_8)
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
    fileZensical.writeText(updatedZensicalContent, Charsets.UTF_8)

    println("Docs generated.")
}
