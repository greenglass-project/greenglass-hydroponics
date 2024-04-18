package io.greenglass.hydroponics.application.models.installation

import org.neo4j.graphdb.*

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel.Graph.IMPLEMENTATION_NODE
import io.greenglass.hydroponics.application.models.implementation.ImplementationNodeModel.Graph.implNodeLabel
import io.greenglass.hydroponics.application.models.system.processLabel

class PhysicalNodeModel(
    val nodeId : String,
    val implNodeId : String
) : GraphNode {

    constructor(node :Node) : this(
        node.getProperty("nodeId") as String,
        node.getSingleRelationship(IMPLEMENTATION_NODE,Direction.OUTGOING)
            .endNode
            .getProperty("implNodeId") as String
    )
    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(physicalNodeLabel)
        node.setProperty("nodeId", nodeId)

        val implNode = checkNotNull(tx.findNode(implNodeLabel,"implNodeId", implNodeId))
        node.createRelationshipTo(implNode,IMPLEMENTATION_NODE )
        return node
    }
    companion object Graph {
        val physicalNodeLabel : Label = Label.label("PhysicalNode")
        val PHYSICAL_NODE: RelationshipType = RelationshipType.withName("PHYSICAL_NODE")
    }
}