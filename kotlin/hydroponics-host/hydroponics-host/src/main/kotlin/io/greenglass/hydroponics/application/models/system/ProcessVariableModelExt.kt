package io.greenglass.hydroponics.application.models.system

import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import org.eclipse.tahu.message.model.MetricDataType
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction

operator fun ProcessVariableModel.Companion.invoke(node : Node) : ProcessVariableModel {
    return ProcessVariableModel(
        variableId = node.getProperty("variableId") as String,
        name = node.getProperty("name") as String,
        description = node.getProperty("description") as String,
        type = MetricDataType.fromInteger(node.getProperty("type") as Int),
        minValue = node.getProperty("minValue") as Double,
        maxValue = node.getProperty("maxValue") as Double,
        tolerance = node.getProperty("tolerance") as Double,
        default = node.getProperty("default") as Double,
        units = node.getProperty("units") as String,
        decimalPlaces = node.getProperty("decimalPlaces") as Int,
    )
}

fun ProcessVariableModel.toNode(tx : Transaction) : Node {
    val node = tx.createNode(ProcessVariableModel.processVariableLabel, VariableModel.variableLabel)
    node.setProperty("variableId", this.variableId)
    node.setProperty("name", this.name)
    node.setProperty("description", this.description)
    node.setProperty("type", this.type.toIntValue())
    node.setProperty("minValue", this.minValue)
    node.setProperty("maxValue", this.maxValue)
    node.setProperty("tolerance", this.tolerance)
    node.setProperty("default", this.default)
    node.setProperty("units", this.units)
    node.setProperty("decimalPlaces", this.decimalPlaces)
    return node;
}

val ProcessVariableModel.Companion.PROCESS_VARIABLE : RelationshipType
    get() = RelationshipType.withName("PROCESS_VARIABLE")
val ProcessVariableModel.Companion.processVariableLabel : Label
    get() = Label.label("ProcessVariable")


