package io.greenglass.hydroponics.application.models.installation

import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel
import org.neo4j.graphdb.Direction
import org.neo4j.graphdb.Node

class PhysicalNodeMetricsModel(
    val nodeId : String,
    val implNode : ImplementationNodeModel
) {

    constructor(node : Node) : this(
        node.getProperty("nodeId") as String,
        ImplementationNodeModel(node.getSingleRelationship(ImplementationNodeModel.IMPLEMENTATION_NODE, Direction.OUTGOING)
            .endNode)
    )
}