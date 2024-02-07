package io.greenglass.hydroponics.application.models.system

import io.greenglass.host.control.controlprocess.models.SequenceModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.host.control.system.SystemModel
import org.neo4j.graphdb.*

class HydroponicsSystemModel(val systemId: String,
                             val name: String,
                             val description : String,
                             val processSchedulers : List<ProcessSchedulerModel>,
                             val sequences : List<SequenceModel>
) {

   constructor(node: Node, processRegistry : ProcessRegistry) : this(
            node.getProperty("systemId") as String,
            node.getProperty("name") as String,
            node.getProperty("description") as String,
            node.getRelationships(Direction.OUTGOING, ProcessSchedulerModel.PROCESS_SCHEDULER)
                .map { r -> ProcessSchedulerModel(r.endNode, processRegistry) },
            node.getRelationships(Direction.OUTGOING, SequenceModel.SEQUENCE)
                .map { r -> SequenceModel(r.endNode) }
        )

        fun toNode(tx: Transaction, processRegistry: ProcessRegistry): Node {
            val node = tx.createNode(systemLabel)

            node.setProperty("systemId", this.systemId)
            node.setProperty("name", this.name)
            node.setProperty("description", this.description)
            processSchedulers.forEach { s ->
                node.createRelationshipTo(s.toNode(tx, processRegistry), ProcessSchedulerModel.PROCESS_SCHEDULER)
            }
            sequences.forEach { s ->
                node.createRelationshipTo(s.toNode(tx), SequenceModel.SEQUENCE)
            }
            return node
        }

        fun toControlledSystemModel() : SystemModel {
            return SystemModel(
                systemId = systemId,
                name = name,
                description = description,
                processes = processSchedulers.map { ps -> ps.processes.toSet() }.flatten(),
                sequences = sequences
            )
        }

    companion object Graph {
        val systemLabel = Label.label("System")
        val SYSTEM = RelationshipType.withName("SYSTEM")
    }
}