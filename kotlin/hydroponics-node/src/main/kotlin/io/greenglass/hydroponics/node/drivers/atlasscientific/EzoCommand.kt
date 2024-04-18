package io.greenglass.hydroponics.node.drivers.atlasscientific


import io.greenglass.node.core.services.GpioService
import io.klogging.NoCoLogging
import kotlinx.coroutines.*
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import java.lang.Thread.sleep

@ExperimentalUnsignedTypes
fun ByteArray.toHex(): String = asUByteArray().joinToString(" ") { it.toString(radix = 16).padStart(2, '0') }
class EzoCommand(private val
                 ezoDevice:  GpioService.I2cController,
                 private val backgroundScope : CoroutineScope,
                 private val name : String) : NoCoLogging {

    private val mutex = Mutex()

    @OptIn(ExperimentalUnsignedTypes::class)
    suspend fun command(command: String, size: Int, delay: Long): String {

        //logger.debug { "$name : Command $command Waiting for lock" }
        return mutex.withLock {
            //logger.debug { "$name :Command $command Got lock" }

             backgroundScope.async {
                try {
                    val result = ezoDevice.writeBytes(command.toByteArray())
                    logger.debug { "$name : Sent  [$command] to ${ezoDevice.device} result = $result" }

                    if(delay == -1L)
                        return@async "0"
                    else {
                        sleep(delay)
                        val buf = ezoDevice.readBytes(size)
                        val status = buf.get(0).toUInt()
                        logger.debug { "$name : Status = $status data = ${buf.toHex()}" }
                        if (status == 1U && buf.size > 2) {
                            val newBuf = buf.sliceArray(IntRange(1, buf.size - 1))
                                .takeWhile { v -> v.toInt() != 0x00 }

                            val value = String(newBuf.toByteArray())
                            logger.debug { "$name : Value = $value" }
                            return@async value
                        }
                    }
                } catch (ex: Exception) {
                    logger.error { "$name : I2C error $ex" }
                    ex.printStackTrace()
                }
                return@async "0"
            }.await()
        }
    }
}