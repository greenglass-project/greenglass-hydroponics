package io.greenglass.hydroponics.application.control.processes.fuzzylogic

import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import io.greenglass.hydroponics.application.models.system.*

class FuzzyLogicProcessModel(process : String,
                             processId : String,
                             name : String,
                             description : String,
                             processVariables : List<ProcessVariableModel>?,
                             manipulatedVariables : List<VariableModel>?,
                             val script : String
) : ProcessModel(process,
                 processId,
                 name,
                 description,
                 processVariables,
                 manipulatedVariables), GraphNode {

    constructor(node: Node) : this(
        process = node.getProperty("process") as String,
        processId = node.getProperty("processId") as String,
        name = node.getProperty("name") as String,
        description = node.getProperty("description") as String,
        processVariables = node.getRelationships(ProcessVariableModel.PROCESS_VARIABLE)
            .map { v -> ProcessVariableModel.Companion.invoke(v.endNode) },
        manipulatedVariables = node.getRelationships(VariableModel.MANIPULATED_VARIABLE)
            .map { v -> VariableModel(v.endNode) },
        script = node.getProperty("script") as String,
    )

    override fun toNode(tx: Transaction): Node {
        KotlinLogging.logger {}.debug { "ADDING FUZZY PROCESS $processId" }

        val node = tx.createNode(fuzzyControlProcessLabel, ProcessModel.processLabel)
        node.setProperty("process", this.process)
        node.setProperty("processId", this.processId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        processVariables?.forEach { pv ->
            node.createRelationshipTo(pv.toNode(tx), ProcessVariableModel.PROCESS_VARIABLE)
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