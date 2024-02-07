package io.greenglass.hydroponics.application.control.processes.statecontrolled

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.providers.MetricProvider
import io.greenglass.host.control.controlprocess.providers.ProcessStateProvider
import io.greenglass.host.control.controlprocess.providers.SetpointProvider
import io.greenglass.host.control.controlprocess.process.Process

import io.greenglass.host.sparkplug.SparkplugService
import io.greenglass.iot.host.registry.RegisterProcess
import io.greenglass.sparkplug.datatypes.MetricIdentifier
import io.greenglass.sparkplug.datatypes.MetricValue
import kotlinx.coroutines.CloseableCoroutineDispatcher

@RegisterProcess(name = "stateControlledProcess", model = StateControlledProcessModel::class)
class StateControlledProcess(instanceId : String,
                             processModel : ProcessModel,
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

    private var metrics : List<MetricIdentifier> = listOf()

    val logger = KotlinLogging.logger {}

    /**
     * start()
     *
     *  Publish a boolean true to all the manipulated-variable metrics
     */
    override suspend fun start() {
        logger.debug { "StateControlledProcess - START" }
        metrics = processModel.manipulatedVariables?.map { mv ->
            metricProvider.metricForVariable(
                instanceId = instanceId,
                processId = processModel.processId,
                variableId = mv.variableId
            )
        }  ?: listOf()
        metrics.forEach { m ->
            sparkplugService.publishToMetric(
                nodeId = m.nodeId,
                name = m.metricName,
                value = MetricValue(true)
            )
        }
    }

    /**
     * stop()
     *
     *  Publish a boolean false to all the manipulated-variable metrics
     */
    override suspend fun stop() {
        logger.debug { "StateControlledProcess - STOP" }
        metrics.forEach { m ->
            sparkplugService.publishToMetric(
                nodeId = m.nodeId,
                name = m.metricName,
                value = MetricValue(false))
        }
    }
}