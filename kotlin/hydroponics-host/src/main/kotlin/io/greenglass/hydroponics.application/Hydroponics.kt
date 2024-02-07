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
import io.greenglass.host.application.nats.NatsService
import io.greenglass.host.application.neo4j.Neo4jService
import io.greenglass.host.sparkplug.SparkplugService
import io.greenglass.hydroponics.application.graphdb.ConfigurationLoader
import io.greenglass.hydroponics.application.microservices.MicroServices
import io.greenglass.sparkplug.datatypes.MetricValue

class Hydroponics

@OptIn(DelicateCoroutinesApi::class, ExperimentalCoroutinesApi::class)
suspend fun main() {
    val logger = KotlinLogging.logger {}

    val sparkplugTimezone = envVariableOrDefault(
        envVariable = "GREENGLASS_TIMEZONE",
        default = "Asia/Bangkok"
    )

    val sparkplugUrl = envVariableOrDefault(
        envVariable = "GREENGLASS_SPARKPLUG_URL",
        default = "mqtt://localhost:1883"
    )

    val sparkplugGroupId = envVariableOrDefault(
        envVariable = "GREENGLASS_SPARKPLUG_GROUPID",
        default = "greenglass"
    )

    val sparkplugHostId = envVariableOrDefault(
        envVariable = "GREENGLASS_SPARKPLUG_HOSTID",
        default = "greenglass-iot"
    )

    val nats = envVariableOrDefault(
        envVariable = "GREENGLASS_NATS_URL",
        default = "nats://localhost:4222"
    )
    //val nitrite = envVariableOrDefault(
    //    envVariable = "GREENGLASS_NITRITE_DB",
    //    default = "hydroponics.db"
    //)

    val influxDbUrl = envVariableOrDefault(
        envVariable = "GREENGLASS_INFLUXDB_URL",
        default = "http://localhost:8086"
    )

    val influxDbOrg = envVariableOrDefault(
        envVariable = "GREENGLASS_INFLUXDB_ORG",
        default = "greenglass"
    )

    val influxDbBucket = envVariableOrDefault(
        envVariable = "GREENGLASS_INFLUXDB_BUCKET",
        default = "greenglass"
    )

    val influxDbToken = envVariableOrDefault(
        envVariable = "GREENGLASS_INFLUXDB_TOKEN",
        default = "U75rZQGl18HCBQXEdT3S5EP2WFVPBCCbNVdJvOpykBZXPTMi0CGHgTdETlU45fuDdU5tb4iiiY4XU6j_pZ0LCw=="
    )

    val configRoot = envVariableOrDefault(
        envVariable = "GREENGLASS_CONFIG_ROOT",
        default = "config"
    )

    logger.info { "GREENGLASS IOT HYDROPONICS "}
    logger.info { "======================================================================= "}
    logger.info { "TIMEZONE          : $sparkplugTimezone"}
    logger.info { "SPARKPLUG_URL     : $sparkplugUrl"}
    logger.info { "SPARKPLUG_GROUPID : $sparkplugGroupId" }
    logger.info { "SPARKPLUG_HOSTID  : $sparkplugHostId" }
    logger.info { "NATS_URL          : $nats" }
    logger.info { "INFLUXDB_URL      : $influxDbUrl" }
    logger.info { "INFLUXDB_BUCKET   : $influxDbBucket" }
    logger.info { "INFLUXDB_TOKEN    : $influxDbToken" }
    logger.info { "CONFIG_ROOT       : $configRoot" }
    logger.info { "======================================================================= "}
    logger.info { "" }

    TimeZone.setDefault(TimeZone.getTimeZone(sparkplugTimezone));
    val dispatcher = newSingleThreadContext("main")

    val processRegistry = HydroponicsProcessRegistry()

    // Start the common services
    val neo4jService = Neo4jService(configRoot)

    val natsService = NatsService(
        url = nats,
        modules = listOf(PhaseModel.deserialiser(), MetricValue.deserialiser())
    )

    val sparkplugService = SparkplugService(
        uri = sparkplugUrl,
        groupId = sparkplugGroupId,
        hostAppId = sparkplugHostId
    )

    val repository = GraphRepository(neo4jService, configRoot, processRegistry)
    ConfigurationLoader(repository,processRegistry).load()

    val installationsManager = InstallationsManager(
        repository = repository,
        sparkplugService = sparkplugService,
        processRegistry = processRegistry,
        nats = natsService
    )
    val microservices = MicroServices(natsService, repository, installationsManager)

    // Start the coroutines
    coroutineScope {
        //launch(dispatcher) { sparkplugService.run() }
        launch(dispatcher) { microservices.run() }
        launch(dispatcher) { installationsManager.run() }
    }
    select<Any>{}
}
