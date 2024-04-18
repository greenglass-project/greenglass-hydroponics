package io.greenglass.hydroponics.node.drivers.gpio

import com.pi4j.io.gpio.digital.DigitalState

import kotlin.math.roundToLong
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

import io.greenglass.node.core.devicedriver.config.DriverConfig
import io.greenglass.node.core.devicedriver.*
import io.greenglass.node.core.devicedriver.config.GpioDigitalOutConfig
import io.greenglass.node.core.services.*
import io.greenglass.node.sparkplug.datatypes.MetricValue
import io.klogging.NoCoLogging

class DosingPumpDriver(
    name: String,
    config: List<DriverConfig>,
    gpio: GpioService,
    persistence: PersistenceService,
    webService: WebService,
    backgroundScope : CoroutineScope
) : DriverModule(name, config, gpio, persistence, webService, backgroundScope), NoCoLogging {

    private val c = checkNotNull(config.firstOrNull() as? GpioDigitalOutConfig)

    val pumpDevice = gpio.digitalOutput(
        pin = c.pin,
        initialState = DigitalState.LOW,
        shutdownState = DigitalState.LOW,
        false
    )

    private val pumpKey = "$name/calibration"
    private var pumpCalibration = persistence.getDouble(pumpKey, 0.0)

    private lateinit var doseVolume: WriteMetricFunction
    private lateinit var doseDuration: WriteMetricFunction
    private val stateFlow = MutableStateFlow(false)

    suspend fun pulsePump(pump: GpioService.DigitalOutputController, duration: Long) = coroutineScope {
        logger.debug { "pulsePump duration = $duration" }
        pump.write(true)
        stateFlow.emit(true)
        delay(duration)
        pump.write(false)
        stateFlow.emit(false)
    }

    override suspend fun registerSettingsHandler(): Unit = coroutineScope {

        // ============================================================================
        // Settings
        // ============================================================================

        webService.addGet("/driver/$name/calibrate") { ctx ->
                ctx.json(Json.encodeToString(DoubleValue(pumpCalibration)))
            }
        webService.addPut("/driver/$name/calibrate") { ctx ->
            logger.debug { "Received PUT on ${ctx.path()} data ${ctx.body()}" }
            val c = Json.decodeFromString<DoubleValue>(ctx.body())
            pumpCalibration = c.value
            logger.debug { "Received $pumpCalibration ${ctx.path()}" }
            persistence.setDouble(pumpKey,pumpCalibration)
        }

        val stateEventFlow = stateFlow
            .asSharedFlow()
            .transform { e -> emit(Json.encodeToString(BoolValue(e))) }
            .stateIn(backgroundScope)

        webService.addEventPublisher("/driver/$name/state", stateEventFlow)
    }

    override suspend fun initialise() {

        doseVolume = object : WriteMetricFunction(this, "DoseVolume") {
            init {
                driver.registerWriteFunction(functionName, this)
            }

            override suspend fun write(value: MetricValue) {
                if (pumpCalibration != 0.0) {
                    val duration = ((value.int64 / pumpCalibration) * 1000).roundToLong()
                    pulsePump(pumpDevice, duration)
                    valueFlow.emit(listOf(driverFunctionMetricValue(value)))
                }
            }

            override suspend fun read() = MetricValue(0L)
        }

        doseDuration = object : WriteMetricFunction(this, "DoseDuration") {
            init {
                driver.registerWriteFunction(functionName, this)
            }

            override suspend fun write(value: MetricValue) {
                val duration = value.int64
                pulsePump(pumpDevice, duration)
                valueFlow.emit(listOf(driverFunctionMetricValue(value)))
            }

            override suspend fun read() = MetricValue(0L)
        }
    }

    override suspend fun readAllMetrics() = arrayListOf(
        doseVolume.driverFunctionMetricValue(doseVolume.read()),
        doseDuration.driverFunctionMetricValue(doseDuration.read())
    )

    companion object {
        val type = "gpio_dosing_pump"
    }
}
