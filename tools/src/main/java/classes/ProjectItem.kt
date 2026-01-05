package classes

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import utils.MarkdownUtil

@Serializable
data class ProjectItem(
    val name: String,
    val description: String,
    val image: String? = null,
    @SerialName("main-maven-id") val mainMavenId: String,
) {
    fun getImage(defaultImage: String): String {
        return image ?: defaultImage
    }

    fun markdownTableCellImage(maxImageWidth: String, defaultImage: String): String {
        val image = getImage(defaultImage)
        return "<img src='$image' alt='Image' style='max-width:$maxImageWidth;'/>"
    }

    fun markdownTableCellLibrary(): String {
        val repoUrl = "https://github.com/MFlisar/$name"
        return "<a href='$repoUrl'>$name</a>"
    }

    fun markdownTableCellDescription() : String {
        return description
    }
}