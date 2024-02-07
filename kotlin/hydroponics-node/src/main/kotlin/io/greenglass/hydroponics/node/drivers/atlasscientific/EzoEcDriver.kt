package io.greenglass.hydroponics.node.drivers.atlasscientific

import kotlinx.coroutines.*
import kotlin.time.Duration.Companion.seconds
import org.eclipse.tahu.message.model.MetricDataType

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.node.core.devicedriver.DeviceDriver
import io.greenglass.node.core.devicedriver.DriverFunction
import io.greenglass.node.core.devicedriver.config.DriverConfig
import io.greenglass.node.core.devicedriver.config.I2cConfig
import io.greenglass.node.core.services.GpioService.Companion.gpio

import io.greenglass.node.core.services.PersistenceService.Companion.persistence
import io.greenglass.sparkplug.datatypes.MetricNameValue
import io.greenglass.sparkplug.datatypes.MetricValue

/**
 * EzoEcDriver
 *
 * @constructor
 *
 * @param metrics
 * @param config
 */
class EzoEcDriver(name : String, metrics : Map<String, String>, config : DriverConfig) : DeviceDriver(name, metrics, config) {

    private val interval = 5L;
    private val logger = KotlinLogging.logger {}

    private val c = checkNotNull(config as? I2cConfig)

    private val i2cDevice  = gpio.i2c(c.device, c.address)
    private val ezoCommand = EzoCommand(i2cDevice)

    private val dryKey = "$name/dry"
    private val lowKey = "$name/low"
    private val highKey = "$name/high"

    private var currentValue: Double = 0.0

    init {
        logger.debug { "Creating ezo_ec" }
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
     * Driver-function "low"
     *
     * Calibrate the low value of the sensor
     *
     * @property metric
     */
    inner class Low(val metric: String) : DriverFunction(metric) {

        override suspend fun readValue() = MetricValue(persistence.getDouble(lowKey) ?: 0.0)

        override suspend fun writeValue(value: MetricValue) {
            ezoCommand.command("Cal,low,${value.double}", size = 0, delay = 600)
            persistence.setDouble(lowKey, value.double)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    /**
     * Driver-function "dry"
     *
     * Calibrate the dry value of the sensor
     *
     * @property metric
     */
    inner class Dry(val metric: String) : DriverFunction(metric) {
        override suspend fun readValue() = MetricValue(persistence.getDouble(dryKey) ?: 0.0)

        override suspend fun writeValue(value: MetricValue) {
            ezoCommand.command("Cal,dry", size = 0, delay = 600)
            persistence.setDouble(dryKey, 0.0)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    /**
     * Driver-function "high"
     *
     *  Calibrate the high value of the sensor
     *
     * @property metric
     */
    inner class High(val metric: String) : DriverFunction(metric) {
        override suspend fun readValue() = MetricValue(persistence.getDouble(highKey) ?: 0.0)

        override suspend fun writeValue(value: MetricValue) {
            ezoCommand.command("Cal,high,$value", size = 0, delay = 600)
            persistence.setDouble(highKey, value.double)
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
            persistence.setDouble(dryKey, 0.0)
            persistence.setDouble(lowKey, 0.0)
            persistence.setDouble(highKey, 0.0)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    companion object {
        val type: String = "ezo_ec"
    }
}