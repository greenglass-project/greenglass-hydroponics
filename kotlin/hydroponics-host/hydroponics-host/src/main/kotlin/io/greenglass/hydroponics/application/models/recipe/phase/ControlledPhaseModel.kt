package io.greenglass.hydroponics.application.models.recipe.phase

import org.neo4j.graphdb.Direction.*
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.hydroponics.application.models.recipe.ProcessScheduleModel
import io.greenglass.hydroponics.application.models.recipe.SetpointModel
import io.greenglass.hydroponics.application.models.recipe.SetpointModel.Graph.SET_POINT

class ControlledPhaseModel(
    type : PhaseType,
    phaseId : String,
    name : String,
    description : String,
    duration : Int,
    var processSchedules : List<ProcessScheduleModel>? = null,
    var setPoints : List<SetpointModel>? = null,

    ) : GraphNode, PhaseModel(type, phaseId,name,description, duration) {
    constructor(node : Node) : this(
        PhaseType.ControlPhase,
        node.getProperty("phaseId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getProperty("duration") as Int,
        node.getRelationships(OUTGOING, ProcessScheduleModel.PROCESS_SCHEDULE).map { r -> ProcessScheduleModel(r.endNode) },
        node.getRelationships(OUTGOING, SET_POINT).map{ r -> SetpointModel(r.endNode) },
    )
    override fun toNode(tx : Transaction) : Node {
        val node = tx.createNode(phaseLabel, controlPhaseLabel)
        node.setProperty("phaseId", this.phaseId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        node.setProperty("duration", this.duration)
        processSchedules?.forEach { s -> s.toNode(tx) }
        setPoints?.forEach { sp -> sp.toNode(tx) }
        return node
    }

    companion object Graph {
        val controlPhaseLabel = Label.label("ControlPhase")
        val PHASE : RelationshipType = RelationshipType.withName("PHASE")
    }
}
