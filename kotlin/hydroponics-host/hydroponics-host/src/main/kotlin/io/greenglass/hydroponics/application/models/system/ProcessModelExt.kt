package io.greenglass.hydroponics.application.models.system

import checkExists
import org.neo4j.graphdb.*
import kotlin.reflect.KFunction

import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.host.control.controlprocess.models.VariableModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry

import io.greenglass.hydroponics.application.models.recipe.SetpointModel.Graph.PROCESS_VARIABLE


operator fun ProcessModel.Companion.invoke(node : Node) : ProcessModel {
    return ProcessModel(
        process = node.getProperty("process") as String,
        processId = node.getProperty("processId") as String,
        name = node.getProperty("name") as String,
        description = node.getProperty("description") as String,
        processVariables = node.getRelationships(Direction.OUTGOING, PROCESS_VARIABLE)?.map { r ->
            ProcessVariableModel(r.endNode)
        },
        manipulatedVariables = node.getRelationships(Direction.OUTGOING, VariableModel.MANIPULATED_VARIABLE)?.map { r ->
            VariableModel(r.endNode)
        },
    )
}

fun ProcessModel.Companion.factory(node : Node, processRegistry : ProcessRegistry) : ProcessModel {
    val process = node.getProperty("process") as String
    return processRegistry.processModelFromNode(process, node)
}

/**
 * ProcessRegistry.processModelFromNode()
 *
 * Extension function to the ProcessRegistry - adds the ability to create a ProcessModel
 * from a name and a graph node. The function looks for a constructor with a single
 * parameter called node
 *
 * @param name
 * @param node
 * @return the ProcessMpdel
 */
fun ProcessRegistry.processModelFromNode(name: String, node : Node) : ProcessModel {
    val modelClass = this.modelClassForName(name)
    val constructors = modelClass.constructors
    var constructor : KFunction<ProcessModel>? = null
    for(c in constructors)
        if(c.parameters.size == 1 && c.parameters[0].name == "node")
            constructor = c
    return checkExists(constructor?.call(node))
}

val ProcessModel.Companion.PROCESS : RelationshipType
    get() = RelationshipType.withName("PROCESS")
val ProcessModel.Companion.processLabel : Label
    get() = Label.label("Process")




