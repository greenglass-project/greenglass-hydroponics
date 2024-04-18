package io.greenglass.hydroponics.application.models.installation
import io.greenglass.hydroponics.application.models.node.METRIC
import io.greenglass.hydroponics.application.models.node.invoke
import io.greenglass.sparkplug.models.Metric
import org.neo4j.graphdb.Direction
import org.neo4j.graphdb.Node

class InstallationNodeModel(
    val nodeId : String,
    val implName : String,
    val nodeType : String,
    val nodeName : String,
    val nodeDescription : String,
    val nodeImage : String,
    val metrics  : List<Metric>

) {
    constructor(modeId: String, implName : String, nodeType : Node) : this(
        modeId,
        implName,
        nodeType.getProperty("type") as String,
        nodeType.getProperty("name") as String,
        nodeType.getProperty("description") as String,
        nodeType.getProperty("image") as String,
        nodeType.getRelationships(Direction.OUTGOING, Metric.METRIC)
            .map { r -> r.endNode }
            .map { n -> Metric.Companion.invoke(n) }
        )
}
