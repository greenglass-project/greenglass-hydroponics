package io.greenglass.hydroponics.application.installations.phases

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.components.scheduling.periodic.duration.DailyDurationEvent
import io.greenglass.host.application.components.scheduling.periodic.duration.DailyDurationScheduler
import io.greenglass.host.control.controlprocess.providers.ProcessStateProvider
import io.greenglass.host.control.controlprocess.providers.SetpointProvider
import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import io.greenglass.hydroponics.application.models.system.ProcessSchedulerEvent
import io.greenglass.hydroponics.application.models.recipe.phase.ControlledPhaseModel
import io.greenglass.hydroponics.application.models.system.ProcessSchedulerModel
import io.greenglass.sparkplug.datatypes.MetricValue
import kotlinx.coroutines.flow.*
import java.time.ZonedDateTime

class ControlledPhaseRunner (installationId : String,
                             processSchedulers : List<ProcessSchedulerModel>,
) : SetpointProvider, ProcessStateProvider, PhaseRunner(installationId) {

    class ProcessScheduleContext(val scheduler : DailyDurationScheduler,
                                 val scheduleFlow : MutableSharedFlow<List<DailyDurationEvent>>,
                                 val eventFlow : Flow<ProcessSchedulerEvent> )


    private val schedulers : HashMap<String, ProcessScheduleContext> = hashMapOf()
    private val setPoints : HashMap<String, MutableSharedFlow<MetricValue>> = hashMapOf()
    private val processControl : HashMap<String, SharedFlow<Boolean>> = hashMapOf()

    val schedulersStateFlow : Flow<ProcessSchedulerEvent>
    val logger = KotlinLogging.logger {}

    init {
        logger.debug { "Starting ControlledPhaseRunner"}

        processSchedulers.forEach { ps ->
            val sFlow = MutableSharedFlow<List<DailyDurationEvent>>(1)
            val scheduler = DailyDurationScheduler(
                instanceId = installationId,
                schedulerId = ps.schedulerId,
                scheduleFlow = sFlow,
            )
            val psEventFlow = scheduler.subscribeToState().transform<Boolean,ProcessSchedulerEvent> {
                    e ->  ProcessSchedulerEvent(
                        installationId = installationId,
                        processId = "",
                        schedulerId = scheduler.schedulerId,
                        event = e
                    )
            }
            schedulers[ps.schedulerId] = ProcessScheduleContext(scheduler, sFlow, psEventFlow)

            ps.processes.forEach { p ->
                processControl[p.processId] = scheduler.subscribeToState()
                p.processVariables?.forEach { pv ->
                    val pFlow = MutableSharedFlow<MetricValue>(2)
                    setPoints[pv.variableId] = pFlow
                }
            }
        }
        val scf = schedulers.values.map { s -> s.eventFlow }.toTypedArray()
        schedulersStateFlow = merge(*scf)
    }

    override fun startPhase(phase: PhaseModel, end : ZonedDateTime) {
        logger.debug { "ControlledPhaseRunner start phase ${phase.phaseId}"}

        phase as ControlledPhaseModel
        phase.processSchedules?.forEach { ps ->
            schedulers[ps.schedulerId]!!.scheduleFlow.tryEmit(ps.toDailyDurationEventList())
        }
        phase.setPoints?.forEach { sp ->
            setPoints[sp.variableId]!!.tryEmit(MetricValue(sp.setPoint))
        }
    }

    override fun resumePhase(phase: PhaseModel, end : ZonedDateTime) {
        logger.debug { "ControlledPhaseRunner resume phase ${phase.phaseId}"}
        phase as ControlledPhaseModel
        phase.processSchedules?.forEach { ps ->
            schedulers[ps.schedulerId]!!.scheduleFlow.tryEmit(ps.toDailyDurationEventList())
        }
        phase.setPoints?.forEach { sp ->
            setPoints[sp.variableId]!!.tryEmit(MetricValue(sp.setPoint))
        }
    }

    override fun stopPhase() {
        logger.debug { "ControlledPhaseRunner stop phase"}
    }

    override fun subscribeToSetpoint(instanceId: String, variableId: String) =
        checkNotNull(setPoints[variableId], lazyMessage = {"variableId $variableId not found"}).asSharedFlow()

    override fun subscribeToProcessState(instanceId: String, processId: String) =
        checkNotNull(processControl[processId])

}

