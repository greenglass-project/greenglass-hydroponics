package io.greenglass.hydroponics.application.models.recipe

class SystemRecipesViewModel(
    val plantId : String,
    val name : String,
    val image : String,
    val recipes : List<String>
) {
    constructor(plant : PlantModel, recipes : List<RecipeModel>) : this(
        plant.plantId,
        plant.name,
        plant.image,
        recipes.map { r -> r.recipeId }
    )
}
