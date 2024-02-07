package io.greenglass.hydroponics.application.models.recipe

import io.greenglass.hydroponics.application.models.recipe.PlantModel.Graph.plantLabel
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import org.neo4j.graphdb.Node
import org.neo4j.graphdb.Transaction

class RecipeViewModel(
    val recipeId : String,
    val description : String,
    val plantId : String,
    val plantName : String,
    val plantImage : String,
    val systemId : String,
    val systemName : String,
) {
    constructor(recipeNode : Node,
                plantNode : Node,
                systemNode : Node
    ) : this (
        recipeId = recipeNode.getProperty("recipeId") as String,
        description = recipeNode.getProperty("description") as String,
        plantId = plantNode.getProperty("plantId") as String,
        plantName = plantNode.getProperty("name") as String,
        plantImage = plantNode.getProperty("image") as String,
        systemId = systemNode.getProperty("systemId") as String,
        systemName = systemNode.getProperty("name") as String,
    )

    constructor(tx : Transaction, recipeModel : RecipeModel) : this (
        recipeId = recipeModel.recipeId,
        description = recipeModel.description,
        plantId = recipeModel.plantId,
        plantName = tx.findNode(plantLabel, "plantId", recipeModel.plantId).getProperty("name") as String,
        plantImage = tx.findNode(
            plantLabel,
            "plantId",
            recipeModel.plantId
        ).getProperty("image") as String,
        systemId = recipeModel.systemId,
        systemName = tx.findNode(
            HydroponicsSystemModel.systemLabel,
            "systemId",
            recipeModel.systemId
        ).getProperty("name") as String,
    )
}

