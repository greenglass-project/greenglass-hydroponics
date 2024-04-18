package io.greenglass.hydroponics.application.models.system

import io.greenglass.host.application.neo4j.getSingleRelationshipToNodeType
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.models.VariableMetricModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import org.neo4j.graphdb.*

import io.greenglass.hydroponics.application.models.node.METRIC
import io.greenglass.hydroponics.application.models.node.metricLabel
import io.greenglass.sparkplug.models.Metric

operator fun VariableMetricModel.Companion.invoke(node : Node) : VariableMetricModel {
    val varNode = checkNotNull(node.getSingleRelationship(VariableModel.VARIABLE, Direction.OUTGOING)?.endNode)
    val procNode = checkNotNull(varNode.getSingleRelationshipToNodeType(
            direction = Direction.INCOMING,
            label = ProcessModel.processLabel
        )?.startNode)
    return VariableMetricModel(
        procNode.getProperty("processId") as String,
        varNode.getProperty("variableId") as String,
        node.getSingleRelationship(Metric.METRIC, Direction.OUTGOING)
            .endNode
            .getProperty("metricName") as String,
    )
}

fun VariableMetricModel.toNode(tx: Transaction): Node {
    val node = tx.createNode(VariableMetricModel.variableMetricLabel)
    val processNode = checkNotNull(tx.findNode(ProcessModel.processLabel,"processId", processId))
    val variableNode = checkNotNull(processNode.getSingleRelationshipToNodeType(
        direction = Direction.OUTGOING,
        label = VariableModel.variableLabel,
        property = "variableId",
        value = variableId)?.endNode,
        lazyMessage = {"cannot find variable $variableId"}
    )
    val metricNode = checkNotNull(
        tx.findNode(Metric.metricLabel,"metricName", metricName),
        lazyMessage = {"metric $metricName not found. VariableId $variableId"}
    )
    node.createRelationshipTo(variableNode, VariableModel.VARIABLE)
    node.createRelationshipTo(metricNode, Metric.METRIC)
    return node
}

val VariableMetricModel.Companion.variableMetricLabel : Label
    get() = Label.label("VariableMetric")
val VariableMetricModel.Companion.VARIABLE_METRIC: RelationshipType
    get() = RelationshipType.withName("VARIABLE_METRIC")
