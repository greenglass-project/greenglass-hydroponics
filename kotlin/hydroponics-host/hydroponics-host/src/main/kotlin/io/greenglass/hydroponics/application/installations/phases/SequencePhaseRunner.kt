package io.greenglass.hydroponics.application.installations.phases

import io.greenglass.host.control.controlprocess.providers.SequenceStateProvider
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import kotlinx.coroutines.flow.SharedFlow
import java.time.ZonedDateTime

class SequencePhaseRunner(installationId : String) : PhaseRunner(installationId), SequenceStateProvider {

    override fun startPhase(phase: PhaseModel, end: ZonedDateTime) {
    }

    override fun resumePhase(phase: PhaseModel, end: ZonedDateTime) {
    }

    override fun stopPhase() {
        TODO("Not yet implemented")
    }

    override fun subscribeToSequenceState(instanceId: String, sequenceId: String): SharedFlow<Boolean> {
        TODO("Not yet implemented")
    }


}