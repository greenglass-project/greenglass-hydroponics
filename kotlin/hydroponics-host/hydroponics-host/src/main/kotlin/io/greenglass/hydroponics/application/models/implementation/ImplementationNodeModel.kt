package io.greenglass.hydroponics.application.models.implementation

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.VariableMetricModel
import io.greenglass.hydroponics.application.models.node.NODE_TYPE
import io.greenglass.hydroponics.application.models.node.nodeTypeLabel
import io.greenglass.hydroponics.application.models.system.VARIABLE_METRIC
import io.greenglass.hydroponics.application.models.system.invoke
import io.greenglass.hydroponics.application.models.system.toNode
import io.greenglass.sparkplug.models.NodeType
import org.neo4j.graphdb.*
import org.neo4j.graphdb.Label.label

class ImplementationNodeModel(
    val implNodeId : String,
    val type : String,
    val description : String,
    val variables : List<VariableMetricModel> ) : GraphNode {

    constructor(node : Node) : this(
        implNodeId = node.getProperty("implNodeId") as String,
        type = node.getSingleRelationship(NodeType.NODE_TYPE, Direction.OUTGOING)
            .endNode
            .getProperty("type") as String,
        description = node.getProperty("description") as String,
        variables = node.getRelationships(VariableMetricModel.VARIABLE_METRIC)
            .map { r -> VariableMetricModel(r.endNode) },
    )
    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(implNodeLabel)
        node.setProperty("implNodeId", implNodeId)
        node.setProperty("description", description)
        val nodeDefNode = checkNotNull(tx.findNode(NodeType.nodeTypeLabel, "type", type), lazyMessage = { "Node type $type not found" })
        node.createRelationshipTo(nodeDefNode, NodeType.NODE_TYPE)
        variables.forEach { v -> node.createRelationshipTo(v.toNode(tx), VariableMetricModel.VARIABLE_METRIC) }
        return node
    }

    fun toVariableTriple() = variables.map { v -> Triple(implNodeId, v.variableId, v.metricName)}

    companion object Graph {
        val implNodeLabel : Label = label("ImplementationNode")
        val IMPLEMENTATION_NODE : RelationshipType = RelationshipType.withName("IMPLEMENTATION_NODE")
    }
}

