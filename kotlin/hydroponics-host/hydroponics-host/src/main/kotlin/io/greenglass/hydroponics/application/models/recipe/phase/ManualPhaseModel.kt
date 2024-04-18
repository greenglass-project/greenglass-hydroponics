package io.greenglass.hydroponics.application.models.recipe.phase

import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction
import io.greenglass.host.application.neo4j.GraphNode

class ManualPhaseModel(
    type : PhaseType,
    phaseId : String,
    name : String,
    description : String,
    duration : Int
) : GraphNode, PhaseModel(type, phaseId,name,description, duration) {
    constructor(node : Node) : this(
        PhaseType.ManualPhase,
        node.getProperty("phaseId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getProperty("duration") as Int
    )
    override fun toNode(tx : Transaction) : Node {
        val node = tx.createNode(phaseLabel, manualPhaseLabel)
        node.setProperty("phaseId", this.phaseId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        node.setProperty("duration", this.duration)
        return node
    }

    companion object Graph {
        val manualPhaseLabel = Label.label("ManualPhase")
    }
}
