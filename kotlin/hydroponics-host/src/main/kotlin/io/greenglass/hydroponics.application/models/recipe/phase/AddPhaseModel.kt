package io.greenglass.hydroponics.application.models.recipe.phase

import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel

class AddPhaseModel(
    val previousPhaseId : String?,
    val phase : PhaseModel
)