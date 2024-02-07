package io.greenglass.hydroponics.application.models.system

import io.greenglass.host.control.controlprocess.models.SequenceModel
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction

operator fun SequenceModel.Companion.invoke(node : Node) : SequenceModel {
    return SequenceModel(
        node.getProperty("sequenceId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
    )
}

fun SequenceModel.toNode(tx: Transaction): Node {
        val node = tx.createNode(SequenceModel.sequenceLabel)
        node.setProperty("sequenceId", sequenceId)
        node.setProperty("name", name)
        node.setProperty("description", description)
        return node
    }

val SequenceModel.Companion.SEQUENCE : RelationshipType
    get() =  RelationshipType.withName("SEQUENCE")

val SequenceModel.Companion.sequenceLabel : Label
    get() = Label.label("Sequence")

