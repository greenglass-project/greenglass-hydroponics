package io.greenglass.hydroponics.node.drivers.atlasscientific


import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.lang.Thread.sleep

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.node.core.services.GpioService

class EzoCommand(private val ezoDevice:  GpioService.I2cController) {

    private val logger = KotlinLogging.logger {}
    private val mutex = Mutex()
    suspend fun command(command: String, size: Int, delay: Long): String {

        return mutex.withLock {
            logger.debug { "Got lock" }
            withContext(Dispatchers.IO) {
                try {
                    val result = ezoDevice.writeBytes(command.toByteArray())
                    logger.debug { "Sent  [$command] result = $result" }

                    sleep(delay)
                    logger.debug { "Reading bytes size = $size "}

                    val buf = ezoDevice.readBytes(size)
                    logger.debug { "received ${buf.size} bytes "} //first byte = ${buf[0]}"}
                    val status = buf.get(0).toUInt()
                     logger.debug { "Status = $status" }
                    if (status == 1U && buf.size > 2) {
                        val newBuf = buf.sliceArray(IntRange(1,buf.size-1))
                            .takeWhile { v -> v.toInt() != 0x00 }

                       val value = String(newBuf.toByteArray())
                        logger.debug { "Value = $value" }
                        return@withContext value
                    }
                } catch (ex: Exception) {
                    logger.error { "I2C error $ex" }
                    ex.printStackTrace()
                }
                return@withContext "0"
            }
        }
    }
}