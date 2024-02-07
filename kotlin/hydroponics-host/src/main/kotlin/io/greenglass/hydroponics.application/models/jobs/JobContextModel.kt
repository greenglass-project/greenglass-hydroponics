package io.greenglass.hydroponics.application.models.jobs

import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.recipe.PlantModel
import io.greenglass.hydroponics.application.models.recipe.RecipeModel

class JobContextModel(
    var job : JobModel,
    val recipe : RecipeModel,
    val plant : PlantModel
) {
    fun currentPhase() = recipe.phases.firstOrNull { p -> p.phaseId == job.phaseId }

    fun nextPhase() : PhaseModel? {
        val curr = recipe.phases.indexOfFirst { p -> p.phaseId == job.phaseId }
        return if(curr == -1 && recipe.phases.isNotEmpty())
            recipe.phases[0]
        else if(curr != recipe.phases.size-1)
            recipe.phases[curr+1]
        else
            null
    }
}
