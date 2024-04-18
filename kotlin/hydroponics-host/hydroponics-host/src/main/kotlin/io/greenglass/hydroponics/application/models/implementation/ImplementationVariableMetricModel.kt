package io.greenglass.hydroponics.application.models.implementation

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.VariableModel
import io.greenglass.hydroponics.application.models.node.METRIC
import io.greenglass.hydroponics.application.models.node.metricLabel
import io.greenglass.hydroponics.application.models.system.VARIABLE
import io.greenglass.hydroponics.application.models.system.variableLabel
import io.greenglass.sparkplug.models.Metric
import org.neo4j.graphdb.*

class ImplementationVariableMetricModel(val variableId : String, val name : String ) : GraphNode {
    constructor(node : Node) : this(
        node.getSingleRelationship(VariableModel.VARIABLE, Direction.OUTGOING)
            .endNode
            .getProperty("variableId") as String,
        node.getSingleRelationship(Metric.METRIC, Direction.OUTGOING)
            .endNode
            .getProperty("name") as String,
        )

    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(implementationVariableMetricLabel)
        val variableNode = checkNotNull(tx.findNode(VariableModel.variableLabel,"variableId", variableId),)
        val metricNode = checkNotNull(
            tx.findNode(Metric.metricLabel,"name", name),
            lazyMessage = {"metric $name not found"}
        )
        node.createRelationshipTo(variableNode, VariableModel.VARIABLE)
        node.createRelationshipTo(metricNode, Metric.METRIC)
        return node
    }

    companion object Graph {
        val implementationVariableMetricLabel = Label.label("VariableMetric")
        val VARIABLE_METRIC = RelationshipType.withName("VARIABLE_METRIC")
    }
}