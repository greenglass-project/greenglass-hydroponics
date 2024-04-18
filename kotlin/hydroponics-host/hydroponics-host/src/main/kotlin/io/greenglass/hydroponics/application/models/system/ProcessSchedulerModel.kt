package io.greenglass.hydroponics.application.models.system

import io.greenglass.application.hydroponics.toNode
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction

open class ProcessSchedulerModel(
    val schedulerId : String,
    val name : String,
    val description : String,
    val processes : List<ProcessModel>
) {

    constructor(node: Node, processRegistry : ProcessRegistry) : this(
        schedulerId = node.getProperty("schedulerId") as String,
        name = node.getProperty("name") as String,
        description = node.getProperty("description") as String,
        processes = node.getRelationships(ProcessModel.PROCESS)
            .map { r -> ProcessModel.factory(r.endNode, processRegistry) }
    )

    fun toNode(tx: Transaction, processRegistry: ProcessRegistry): Node {
        val node = tx.createNode(schedulerLabel)
        node.setProperty("schedulerId", this.schedulerId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        processes.forEach { p ->
            node.createRelationshipTo(p.toNode(tx), ProcessModel.PROCESS)
        }
        return node;
    }

    companion object Graph {
        val schedulerLabel = Label.label("ProcessScheduler")
        val PROCESS_SCHEDULER = RelationshipType.withName("PROCESS_SCHEDULER")
    }
}

