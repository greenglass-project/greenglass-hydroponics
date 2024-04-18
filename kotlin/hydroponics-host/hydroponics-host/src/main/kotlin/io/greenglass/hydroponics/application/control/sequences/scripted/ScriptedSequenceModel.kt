package io.greenglass.hydroponics.application.control.sequences.scripted

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.models.SequenceModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import io.greenglass.hydroponics.application.models.system.*
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction

class ScriptedSequenceModel(sequenceId : String,
                            name : String,
                            description : String,
                            sequenceVariables : List<VariableModel>?,
                            manipulatedVariables : List<VariableModel>?,
                            val script : String
) : SequenceModel(sequenceId, name, description, sequenceVariables, manipulatedVariables), GraphNode {


    constructor(node: Node): this(
        sequenceId = node.getProperty("sequenceId") as String,
        name = node.getProperty("name") as String,
        description = node.getProperty("description") as String,
        sequenceVariables  = node.getRelationships(VariableModel.SEQUENCE_VARIABLE)
            .map { v -> VariableModel(v.endNode) },
        manipulatedVariables = node.getRelationships(VariableModel.MANIPULATED_VARIABLE)
            .map { v -> VariableModel(v.endNode) },
        script = node.getProperty("script") as String,
    )

    override fun toNode(tx: Transaction): Node {
        KotlinLogging.logger {}.debug { "ADDING SCRIPTED SEQUENCE PROCESS $sequenceId" }

        val node = tx.createNode(fuzzyControlProcessLabel, ProcessModel.processLabel)
        node.setProperty("sequenceId", this.sequenceId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        sequenceVariables?.forEach { pv ->
            node.createRelationshipTo(pv.toNode(tx), VariableModel.VARIABLE)
        }
        manipulatedVariables?.forEach { mav ->
            node.createRelationshipTo(mav.toNode(tx), VariableModel.MANIPULATED_VARIABLE)
        }
        node.setProperty("script", script)
        return node
    }

    companion object Graph {
        val fuzzyControlProcessLabel = Label.label("FuzzyControlProcess")
    }


}