package io.greenglass.hydroponics.node.drivers.atlasscientific

import kotlinx.coroutines.*
import kotlin.time.Duration.Companion.seconds
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.future.asCompletableFuture
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

import io.javalin.http.HttpStatus
import io.javalin.http.bodyAsClass

import io.greenglass.node.core.devicedriver.config.DriverConfig
import io.greenglass.node.core.services.*
import io.greenglass.node.sparkplug.datatypes.MetricValue
import io.greenglass.node.core.devicedriver.*
import io.greenglass.node.core.devicedriver.config.I2cConfig
import io.klogging.NoCoLogging
import io.klogging.logger

@Serializable
data class CalibrationRequest(val command : String, val value : Double)
@Serializable
data class Settings(val tickInterval : Int, val window : Int)

class EzoEptDriver(name: String,
                   config: List<DriverConfig>,
                   gpio : GpioService,
                   persistence: PersistenceService,
                   webService : WebService,
                   backgroundScope : CoroutineScope
) : DriverModule(name, config,gpio,persistence, webService, backgroundScope), NoCoLogging {

    // Keys for persistent storage
    private val tickKey = "/driver/$name/tick"
    private val windowKey = "/driver/$name/window"

    // Get the config
    private val configMap = config.associateBy { c -> c.name }
    private val ecConfig = checkNotNull(configMap["ec-sensor"] as? I2cConfig)
    private val phConfig = checkNotNull(configMap["ph-sensor"] as? I2cConfig)
    private val rtdConfig = checkNotNull(configMap["rtd-sensor"] as? I2cConfig)

    // Create the device and command objects
    private val ecSensor = gpio.i2c(ecConfig.device, ecConfig.address)
    private val ecCommand = EzoCommand(ecSensor, backgroundScope, "EC")

    private val phSensor = gpio.i2c(phConfig.device, phConfig.address)
    private val phCommand = EzoCommand(phSensor, backgroundScope, "PH")

    private val rtdSensor = gpio.i2c(rtdConfig.device, rtdConfig.address)
    private val rtdCommand = EzoCommand(rtdSensor, backgroundScope, "RTD")

    private var currentEcValue: Double = 0.0
    private var currentPhValue: Double = 0.0
    private var currentRtdValue: Double = 0.0

    private val ecValueWindow: ValueWindow
    private val phValueWindow: ValueWindow
    private val rtdValueWindow: ValueWindow

    private val ecMeasurement = MutableStateFlow(0.0)
    private val phMeasurement = MutableStateFlow(0.0)
    private val rtdMeasurement = MutableStateFlow(0.0)

    private var tick = 3
    private var window = 10
    private var updateJob: Job? = null

    private var online = false;

    // Read driver functions
    private lateinit var ecValue: ReadMetricFunction
    private lateinit var phValue: ReadMetricFunction
    private lateinit var rtdValue: ReadMetricFunction

    init {
        logger.info { "Creating EzoEptDriver" }
        tick = persistence.getInt(tickKey, 3)
        window = persistence.getInt(windowKey, 10)

        ecValueWindow = ValueWindow(window, 0)
        phValueWindow = ValueWindow(window, 2)
        rtdValueWindow = ValueWindow(window, 1)
    }

    // Initialise the driver functions
    override suspend fun initialise() = coroutineScope {
        ecValue = object : ReadMetricFunction(this@EzoEptDriver, "EcValue") {}
        phValue = object : ReadMetricFunction(this@EzoEptDriver, "PhValue") {}
        rtdValue = object : ReadMetricFunction(this@EzoEptDriver, "RtdValue") {}

        // ============================================================================
        // Start the readers
        // ============================================================================
        updateJob = backgroundScope.launch {
            while (true) {

                logger.info { "Reading the temperature" }
                rtdMeasurement.emit(rtdCommand.command("R", size = 8, delay = 600).toDouble())

                logger.info { "Reading the EC and pH" }
                val values = listOf(
                    async {
                        ecMeasurement.emit(ecCommand.command("R", size = 8, delay = 600).toDouble())
                    },
                    async {
                        phMeasurement.emit(phCommand.command("R", size = 8, delay = 900).toDouble())
                    }
                )
                values.awaitAll()

                if (online) {
                    val metrics: ArrayList<DriverFunctionMetricValue> = arrayListOf()

                    val temp = rtdValueWindow.addValue(rtdMeasurement.asStateFlow().value)
                    if (temp != null) {
                        logger.info { "TEMP NEW  = $temp TEMP CURRENT = $currentRtdValue" }
                        if (currentRtdValue != temp) {
                            currentRtdValue = temp
                            metrics.add(rtdValue.driverFunctionMetricValue(MetricValue(currentRtdValue)))
                        }
                    }

                    val ec = ecValueWindow.addValue(ecMeasurement.asStateFlow().value)
                    if (ec != null) {
                        logger.info { "EC NEW = $ec EC CURRENT = $currentEcValue" }
                        if (currentEcValue != ec) {
                            currentEcValue = ec
                            metrics.add(ecValue.driverFunctionMetricValue(MetricValue(currentEcValue)))
                        }
                    }

                    val ph = phValueWindow.addValue(phMeasurement.asStateFlow().value)
                    if (ph != null) {
                        logger.info { "PH NEW = $ph PH CURRENT = $currentPhValue" }
                        if (currentPhValue != ph) {
                            currentPhValue = ph
                            metrics.add(phValue.driverFunctionMetricValue(MetricValue(currentPhValue)))
                        }
                    }

                    logger.info { "Found ${metrics.size} metrics" }
                    if (metrics.isNotEmpty()) {
                        valueFlow.emit(metrics)
                    }
                }
                delay(tick.seconds)
            }
        }

        // ============================================================================
        // Web Service - Settings
        // ============================================================================
        webService.addGet("/driver/$name/settings") { ctx ->
            logger.info { " received request on [/driver/$name/settings]"}

            ctx.json(
                Json.encodeToString(
                    Settings(
                        tickInterval = persistence.getInt(tickKey, 3),
                        window = persistence.getInt(windowKey, 10),
                    )
                )
            )
        }

        webService.addPut("/driver/$name/settings") { ctx ->
            val settings = ctx.bodyAsClass<Settings>()
            persistence.setInt(tickKey, settings.tickInterval)
            persistence.setInt(windowKey, settings.window)

            tick = settings.tickInterval
            window = settings.window
            persistence.setInt(windowKey, window)
            ecValueWindow.setWindowSize(window)
            phValueWindow.setWindowSize(window)
            rtdValueWindow.setWindowSize(window)
        }

        // ============================================================================
        //   Web Service - EC
        // ============================================================================

        // Live value
        val ecEventFlow = ecMeasurement
            .asSharedFlow()
            .transform { e -> emit(Json.encodeToString(DoubleValue(e))) }
            .stateIn(backgroundScope)
        webService.addEventPublisher("/driver/$name/ec/value", ecEventFlow)

        // Hardware reset
        webService.addPost("/driver/$name/ec/reset") { ctx ->
            logger.info { "Received ${ctx.path()}" }
            ctx.future {
                backgroundScope.launch {
                    ecCommand.command("Factory", size = 0, delay = -1)
                    delay(500)
                    val r = ecCommand.command("Cal,?", size = 8, delay = 300)
                    val resp = Json.encodeToString(IntValue(calibrationState(r)))
                    logger.info { "EC RESPONSE = $resp" }
                    ctx.json(resp)
                }.asCompletableFuture()
            }
        }

        // Calibration
        webService.addPost("/driver/$name/ec/calibrate") { ctx ->
            logger.info { "Received ${ctx.path()}" }
            ctx.future {
                backgroundScope.launch {
                    val req = ctx.bodyAsClass(CalibrationRequest::class.java)
                    when(req.command) {
                        "state" -> {
                            val r = ecCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "EC RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "clear" -> {
                            ecCommand.command("Cal,clear", size = 1, delay = 300)
                            val r = ecCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "EC RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "dry" -> {
                            ecCommand.command("Cal,dry", size = 1, delay = 600)
                            val r = ecCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "EC RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "low" -> {
                            ecCommand.command("Cal,low,${req.value}", 1, 600)
                            val r = ecCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "EC RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "high" -> {
                            ecCommand.command("Cal,high,${req.value}", 1, 600)
                            val r = ecCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "EC RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        else ->  ctx.status(HttpStatus.BAD_REQUEST)
                    }
                }.asCompletableFuture()
            }
        }

        // ============================================================================
        //  Web Service - PH
        // ============================================================================

        // Live value
        val phEventFlow = phMeasurement
            .asSharedFlow()
            .transform { e -> emit(Json.encodeToString(DoubleValue(e))) }
            .stateIn(backgroundScope)
        webService.addEventPublisher("/driver/$name/ph/value", phEventFlow)

        // Hardware reset
        webService.addPost("/driver/$name/ph/reset") { ctx ->
            logger.info { "Received ${ctx.path()}" }
            ctx.future {
                backgroundScope.launch {
                    phCommand.command("Factory", size = 0, delay = -1)
                    delay(500)
                    val r = phCommand.command("Cal,?", size = 8, delay = 300)
                    val resp = Json.encodeToString(IntValue(calibrationState(r)))
                    logger.info { "PH RESPONSE = $resp" }
                    ctx.json(resp)
                }.asCompletableFuture()
            }
        }

        // Calibration
        webService.addPost("/driver/$name/ph/calibrate") { ctx ->
            logger.info { "Received ${ctx.path()}" }
            ctx.future {
                backgroundScope.launch {
                    val req = ctx.bodyAsClass(CalibrationRequest::class.java)
                    when(req.command) {
                        "state" -> {
                            val r = phCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "PH RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "clear" -> {
                            phCommand.command("Cal,clear", size = 1, delay = 900)
                            val r = phCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "PH RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "low" -> {
                            phCommand.command("Cal,low,${req.value}", 1, 900)
                            val r = phCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "PH RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "mid" -> {
                            phCommand.command("Cal,mid,${req.value})", 1, 900)
                            val r = phCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "PH RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "high" -> {
                            phCommand.command("Cal,high,${req.value})", 1, 900)
                            val r = phCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "PH RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        else ->  ctx.status(HttpStatus.BAD_REQUEST)
                    }
                }.asCompletableFuture()
            }
        }

        // ============================================================================
        //  Web Service - RTD
        // ============================================================================

        // Live value
        val rtdEventFlow = rtdMeasurement
            .asStateFlow()
            .transform { e -> emit(Json.encodeToString(DoubleValue(e))) }
            .stateIn(backgroundScope)
        webService.addEventPublisher("/driver/$name/rtd/value", rtdEventFlow)

        // Hardware reset
        webService.addPost("/driver/$name/rtd/reset") { ctx ->
            logger.info { "Received ${ctx.path()}" }
            ctx.future {
                backgroundScope.launch {
                    rtdCommand.command("Factory", size = 0, delay = -1)
                    delay(500)
                    val r = rtdCommand.command("Cal,?", size = 8, delay = 300)
                    val resp = Json.encodeToString(IntValue(calibrationState(r)))
                    logger.info { "RTD RESPONSE = $resp" }
                    ctx.json(resp)
                }.asCompletableFuture()
            }
        }

        webService.addPost("/driver/$name/rtd/calibrate") { ctx ->
            logger.info { "Received ${ctx.path()}" }
            ctx.future {
                backgroundScope.launch {
                    val req = ctx.bodyAsClass(CalibrationRequest::class.java)
                    when(req.command) {
                        "state" -> {
                            val r = rtdCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "RTD RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "clear" -> {
                            rtdCommand.command("Cal,clear", size = 1, delay = 600)
                            val r = rtdCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "RTD RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        "temp" -> {
                            async { rtdCommand.command("Cal,${req.value}", 1, 600) }.await()
                            val r = rtdCommand.command("Cal,?", size = 8, delay = 300)
                            val resp = Json.encodeToString(IntValue(calibrationState(r)))
                            logger.info { "RTD RESPONSE = $resp" }
                            ctx.json(resp)
                        }
                        else ->  ctx.status(HttpStatus.BAD_REQUEST)
                    }
                }.asCompletableFuture()
            }
        }
    }

    // =======================================================================================
    //  Metric functions
    // =======================================================================================
    override suspend fun readAllMetrics(): List<DriverFunctionMetricValue> {
        logger.info { "readAllMetrics()" }
        val metrics : ArrayList<DriverFunctionMetricValue> = arrayListOf()

        // Read the temperature first and calibrate the EC and pH sensors
        logger.info { "Reading the temperature" }
        currentRtdValue = rtdCommand.command("R", size = 8, delay = 600).toDouble()

        coroutineScope {
            //logger.info { "Calibrating temperature $currentRtdValue" }
            //val cmds = listOf(
            //    launch { ecCommand.command("T,$currentRtdValue", size = 1, delay = 300) },
            //    launch { phCommand.command("T,$currentRtdValue", size = 1, delay = 300) }
            //)
            //cmds.joinAll()

            logger.info { "Reading EC and pH" }
            val values = listOf(
                async { currentEcValue = ecCommand.command("R", size = 8, delay = 600).toDouble() },
                async { currentPhValue = phCommand.command("R", size = 8, delay = 900).toDouble() }
            )
            values.awaitAll()
        }

        metrics.add(rtdValue.driverFunctionMetricValue(MetricValue(currentRtdValue)))
        metrics.add(ecValue.driverFunctionMetricValue(MetricValue(currentEcValue)))
        metrics.add(phValue.driverFunctionMetricValue(MetricValue(currentPhValue)))

        return metrics
    }

    override fun startUpdates() {
    }

     fun startReaders() {
        updateJob = backgroundScope.launch {
            while(true) {
                val metrics : ArrayList<DriverFunctionMetricValue> = arrayListOf()

                //logger.info { "Reading the temperature" }
                val tm = rtdCommand.command("R", size = 8, delay = 600).toDouble()
                val temp = rtdValueWindow.addValue(tm)
                if(temp != null) {
                    logger.info { "TEMP NEW  = $temp TEMP CURRENT = $currentRtdValue"}
                    if(currentRtdValue != temp ) {
                        currentRtdValue = temp
                        logger.info { "Calibrating temperature $currentRtdValue" }
                        //val cmds = listOf(
                        //    launch { ecCommand.command("T,$currentRtdValue", size = 1, delay = 300) },
                        //    launch { phCommand.command("T,$currentRtdValue", size = 1, delay = 300) }
                        //)
                        //cmds.joinAll()
                        metrics.add(rtdValue.driverFunctionMetricValue(MetricValue(currentRtdValue)))
                    }
                }
               // logger.info { "Reading the EC and pH" }
                val values = listOf(
                    async {
                        val em = ecCommand.command("R", size = 8, delay = 600).toDouble()
                        val ec = ecValueWindow.addValue(em)
                        if(ec != null) {
                            logger.info { "EC NEW = $ec EC CURRENT = $currentEcValue"}
                            if(currentEcValue != ec) {
                                currentEcValue = ec
                                metrics.add(ecValue.driverFunctionMetricValue(MetricValue(currentEcValue)))
                            }
                        }
                    },
                    async {
                        val pm = phCommand.command("R", size = 8, delay = 900).toDouble()
                        val ph = phValueWindow.addValue(pm)
                        if(ph != null) {
                            logger.info { "PH NEW = $ph PH CURRENT = $currentPhValue"}
                            if(currentPhValue != ph) {
                                currentPhValue = ph
                                metrics.add(phValue.driverFunctionMetricValue(MetricValue(currentPhValue)))
                            }
                        }
                    }
                )
                values.awaitAll()
                logger.info { "Found ${metrics.size} metrics"}
                if(metrics.isNotEmpty()) {
                    valueFlow.emit(metrics)
                }
                delay(tick.seconds)
            }
        }
    }

    private fun calibrationState(text : String) = text.split(',')[1].toInt()

    override fun stopUpdates() {
        updateJob?.cancel()
    }

    companion object {
        val type = "ezo_ept"
    }
}