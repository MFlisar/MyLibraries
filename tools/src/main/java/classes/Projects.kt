package classes

import kotlinx.serialization.Serializable

@Serializable
data class Projects(
    val projects: List<ProjectGroup>,
)