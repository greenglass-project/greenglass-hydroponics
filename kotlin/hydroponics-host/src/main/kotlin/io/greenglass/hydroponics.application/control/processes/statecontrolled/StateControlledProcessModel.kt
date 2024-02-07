package io.greenglass.hydroponics.application.control.processes.statecontrolled

import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction
import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import io.greenglass.hydroponics.application.models.system.MANIPULATED_VARIABLE
import io.greenglass.hydroponics.application.models.system.invoke
import io.greenglass.hydroponics.application.models.system.processLabel
import io.greenglass.hydroponics.application.models.system.toNode

class StateControlledProcessModel(
    process : String,
    processId : String,
    name : String,
    description : String,
    manipulatedVariables : List<VariableModel>?,
) : ProcessModel(process, processId, name, description, null, manipulatedVariables) {

    constructor(node: Node): this(
        process = node.getProperty("process") as String,
        processId = node.getProperty("processId") as String,
            name = node.getProperty("name") as String,
            description = node.getProperty("description") as String,
            manipulatedVariables = node.getRelationships(VariableModel.MANIPULATED_VARIABLE)
                .map { v -> VariableModel(v.endNode) },
                //.map { v -> VariableModel.Companion.invoke(v.endNode) },

    )

    fun StateControlledProcessModel.toNode(tx: Transaction): Node {
        KotlinLogging.logger {}.debug { "ADDING STATE PROCESS $processId" }

        val node = tx.createNode(stateControlledProcessLabel, ProcessModel.processLabel)
        node.setProperty("process", this.process)
        node.setProperty("processId", this.processId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        manipulatedVariables?.forEach { mav ->
            node.createRelationshipTo(mav.toNode(tx), VariableModel.MANIPULATED_VARIABLE)
        }
        return node
    }

companion object Graph {
    val stateControlledProcessLabel = Label.label("StateControlledProcess")

}
}