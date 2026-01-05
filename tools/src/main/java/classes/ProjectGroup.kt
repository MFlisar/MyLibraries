package classes

import kotlinx.serialization.Serializable

@Serializable
data class ProjectGroup(
    val group: String,
    val items: List<ProjectItem>,
) {
    val fileNameFromGroup = group
        .lowercase()
        .replace(" ", "-")
        .replace(Regex("[^a-zA-Z0-9-]"), "")
}