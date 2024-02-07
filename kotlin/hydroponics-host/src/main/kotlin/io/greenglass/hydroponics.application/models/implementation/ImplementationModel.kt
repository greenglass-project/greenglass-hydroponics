package io.greenglass.hydroponics.application.models.implementation

import org.neo4j.graphdb.*

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel.Graph.IMPLEMENTATION_NODE
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel

class ImplementationModel(
    val implementationId : String,
    val systemId : String,
    val name : String,
    val nodes : List<ImplementationNodeModel>

) : GraphNode {

    constructor(node : Node) : this(
        implementationId = node.getProperty("implementationId") as String,
        systemId = node.getSingleRelationship(HydroponicsSystemModel.SYSTEM,Direction.OUTGOING)
            .endNode
            .getProperty("systemId") as String,
        name = node.getProperty("name") as String,
        nodes = node.getRelationships(IMPLEMENTATION_NODE).map { r -> ImplementationNodeModel(r.endNode) }
    )

    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(implementationLabel)
        val systemNode = checkNotNull(tx.findNode(HydroponicsSystemModel.systemLabel,"systemId", systemId ))
        node.createRelationshipTo(systemNode, HydroponicsSystemModel.SYSTEM)
        node.setProperty("implementationId", implementationId)
        node.setProperty("name", name)
        nodes.forEach { n -> node.createRelationshipTo(n.toNode(tx), IMPLEMENTATION_NODE)}
        return node
    }

    companion object Graph {
        val implementationLabel : Label = Label.label("Implementation")
        val IMPLEMENTATION : RelationshipType = RelationshipType.withName("IMPLEMENTATION")
    }
}
