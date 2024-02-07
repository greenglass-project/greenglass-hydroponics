package io.greenglass.hydroponics.node.drivers.atlasscientific

import io.github.oshai.kotlinlogging.KotlinLogging
import org.eclipse.tahu.message.model.MetricDataType

import kotlinx.coroutines.*
import kotlin.time.Duration.Companion.seconds

import io.greenglass.node.core.devicedriver.DriverFunction
import io.greenglass.node.core.devicedriver.config.DriverConfig
import io.greenglass.node.core.devicedriver.config.I2cConfig
import io.greenglass.node.core.services.GpioService
import io.greenglass.node.core.services.PersistenceService
import io.greenglass.sparkplug.datatypes.MetricNameValue
import io.greenglass.sparkplug.datatypes.MetricValue
import io.greenglass.node.core.devicedriver.DeviceDriver


class EzoRtdDriver(name : String, metrics : Map<String, String>, config : DriverConfig) : DeviceDriver(type, metrics, config) {


    private val interval = 5L;

    private val c = checkNotNull(config as? I2cConfig)

    private val logger = KotlinLogging.logger {}
    private val i2cDevice  = GpioService.gpio.i2c(c.device, c.address)
    private val ezoCommand = EzoCommand(i2cDevice)

    private var currentValue : Double = 0.0

    private val tempKey = "$name/temp"


    init {
        logger.debug { "Creating EzoRtdDriver"}
    }

    /**
     * Driver Functiobn "value"
     *
     * Read function to get the current EC value
     *
     * @property metric
     */
    inner class Value(val metric: String) : DriverFunction(metric) {
        private var job: Job? = null

        private suspend fun value() = ezoCommand.command("R", size = 8, delay = 600)

        override suspend fun readValue(): MetricValue {
            currentValue = value().toDouble()
            return MetricValue(MetricDataType.Double, currentValue)
        }

        override suspend fun startAsyncRead() {
            logger.debug { "starting async read" }
            job = CoroutineScope(Dispatchers.Default).launch {
                while (true) {
                    logger.debug { "EzoEcDriver task" }
                    val newValue = value().toDouble()
                    if (newValue != currentValue) {
                        logger.debug { "EC = $newValue" }
                        valueFlow.emit(MetricNameValue(metric, MetricValue(newValue)))
                        currentValue = newValue
                    }
                    delay(interval.seconds)
                }
            }
        }

        override suspend fun stopAsyncRead() {
            job?.cancel()
        }
    }

    /**
     * Driver-function "temp"
     *
     * Calibrate the temperature reading of the sensor
     *
     * @property metric
     */
    inner class Temp(val metric: String) : DriverFunction(metric) {

        override suspend fun readValue() = MetricValue(PersistenceService.persistence.getDouble(tempKey) ?: 0.0)

        override suspend fun writeValue(value: MetricValue) {
            ezoCommand.command("Cal,low,${value.double}", size = 0, delay = 600)
            PersistenceService.persistence.setDouble(tempKey, value.double)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    /**
     * Driver-function "clear"
     *
     *  Clear the calibration
     *
     * @property metric
     */
    inner class Clear(val metric: String) : DriverFunction(metric) {
        override suspend fun readValue() = MetricValue(false)

        override suspend fun writeValue(value: MetricValue) {
            ezoCommand.command("Cal,clear", size = 0, delay = 300)
            PersistenceService.persistence.setDouble(tempKey, 0.0)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    companion object {
        val type: String = "ezo_rtd"
    }
}
