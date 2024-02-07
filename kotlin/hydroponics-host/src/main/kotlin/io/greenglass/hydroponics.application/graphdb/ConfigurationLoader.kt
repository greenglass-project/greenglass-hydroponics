package io.greenglass.hydroponics.application.graphdb

import com.fasterxml.jackson.databind.MapperFeature
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.module.SimpleModule
import com.fasterxml.jackson.dataformat.yaml.YAMLFactory
import com.fasterxml.jackson.module.kotlin.KotlinFeature
import com.fasterxml.jackson.module.kotlin.KotlinModule
import com.fasterxml.jackson.module.kotlin.readValue
import io.github.oshai.kotlinlogging.KotlinLogging
import io.greenglass.host.control.controlprocess.models.ProcessModel
import io.greenglass.host.control.controlprocess.registry.ProcessRegistry
import io.greenglass.hydroponics.application.models.implementation.ImplementationModel
import io.greenglass.hydroponics.application.models.recipe.PlantModel
import io.greenglass.hydroponics.application.models.system.HydroponicsSystemModel
import io.greenglass.sparkplug.models.NodeType

class ConfigurationLoader(private val repository : GraphRepository,
                          private val processRegistry: ProcessRegistry
) {

    private val classLoader = ConfigurationLoader::class.java.classLoader
    private val mapper = ObjectMapper(YAMLFactory())
    private val logger = KotlinLogging.logger {}

    init {
        mapper.registerModule(
            KotlinModule.Builder()
                .withReflectionCacheSize(512)
                .configure(KotlinFeature.NullToEmptyCollection, false)
                .configure(KotlinFeature.NullToEmptyMap, false)
                .configure(KotlinFeature.NullIsSameAsDefault, false)
                .configure(KotlinFeature.SingletonSupport, false)
                .configure(KotlinFeature.StrictNullChecks, false)
                .build()
        )
        mapper.enable(MapperFeature.ACCEPT_CASE_INSENSITIVE_ENUMS)
        mapper.registerModule(processModeldeserialiser())
    }

    fun load() {
        classLoader.getResources("systems").asIterator().forEach { n ->
            val system: HydroponicsSystemModel = mapper.readValue(n)

            if (!repository.systemExists(system.systemId))
                repository.addSystem(system)
        }
        classLoader.getResources("nodes").asIterator().forEach { n ->
            val node: NodeType = mapper.readValue(n)
            val nodeType = NodeType(
                type = node.type,
                name = node.name,
                description = node.description,
                image = node.image,
                metrics = node.metrics
            )

            if(!repository.nodeExists(node.type))
                repository.addNode(nodeType)
        }

        classLoader.getResources("implementations").asIterator().forEach { n ->
            val implementation: ImplementationModel = mapper.readValue(n)
            if(!repository.implementationExists((implementation.implementationId)))
                repository.addImplementation(implementation)
        }

        classLoader.getResources("plants").asIterator().forEach { n ->
            val plantDef: PlantModel = mapper.readValue(n)
            if(!repository.plantExists(plantDef.plantId))
                repository.addPlant(plantDef)
        }
    }



    private fun processModeldeserialiser() : SimpleModule {
        val module = SimpleModule()
        module.addDeserializer(ProcessModel::class.java, ProcessModelDeserializer(processRegistry))
        return module
    }
}