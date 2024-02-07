package io.greenglass.hydroponics.application.models.node

//import io.greenglass.host.sparkplug.models.Metric
import io.greenglass.sparkplug.models.Metric
import io.greenglass.sparkplug.models.MetricDirection
import org.eclipse.tahu.message.model.MetricDataType
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction


operator fun Metric.Companion.invoke(node : Node) : Metric {
    return Metric(
        node.getProperty("metricName") as String,
        MetricDataType.fromInteger(node.getProperty("type") as Int),
        MetricDirection.valueOf(node.getProperty("direction") as String),
        node.getProperty("description") as String,
    )
}

fun Metric.toNode(tx: Transaction): Node {
    val node = tx.createNode(Metric.metricLabel)
    node.setProperty("metricName", metricName)
    node.setProperty("type", type.toIntValue())
    node.setProperty("direction", direction.name)
    node.setProperty("description", description)
    return node
}

val Metric.Companion.metricLabel
    get() = Label.label("Metric")
val Metric.Companion.METRIC : RelationshipType
    get() = RelationshipType.withName("METRIC")
