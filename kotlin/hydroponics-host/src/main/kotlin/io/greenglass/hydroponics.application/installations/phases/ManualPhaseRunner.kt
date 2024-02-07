package io.greenglass.hydroponics.application.installations.phases

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import java.time.ZonedDateTime

class ManualPhaseRunner(installationId : String) : PhaseRunner(installationId){

    val logger = KotlinLogging.logger {}

    init {
        logger.debug { "Starting ManualPhaseRunner"}
    }


    override fun startPhase(phase: PhaseModel, end: ZonedDateTime) {
        logger.debug { "ManualPhaseRunner start phase ${phase.phaseId}"}

    }

    override fun resumePhase(phase: PhaseModel, end: ZonedDateTime) {
        logger.debug { "ManualPhaseRunner resume phase ${phase.phaseId}"}
    }

    override fun stopPhase() {
        logger.debug { "ManualPhaseRunner stop phase"}
    }
}