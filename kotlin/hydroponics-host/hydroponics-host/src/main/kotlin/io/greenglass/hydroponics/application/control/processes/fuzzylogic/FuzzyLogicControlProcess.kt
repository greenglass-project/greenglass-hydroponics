package io.greenglass.hydroponics.application.control.processes.fuzzylogic

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.control.controlprocess.providers.MetricProvider
import io.greenglass.host.control.controlprocess.providers.ProcessStateProvider
import io.greenglass.host.control.controlprocess.providers.SetpointProvider
import io.greenglass.host.sparkplug.SparkplugService
import io.greenglass.host.control.controlprocess.process.Process
import io.greenglass.host.sparkplug.subscribeToMetric

import io.greenglass.iot.host.registry.RegisterProcess
import io.greenglass.sparkplug.datatypes.MetricIdentifier
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableSharedFlow

@RegisterProcess(name = "fuzzyLogicProcess", model = FuzzyLogicProcessModel::class)
class FuzzyLogicControlProcess (instanceId : String,
                                processModel : FuzzyLogicProcessModel,
                                metricProvider : MetricProvider,
                                setpointProvider : SetpointProvider,
                                processStateProvider : ProcessStateProvider,
                                sparkplugService: SparkplugService,
                                dispatcher : CloseableCoroutineDispatcher

) : Process(instanceId,
            processModel,
            metricProvider,
            setpointProvider,
            processStateProvider,
            sparkplugService,
            dispatcher
) {

    private val logger = KotlinLogging.logger {}

    private lateinit var pvMetrics : Map<String, MetricIdentifier>
    private lateinit var mvMetrics : Map<String, MetricIdentifier>
    private lateinit var flc : FuzzyLogicController

    private val calculateTrigger : MutableSharedFlow<Boolean> = MutableSharedFlow(1)

    override suspend fun run() {
        super.run()

        flc = FuzzyLogicController(
            processModel = processModel as FuzzyLogicProcessModel,
            calculateTrigger = calculateTrigger,
            processScope = processScope,
            dispatcher = dispatcher
        )

        processScope.launch(dispatcher) { flc.run() }

        pvMetrics = processModel.processVariables?.associate {
                pv -> Pair(
            pv.name,
            metricProvider.metricForVariable(
                instanceId = instanceId,
                processId = processModel.processId,
                variableId = pv.variableId
            ))
        } ?: mapOf()

        val subsFlow =
        pvMetrics.forEach { e ->
            processScope.launch(dispatcher) {
                subscribeToMetric(sparkplug = sparkplugService,
                        nodeId = e.value.nodeId,
                        name = e.value.metricName,
                    ).publishToFLCVariable(flc, e.key)
            }
        }

        mvMetrics = processModel.manipulatedVariables?.associate {
                pv -> Pair(
            pv.variableId,
            metricProvider.metricForVariable(
                instanceId = instanceId,
                processId = processModel.processId,
                variableId = pv.variableId
            ))
        } ?: mapOf()
    }

    override suspend fun start() {
        logger.debug { "FuzzyLogicControlProcess - START" }
    }
    override suspend fun stop() {
        logger.debug { "FuzzyLogicControlProcess - STOP" }
    }
}