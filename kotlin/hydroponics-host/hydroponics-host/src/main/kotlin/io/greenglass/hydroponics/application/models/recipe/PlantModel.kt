package io.greenglass.hydroponics.application.models.recipe

import org.neo4j.graphdb.Label
import org.neo4j.graphdb.Label.*
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.RelationshipType
import org.neo4j.graphdb.Transaction
import io.greenglass.host.application.neo4j.GraphNode

class PlantModel(
    val plantId : String,
    val name : String,
    val description : String,
    val image : String
) : GraphNode {

    constructor(node : Node) : this(
        node.getProperty("plantId") as String,
        node.getProperty("name") as String,
        node.getProperty("description") as String,
        node.getProperty("image") as String,
        )

    override fun toNode(tx : Transaction) : Node {
        val node = tx.createNode(plantLabel)
        node.setProperty("plantId", this.plantId)
        node.setProperty("name", this.name)
        node.setProperty("description", this.description)
        node.setProperty("image", this.image)
        return node
    }

    companion object Graph {
        val plantLabel : Label = label("Plant")
        val PLANT : RelationshipType = RelationshipType.withName("PLANT")
    }
}
