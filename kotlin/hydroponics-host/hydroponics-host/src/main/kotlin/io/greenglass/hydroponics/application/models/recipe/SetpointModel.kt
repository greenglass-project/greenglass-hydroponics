package io.greenglass.hydroponics.application.models.recipe

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.host.control.controlprocess.models.ProcessVariableModel
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel.Graph.phaseLabel
import org.neo4j.graphdb.*

import io.greenglass.hydroponics.application.models.system.processVariableLabel


class SetpointModel(
    val phaseId : String,
    val variableId : String,
    val setPoint : Double
) : GraphNode {
    constructor(node : Node) : this(
        node.getSingleRelationship(SET_POINT, Direction.INCOMING).startNode.getProperty("phaseId") as String,
        node.getSingleRelationship(PROCESS_VARIABLE, Direction.OUTGOING).endNode.getProperty("variableId") as String,
        node.getProperty("setPoint") as Double,
        )

    override fun toNode(tx : Transaction) : Node {
        val phaseNode = checkNotNull(tx.findNode(phaseLabel, "phaseId", this.phaseId))
        val variableNode = checkNotNull(tx.findNode(ProcessVariableModel.processVariableLabel, "variableId", this.variableId))
        val node = tx.createNode(setPointLabel)
        phaseNode.createRelationshipTo(node, SET_POINT)
        node.createRelationshipTo(variableNode, PROCESS_VARIABLE)
        node.setProperty("setPoint", this.setPoint)
        return node
    }

    companion object Graph {
        val SET_POINT : RelationshipType = RelationshipType.withName("SET_POINT")
        val PROCESS_VARIABLE : RelationshipType = RelationshipType.withName("PROCESS_VARIABLE")
        val setPointLabel : Label = Label.label("SetPoint")
    }
}
