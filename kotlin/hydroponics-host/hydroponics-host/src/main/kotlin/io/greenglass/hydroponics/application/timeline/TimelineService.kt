package io.greenglass.hydroponics.application.timeline

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.influxdb.InfluxDbService
import io.greenglass.host.application.influxdb.toTimeLine
import io.greenglass.hydroponics.application.installations.InstallationsManager
import io.greenglass.sparkplug.datatypes.NodeMetricNameValue
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.map

class TimelineService(
    private val installations: InstallationsManager,
    private val influxDbService: InfluxDbService
    ) {

    private val logger = KotlinLogging.logger {}

    @OptIn(DelicateCoroutinesApi::class, ExperimentalCoroutinesApi::class)
    suspend fun run() {
        val microServiceScope = CoroutineScope(newSingleThreadContext("microservices"))


        installations.installations().forEach { i ->
            // Log node events
            i.nodesCtxs.values.forEach { n ->

                // Set up subscribers for each metric in the node and publish
                // changes to the timeline database
                n.metricsCtxs.values.forEach { m ->
                    microServiceScope.launch {
                        m.value
                            .map { v -> NodeMetricNameValue(n.node.nodeId, m.metric.metricName, v) }
                            .toTimeLine(influxDbService)
                    }
                }
            }
        }
    }
}