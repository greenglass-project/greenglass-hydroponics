package io.greenglass.hydroponics.application.models.recipe.phase

import checkExists
import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.SequenceModel
import io.greenglass.hydroponics.application.models.system.SEQUENCE
import io.greenglass.hydroponics.application.models.system.sequenceLabel
import org.neo4j.graphdb.Direction

class SequencePhaseModel(
    type : PhaseType,
    phaseId : String,
    name : String,
    description : String,
    duration : Int,
    val sequenceId : String,
) : GraphNode, PhaseModel(type, phaseId, name, description, duration) {
    constructor(node : Node) : this(
        PhaseType.SequencePhasse,
        node.getProperty("phaseId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getProperty("duration") as Int,
        node.getSingleRelationship(SequenceModel.SEQUENCE, Direction.OUTGOING).endNode.getProperty("sequenceId") as String,
        )
    override fun toNode(tx : Transaction) : Node {
        val node = tx.createNode(phaseLabel, sequencePhaseLabel)
        val seqNode = checkExists(tx.findNode(SequenceModel.sequenceLabel, "sequenceId", sequenceId))
        node.setProperty("phaseId", this.phaseId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        node.setProperty("duration", this.duration)
        node.createRelationshipTo(seqNode, SequenceModel.SEQUENCE)
        return node
    }

    companion object Graph {
        val sequencePhaseLabel = Label.label("SequencePhase")
    }
}
