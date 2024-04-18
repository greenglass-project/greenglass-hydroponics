package io.greenglass.hydroponics.application.microservices

import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.application.microservice.microService
import io.greenglass.host.application.nats.NatsService
import io.greenglass.hydroponics.application.graphdb.GraphRepository
import io.greenglass.hydroponics.application.models.config.CoroutineScopes
import io.greenglass.hydroponics.application.models.config.MasterConfig
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow

class BootstrapMicroServices( private val ns: NatsService,
                              private val repository: GraphRepository,
                              private val masterConfigFlow : MutableSharedFlow<MasterConfig>,
                              private val coroutineScopes: CoroutineScopes
) {

    private val logger = KotlinLogging.logger {}

    suspend fun run() {
        logger.debug { "Starting Bootstrap Microservices" }

        // ========================= Master Config ==================================
        coroutineScopes.microServicesScope.launch {
            microService<Unit, MasterConfig>(ns, "findone.masterconfig")
            { m -> repository.findOneMasterConfig() }
        }

        coroutineScopes.microServicesScope.launch {
            microService<MasterConfig, Unit>(ns, "add.masterconfig")
            { m -> repository.addMasterConfig(m.obj!!) }
        }

        coroutineScopes.microServicesScope.launch {
            microService<MasterConfig, Unit>(ns, "update.masterconfig")
            { m -> repository.updateMasterConfig(m.obj!!) }
        }
    }
}
