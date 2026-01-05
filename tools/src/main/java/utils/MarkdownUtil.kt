package utils

import com.vladsch.flexmark.html.HtmlRenderer
import com.vladsch.flexmark.parser.Parser
import com.vladsch.flexmark.util.data.MutableDataSet

object MarkdownUtil {

    val options = MutableDataSet()
    val parser = Parser.builder(options).build()
    val renderer = HtmlRenderer.builder(options).build()

    fun convertMarkdownToHtml(markdown: String): String {
        val document = parser.parse(markdown)
        return renderer.render(document)
    }

    fun <T> buildTable(
        headers: List<String>,
        items: List<T>,
        itemToCells: (T) -> List<String>
    ) : String {

        // build a markdown table
        val sb = StringBuilder()

        // header
        sb.append("|")
        for (header in headers) {
            sb.append(" $header |")
        }
        sb.append("\n|")
        for (i in headers.indices) {
            sb.append(" --- |")
        }

        // rows
        for (item in items) {
            sb.append("\n|")
            val cells = itemToCells(item)
            for (cell in cells) {
                sb.append(" $cell |")
            }
        }

        return sb.toString()
    }
}