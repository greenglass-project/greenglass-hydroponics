/******************************************************************************
 *  Copyright 2023 Steve Hopkins
 *
 *  Use of this source code is governed by an MIT-style
 *  license that can be found in the LICENSE file or at
 *  https://opensource.org/licenses/MIT.
 *
 *****************************************************************************/
package io.greenglass.hydroponics.application

import envVariableOrDefault
import io.greenglass.application.hydroponics.HydroponicsProcessRegistry
import io.greenglass.hydroponics.application.graphdb.GraphRepository
import io.greenglass.hydroponics.application.installations.InstallationsManager

import io.greenglass.hydroponics.application.models.recipe.phase.PhaseModel
import java.util.*

import kotlinx.coroutines.*
import kotlinx.coroutines.selects.select
import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.influxdb.InfluxDbService
import io.greenglass.host.application.nats.NatsService
import io.greenglass.host.application.neo4j.Neo4jService
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.host.sparkplug.SparkplugService
import io.greenglass.hydroponics.application.graphdb.ConfigurationLoader
import io.greenglass.hydroponics.application.microservices.BootstrapMicroServices
import io.greenglass.hydroponics.application.microservices.MicroServices
import io.greenglass.hydroponics.application.models.config.CoroutineScopes
import io.greenglass.hydroponics.application.models.config.EnvironmentConfig
import io.greenglass.hydroponics.application.models.config.MasterConfig
import io.greenglass.hydroponics.application.timeline.TimelineService
import io.greenglass.sparkplug.datatypes.MetricValue
import kotlinx.coroutines.flow.MutableSharedFlow

class Hydroponics

@OptIn(DelicateCoroutinesApi::class, ExperimentalCoroutinesApi::class)
suspend fun main() {
    val logger = KotlinLogging.logger {}

    val masterConfigFlow = MutableSharedFlow<MasterConfig>(1)

    val environment = EnvironmentConfig(
        sparkplugUrl = envVariableOrDefault(
            envVariable = "GREENGLASS_SPARKPLUG_URL",
            default = "mqtt://localhost:1883"
        ),
        nats = envVariableOrDefault(
            envVariable = "GREENGLASS_NATS_URL",
            default = "nats://localhost:4222"
        ),
        influxDbUrl = envVariableOrDefault(
            envVariable = "GREENGLASS_INFLUXDB_URL",
            default = "http://localhost:8086"
        ),
        influxDbOrg = envVariableOrDefault(
            envVariable = "GREENGLASS_INFLUXDB_ORG",
            default = "greenglass"
        ),
        influxDbBucket = envVariableOrDefault(
            envVariable = "GREENGLASS_INFLUXDB_BUCKET",
            default = "greenglass"
        ),

        configRoot = envVariableOrDefault(
            envVariable = "GREENGLASS_CONFIG_ROOT",
            default = "config"
        ),
        runtimeRoot = envVariableOrDefault(
            envVariable = "GREENGLASS_RUNTIME_ROOT",
            default = "runtime"
        )
    )

    logger.info { "GREENGLASS HYDROPONICS - ENVIRONMENT"}
    logger.info { "======================================================================= "}
    logger.info { "SPARKPLUG_URL     : ${environment.sparkplugUrl}"}
    logger.info { "NATS_URL          : ${environment.nats}" }
    logger.info { "INFLUXDB_URL      : ${environment.influxDbUrl}" }
    logger.info { "INFLUXDB_BUCKET   : ${environment.influxDbBucket}" }
    logger.info { "CONFIG_ROOT       : ${environment.configRoot}" }
    logger.info { "RUNTIME_ROOT      : ${environment.runtimeRoot}" }
    logger.info { "======================================================================= "}
    logger.info { "" }

    val coroutineScopes = CoroutineScopes(
        mainScope = CoroutineScope(newSingleThreadContext("main")),
        microServicesScope = CoroutineScope(newSingleThreadContext("microservices"))
    )

    val processRegistry = HydroponicsProcessRegistry()

    // Start the common services
    val neo4jService = Neo4jService(environment.runtimeRoot)

    val natsService = NatsService(
        url = environment.nats,
        modules = listOf(PhaseModel.deserialiser(), MetricValue.deserialiser())
    )

    val repository = GraphRepository(neo4jService, environment.configRoot, processRegistry, masterConfigFlow)
    ConfigurationLoader(repository, environment.configRoot, processRegistry).load()

    val bootstrapMicroServices = BootstrapMicroServices(natsService, repository, masterConfigFlow, coroutineScopes)
    val application = Application(
        masterConfigFlow = masterConfigFlow,
        environmentConfig = environment,
        repository = repository,
        natsService = natsService,
        processRegistry =  processRegistry,
        coroutineScopes = coroutineScopes
    )

    // Start the coroutines
    coroutineScopes.mainScope.launch { application.run() }
    coroutineScopes.mainScope.launch { bootstrapMicroServices.run() }

    // Get the master config if any
    val masterConfig : MasterConfig? = repository.findOneMasterConfig().successOrNull()
    if(masterConfig != null) {
        logger.debug { "Master config found" }
        masterConfigFlow.emit(masterConfig)
    } else {
        logger.debug { "No Master config found" }
    }
}
