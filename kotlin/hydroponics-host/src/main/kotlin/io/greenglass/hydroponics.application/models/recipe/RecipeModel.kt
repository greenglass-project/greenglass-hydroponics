package io.greenglass.hydroponics.application.models.recipe

import io.greenglass.host.application.neo4j.GraphNode
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.recipe.PlantModel.Graph.PLANT
import io.greenglass.hydroponics.application.models.recipe.PlantModel.Graph.plantLabel
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel.Graph.PHASE
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import org.neo4j.graphdb.*


class RecipeModel(
    val recipeId : String,
    val description : String,
    val plantId : String,
    val systemId : String,
    val phases : List<PhaseModel>
) : GraphNode {

    constructor(tx : Transaction, node : Node) : this(
        node.getProperty("recipeId") as String,
        node.getProperty("description") as String,
        node.getSingleRelationship(PLANT, Direction.OUTGOING).endNode.getProperty("plantId") as String,
        node.getSingleRelationship(HydroponicsSystemModel.SYSTEM, Direction.OUTGOING).endNode.getProperty("systemId") as String,
        findPhases(tx, node)
    )

    override fun toNode(tx: Transaction): Node {
        val node = tx.createNode(recipeLabel)
        val plantNode = checkNotNull(tx.findNode(plantLabel, "plantId", plantId))
        val systemNode = checkNotNull(tx.findNode(HydroponicsSystemModel.systemLabel, "systemId", systemId))
        node.setProperty("recipeId", this.recipeId)
        node.setProperty("description", this.description)
        //plantNode.createRelationshipTo(node, RECIPE)
        node.createRelationshipTo(systemNode, HydroponicsSystemModel.SYSTEM)
        node.createRelationshipTo(plantNode, PLANT)
        var current = node
        phases.forEach { p ->
            val pNode = p.toNode(tx)
            current.createRelationshipTo(pNode, PHASE)
            current = pNode
        }
        return node
    }

    companion object Graph {

        private fun findPhases(tx : Transaction, node : Node) : List<PhaseModel> {
            val pn : ArrayList<PhaseModel> = arrayListOf()
            var currentNode = node;
            while(currentNode.hasRelationship(Direction.OUTGOING, PHASE)) {
                currentNode = currentNode.getSingleRelationship(PHASE, Direction.OUTGOING).endNode
                pn.add(PhaseModel.factory(currentNode))
            }
            return pn;
        }

        val recipeLabel = Label.label("Recipe")
        val RECIPE : RelationshipType = RelationshipType.withName("RECIPE")
    }
}