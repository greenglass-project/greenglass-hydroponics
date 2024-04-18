package io.greenglass.hydroponics.node

import kotlin.system.exitProcess
import kotlinx.coroutines.*

import io.greenglass.hydroponics.node.drivers.atlasscientific.EzoEptDriver
import io.greenglass.hydroponics.node.drivers.gpio.DosingPumpDriver
import io.greenglass.node.core.devicedriver.drivers.GpioDigitalInDriver
import io.greenglass.node.core.devicedriver.drivers.GpioDigitalOutDriver
import io.greenglass.node.core.devicedriver.drivers.SysinfoDriver
import io.greenglass.node.core.services.*
import io.klogging.Level
import io.klogging.config.ANSI_CONSOLE
import io.klogging.config.loggingConfiguration
import io.klogging.logger

class Node

/**
 * main()
 *
 * @param args
 */
@OptIn(ExperimentalCoroutinesApi::class)
fun main(args: Array<String>): Unit = runBlocking {

    loggingConfiguration {
        ANSI_CONSOLE()
        kloggingMinLogLevel(Level.DEBUG)
        //minDirectLogLevel(Level.TRACE)
    }
    val logger = logger("main")

    var active = false

    if(args.size != 2) {
        logger.error { "2 parameters required - ${args.size} supplied" }
        exitProcess(1)
    }

    val config = args[0]
    val web = args[1]

    logger.info { "========================================="}
    logger.info { "config : $config"}
    logger.info { "web    : $web"}
    logger.info { "========================================="}

    // Create the backgroundScope
    val backgroundScope = CoroutineScope(
        newCoroutineContext(Dispatchers.IO + SupervisorJob() + CoroutineExceptionHandler { ctx, t ->
            runBlocking { logger.error { "COROUTINE ERROR ${t.stackTraceToString()}" }}
        }))

    // Create the service
    logger.debug { "Creating services.... "}

    val gpio = GpioService(backgroundScope)
    val persistence = PersistenceService()

    val webService = WebService(
        port = 8181,
        contextRoot = web,
        persistence = persistence,
        backgroundScope = backgroundScope
    )

    logger.debug { "Registering drivers.... "}
    val drivers = DriversService(gpio, persistence, webService, backgroundScope)
    drivers.registerDriver(SysinfoDriver.type) { n,c,g,p,s,b -> SysinfoDriver(n,c,g,p,s,b) }
    drivers.registerDriver(GpioDigitalInDriver.type) { n,c,g,p,s,b -> GpioDigitalInDriver(n,c,g,p,s,b) }
    drivers.registerDriver(GpioDigitalOutDriver.type) { n,c,g,p,s,b -> GpioDigitalOutDriver(n,c,g,p,s,b) }
    drivers.registerDriver(DosingPumpDriver.type) { n, c, g, p, s, b -> DosingPumpDriver(n,c,g,p,s,b) }
    drivers.registerDriver(EzoEptDriver.type)  { n,c,g,p,s,b -> EzoEptDriver(n,c,g,p,s,b) }

    logger.debug { "Create the application service.... "}
    val application = ApplicationService(
        configDirectory = config,
        persistence = persistence,
        drivers = drivers,
        webService = webService,
        backgroundScope = backgroundScope
    )

    logger.debug { "Starting webService service.... "}
    backgroundScope.launch {
        webService.start()
        application.initialise()
    }
}


