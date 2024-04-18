package io.greenglass.hydroponics.application.models.system

import io.greenglass.host.control.controlprocess.models.VariableModel
import org.eclipse.tahu.message.model.MetricDataType
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Label.*
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction

operator fun VariableModel.Companion.invoke(node : Node) : VariableModel {
    return VariableModel(
        variableId = node.getProperty("variableId") as String,
        name = node.getProperty("name") as String,
        description = node.getProperty("description") as String,
        type = MetricDataType.fromInteger(node.getProperty("type") as Int)
    )
}

fun VariableModel.toNode(tx : Transaction) : Node {
    val node = tx.createNode(VariableModel.variableLabel)
    node.setProperty("variableId", this.variableId)
    node.setProperty("name", this.name)
    node.setProperty("description", this.description)
    node.setProperty("type", this.type.toIntValue())
    return node;
}
val VariableModel.Companion.variableLabel : Label
    get() = label("Variable")
val VariableModel.Companion.VARIABLE : RelationshipType
    get() = RelationshipType.withName("VARIABLE")
val VariableModel.Companion.MANIPULATED_VARIABLE: RelationshipType
    get() = RelationshipType.withName("MANIPULATED_VARIABLE'");

val VariableModel.Companion.SEQUENCE_VARIABLE: RelationshipType
    get() = RelationshipType.withName("SEQUENCE_VARIABLE'");
