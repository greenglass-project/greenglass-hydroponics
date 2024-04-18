package io.greenglass.hydroponics.application

import io.github.oshai.kotlinlogging.KotlinLogging
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow

import io.greenglass.host.application.influxdb.InfluxDbService
import io.greenglass.host.application.nats.NatsService
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.host.sparkplug.SparkplugService
import io.greenglass.hydroponics.application.graphdb.GraphRepository
import io.greenglass.hydroponics.application.installations.InstallationsManager
import io.greenglass.hydroponics.application.microservices.MicroServices
import io.greenglass.hydroponics.application.models.config.CoroutineScopes
import io.greenglass.hydroponics.application.models.config.EnvironmentConfig
import io.greenglass.hydroponics.application.models.config.MasterConfig
import io.greenglass.hydroponics.application.timeline.TimelineService
import kotlinx.coroutines.flow.collect

class Application(private val masterConfigFlow : MutableSharedFlow<MasterConfig>,
                  private val environmentConfig: EnvironmentConfig,
                  private val repository: GraphRepository,
                  private val natsService: NatsService,
                  private val processRegistry: ProcessRegistry,
                  private val coroutineScopes: CoroutineScopes

    ) {

    private val logger = KotlinLogging.logger {}
    private var applicationStarted = false

    suspend fun run() {

        logger.debug { "Starting Application" }
        coroutineScopes.mainScope.launch {
            logger.debug { "Starting Master config listener" }

            // Listen for the master config bobject
            masterConfigFlow.asSharedFlow().collect { c ->
                logger.debug { "Master Config received" }
                if(!applicationStarted) {

                    val sparkplugService = SparkplugService(
                        uri = environmentConfig.sparkplugUrl,
                        groupId = c.groupId,
                        hostAppId = c.hostId
                    )

                    val influxdbService = InfluxDbService(
                        url = environmentConfig.influxDbUrl,
                        org = environmentConfig.influxDbOrg,
                        bucket = environmentConfig.influxDbBucket,
                        token = c.influxdbKey
                    )

                    val installationsManager = InstallationsManager(
                        repository = repository,
                        sparkplugService = sparkplugService,
                        influxDbService = influxdbService,
                        processRegistry = processRegistry,
                        nats = natsService,
                    )
                    val microservices = MicroServices(natsService, repository, installationsManager, coroutineScopes)
                    val timelineService = TimelineService(installationsManager, influxdbService)


                    // Start the coroutines
                    coroutineScope {
                        installationsManager.run()
                        coroutineScopes.mainScope.launch { microservices.run() }
                        coroutineScopes.mainScope.launch{ timelineService.run() }
                    }
                    applicationStarted = true

                } else {
                    logger.debug { "Application already started" }
                }
            }
        }
    }
}