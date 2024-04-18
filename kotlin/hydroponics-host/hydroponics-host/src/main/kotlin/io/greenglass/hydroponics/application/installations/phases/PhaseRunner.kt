package io.greenglass.hydroponics.application.installations.phases

import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import java.time.ZonedDateTime

abstract class PhaseRunner(val installationId : String) {

    abstract fun startPhase(phase: PhaseModel, end : ZonedDateTime)
    abstract fun resumePhase(phase: PhaseModel, end : ZonedDateTime)
    abstract fun stopPhase()

}