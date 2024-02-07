package io.greenglass.hydroponics.node.drivers.gpio

import com.pi4j.io.gpio.digital.DigitalState
import io.github.oshai.kotlinlogging.KotlinLogging

import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.delay
import kotlin.math.roundToLong

import io.greenglass.node.core.devicedriver.DeviceDriver
import io.greenglass.node.core.devicedriver.DriverFunction
import io.greenglass.node.core.devicedriver.config.DriverConfig
import io.greenglass.node.core.devicedriver.config.GpioDigitalOutConfig

import io.greenglass.node.core.services.GpioService
import io.greenglass.node.core.services.GpioService.Companion.gpio
import io.greenglass.node.core.services.PersistenceService

import io.greenglass.sparkplug.datatypes.MetricNameValue
import io.greenglass.sparkplug.datatypes.MetricValue

class DosingPumpDriver(name : String, metrics : Map<String, String>, config : DriverConfig) : DeviceDriver(name, metrics, config) {

    private val logger = KotlinLogging.logger {}

    private val c = checkNotNull(config as? GpioDigitalOutConfig)

    private val persistence = PersistenceService.persistence
    val pumpDevice = gpio.digitalOutput(
        pin = c.pin,
        initialState = DigitalState.LOW,
        shutdownState = DigitalState.LOW,
        false
    )

    private val pumpKey = "$name/calibration"
    private var pumpcalibration = persistence.getDouble(pumpKey, 0.0)

    suspend fun pulsePump(pump : GpioService.DigitalOutputController, duration : Long) = coroutineScope {
        logger.debug { "pulsePump duration = $duration" }
        pump.write(true)
        delay(duration)
        pump.write(false)
    }

    /*inner class State(val metric : String) : DriverFunction(metric) {
        override suspend fun readValue(): MetricValue = MetricValue(pumpDevice.read())
        override suspend fun writeValue(value: MetricValue) {
            if(value.isBoolean) {
                pumpDevice.write(value.boolean)
                valueFlow.tryEmit(MetricNameValue(metric, value))

            }
        }
    }*/

    inner class Calibrate(val metric : String) : DriverFunction(metric) {
        override suspend fun readValue() = MetricValue(pumpcalibration)
        override suspend fun writeValue(value: MetricValue) {
            pumpcalibration = value.double
            persistence.setDouble(pumpKey, pumpcalibration)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    inner class DoseVolume(val metric : String) : DriverFunction(metric) {
        override suspend fun readValue() = MetricValue(0L)
        override suspend fun writeValue(value: MetricValue) {
            if(pumpcalibration != 0.0) {
                val duration = ((value.int64/pumpcalibration)*1000).roundToLong()
                pulsePump(pumpDevice, duration)
                valueFlow.emit(MetricNameValue(metric, value))
            }
        }
    }

    inner class DoseDuration(val metric : String) : DriverFunction(metric) {
        override suspend fun readValue() = MetricValue(0L)
        override suspend fun writeValue(value: MetricValue) {
            val duration = value.int64
            pulsePump(pumpDevice,duration)
            valueFlow.emit(MetricNameValue(metric, value))
        }
    }

    companion object {
        val type = "gpio_dosing_pump"
    }
}