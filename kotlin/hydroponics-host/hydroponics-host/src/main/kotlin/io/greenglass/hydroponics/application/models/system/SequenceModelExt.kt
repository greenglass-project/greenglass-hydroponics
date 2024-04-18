package io.greenglass.hydroponics.application.models.system

import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.models.SequenceModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import io.greenglass.hydroponics.application.models.recipe.SetpointModel
import org.neo4j.graphdb.*

operator fun SequenceModel.Companion.invoke(node : Node) : SequenceModel {
    return SequenceModel(
        node.getProperty("sequenceId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        sequenceVariables = node.getRelationships(Direction.OUTGOING, VariableModel.SEQUENCE_VARIABLE)?.map { r ->
            ProcessVariableModel(r.endNode)
        },
        manipulatedVariables = node.getRelationships(Direction.OUTGOING, VariableModel.MANIPULATED_VARIABLE)?.map { r ->
            VariableModel(r.endNode)
        },

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

