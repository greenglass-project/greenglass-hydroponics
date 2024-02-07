package io.greenglass.hydroponics.node

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.hydroponics.node.drivers.atlasscientific.EzoEcDriver
import io.greenglass.hydroponics.node.drivers.atlasscientific.EzoPhDriver
import io.greenglass.hydroponics.node.drivers.atlasscientific.EzoRtdDriver
import io.greenglass.hydroponics.node.drivers.gpio.DosingPumpDriver
import io.greenglass.node.core.configuration.ConfigLoader
import io.greenglass.node.core.devicedriver.drivers.GpioDigitalInDriver
import io.greenglass.node.core.devicedriver.drivers.GpioDigitalOutDriver
import io.greenglass.node.core.services.DriversService.Companion.drivers
import kotlinx.coroutines.runBlocking

import io.greenglass.node.core.services.SparkplugService.Companion.sparkplug
import kotlin.system.exitProcess


class Node

/**
 * main()
 *
 *  Arguments
 *  1. hostUrl e.g 'mqtt://elnor.local:1883'
 *  2. groupId e.g 'greenglass'
 *  3. hostId e.g  'elnor'
 *  4. nodeId e.g '353ce036b3744122'
 *  4. node-type e.g. 3-RELAYS
 *
 * @param args
 */
fun main(args: Array<String>): Unit = runBlocking {

    val logger = KotlinLogging.logger {}

    if(args.size != 5) {
        logger.error { "5 parameters required" }
        exitProcess(1)
    }

    val hostUrl = args[0]
    val groupId = args[1]
    val hostId = args[2]
    val nodeId = args[3]
    val type = args[4]

    logger.debug { "========================================="}
    logger.debug { "uri       : $hostUrl"}
    logger.debug { "groupId   : $groupId"}
    logger.debug { "hostId    : $hostId"}
    logger.debug { "nodeId    : $nodeId"}
    logger.debug { "node type : $type"}
    logger.debug { "========================================="}

    logger.debug { "Registering drivers.... "}

    drivers.registerDriver(GpioDigitalInDriver.type) { n,m,c -> GpioDigitalInDriver(n,m,c) }
    drivers.registerDriver(GpioDigitalOutDriver.type) { n, m, c -> GpioDigitalOutDriver(n,m,c) }
    drivers.registerDriver(DosingPumpDriver.type) { n, m, c -> DosingPumpDriver(n,m,c) }
    drivers.registerDriver(EzoEcDriver.type)  { n, m, c -> EzoEcDriver(n,m,c) }
    drivers.registerDriver(EzoPhDriver.type)  { n, m, c -> EzoPhDriver(n,m,c) }
    drivers.registerDriver(EzoRtdDriver.type)  { n, m, c -> EzoRtdDriver(n,m,c) }

    logger.debug { "Registering node-definition.... "}
    val nodeDefinition = ConfigLoader.load(type)

    logger.debug { "Starting sparkplug service .... "}
    sparkplug.start(uri = hostUrl,
        groupId = groupId,
        hostId = hostId,
        nodeId = nodeId,
        nodeDefinition = nodeDefinition
    )
}

